local _, GQ = ...

GQ.Compare = GQ.Compare or {}

local function GetItemLevel(itemLinkOrId, entry)
    if type(entry) == "table" and entry.minLevel then
        local itemId = entry.itemId or itemLinkOrId
        if itemId then
            local _, _, _, itemLevel = GetItemInfo(itemId)
            if itemLevel and itemLevel > 0 then
                return itemLevel
            end
        end
        return entry.minLevel
    end

    if not itemLinkOrId then
        return 0
    end

    if type(itemLinkOrId) == "number" then
        local _, _, _, itemLevel = GetItemInfo(itemLinkOrId)
        return itemLevel or 0
    end

    local _, _, _, itemLevel = GetItemInfo(itemLinkOrId)
    return itemLevel or 0
end

function GQ.Compare:GetEquippedItemLevel(slotName)
    local invSlots = GQ.Data:GetInventorySlots(slotName)
    if #invSlots == 0 then
        return 0
    end

    if #invSlots == 1 then
        local link = GetInventoryItemLink("player", invSlots[1])
        return GetItemLevel(link)
    end

    -- Rings/trinkets: compare against the weaker equipped slot.
    local lowestIlvl
    for _, invSlot in ipairs(invSlots) do
        local ilvl = GetItemLevel(GetInventoryItemLink("player", invSlot))
        if lowestIlvl == nil or ilvl < lowestIlvl then
            lowestIlvl = ilvl
        end
    end

    return lowestIlvl or 0
end

-- Lower-tier armor only ranks if it is clearly stronger than the best preferred-tier option.
local LOWER_ARMOR_ILVL_MARGIN = 8
local LOWER_ARMOR_SCORE_PENALTY = 500

function GQ.Compare:ScoreEntry(entry, equippedIlvl, slotName, maxPreferredIlvl)
    local itemIlvl = GetItemLevel(entry.itemId, entry)
    local upgradeDelta = itemIlvl - equippedIlvl

    -- Simple relevance: prefer higher item level upgrades; slight bonus for quest/boss sources.
    local sourceBonus = 0
    if entry.sourceType == "quest_reward" or entry.sourceType == "seasonal_quest" then
        sourceBonus = 2
    elseif entry.sourceType == "boss_drop" or entry.sourceType == "raid_trash" then
        sourceBonus = 1
    elseif entry.sourceType == "vendor" then
        sourceBonus = 1
    elseif entry.sourceType == "profession" then
        sourceBonus = 1
    end

    local armorPenalty = 0
    if slotName and GQ.Equip and GQ.Equip.MeetsArmorPreference then
        local classFile = GQ:GetEffectiveClass()
        local playerLevel = GQ:GetEffectiveLevel()
        if not GQ.Equip:MeetsArmorPreference(entry.itemId, slotName, classFile, playerLevel) then
            if not maxPreferredIlvl or itemIlvl < maxPreferredIlvl + LOWER_ARMOR_ILVL_MARGIN then
                armorPenalty = -LOWER_ARMOR_SCORE_PENALTY
            end
        end
    end

    return upgradeDelta * 10 + sourceBonus + armorPenalty, itemIlvl
end

-- Classes whose generated picks are fully stat-weighted in the pipeline; runtime
-- ilvl re-ranking would wrongly promote high-dps staves/wands over stat sticks.
local PIPELINE_RANK_CLASSES = {
    PRIEST = true,
    MAGE = true,
    WARLOCK = true,
}

function GQ.Compare:RankEntries(entries, slotName, maxResults)
    maxResults = maxResults or 3
    local equippedIlvl = self:GetEquippedItemLevel(slotName)
    local classFile = GQ:GetEffectiveClass()
    local playerLevel = GQ:GetEffectiveLevel()
    local maxPreferredIlvl = 0

    if GQ.Equip and GQ.Equip.MeetsArmorPreference then
        for _, entry in ipairs(entries) do
            if GQ.Equip:MeetsArmorPreference(entry.itemId, slotName, classFile, playerLevel) then
                maxPreferredIlvl = math.max(maxPreferredIlvl, GetItemLevel(entry.itemId, entry))
            end
        end
    end

    local scored = {}

    for _, entry in ipairs(entries) do
        local score, itemIlvl = self:ScoreEntry(entry, equippedIlvl, slotName, maxPreferredIlvl)
        table.insert(scored, { entry = entry, score = score, itemIlvl = itemIlvl })
    end

    local function PrefersRank(entry)
        if not entry then
            return false
        end
        if entry.origin == "guide" then
            return true
        end
        if not entry.generated then
            return true
        end
        if PIPELINE_RANK_CLASSES[classFile] then
            return true
        end
        return false
    end

    table.sort(scored, function(a, b)
        local rankA = a.entry.curatedRank
        local rankB = b.entry.curatedRank
        local aRanked = PrefersRank(a.entry)
        local bRanked = PrefersRank(b.entry)

        -- Hand-curated and origin="guide" rows keep pipeline rank. Other generated
        -- picks re-rank at runtime by upgrade score so ilvl beats stale slot order.
        if aRanked and bRanked then
            if rankA and rankB and rankA ~= rankB then
                return rankA < rankB
            end
            if rankA and not rankB then
                return true
            end
            if rankB and not rankA then
                return false
            end
        end

        if a.score ~= b.score then
            return a.score > b.score
        end
        if rankA and rankB and rankA ~= rankB then
            return rankA < rankB
        end
        return a.itemIlvl > b.itemIlvl
    end)

    local results = {}
    for i = 1, math.min(maxResults, #scored) do
        table.insert(results, scored[i].entry)
    end

    return results, equippedIlvl
end
