local _, GQ = ...

GQ.Indicator = GQ.Indicator or {}

local ARROW_TEXTURE = "Interface\\BUTTONS\\Arrow-Up-Up"
local ARROW_SIZE = 14
local ARROW_COLOR = { 0.15, 1, 0.15 }

local function GetItemIdFromLink(link)
    if not link then
        return nil
    end
    return tonumber(link:match("item:(%d+)"))
end

function GQ.Indicator:GetIconAnchor(button)
    if not button then
        return nil
    end

    if button.icon and button.icon.IsObjectType and button.icon:IsObjectType("Texture") then
        return button.icon
    end
    if button.Icon and button.Icon.IsObjectType and button.Icon:IsObjectType("Texture") then
        return button.Icon
    end
    if button.IconTexture then
        return button.IconTexture
    end

    local name = button.GetName and button:GetName()
    if name then
        local named = _G[name .. "IconTexture"] or _G[name .. "Icon"]
        if named then
            return named
        end
    end

    if button.IconFrame then
        return button.IconFrame.icon or button.IconFrame.Icon or button.IconFrame
    end

    return button
end

function GQ.Indicator:EnsureOverlay(button)
    if not button then
        return nil
    end

    if button.gqUpgradeArrow then
        return button.gqUpgradeArrow
    end

    local anchor = self:GetIconAnchor(button)
    if not anchor then
        return nil
    end

    local arrow = anchor:CreateTexture(nil, "OVERLAY", nil, 7)
    arrow:SetSize(ARROW_SIZE, ARROW_SIZE)
    arrow:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", 1, 1)
    arrow:SetTexture(ARROW_TEXTURE)
    arrow:SetVertexColor(ARROW_COLOR[1], ARROW_COLOR[2], ARROW_COLOR[3])
    arrow:Hide()

    button.gqUpgradeArrow = arrow
    return arrow
end

function GQ.Indicator:HideButton(button)
    if button and button.gqUpgradeArrow then
        button.gqUpgradeArrow:Hide()
    end
end

function GQ.Indicator:UpdateButton(button, link)
    if not button then
        return
    end

    local itemId = GetItemIdFromLink(link)
    local arrow = self:EnsureOverlay(button)
    if not arrow then
        return
    end

    if itemId and self:IsUpgradeItem(itemId) then
        arrow:Show()
    else
        arrow:Hide()
    end
end

function GQ.Indicator:RebuildCache()
    self.upgradeItems = {}

    if not GQ.Data or not GQ.Data.GetSlotsForClass then
        return
    end

    local classFile = GQ:GetEffectiveClass()
    if not classFile then
        return
    end

    for _, slotName in ipairs(GQ.Data:GetSlotsForClass(classFile)) do
        local upgrades = GQ.Data:GetTopUpgradesForSlot(slotName, 3)
        for _, entry in ipairs(upgrades) do
            if entry.itemId then
                self.upgradeItems[entry.itemId] = true
            end
        end
    end
end

function GQ.Indicator:IsUpgradeItem(itemId)
    return itemId and self.upgradeItems and self.upgradeItems[itemId] == true
end

function GQ.Indicator:CollectItemButtons(root, results, depth, seen)
    if not root or depth > 8 then
        return
    end

    seen = seen or {}
    if seen[root] then
        return
    end
    seen[root] = true

    if root.GetObjectType and root:GetObjectType() == "Button" and self:GetIconAnchor(root) then
        table.insert(results, root)
    end

    if root.GetChildren then
        local ok, children = pcall(root.GetChildren, root)
        if ok and children then
            for _, child in ipairs(children) do
                self:CollectItemButtons(child, results, depth + 1, seen)
            end
        end
    end

    if root.GetNumChildren then
        local ok, count = pcall(root.GetNumChildren, root)
        if ok and count then
            for i = 1, count do
                local okChild, child = pcall(root.GetChild, root, i)
                if okChild and child then
                    self:CollectItemButtons(child, results, depth + 1, seen)
                end
            end
        end
    end
end

function GQ.Indicator:GetQuestLogRewardButtons()
    local results = {}
    local seen = {}
    local roots = {
        _G.QuestLogQuestDetail,
        _G.QuestLogDetailScrollChildFrame,
        _G.QuestLogDetailScrollFrameScrollChild,
        QuestLogDetailScrollFrame and QuestLogDetailScrollFrame.ScrollChild,
    }

    for _, root in ipairs(roots) do
        if root then
            local rewardsFrame = root.rewardsFrame or root.RewardsFrame or _G.QuestLogQuestDetailRewardsFrame
            if rewardsFrame then
                if rewardsFrame.RewardFrames then
                    for _, frame in ipairs(rewardsFrame.RewardFrames) do
                        local btn = frame.Item or frame.item or frame
                        if btn and not seen[btn] then
                            seen[btn] = true
                            table.insert(results, btn)
                        end
                    end
                end

                for i = 1, 12 do
                    local btn = rewardsFrame["Item" .. i]
                    if btn and not seen[btn] then
                        seen[btn] = true
                        table.insert(results, btn)
                    end
                end

                self:CollectItemButtons(rewardsFrame, results, 0, seen)
            end
        end
    end

    return results
end

