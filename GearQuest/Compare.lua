local _, GQ = ...

GQ.Compare = GQ.Compare or {}

local function GetItemLevel(itemLinkOrId)
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
    local invSlot = GQ.Data:GetInventorySlot(slotName)
    if not invSlot then
        return 0
    end

    local link = GetInventoryItemLink("player", invSlot)
    return GetItemLevel(link)
end

function GQ.Compare:ScoreEntry(entry, equippedIlvl)
    local itemIlvl = GetItemLevel(entry.itemId)
    local upgradeDelta = itemIlvl - equippedIlvl

    -- Simple relevance: prefer higher item level upgrades; slight bonus for quest/boss sources.
    local sourceBonus = 0
    if entry.sourceType == "quest_reward" then
        sourceBonus = 2
    elseif entry.sourceType == "boss_drop" then
        sourceBonus = 1
    end

    return upgradeDelta * 10 + sourceBonus, itemIlvl
end

function GQ.Compare:RankEntries(entries, slotName, maxResults)
    maxResults = maxResults or 3
    local equippedIlvl = self:GetEquippedItemLevel(slotName)
    local scored = {}

    for _, entry in ipairs(entries) do
        local score, itemIlvl = self:ScoreEntry(entry, equippedIlvl)
        if itemIlvl > equippedIlvl or equippedIlvl == 0 then
            table.insert(scored, { entry = entry, score = score, itemIlvl = itemIlvl })
        end
    end

    table.sort(scored, function(a, b)
        if a.score ~= b.score then
            return a.score > b.score
        end
        return a.itemIlvl > b.itemIlvl
    end)

    local results = {}
    for i = 1, math.min(maxResults, #scored) do
        table.insert(results, scored[i].entry)
    end

    return results, equippedIlvl
end