function GQ.Indicator:UpdateQuestLogRewards()
    if not QuestLogFrame or not QuestLogFrame:IsShown() then
        return
    end

    if not GetQuestLogSelection or not GetQuestLogItemLink then
        return
    end

    local questIndex = GetQuestLogSelection()
    if not questIndex or questIndex <= 0 then
        return
    end

    local buttons = self:GetQuestLogRewardButtons()
    local buttonIndex = 1

    local function ApplyLinks(itemType, countFn)
        local count = countFn and countFn(questIndex) or 0
        for i = 1, count do
            local link = GetQuestLogItemLink(itemType, i)
            local button = buttons[buttonIndex]
            if button then
                self:UpdateButton(button, link)
                buttonIndex = buttonIndex + 1
            end
        end
    end

    ApplyLinks("choice", GetNumQuestLogChoices)
    ApplyLinks("reward", GetNumQuestLogRewards)

    for i = buttonIndex, #buttons do
        self:HideButton(buttons[i])
    end
end

function GQ.Indicator:UpdateLootFrame()
    if not LootFrame or not LootFrame:IsShown() or not GetLootSlotLink then
        return
    end

    local numLootItems = LootFrame.numLootItems or 0
    local numLootToShow = LOOTFRAME_NUMBUTTONS or 4
    if numLootItems > numLootToShow then
        numLootToShow = numLootToShow - 1
    end

    local page = LootFrame.page or 1
    for i = 1, LOOTFRAME_NUMBUTTONS or 4 do
        local button = _G["LootButton" .. i]
        if button then
            if button:IsShown() then
                local slot = ((page - 1) * numLootToShow) + i
                if slot <= numLootItems and GetLootSlotLink then
                    self:UpdateButton(button, GetLootSlotLink(slot))
                else
                    self:HideButton(button)
                end
            else
                self:HideButton(button)
            end
        end
    end
end

function GQ.Indicator:UpdateGroupLootFrames()
    local maxFrames = NUM_GROUP_LOOT_FRAMES or 4
    for i = 1, maxFrames do
        local frame = _G["GroupLootFrame" .. i]
        if frame and frame:IsShown() and frame.rollID and GetLootRollItemLink then
            self:UpdateButton(frame, GetLootRollItemLink(frame.rollID))
        elseif frame then
            self:HideButton(frame)
        end
    end
end

function GQ.Indicator:UpdateTradeSkillFrame()
    if not TradeSkillFrame or not TradeSkillFrame:IsShown() or not GetTradeSkillItemLink then
        return
    end

    local offset = 0
    if TradeSkillListScrollFrame and FauxScrollFrame_GetOffset then
        offset = FauxScrollFrame_GetOffset(TradeSkillListScrollFrame) or 0
    end

    local displayed = TRADE_SKILLS_DISPLAYED or 8
    for i = 1, displayed do
        local button = _G["TradeSkillSkill" .. i]
        if button then
            if button:IsShown() then
                self:UpdateButton(button, GetTradeSkillItemLink(offset + i))
            else
                self:HideButton(button)
            end
        end
    end

    local detailIcon = _G.TradeSkillDetailIcon
        or (TradeSkillFrame and TradeSkillFrame.DetailIcon)
        or _G.TradeSkillDetailItemIcon
    if detailIcon and GetTradeSkillSelectionIndex then
        local index = GetTradeSkillSelectionIndex()
        if index and index > 0 then
            self:UpdateButton(detailIcon, GetTradeSkillItemLink(index))
        else
            self:HideButton(detailIcon)
        end
    end
end

function GQ.Indicator:UpdateCraftFrame()
    if not CraftFrame or not CraftFrame:IsShown() or not GetCraftItemLink then
        return
    end

    local offset = 0
    if CraftListScrollFrame and FauxScrollFrame_GetOffset then
        offset = FauxScrollFrame_GetOffset(CraftListScrollFrame) or 0
    end

    local displayed = CRAFTS_DISPLAYED or 8
    for i = 1, displayed do
        local button = _G["Craft" .. i]
        if button then
            if button:IsShown() then
                self:UpdateButton(button, GetCraftItemLink(offset + i))
            else
                self:HideButton(button)
            end
        end
    end

    local detailIcon = _G.CraftIcon or (CraftFrame and CraftFrame.DetailIcon)
    if detailIcon and GetCraftSelectionIndex then
        local index = GetCraftSelectionIndex()
        if index and index > 0 then
            self:UpdateButton(detailIcon, GetCraftItemLink(index))
        else
            self:HideButton(detailIcon)
        end
    end
end

function GQ.Indicator:RefreshAll()
    self:UpdateLootFrame()
    self:UpdateGroupLootFrames()
    self:UpdateQuestLogRewards()
    self:UpdateTradeSkillFrame()
    self:UpdateCraftFrame()
end

function GQ.Indicator:HookFunction(name, handler)
    if type(_G[name]) == "function" and not self.hooks[name] then
        self.hooks[name] = true
        hooksecurefunc(name, handler)
    end
end

function GQ.Indicator:Init()
    self.hooks = {}

    self:RebuildCache()

    self:HookFunction("LootFrame_Update", function()
        self:UpdateLootFrame()
    end)

    self:HookFunction("GroupLootFrame_OpenNewFrame", function()
        self:UpdateGroupLootFrames()
    end)

    self:HookFunction("QuestLog_UpdateQuestDetails", function()
        self:UpdateQuestLogRewards()
    end)

    self:HookFunction("QuestLog_Update", function()
        self:UpdateQuestLogRewards()
    end)

    self:HookFunction("TradeSkillFrame_Update", function()
        self:UpdateTradeSkillFrame()
    end)

    self:HookFunction("CraftFrame_Update", function()
        self:UpdateCraftFrame()
    end)

    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("START_LOOT_ROLL")
    eventFrame:RegisterEvent("LOOT_OPENED")
    eventFrame:RegisterEvent("LOOT_CLOSED")
    eventFrame:SetScript("OnEvent", function()
        self:RefreshAll()
    end)
end
