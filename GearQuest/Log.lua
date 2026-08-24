local _, GQ = ...

GQ.Log = GQ.Log or {}

local FRAME_WIDTH = 384
local FRAME_HEIGHT = 512
local ROW_HEIGHT = 16
local TAB_HEIGHT = 22
local TAB_BAR_PAD = 2
local TAB_ROW_HEIGHT = TAB_HEIGHT + TAB_BAR_PAD
local TAB_TOP_OFFSET = 54
local LIST_TOP_OFFSET = TAB_TOP_OFFSET + TAB_ROW_HEIGHT
local PORTRAIT_TEXTURE = "Interface\\QuestFrame\\UI-QuestLog-BookIcon"
local PORTRAIT_TEX_INSET = 0.08
local PORTRAIT_SLOT_SIZE = 61
local PORTRAIT_SLOT_X = 8
local PORTRAIT_SLOT_Y = -8
local PORTRAIT_DISPLAY_SIZE = 58

-- Content area below title bar and above footer buttons.
local HEADER_OFFSET = 74
local FOOTER_OFFSET = 38
local CONTENT_HEIGHT = FRAME_HEIGHT - HEADER_OFFSET - FOOTER_OFFSET
local LIST_SECTION_HEIGHT = math.max(120, math.floor(CONTENT_HEIGHT * 0.40) - 20)
local CONTENT_LEFT = 4
local CONTENT_RIGHT_GUTTER = 30
local PANEL_WIDTH = FRAME_WIDTH - CONTENT_LEFT - CONTENT_RIGHT_GUTTER
local PANEL_INSET = 2
local GUTTER_INSET = 6
local SECTION_DIVIDER_HEIGHT = 3
local METAL_EDGE = "Interface\\Tooltips\\UI-Tooltip-Border"
local REWARD_ICON_SIZE = 44
local REWARD_NAME_MIN_WIDTH = 150
local REWARD_NAME_PAD = 16
local LIST_TOOLTIP_X_GAP = 20
local LIST_NEW_LABEL = " |cffFFD200New|r"
local SPEC_PICKER_WIDTH = 188
local SPEC_PICKER_ROW_HEIGHT = 20
local SPEC_PICKER_PAD = 4
local SPEC_ICON_SIZE = 18
local SPEC_ARROW_SIZE = 27
local SPEC_CONTROL_GAP = 2
local SPEC_CONTROL_WIDTH = SPEC_ICON_SIZE + SPEC_CONTROL_GAP + SPEC_ARROW_SIZE
local SPEC_CONTROL_HEIGHT = math.max(SPEC_ICON_SIZE, SPEC_ARROW_SIZE)
local SPEC_ROW_GAP = 2
local LOG_FRAME_STRATA = "DIALOG"
local LOG_FRAME_LEVEL = 100

local function ApplyLogWindowLayer(frame)
    if not frame then
        return
    end

    if frame.SetFrameStrata then
        frame:SetFrameStrata(LOG_FRAME_STRATA)
    end
    if frame.SetFrameLevel then
        frame:SetFrameLevel(LOG_FRAME_LEVEL)
    end
end

local function BringLogWindowToFront(frame)
    ApplyLogWindowLayer(frame)
    if frame and frame.Raise then
        frame:Raise()
    end
end
local TAB_GROUP_WIDTH = (88 * 2) + 4
local DETAIL_TEXT_COLOR = { 0.13, 0.09, 0.04 }
local DETAIL_TEXT_HEX = "21160a"
local QUEST_DETAIL_TITLE_FONTS = {
    "QuestFont_Large", "QuestFont", "GameFontHighlight", "GameFontNormal",
}

local QUEST_DETAIL_HEADER_FONTS = {
    "QuestFont", "GameFontHighlight", "GameFontNormal",
}

local QUEST_DETAIL_BODY_FONTS = {
    "QuestFont", "GameFontHighlight", "GameFontNormal",
}

local function GetHuntRecord(id)
    GearQuestDB.hunts = GearQuestDB.hunts or {}
    return GearQuestDB.hunts[id]
end

local function GetObtainedTimestamp(id)
    GearQuestDB.obtained = GearQuestDB.obtained or {}
    return GearQuestDB.obtained[id]
end

local function IsDismissedCompleted(id)
    GearQuestDB.dismissedCompleted = GearQuestDB.dismissedCompleted or {}
    return GearQuestDB.dismissedCompleted[id] == true
end

local function EnsureHuntRecord(id)
    GearQuestDB.hunts = GearQuestDB.hunts or {}
    if not GearQuestDB.hunts[id] then
        GearQuestDB.hunts[id] = {
            status = "tracked",
            trackedAt = time(),
        }
    end
    return GearQuestDB.hunts[id]
end

local function NormalizeHuntStatus(status)
    if status == "active" then
        return "tracked"
    end
    return status
end

local function GetHuntStatus(id)
    local record = GetHuntRecord(id)
    if not record then
        return "available"
    end
    return NormalizeHuntStatus(record.status or "tracked")
end

local function FormatCompletedDate(timestamp)
    if not timestamp then
        return nil
    end
    if date then
        return date("%B %d, %Y at %H:%M", timestamp)
    end
    return tostring(timestamp)
end

local function ItemLinkToId(link)
    if not link then
        return nil
    end
    return tonumber(link:match("item:(%d+)"))
end

local function GetBagItemLink(bag, slot)
    if C_Container and C_Container.GetContainerItemLink then
        return C_Container.GetContainerItemLink(bag, slot)
    end
    if GetContainerItemLink then
        return GetContainerItemLink(bag, slot)
    end
end

local function GetBagSlotCount(bag)
    if C_Container and C_Container.GetContainerNumSlots then
        return C_Container.GetContainerNumSlots(bag) or 0
    end
    if GetContainerNumSlots then
        return GetContainerNumSlots(bag) or 0
    end
    return 0
end

local function PlayerOwnsItem(itemId)
    if not itemId then
        return false
    end

    local ok, owned = pcall(function()
        for invSlot = 1, 19 do
            if ItemLinkToId(GetInventoryItemLink("player", invSlot)) == itemId then
                return true
            end
        end

        local numBags = NUM_BAG_SLOTS or 4
        for bag = 0, numBags do
            local numSlots = GetBagSlotCount(bag)
            for slot = 1, numSlots do
                if ItemLinkToId(GetBagItemLink(bag, slot)) == itemId then
                    return true
                end
            end
        end

        return false
    end)

    return ok and owned or false
end

local function GetCraftedTimestamp(itemId)
    GearQuestDB.crafted = GearQuestDB.crafted or {}
    return GearQuestDB.crafted[itemId]
end

local function ExtractItemIdFromChatMessage(msg)
    if not msg then
        return nil
    end

    -- Only the local player's craft/loot lines — never party loot chat with item links.
    if msg:find("You create", 1, true) then
        local itemId = tonumber(msg:match("item:(%d+)"))
        if itemId then
            return itemId
        end

        local itemName = msg:match("You create %[(.-)%]")
            or msg:match("You create (.+)%.")
        if not itemName then
            return nil
        end

        itemName = strtrim(itemName)

        for _, entry in ipairs(GQ.Data.entries) do
            if entry.sourceType == "profession" and entry.itemId then
                local name = GetItemInfo(entry.itemId)
                if name == itemName then
                    return entry.itemId
                end
            end
        end

        return nil
    end

    if msg:find("You receive loot", 1, true) or msg:find("You loot", 1, true) then
        return tonumber(msg:match("item:(%d+)"))
    end

    return nil
end

local function PlayerHasProducedProfessionItem(entry)
    if not entry or entry.sourceType ~= "profession" or not entry.itemId then
        return false
    end
    return GetCraftedTimestamp(entry.itemId) ~= nil
end

local function PlayerHasObtainedEntryItem(entry)
    if not entry or not entry.itemId then
        return false
    end

    if entry.sourceType == "profession" then
        return PlayerHasProducedProfessionItem(entry)
    end

    return PlayerOwnsItem(entry.itemId)
end

local function FormatActiveListItemText(name, entry, status, includeNewLabel)
    local text = name

    if includeNewLabel and GQ.Data:IsEntryNewForPlayer(entry) then
        text = text .. LIST_NEW_LABEL
    end

    if status == "tracked" then
        text = text .. " |cff00ff00(Tracked)|r"
    end

    return text
end

local function ShowItemTooltipForRow(row)
    if not row or not row.entry or not row.text then
        return
    end

    GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    GameTooltip:SetHyperlink("item:" .. row.entry.itemId)

    local textTop = row.text:GetTop()
    local textBottom = row.text:GetBottom()
    local textLeft = row.text:GetLeft()
    local textWidth = row.text:GetStringWidth()
    if textTop and textBottom then
        local textCenterY = (textTop + textBottom) / 2
        local anchorX = row:GetRight()
        if not anchorX and textLeft and textWidth then
            anchorX = textLeft + textWidth
        end
        if anchorX then
            GameTooltip:ClearAllPoints()
            GameTooltip:SetPoint("LEFT", UIParent, "BOTTOMLEFT", anchorX + LIST_TOOLTIP_X_GAP, textCenterY)
        end
    end

    GameTooltip:Show()
end

local function HideItemTooltip()
    GameTooltip:Hide()
end

local function InsertItemLink(itemId)
    if not itemId then
        return
    end

    local link = select(2, GetItemInfo(itemId)) or ("item:" .. itemId)
    if HandleModifiedItemClick then
        HandleModifiedItemClick(link)
    elseif ChatEdit_InsertLink then
        ChatEdit_InsertLink(link)
    end
end

local function CreateRewardItemButton(parent, name)
    local button = CreateFrame("Button", name, parent)
    button:SetHeight(REWARD_ICON_SIZE)
    button:SetWidth(REWARD_ICON_SIZE + REWARD_NAME_MIN_WIDTH)

    local iconFrame = CreateFrame("Frame", nil, button)
    iconFrame:SetSize(REWARD_ICON_SIZE, REWARD_ICON_SIZE)
    iconFrame:SetPoint("LEFT", button, "LEFT", 0, 0)
    iconFrame:EnableMouse(false)

    button.icon = iconFrame:CreateTexture(nil, "ARTWORK")
    button.icon:SetAllPoints(iconFrame)

    button.nameBg = button:CreateTexture(nil, "BACKGROUND")
    button.nameBg:SetPoint("LEFT", iconFrame, "RIGHT", 0, 0)
    button.nameBg:SetPoint("RIGHT", button, "RIGHT", 0, 0)
    button.nameBg:SetPoint("TOP", iconFrame, "TOP", 0, 0)
    button.nameBg:SetPoint("BOTTOM", iconFrame, "BOTTOM", 0, 0)
    button.nameBg:SetColorTexture(0, 0, 0, 0.55)

    button.name = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.name:SetPoint("LEFT", button.nameBg, "LEFT", 8, 0)
    button.name:SetPoint("RIGHT", button.nameBg, "RIGHT", -10, 0)
    button.name:SetJustifyH("LEFT")
    button.name:SetWordWrap(false)
    button.name:SetTextColor(1, 1, 1)

    button:SetScript("OnEnter", function(self)
        if not self.itemId then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink("item:" .. self.itemId)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        HideItemTooltip()
    end)

    button:SetScript("OnClick", function(self)
        if self.itemId and IsModifiedClick("CHATLINK") then
            InsertItemLink(self.itemId)
        end
    end)

    return button
end

local function CreateFontStringWithFallback(parent, candidates)
    for _, font in ipairs(candidates) do
        local ok, fs = pcall(parent.CreateFontString, parent, nil, "ARTWORK", font)
        if ok and fs then
            return fs
        end
    end
    return parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
end

local PARCHMENT_TEXTURE = "Interface\\AddOns\\GearQuest\\Textures\\GQ-Parchment.png"

local function ApplyParchmentBackground(parent)
    if parent.parchmentApplied then
        return
    end
    parent.parchmentApplied = true

    local parchment = parent:CreateTexture(nil, "BACKGROUND", nil, 0)
    parchment:SetTexture(PARCHMENT_TEXTURE)
    parchment:SetAllPoints()
    -- Stretch once so clean top/left and worn bottom/right stay anchored to the panel.
end

local function ApplyBlackBackground(parent)
    if parent.blackBg then
        return
    end
    local bg = parent:CreateTexture(nil, "BACKGROUND", nil, -8)
    bg:SetAllPoints()
    bg:SetColorTexture(0.02, 0.02, 0.02, 1)
    parent.blackBg = bg
end

local function ApplyMetalEdge(frame, edgeSize)
    if not frame or not frame.SetBackdrop then
        return
    end
    frame:SetBackdrop({
        edgeFile = METAL_EDGE,
        tile = true,
        tileSize = 16,
        edgeSize = edgeSize or 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
end

local function CreateSectionDivider(parent)
    local divider = CreateFrame("Frame", nil, parent)
    divider:SetHeight(SECTION_DIVIDER_HEIGHT)

    local top = divider:CreateTexture(nil, "ARTWORK")
    top:SetPoint("TOPLEFT", divider, "TOPLEFT", 0, 0)
    top:SetPoint("TOPRIGHT", divider, "TOPRIGHT", 0, 0)
    top:SetHeight(1)
    top:SetColorTexture(0.62, 0.54, 0.36, 1)

    local bottom = divider:CreateTexture(nil, "ARTWORK")
    bottom:SetPoint("BOTTOMLEFT", divider, "BOTTOMLEFT", 0, 0)
    bottom:SetPoint("BOTTOMRIGHT", divider, "BOTTOMRIGHT", 0, 0)
    bottom:SetHeight(1)
    bottom:SetColorTexture(0.22, 0.19, 0.14, 1)

    return divider
end

local function EnableClipping(frame)
    if frame and frame.SetClipsChildren then
        frame:SetClipsChildren(true)
    end
end

local SCROLLBAR_INSET = 22

local function ConfigurePanelScrollBar(scroll)
    if not scroll or not scroll.GetName then
        return
    end

    local scrollName = scroll:GetName()

    for _, suffix in ipairs({ "Top", "Bottom", "Middle", "Left", "Right" }) do
        local piece = _G[scrollName .. suffix]
        if piece then
            if piece.SetAlpha then
                piece:SetAlpha(1)
            end
            piece:Show()
        end
    end

    local scrollBar = _G[scrollName .. "ScrollBar"]
    if not scrollBar then
        return
    end

    if not scrollBar.gqTrackBg then
        local trackBg = scrollBar:CreateTexture(nil, "BACKGROUND", nil, -8)
        trackBg:SetAllPoints()
        trackBg:SetColorTexture(0, 0, 0, 1)
        scrollBar.gqTrackBg = trackBg
    end

    scrollBar:Show()
end

local function LayoutDetailScroll(frame)
    if not frame or not frame.detailScroll or not frame.detailBg then
        return
    end

    -- Parent to the log frame (not detailBg) so clipping/backdrop on the parchment
    -- panel does not hide the Blizzard scrollbar chrome.
    frame.detailScroll:SetParent(frame)
    frame.detailScroll:ClearAllPoints()
    frame.detailScroll:SetPoint("TOPLEFT", frame.detailBg, "TOPLEFT", PANEL_INSET, -PANEL_INSET)
    frame.detailScroll:SetPoint("BOTTOMRIGHT", frame.detailBg, "BOTTOMRIGHT", -PANEL_INSET, PANEL_INSET)
    frame.detailScroll:SetFrameLevel(frame.detailBg:GetFrameLevel() + 10)
    frame.detailScroll:Show()
    ConfigurePanelScrollBar(frame.detailScroll)
end

local function CreatePanelScrollFrame(name, parent)
    local scrollOk, scroll = pcall(CreateFrame, "ScrollFrame", name, parent, "UIPanelScrollFrameTemplate")
    if not scrollOk or not scroll then
        scroll = CreateFrame("ScrollFrame", name, parent)
    end

    return scroll
end

local function UpdateScrollChildRect(scroll)
    if not scroll then
        return
    end
    if scroll.UpdateScrollChildRect then
        scroll:UpdateScrollChildRect()
    elseif _G.ScrollFrame_UpdateScrollChildRect then
        ScrollFrame_UpdateScrollChildRect(scroll)
    end
end

local function SetFrameTitle(frame, text)
    if frame.TitleText then
        frame.TitleText:SetText(text)
        return
    end
    local title = frame:GetName() and _G[frame:GetName() .. "TitleText"]
    if title then
        title:SetText(text)
    end
end

local function GetPortraitTexture(frame)
    if not frame then
        return nil
    end

    local container = frame.PortraitContainer or (frame.GetName and _G[frame:GetName() .. "PortraitContainer"])
    if container and container.portrait then
        return container.portrait
    end
    if container and container.GetName then
        local named = _G[container:GetName() .. "Portrait"]
        if named then
            return named
        end
    end

    if frame.GetName then
        return _G[frame:GetName() .. "Portrait"]
    end
    return nil
end

local function ApplyPortraitToBlizzardSlot(tex, texturePath)
    if not tex or not texturePath then
        return
    end

    tex:Show()

    if SetPortraitToTexture then
        local ok = pcall(SetPortraitToTexture, tex, texturePath)
        if ok then
            return
        end
    end

    tex:SetTexture(texturePath)
    tex:SetTexCoord(PORTRAIT_TEX_INSET, 1 - PORTRAIT_TEX_INSET, PORTRAIT_TEX_INSET, 1 - PORTRAIT_TEX_INSET)
end

local function ApplyCircularPortraitTexture(tex, texturePath, anchorFrame)
    if not tex or not texturePath or not anchorFrame then
        return
    end

    tex:ClearAllPoints()
    tex:SetSize(PORTRAIT_DISPLAY_SIZE, PORTRAIT_DISPLAY_SIZE)
    tex:SetPoint("CENTER", anchorFrame, "CENTER", 0, 0)
    ApplyPortraitToBlizzardSlot(tex, texturePath)
end

local function EnsureFallbackPortraitIcon(frame)
    if frame.gqPortraitIcon then
        return frame.gqPortraitIcon, frame.gqPortraitHolder
    end

    local holder = CreateFrame("Frame", nil, frame)
    holder:SetSize(PORTRAIT_SLOT_SIZE, PORTRAIT_SLOT_SIZE)
    holder:SetPoint("TOPLEFT", frame, "TOPLEFT", PORTRAIT_SLOT_X, PORTRAIT_SLOT_Y)
    holder:SetFrameLevel(frame:GetFrameLevel() + 20)

    local ring = holder:CreateTexture(nil, "OVERLAY")
    ring:SetSize(53, 53)
    ring:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    ring:SetPoint("TOPLEFT", holder, "TOPLEFT", -1, 1)

    local icon = holder:CreateTexture(nil, "ARTWORK")
    frame.gqPortraitHolder = holder
    frame.gqPortraitIcon = icon
    return icon, holder
end

local function SetupQuestLogPortrait(frame)
    if frame.gqBookIcon then
        frame.gqBookIcon:Hide()
    end

    local container = frame.PortraitContainer
        or (frame.GetName and _G[frame:GetName() .. "PortraitContainer"])
    if container then
        container:Show()
    end

    local tex = GetPortraitTexture(frame)
    if tex then
        if frame.gqPortraitHolder then
            frame.gqPortraitHolder:Hide()
        end
        ApplyPortraitToBlizzardSlot(tex, PORTRAIT_TEXTURE)
        return
    end

    if container then
        container:Hide()
    end

    local icon, holder = EnsureFallbackPortraitIcon(frame)
    ApplyCircularPortraitTexture(icon, PORTRAIT_TEXTURE, holder)
    holder:Show()
end

function GQ.Log:GetListTab()
    GearQuestDB.ui = GearQuestDB.ui or {}
    return GearQuestDB.ui.listTab or "active"
end

function GQ.Log:SetListTab(tab)
    GearQuestDB.ui = GearQuestDB.ui or {}
    GearQuestDB.ui.listTab = tab
    self.selectedHuntId = nil
    self:ClearDetail()
    self:Refresh()
end

function GQ.Log:EntryMatchesTrackedHunt(entry)
    if not entry then
        return false
    end

    local classFile = GQ:GetEffectiveClass()
    if entry.classes and not entry.classes[classFile] then
        return false
    end

    local faction = GQ:GetEffectiveFaction()
    if entry.factions and not entry.factions[faction] then
        return false
    end

    if GQ.Equip and GQ.Equip.EntryMatchesSpec and not GQ.Equip:EntryMatchesSpec(entry) then
        return false
    end

    return true
end

function GQ.Log:IsSlotCollapsed(slotName)
    slotName = GQ.Data:NormalizeSlotName(slotName)
    GearQuestDB.ui = GearQuestDB.ui or {}
    GearQuestDB.ui.collapsedSlots = GearQuestDB.ui.collapsedSlots or {}

    if GearQuestDB.ui.collapsedSlots[slotName] ~= nil then
        return GearQuestDB.ui.collapsedSlots[slotName]
    end

    -- Migrate saved collapse state from old duplicate categories.
    if slotName == "Finger" then
        for _, legacy in ipairs({ "Finger0", "Finger1" }) do
            if GearQuestDB.ui.collapsedSlots[legacy] ~= nil then
                return GearQuestDB.ui.collapsedSlots[legacy]
            end
        end
    elseif slotName == "Trinket" then
        for _, legacy in ipairs({ "Trinket0", "Trinket1" }) do
            if GearQuestDB.ui.collapsedSlots[legacy] ~= nil then
                return GearQuestDB.ui.collapsedSlots[legacy]
            end
        end
    end

    local upgrades = GQ.Data:GetTopUpgradesForSlot(slotName, 1)
    return #upgrades == 0 and #self:GetActiveSlotListEntries(slotName) == 0
end

function GQ.Log:SetSlotCollapsed(slotName, collapsed)
    slotName = GQ.Data:NormalizeSlotName(slotName)
    GearQuestDB.ui = GearQuestDB.ui or {}
    GearQuestDB.ui.collapsedSlots = GearQuestDB.ui.collapsedSlots or {}
    GearQuestDB.ui.collapsedSlots[slotName] = collapsed
end

function GQ.Log:ToggleSlotCollapsed(slotName)
    self:SetSlotCollapsed(slotName, not self:IsSlotCollapsed(slotName))
    self:Refresh()
end

function GQ.Log:GetActiveSlotListEntries(slotName)
    local results = {}
    local seen = {}

    for _, entry in ipairs(GQ.Data:GetTopUpgradesForSlot(slotName, 3)) do
        if not self:IsEntryObtained(entry.id) then
            seen[entry.id] = true
            table.insert(results, entry)
        end
    end

    for id, record in pairs(GearQuestDB.hunts or {}) do
        if not seen[id] and NormalizeHuntStatus(record.status) == "tracked" and not self:IsEntryObtained(id) then
            local entry = GQ.Data:GetEntryById(id)
            if entry and GQ.Data:EntryMatchesSlot(entry, slotName)
                and GQ.Data:EntryMatchesPlayerBand(entry)
                and self:EntryMatchesTrackedHunt(entry) then
                seen[id] = true
                table.insert(results, entry)
            end
        end
    end

    return results
end

function GQ.Log:GetCompletedSlotListEntries(slotName)
    local results = {}
    local seen = {}

    GearQuestDB.obtained = GearQuestDB.obtained or {}
    for id, obtainedAt in pairs(GearQuestDB.obtained) do
        if not IsDismissedCompleted(id) then
            local entry = GQ.Data:GetEntryById(id)
            if entry and GQ.Data:EntryMatchesSlot(entry, slotName)
                and GQ.Data:EntryMatchesPlayerBand(entry)
                and self:EntryMatchesTrackedHunt(entry) then
                seen[id] = true
                table.insert(results, {
                    entry = entry,
                    completedAt = obtainedAt or 0,
                })
            end
        end
    end

    for id, record in pairs(GearQuestDB.hunts or {}) do
        if not seen[id] and not IsDismissedCompleted(id) and NormalizeHuntStatus(record.status) == "completed" then
            local entry = GQ.Data:GetEntryById(id)
            if entry and GQ.Data:EntryMatchesSlot(entry, slotName)
                and GQ.Data:EntryMatchesPlayerBand(entry)
                and self:EntryMatchesTrackedHunt(entry) then
                seen[id] = true
                table.insert(results, {
                    entry = entry,
                    completedAt = record.completedAt or record.trackedAt or 0,
                })
            end
        end
    end

    table.sort(results, function(a, b)
        if a.completedAt ~= b.completedAt then
            return a.completedAt > b.completedAt
        end
        return a.entry.id < b.entry.id
    end)

    local entries = {}
    for _, row in ipairs(results) do
        table.insert(entries, row.entry)
    end

    return entries
end

-- Backwards-compatible alias
function GQ.Log:GetSlotListEntries(slotName)
    if self:GetListTab() == "completed" then
        return self:GetCompletedSlotListEntries(slotName)
    end
    return self:GetActiveSlotListEntries(slotName)
end

function GQ.Log:TrackHunt(id)
    local entry = GQ.Data:GetEntryById(id)
    if not entry then
        return
    end

    local record = EnsureHuntRecord(id)
    record.status = "tracked"
    record.trackedAt = time()
    self:CheckAutoCompletion()
    self:Refresh()
    if GQ.Tracker then
        GQ.Tracker:Refresh()
    end
end

function GQ.Log:ActivateHunt(id)
    self:TrackHunt(id)
end

function GQ.Log:RecordCraftedItem(itemId)
    if not itemId then
        return false
    end

    GearQuestDB.crafted = GearQuestDB.crafted or {}
    if GearQuestDB.crafted[itemId] then
        return false
    end

    GearQuestDB.crafted[itemId] = time()
    return true
end

function GQ.Log:HandleCraftChatMessage(msg)
    local itemId = ExtractItemIdFromChatMessage(msg)
    if not itemId then
        return
    end

    if self:RecordCraftedItem(itemId) then
        self:ScheduleAutoCompletionCheck()
    end
end

function GQ.Log:IsEntryObtained(id)
    if not id then
        return false
    end
    if GetObtainedTimestamp(id) then
        return true
    end
    local record = GetHuntRecord(id)
    return record and NormalizeHuntStatus(record.status) == "completed"
end

function GQ.Log:IsItemIdObtained(itemId)
    if not itemId then
        return false
    end

    for _, entry in ipairs(GQ.Data:GetEntriesByItemId(itemId)) do
        if GQ.Data:EntryMatchesPlayer(entry) and self:IsEntryObtained(entry.id) then
            return true
        end
    end

    return false
end

function GQ.Log:ShouldAutoCompleteOnObtain(entry)
    if not entry or self:IsEntryObtained(entry.id) then
        return false
    end

    if GetHuntStatus(entry.id) == "tracked" then
        return true
    end

    local slotName = GQ.Data:NormalizeSlotName(entry.slot)
    for _, upgrade in ipairs(GQ.Data:GetTopUpgradesForSlot(slotName, 3)) do
        if upgrade.id == entry.id then
            return true
        end
    end

    return false
end

function GQ.Log:MarkEntryObtained(entry, options)
    if not entry or not entry.id or self:IsEntryObtained(entry.id) then
        return false
    end

    local now = time()
    GearQuestDB.obtained = GearQuestDB.obtained or {}
    GearQuestDB.obtained[entry.id] = now

    local record = GetHuntRecord(entry.id) or {}
    record.status = "completed"
    record.completedAt = now
    record.obtained = true
    GearQuestDB.hunts[entry.id] = record

    local showToast = not options or options.showToast ~= false
    if showToast and GQ.Toast then
        GQ.Toast:ShowForEntry(entry)
    end

    return true
end

function GQ.Log:CompleteHunt(id)
    local entry = GQ.Data:GetEntryById(id)
    if entry then
        self:MarkEntryObtained(entry, { showToast = false })
    else
        local record = GetHuntRecord(id)
        if record then
            record.status = "completed"
            record.completedAt = time()
            GearQuestDB.obtained = GearQuestDB.obtained or {}
            GearQuestDB.obtained[id] = record.completedAt
        end
    end

    self:Refresh()
    if GQ.Tracker then
        GQ.Tracker:Refresh()
    end
end

function GQ.Log:WillHuntDisappearFromActiveList(id)
    if self:GetListTab() ~= "active" then
        return false
    end

    local record = GetHuntRecord(id)
    if not record or NormalizeHuntStatus(record.status) ~= "tracked" then
        return false
    end

    local entry = GQ.Data:GetEntryById(id)
    if not entry or not entry.slot then
        return false
    end

    local slotName = GQ.Data:NormalizeSlotName(entry.slot)
    for _, upgrade in ipairs(GQ.Data:GetTopUpgradesForSlot(slotName, 3)) do
        if upgrade.id == id then
            return false
        end
    end

    return true
end

function GQ.Log:EnsureUntrackConfirmDialog()
    if self.untrackDialogRegistered then
        return
    end
    self.untrackDialogRegistered = true

    StaticPopupDialogs["GEARQUEST_CONFIRM_UNTRACK"] = {
        text = "Are you sure you want to untrack this gear quest? It will become unavailable once you do",
        button1 = "Agree",
        button2 = "Cancel",
        OnAccept = function(dialog)
            local id = dialog.data
            if id and GQ.Log then
                GQ.Log:UntrackHunt(id)
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = 1,
        preferredIndex = 3,
    }
end

function GQ.Log:RequestUntrackHunt(id)
    if not id then
        return
    end

    self:EnsureUntrackConfirmDialog()

    if self:WillHuntDisappearFromActiveList(id) then
        StaticPopup_Show("GEARQUEST_CONFIRM_UNTRACK", nil, nil, id)
        return
    end

    self:UntrackHunt(id)
end

function GQ.Log:UntrackHunt(id)
    local willDisappear = self:WillHuntDisappearFromActiveList(id)
    local onCompletedTab = self:GetListTab() == "completed"

    if self:IsEntryObtained(id) and onCompletedTab then
        GearQuestDB.dismissedCompleted = GearQuestDB.dismissedCompleted or {}
        GearQuestDB.dismissedCompleted[id] = true
    end

    GearQuestDB.hunts[id] = nil

    if self.selectedHuntId == id and (willDisappear or onCompletedTab) then
        self.selectedHuntId = nil
        self:ClearDetail()
    end

    self:Refresh()
    if GQ.Tracker then
        GQ.Tracker:Refresh()
    end
end

function GQ.Log:AbandonHunt(id)
    self:RequestUntrackHunt(id)
end

function GQ.Log:WipeCharacterData()
    GearQuestDB.hunts = {}
    GearQuestDB.obtained = {}
    GearQuestDB.crafted = {}
    GearQuestDB.dismissedCompleted = {}

    self.selectedHuntId = nil
    self:ClearDetail()
    self:SetListTab("active")

    if GQ.Toast and GQ.Toast.ClearQueue then
        GQ.Toast:ClearQueue()
    end

    self:Refresh()
    if GQ.Tracker then
        GQ.Tracker:Refresh()
    end
    if GQ.RefreshUI then
        GQ:RefreshUI()
    end
end

function GQ.Log:CheckAutoCompletion()
    local changed = false

    for _, entry in ipairs(GQ.Data.entries) do
        if GQ.Data:EntryMatchesPlayer(entry)
            and self:ShouldAutoCompleteOnObtain(entry)
            and PlayerHasObtainedEntryItem(entry)
        then
            if self:MarkEntryObtained(entry) then
                changed = true
                local itemName = GetItemInfo(entry.itemId) or ("Item " .. entry.itemId)
                if entry.sourceType == "profession" then
                    print("|cff66ccffGearQuest|r: Completed — " .. itemName .. " crafted.")
                else
                    print("|cff66ccffGearQuest|r: Completed — " .. itemName .. " obtained.")
                end
            end
        end
    end

    if changed then
        if self.frame and self.frame:IsShown() then
            self:Refresh()
        end

        if GQ.Tracker then
            GQ.Tracker:Refresh()
        end

        if GQ and GQ.RefreshUI then
            GQ:RefreshUI()
        end
    end
end

function GQ.Log:ScheduleAutoCompletionCheck()
    if self.completionPending then
        return
    end
    self.completionPending = true
    if C_Timer and C_Timer.After then
        C_Timer.After(0.25, function()
            GQ.Log.completionPending = false
            GQ.Log:CheckAutoCompletion()
        end)
    else
        self.completionPending = false
        self:CheckAutoCompletion()
    end
end

function GQ.Log:EnsureDetailReward(frame)
    if not frame or not frame.detailChild then
        return
    end

    if frame.detailRewardIcon and frame.detailRewardIcon.name then
        return
    end

    if frame.detailRewardIcon then
        frame.detailRewardIcon:Hide()
        frame.detailRewardIcon:SetParent(nil)
        frame.detailRewardIcon = nil
    end

    if not frame.detailRewardHeader then
        frame.detailRewardHeader = CreateFontStringWithFallback(frame.detailChild, QUEST_DETAIL_HEADER_FONTS)
        frame.detailRewardHeader:SetPoint("TOPLEFT", frame.detailBody, "BOTTOMLEFT", 0, -16)
        frame.detailRewardHeader:SetText("REWARD")
        frame.detailRewardHeader:SetTextColor(DETAIL_TEXT_COLOR[1], DETAIL_TEXT_COLOR[2], DETAIL_TEXT_COLOR[3])
        frame.detailRewardHeader:Hide()
    end

    frame.detailRewardIcon = CreateRewardItemButton(frame.detailChild, frame:GetName() .. "RewardItem")
    frame.detailRewardIcon:SetPoint("TOPLEFT", frame.detailRewardHeader, "BOTTOMLEFT", 0, -8)
    frame.detailRewardIcon:Hide()
end

function GQ.Log:UpdateDetailReward(itemId)
    if not self.frame then
        return
    end

    self:EnsureDetailReward(self.frame)

    local header = self.frame.detailRewardHeader
    local icon = self.frame.detailRewardIcon
    if not header or not icon then
        return
    end

    if not itemId then
        header:Hide()
        icon:Hide()
        icon.itemId = nil
        return
    end

    header:Show()
    icon:Show()
    icon.itemId = itemId

    local itemName = GetItemInfo(itemId) or ("Item " .. itemId)
    icon.name:SetText(itemName)

    local nameWidth = icon.name:GetStringWidth() or REWARD_NAME_MIN_WIDTH
    local totalWidth = REWARD_ICON_SIZE + math.max(REWARD_NAME_MIN_WIDTH, nameWidth + REWARD_NAME_PAD)
    icon:SetWidth(totalWidth)

    local texture = GetItemIcon(itemId)
    if texture then
        icon.icon:SetTexture(texture)
    else
        icon.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    end
end

function GQ.Log:MeasureDetailContentHeight()
    if not self.frame then
        return 0
    end

    local height = 8

    if self.frame.detailTitle and self.frame.detailTitle:IsShown() then
        height = height + (self.frame.detailTitle:GetStringHeight() or 0) + 16
    end
    if self.frame.detailHeader and self.frame.detailHeader:IsShown() then
        height = height + (self.frame.detailHeader:GetStringHeight() or 0) + 8
    end
    if self.frame.detailBody and self.frame.detailBody:IsShown() then
        height = height + (self.frame.detailBody:GetStringHeight() or 0) + 16
    end
    if self.frame.detailRewardHeader and self.frame.detailRewardHeader:IsShown() then
        height = height + (self.frame.detailRewardHeader:GetStringHeight() or 0) + 8 + REWARD_ICON_SIZE + 16
    end

    return height
end

function GQ.Log:UpdateDetailScrollHeight()
    if not self.frame or not self.frame.detailScroll then
        return
    end

    local contentHeight = self:MeasureDetailContentHeight()
    local visibleHeight = self.frame.detailScroll:GetHeight() or 120
    self.frame.detailChild:SetHeight(math.max(contentHeight, visibleHeight))
    UpdateScrollChildRect(self.frame.detailScroll)
end

function GQ.Log:CreateListRow(index)
    local row = CreateFrame("Button", "GearQuestLogRow" .. index, self.frame.scrollChild)
    row:SetHeight(ROW_HEIGHT)
    row:Hide()

    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(16, 16)
    row.icon:SetPoint("LEFT", row, "LEFT", 4, 0)

    row.text = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.text:SetPoint("LEFT", row.icon, "RIGHT", 4, 0)
    row.text:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    row.text:SetJustifyH("LEFT")

    row.highlight = row:CreateTexture(nil, "BACKGROUND")
    row.highlight:SetAllPoints()
    row.highlight:SetColorTexture(0.28, 0.22, 0.08, 0.55)
    row.highlight:Hide()

    row:SetScript("OnEnter", function(self)
        ShowItemTooltipForRow(self)
    end)

    row:SetScript("OnLeave", function()
        HideItemTooltip()
    end)

    return row
end

function GQ.Log:EnsureTrackerEvents()
    if self.trackerFrame then
        return
    end

    local tracker = CreateFrame("Frame")
    tracker:RegisterEvent("BAG_UPDATE")
    tracker:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    tracker:RegisterEvent("MERCHANT_CLOSED")
    tracker:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    tracker:RegisterEvent("CHAT_MSG_SKILL")
    tracker:RegisterEvent("CHAT_MSG_LOOT")
    tracker:SetScript("OnEvent", function(_, event, msg)
        local log = _G.GearQuest and _G.GearQuest.Log
        if not log then
            return
        end

        if event == "CHAT_MSG_SKILL" or event == "CHAT_MSG_LOOT" then
            log:HandleCraftChatMessage(msg)
            return
        end

        log:ScheduleAutoCompletionCheck()
    end)
    self.trackerFrame = tracker
end

local function ApplySpecPickerChrome(picker)
    if not picker then
        return
    end

    ApplyBlackBackground(picker)
    ApplyMetalEdge(picker, 12)
end

function GQ.Log:HideSpecPicker()
    if self.frame and self.frame.specPicker then
        self.frame.specPicker:Hide()
    end
    if self._specPickerCatcher then
        self._specPickerCatcher:Hide()
    end
end

function GQ.Log:EnsureSpecPicker(frame)
    if frame.specPicker then
        ApplySpecPickerChrome(frame.specPicker)
        return frame.specPicker
    end

    local parent = frame.tabBar or frame
    local picker
    local ok, framed = pcall(CreateFrame, "Frame", "GearQuestSpecPicker", parent, "BackdropTemplate")
    if ok and framed then
        picker = framed
    else
        picker = CreateFrame("Frame", "GearQuestSpecPicker", parent)
    end

    picker:SetFrameStrata("FULLSCREEN_DIALOG")
    picker:SetSize(SPEC_PICKER_WIDTH, SPEC_PICKER_PAD * 2)
    picker:Hide()
    ApplySpecPickerChrome(picker)
    picker.rows = {}

    frame.specPicker = picker
    return picker
end

function GQ.Log:RefreshSpecPickerRows()
    local frame = self.frame
    if not frame or not frame.specPicker or not GQ.Spec then
        return
    end

    local picker = frame.specPicker
    local options = GQ.Spec:GetOptions(GQ:GetEffectiveClass()) or {}
    local current = GQ.Spec:GetEffectiveSpec()
    local rowCount = #options

    for i, row in ipairs(picker.rows) do
        row:Hide()
    end

    for i, opt in ipairs(options) do
        local row = picker.rows[i]
        if not row then
            row = CreateFrame("Button", nil, picker)
            row:SetSize(SPEC_PICKER_WIDTH - (SPEC_PICKER_PAD * 2), SPEC_PICKER_ROW_HEIGHT)
            row.icon = row:CreateTexture(nil, "ARTWORK")
            row.icon:SetSize(16, 16)
            row.icon:SetPoint("LEFT", row, "LEFT", 2, 0)
            row.label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            row.label:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
            row.label:SetJustifyH("LEFT")
            local highlight = row:GetHighlightTexture()
            if highlight then
                highlight:SetAlpha(0.25)
            end
            picker.rows[i] = row
        end

        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", picker, "TOPLEFT", SPEC_PICKER_PAD, -(SPEC_PICKER_PAD + ((i - 1) * SPEC_PICKER_ROW_HEIGHT)))
        row:Show()

        local selectable = GQ.Spec:IsSpecSelectable(opt.id)
        row.icon:SetTexture(GQ.Spec:GetSpecIcon(opt.id, GQ:GetEffectiveClass()))
        if selectable then
            row.icon:SetVertexColor(1, 1, 1)
        else
            row.icon:SetVertexColor(0.45, 0.45, 0.45)
        end

        local selected = (current == opt.id)
        if not selectable then
            row:Disable()
            row.label:SetText("|cff888888" .. opt.label .. " (coming later)|r")
            row:SetScript("OnClick", nil)
        else
            row:Enable()
            if selected then
                row.label:SetText("|cffFFD200> |r" .. opt.label)
            else
                row.label:SetText(opt.label)
            end

            row:SetScript("OnClick", function()
                local ok, err = GQ.Spec:SetSelectedSpec(opt.id)
                if not ok then
                    print("|cff66ccffGearQuest|r: " .. (err or "Could not change specialization."))
                    return
                end
                print(string.format(
                    "|cff66ccffGearQuest|r: Now viewing |cff00ff00%s|r upgrades.",
                    opt.label
                ))
                GQ.Log:HideSpecPicker()
                GQ.Log:UpdateSpecButton()
                if GQ.Log.frame and GQ.Log.frame:IsShown() then
                    GQ.Log:Refresh()
                end
            end)
        end
    end

    picker:SetHeight((SPEC_PICKER_PAD * 2) + (rowCount * SPEC_PICKER_ROW_HEIGHT))
end

function GQ.Log:ToggleSpecPicker(anchorBtn)
    local frame = self.frame
    if not frame or not anchorBtn then
        return
    end

    self:EnsureSpecPicker(frame)
    local picker = frame.specPicker

    if picker:IsShown() then
        self:HideSpecPicker()
        return
    end

    self:RefreshSpecPickerRows()
    picker:ClearAllPoints()
    picker:SetPoint("TOPRIGHT", anchorBtn, "BOTTOMRIGHT", 0, -2)
    picker:SetFrameLevel((anchorBtn:GetFrameLevel() or 1) + 10)
    picker:Show()

    if not self._specPickerCatcher then
        local catcher = CreateFrame("Frame", "GearQuestSpecPickerCatcher", UIParent)
        catcher:SetFrameStrata("FULLSCREEN_DIALOG")
        catcher:SetAllPoints(UIParent)
        catcher:EnableMouse(true)
        catcher:Hide()
        catcher:SetScript("OnMouseDown", function()
            GQ.Log:HideSpecPicker()
        end)
        self._specPickerCatcher = catcher
    end

    self._specPickerCatcher:SetFrameLevel(picker:GetFrameLevel() - 1)
    self._specPickerCatcher:Show()
end

function GQ.Log:WireSpecArrow(arrowFrame)
    if not arrowFrame or arrowFrame.gqArrowWired then
        return
    end

    arrowFrame.gqArrowWired = true
    arrowFrame:EnableMouse(true)

    arrowFrame:SetScript("OnEnter", function(self)
        if self.gqHighlight then
            self.gqHighlight:Show()
        end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Change specialization", 1, 1, 1)
        GameTooltip:Show()
    end)
    arrowFrame:SetScript("OnLeave", function(self)
        if self.gqHighlight then
            self.gqHighlight:Hide()
        end
        GameTooltip:Hide()
    end)
    arrowFrame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            local log = _G.GearQuest and _G.GearQuest.Log
            if log then
                log:ToggleSpecPicker(self)
            end
        end
    end)
end

function GQ.Log:ApplySpecArrowStyle(arrowFrame, iconFrame)
    if not arrowFrame then
        return
    end

    arrowFrame:SetSize(SPEC_ARROW_SIZE, SPEC_ARROW_SIZE)

    if arrowFrame.bg then
        arrowFrame.bg:Hide()
    end

    if arrowFrame.border then
        arrowFrame.border:Hide()
    end

    if arrowFrame.text then
        arrowFrame.text:Hide()
    end

    if arrowFrame.SetNormalTexture then
        arrowFrame:SetNormalTexture(nil)
        arrowFrame:SetPushedTexture(nil)
        arrowFrame:SetDisabledTexture(nil)
        arrowFrame:SetHighlightTexture(nil)
    end

    if not arrowFrame.arrow then
        arrowFrame.arrow = arrowFrame:CreateTexture(nil, "ARTWORK")
        arrowFrame.arrow:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
    end

    arrowFrame.arrow:ClearAllPoints()
    arrowFrame.arrow:SetAllPoints(arrowFrame)
    arrowFrame.arrow:Show()

    if not arrowFrame.gqHighlight then
        arrowFrame.gqHighlight = arrowFrame:CreateTexture(nil, "HIGHLIGHT")
        arrowFrame.gqHighlight:SetAllPoints()
        arrowFrame.gqHighlight:SetColorTexture(1, 1, 1, 0.15)
        arrowFrame.gqHighlight:Hide()
    end

    if iconFrame then
        arrowFrame:ClearAllPoints()
        arrowFrame:SetPoint("CENTER", iconFrame, "RIGHT", SPEC_CONTROL_GAP + (SPEC_ARROW_SIZE / 2), 0)
    end
end

function GQ.Log:EnsureSpecArrow(frame)
    if frame.tabSpecArrow and frame.tabSpecArrow:GetObjectType() == "Button" then
        frame.tabSpecArrow:Hide()
        frame.tabSpecArrow = nil
    end

    if not frame.tabSpecArrow and frame.tabSpecControl then
        local arrowFrame = CreateFrame("Frame", nil, frame.tabSpecControl)
        frame.tabSpecArrow = arrowFrame
        self:WireSpecArrow(arrowFrame)
    end

    self:ApplySpecArrowStyle(frame.tabSpecArrow, frame.tabSpecIcon)
end

function GQ.Log:EnsureSpecControl(frame)
    if frame.tabSpecControl then
        frame.tabSpecControl:SetSize(SPEC_CONTROL_WIDTH, SPEC_CONTROL_HEIGHT)
        self:EnsureSpecArrow(frame)
        return frame.tabSpecControl
    end

    if frame.tabSpec then
        frame.tabSpec:Hide()
        frame.tabSpec:SetScript("OnClick", nil)
    end

    local tabBar = frame.tabBar or frame
    local control = CreateFrame("Frame", "GearQuestLogSpecControl", tabBar)
    control:SetSize(SPEC_CONTROL_WIDTH, SPEC_CONTROL_HEIGHT)
    control:Hide()

    local iconFrame = CreateFrame("Frame", nil, control)
    iconFrame:SetSize(SPEC_ICON_SIZE, SPEC_ICON_SIZE)
    iconFrame:SetPoint("LEFT", control, "LEFT", 0, 0)
    iconFrame:EnableMouse(true)

    iconFrame.border = iconFrame:CreateTexture(nil, "OVERLAY")
    iconFrame.border:SetAllPoints()
    iconFrame.border:SetTexture("Interface\\Common\\WhiteIconFrame")

    iconFrame.icon = iconFrame:CreateTexture(nil, "ARTWORK")
    iconFrame.icon:SetPoint("TOPLEFT", iconFrame, "TOPLEFT", 1, -1)
    iconFrame.icon:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", -1, 1)

    iconFrame:SetScript("OnEnter", function(self)
        if not GQ.Spec then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(GQ.Spec:GetSelectedSpecLabel(), 1, 1, 1)
        GameTooltip:Show()
    end)
    iconFrame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    local arrowFrame = CreateFrame("Frame", nil, control)
    frame.tabSpecArrow = arrowFrame
    self:ApplySpecArrowStyle(arrowFrame, iconFrame)
    self:WireSpecArrow(arrowFrame)

    frame.tabSpecControl = control
    frame.tabSpecIcon = iconFrame
    return control
end

function GQ.Log:RepositionSpecButton(frame)
    if not frame or not frame.tabBar then
        return
    end

    local tabBar = frame.tabBar
    local tabGroup = tabBar.tabGroup
    if not tabGroup then
        return
    end

    tabBar:SetHeight(TAB_HEIGHT)

    if tabGroup:GetParent() ~= tabBar then
        tabGroup:SetParent(tabBar)
    end

    tabGroup:ClearAllPoints()
    tabGroup:SetSize(TAB_GROUP_WIDTH, TAB_HEIGHT)
    tabGroup:SetPoint("CENTER", tabBar, "CENTER", 0, 0)

    self:EnsureSpecControl(frame)
    local control = frame.tabSpecControl
    if control then
        if control:GetParent() ~= tabBar then
            control:SetParent(tabBar)
        end
        control:ClearAllPoints()
        control:SetPoint("BOTTOMRIGHT", tabBar, "TOPRIGHT", -8, -SPEC_ROW_GAP)
    end
end

function GQ.Log:UpdateTabVisuals()
    if not self.frame or not self.frame.tabActive then
        return
    end

    local tab = self:GetListTab()
    local activeSelected = tab == "active"
    self.frame.tabActive:SetEnabled(not activeSelected)
    self.frame.tabCompleted:SetEnabled(activeSelected)
    self:UpdateSpecButton()
end

function GQ.Log:UpdateSpecButton()
    if not self.frame then
        return
    end

    self:EnsureSpecControl(self.frame)
    local control = self.frame.tabSpecControl
    if not control then
        return
    end

    if GQ.Spec and GQ.Spec.IsActive and GQ.Spec:IsActive() then
        control:Show()
        local specId = GQ.Spec:GetEffectiveSpec()
        if self.frame.tabSpecIcon and self.frame.tabSpecIcon.icon then
            self.frame.tabSpecIcon.icon:SetTexture(GQ.Spec:GetSpecIcon(specId, GQ:GetEffectiveClass()))
        end
    else
        control:Hide()
    end
    self:RepositionSpecButton(self.frame)
end

function GQ.Log:UpdateFooterButtons()
    if not self.frame then
        return
    end

    local tab = self:GetListTab()
    local selectedId = self.selectedHuntId
    local status = selectedId and GetHuntStatus(selectedId) or nil
    local isTracked = status == "tracked"

    if tab == "completed" then
        self.frame.trackBtn:Hide()
        self.frame.untrackBtn:Show()
        self.frame.untrackBtn:SetText("Remove")
        self.frame.untrackBtn:SetEnabled(selectedId ~= nil)
    else
        self.frame.trackBtn:Show()
        self.frame.untrackBtn:Show()
        self.frame.trackBtn:SetText("Track")
        self.frame.untrackBtn:SetText("Untrack")

        if not selectedId then
            self.frame.trackBtn:SetEnabled(false)
            self.frame.untrackBtn:SetEnabled(false)
        else
            self.frame.trackBtn:SetEnabled(not isTracked)
            self.frame.untrackBtn:SetEnabled(isTracked)
        end
    end
end

function GQ.Log:EnsureTabBar(frame)
    if not frame.tabBar then
        local tabBar = CreateFrame("Frame", nil, frame)
        tabBar:SetHeight(TAB_HEIGHT)
        frame.tabBar = tabBar

        local tabGroup = CreateFrame("Frame", nil, tabBar)
        tabGroup:SetSize(TAB_GROUP_WIDTH, TAB_HEIGHT)
        tabGroup:SetPoint("CENTER", tabBar, "CENTER", 0, 0)
        tabBar.tabGroup = tabGroup

        local tabActive = CreateFrame("Button", "GearQuestLogTabActive", tabGroup, "UIPanelButtonTemplate")
        tabActive:SetSize(88, TAB_HEIGHT)
        tabActive:SetPoint("LEFT", tabGroup, "LEFT", 0, 0)
        tabActive:SetText("Active")
        frame.tabActive = tabActive

        local tabCompleted = CreateFrame("Button", "GearQuestLogTabCompleted", tabGroup, "UIPanelButtonTemplate")
        tabCompleted:SetSize(88, TAB_HEIGHT)
        tabCompleted:SetPoint("LEFT", tabActive, "RIGHT", 4, 0)
        tabCompleted:SetText("Completed")
        frame.tabCompleted = tabCompleted

        tabActive:SetScript("OnClick", function()
            local log = _G.GearQuest and _G.GearQuest.Log
            if log then
                log:HideSpecPicker()
                log:SetListTab("active")
            end
        end)

        tabCompleted:SetScript("OnClick", function()
            local log = _G.GearQuest and _G.GearQuest.Log
            if log then
                log:HideSpecPicker()
                log:SetListTab("completed")
            end
        end)
    end

    if frame.tabBar and not frame.tabSpecControl then
        self:EnsureSpecControl(frame)
    end

    self:RepositionSpecButton(frame)

    frame.tabBar:ClearAllPoints()
    if frame.tabBar:GetParent() ~= frame then
        frame.tabBar:SetParent(frame)
    end
    frame.tabBar:SetPoint("TOPLEFT", frame, "TOPLEFT", CONTENT_LEFT, -TAB_TOP_OFFSET)
    frame.tabBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -CONTENT_RIGHT_GUTTER, -TAB_TOP_OFFSET)

    if frame.listInset then
        frame.listInset:ClearAllPoints()
        frame.listInset:SetPoint("TOPLEFT", frame.tabBar, "BOTTOMLEFT", 0, -TAB_BAR_PAD)
        frame.listInset:SetSize(PANEL_WIDTH, LIST_SECTION_HEIGHT)
    end

    if frame.scroll and frame.listInset then
        frame.scroll:ClearAllPoints()
        frame.scroll:SetPoint("TOPLEFT", frame.listInset, "TOPLEFT", PANEL_INSET, -PANEL_INSET)
        frame.scroll:SetPoint("BOTTOMRIGHT", frame.listInset, "BOTTOMRIGHT", -PANEL_INSET, PANEL_INSET)
        ConfigurePanelScrollBar(frame.scroll)
    end

    if frame.listGutter and frame.listInset then
        frame.listGutter:ClearAllPoints()
        frame.listGutter:SetPoint("TOPLEFT", frame.listInset, "TOPRIGHT", 0, 0)
        frame.listGutter:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -GUTTER_INSET, -(LIST_TOP_OFFSET + LIST_SECTION_HEIGHT))
    end

    self:UpdateTabVisuals()
end

function GQ.Log:WireControls(frame)
    frame.trackBtn:SetScript("OnClick", function()
        local log = _G.GearQuest and _G.GearQuest.Log
        if log and log.selectedHuntId then
            log:TrackHunt(log.selectedHuntId)
        end
    end)

    frame.untrackBtn:SetScript("OnClick", function()
        local log = _G.GearQuest and _G.GearQuest.Log
        if log and log.selectedHuntId then
            log:RequestUntrackHunt(log.selectedHuntId)
        end
    end)

    frame.exitBtn:SetScript("OnClick", function()
        local log = _G.GearQuest and _G.GearQuest.Log
        if log then
            log:Hide()
        end
    end)
end

function GQ.Log:BindExistingFrame(frame)
    self.frame = frame
    ApplyLogWindowLayer(frame)
    self.listRows = {}
    self.selectedHuntId = nil
    frame.scroll = frame.scroll or _G.GearQuestLogListScrollFrame
    frame.scrollChild = frame.scrollChild or _G.GearQuestLogListScrollChild
    frame.detailScroll = frame.detailScroll or _G.GearQuestLogDetailScrollFrame
    frame.detailChild = frame.detailChild or _G.GearQuestLogDetailScrollChild
    frame.listInset = frame.listInset or frame
    self:EnsureTabBar(frame)
    self:EnsureDetailReward(frame)
    LayoutDetailScroll(frame)
    if frame.trackBtn and frame.untrackBtn and frame.exitBtn then
        self:WireControls(frame)
    end
    self:EnsureTrackerEvents()
end

function GQ.Log:MigrateObtainedRecords()
    GearQuestDB.obtained = GearQuestDB.obtained or {}
    GearQuestDB.crafted = GearQuestDB.crafted or {}
    GearQuestDB.dismissedCompleted = GearQuestDB.dismissedCompleted or {}

    for id, record in pairs(GearQuestDB.hunts or {}) do
        if NormalizeHuntStatus(record.status) == "completed" and not GearQuestDB.obtained[id] then
            GearQuestDB.obtained[id] = record.completedAt or record.trackedAt or time()
        end
    end

    for id, obtainedAt in pairs(GearQuestDB.obtained) do
        local entry = GQ.Data:GetEntryById(id)
        if entry and entry.sourceType == "profession" and entry.itemId and not GearQuestDB.crafted[entry.itemId] then
            GearQuestDB.crafted[entry.itemId] = obtainedAt
        end
    end
end

function GQ.Log:Init()
    self:MigrateObtainedRecords()

    if self.frame then
        return
    end

    self:EnsureItemInfoListener()

    if _G.GearQuestLogFrame then
        self:BindExistingFrame(_G.GearQuestLogFrame)
        return
    end

    local ok, frame = pcall(CreateFrame, "Frame", "GearQuestLogFrame", UIParent, "PortraitFrameTemplate")
    if not ok or not frame then
        frame = CreateFrame("Frame", "GearQuestLogFrame", UIParent)
        if frame.SetBackdrop then
            frame:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                tile = true,
                tileSize = 32,
                edgeSize = 32,
                insets = { left = 11, right = 12, top = 12, bottom = 11 },
            })
        end
        CreateFrame("Button", nil, frame, "UIPanelCloseButton"):SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)
    end

    frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        BringLogWindowToFront(self)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetScript("OnShow", function(self)
        BringLogWindowToFront(self)
    end)
    ApplyLogWindowLayer(frame)
    frame:Hide()
    tinsert(UISpecialFrames, frame:GetName())

    SetFrameTitle(frame, "GearQuest Log")
    SetupQuestLogPortrait(frame)

    frame.listInset = CreateFrame("Frame", nil, frame)
    frame.listInset:SetSize(PANEL_WIDTH, LIST_SECTION_HEIGHT)
    ApplyBlackBackground(frame.listInset)
    ApplyMetalEdge(frame.listInset, 12)

    frame.scroll = CreatePanelScrollFrame("GearQuestLogListScrollFrame", frame.listInset)
    frame.scroll:SetPoint("TOPLEFT", frame.listInset, "TOPLEFT", PANEL_INSET, -PANEL_INSET)
    frame.scroll:SetPoint("BOTTOMRIGHT", frame.listInset, "BOTTOMRIGHT", -PANEL_INSET, PANEL_INSET)

    frame.scrollChild = CreateFrame("Frame", "GearQuestLogListScrollChild", frame.scroll)
    frame.scrollChild:SetWidth(PANEL_WIDTH - (PANEL_INSET * 2) - SCROLLBAR_INSET)
    frame.scrollChild:SetHeight(1)
    frame.scroll:SetScrollChild(frame.scrollChild)

    frame.listGutter = CreateFrame("Frame", nil, frame)

    frame.sectionDivider = CreateSectionDivider(frame)
    frame.sectionDivider:SetPoint("TOPLEFT", frame.listInset, "BOTTOMLEFT", 0, 0)
    frame.sectionDivider:SetPoint("TOPRIGHT", frame.listInset, "BOTTOMRIGHT", 0, 0)

    frame.detailBg = CreateFrame("Frame", nil, frame)
    frame.detailBg:SetPoint("TOPLEFT", frame.sectionDivider, "BOTTOMLEFT", 0, 0)
    frame.detailBg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -CONTENT_RIGHT_GUTTER, FOOTER_OFFSET)
    EnableClipping(frame.detailBg)
    ApplyParchmentBackground(frame.detailBg)
    ApplyMetalEdge(frame.detailBg, 12)

    frame.detailScroll = CreatePanelScrollFrame("GearQuestLogDetailScrollFrame", frame)
    LayoutDetailScroll(frame)

    frame.detailChild = CreateFrame("Frame", "GearQuestLogDetailScrollChild", frame.detailScroll)
    frame.detailChild:SetWidth(PANEL_WIDTH - (PANEL_INSET * 2) - SCROLLBAR_INSET - 8)
    frame.detailScroll:SetScrollChild(frame.detailChild)

    frame.detailGutter = CreateFrame("Frame", nil, frame)
    frame.detailGutter:SetPoint("TOPLEFT", frame.detailBg, "TOPRIGHT", 0, 0)
    frame.detailGutter:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -GUTTER_INSET, FOOTER_OFFSET)

    ConfigurePanelScrollBar(frame.scroll)

    frame.detailTitle = CreateFontStringWithFallback(frame.detailChild, QUEST_DETAIL_TITLE_FONTS)
    frame.detailTitle:SetPoint("TOPLEFT", frame.detailChild, "TOPLEFT", 8, -8)
    frame.detailTitle:SetPoint("RIGHT", frame.detailChild, "RIGHT", -8, 0)
    frame.detailTitle:SetJustifyH("LEFT")
    frame.detailTitle:SetTextColor(DETAIL_TEXT_COLOR[1], DETAIL_TEXT_COLOR[2], DETAIL_TEXT_COLOR[3])
    frame.detailTitle:Hide()

    frame.detailHeader = CreateFontStringWithFallback(frame.detailChild, QUEST_DETAIL_HEADER_FONTS)
    frame.detailHeader:SetPoint("TOPLEFT", frame.detailTitle, "BOTTOMLEFT", 0, -16)
    frame.detailHeader:SetText("DESCRIPTION")
    frame.detailHeader:SetTextColor(DETAIL_TEXT_COLOR[1], DETAIL_TEXT_COLOR[2], DETAIL_TEXT_COLOR[3])
    frame.detailHeader:Hide()

    frame.detailBody = CreateFontStringWithFallback(frame.detailChild, QUEST_DETAIL_BODY_FONTS)
    frame.detailBody:SetPoint("TOPLEFT", frame.detailHeader, "BOTTOMLEFT", 0, -8)
    frame.detailBody:SetPoint("RIGHT", frame.detailChild, "RIGHT", -8, 0)
    frame.detailBody:SetJustifyH("LEFT")
    frame.detailBody:SetWordWrap(true)
    frame.detailBody:SetTextColor(DETAIL_TEXT_COLOR[1], DETAIL_TEXT_COLOR[2], DETAIL_TEXT_COLOR[3])
    frame.detailBody:Hide()

    self:EnsureDetailReward(frame)

    frame.detailEmpty = CreateFontStringWithFallback(frame.detailChild, QUEST_DETAIL_BODY_FONTS)
    frame.detailEmpty:SetPoint("TOPLEFT", frame.detailChild, "TOPLEFT", 8, -8)
    frame.detailEmpty:SetText("Select an upgrade to see how to get it.")
    frame.detailEmpty:SetTextColor(DETAIL_TEXT_COLOR[1], DETAIL_TEXT_COLOR[2], DETAIL_TEXT_COLOR[3])
    frame.detailEmpty:Show()

    frame.trackBtn = CreateFrame("Button", "GearQuestLogTrackButton", frame, "UIPanelButtonTemplate")
    frame.trackBtn:SetSize(106, 22)
    frame.trackBtn:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 18, 12)
    frame.trackBtn:SetText("Track")

    frame.untrackBtn = CreateFrame("Button", "GearQuestLogUntrackButton", frame, "UIPanelButtonTemplate")
    frame.untrackBtn:SetSize(106, 22)
    frame.untrackBtn:SetPoint("LEFT", frame.trackBtn, "RIGHT", 2, 0)
    frame.untrackBtn:SetText("Untrack")

    frame.exitBtn = CreateFrame("Button", "GearQuestLogExitButton", frame, "UIPanelButtonTemplate")
    frame.exitBtn:SetSize(106, 22)
    frame.exitBtn:SetPoint("LEFT", frame.untrackBtn, "RIGHT", 2, 0)
    frame.exitBtn:SetText("Exit")

    self:WireControls(frame)
    self:EnsureTrackerEvents()
    self:EnsureTabBar(frame)

    self.listRows = {}
    self.frame = frame
    self.selectedHuntId = nil
    self:ClearDetail()
end

function GQ.Log:SetDetailEmpty(empty)
    if not self.frame then
        return
    end

    if empty then
        self.frame.detailEmpty:Show()
        self.frame.detailHeader:Hide()
        self.frame.detailTitle:Hide()
        self.frame.detailBody:Hide()
        if self.frame.detailRewardHeader then
            self.frame.detailRewardHeader:Hide()
        end
        if self.frame.detailRewardIcon then
            self.frame.detailRewardIcon:Hide()
        end
    else
        self.frame.detailEmpty:Hide()
        self.frame.detailHeader:Show()
        self.frame.detailTitle:Show()
        self.frame.detailBody:Show()
    end
end

function GQ.Log:ClearDetail()
    if not self.frame then
        return
    end
    self.frame.detailTitle:SetText("")
    self.frame.detailBody:SetText("")
    self:UpdateDetailReward(nil)
    self:SetDetailEmpty(true)
end

function GQ.Log:ConfigureRow(row, yOffset, rowType, slotName, entry)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", self.frame.scrollChild, "TOPLEFT", 0, -yOffset)
    row:SetPoint("RIGHT", self.frame.scrollChild, "RIGHT", 0, 0)
    row:SetHeight(ROW_HEIGHT)
    row.rowType = rowType
    row.slotName = slotName
    row.entry = entry
    row.huntId = entry and entry.id or nil

    if rowType == "header" then
        local collapsed = self:IsSlotCollapsed(slotName)
        row.icon:SetTexture(collapsed and "Interface\\Buttons\\UI-PlusButton-Up" or "Interface\\Buttons\\UI-MinusButton-Up")
        row.text:ClearAllPoints()
        row.text:SetPoint("LEFT", row.icon, "RIGHT", 4, 0)
        row.text:SetPoint("RIGHT", row, "RIGHT", -6, 0)
        row.text:SetText(GQ.Data:SlotLabel(slotName))
        row.text:SetTextColor(1, 0.82, 0)
        row.highlight:Hide()
        row:SetScript("OnClick", function()
            local log = _G.GearQuest and _G.GearQuest.Log
            if log then
                log:ToggleSlotCollapsed(slotName)
            end
        end)
    elseif rowType == "empty" then
        row.icon:SetTexture(nil)
        row.text:ClearAllPoints()
        row.text:SetPoint("LEFT", row, "LEFT", 20, 0)
        row.text:SetPoint("RIGHT", row, "RIGHT", -6, 0)
        if self:GetListTab() == "completed" then
            row.text:SetText("No completed hunts in this slot.")
        else
            row.text:SetText("No upgrades for your level yet.")
        end
        row.text:SetTextColor(0.6, 0.6, 0.6)
        row.highlight:Hide()
        row:SetScript("OnClick", nil)
    elseif rowType == "empty_all" then
        row.icon:SetTexture(nil)
        row.text:ClearAllPoints()
        row.text:SetPoint("LEFT", row, "LEFT", 8, 0)
        row.text:SetPoint("RIGHT", row, "RIGHT", -6, 0)
        row.text:SetText("No completed hunts yet.")
        row.text:SetTextColor(0.6, 0.6, 0.6)
        row.highlight:Hide()
        row:SetScript("OnClick", nil)
    else
        local name = GetItemInfo(entry.itemId) or ("Item " .. entry.itemId)
        local _, _, quality = GetItemInfo(entry.itemId)
        local r, g, b = GetItemQualityColor(quality or 1)
        local status = GetHuntStatus(entry.id)

        row.icon:SetTexture(nil)
        row.text:ClearAllPoints()
        row.text:SetPoint("LEFT", row, "LEFT", 20, 0)
        row.text:SetPoint("RIGHT", row, "RIGHT", -6, 0)

        local showNewLabel = self:GetListTab() == "active"

        if status == "completed" then
            row.text:SetText(name)
            row.text:SetTextColor(r, g, b)
        elseif status == "tracked" then
            row.text:SetText(FormatActiveListItemText(name, entry, status, showNewLabel))
            row.text:SetTextColor(r, g, b)
        else
            row.text:SetText(FormatActiveListItemText(name, entry, status, showNewLabel))
            row.text:SetTextColor(r, g, b)
        end

        if entry.id == self.selectedHuntId then
            row.highlight:Show()
        else
            row.highlight:Hide()
        end
        row:SetScript("OnClick", function()
            local log = _G.GearQuest and _G.GearQuest.Log
            if log then
                log:SelectHunt(entry.id)
            end
        end)
    end

    row:Show()
end

function GQ.Log:ScrollListToRow(layoutIndex)
    if not layoutIndex or not self.frame or not self.frame.scroll then
        return
    end

    local scroll = self.frame.scroll
    local scrollChild = self.frame.scrollChild
    if not scrollChild then
        return
    end

    local visibleHeight = scroll:GetHeight() or LIST_SECTION_HEIGHT
    local contentHeight = scrollChild:GetHeight() or 0
    local maxScroll = math.max(0, contentHeight - visibleHeight)
    if maxScroll <= 0 then
        scroll:SetVerticalScroll(0)
        return
    end

    local rowTop = (layoutIndex - 1) * ROW_HEIGHT
    local target = rowTop - math.floor((visibleHeight - ROW_HEIGHT) / 2)
    target = math.max(0, math.min(target, maxScroll))
    scroll:SetVerticalScroll(target)

    local scrollBar = _G[scroll:GetName() .. "ScrollBar"]
    if scrollBar then
        scrollBar:SetValue(target)
    end
end

function GQ.Log:BuildDetailLines(entry)
    local lines = { entry.instructions }

    if entry.sourceType == "world_drop" then
        local isBoE = GQ.Equip and GQ.Equip.IsBindOnEquip and GQ.Equip:IsBindOnEquip(entry.itemId)
        if isBoE then
            table.insert(lines, "\nAuction House: Also check the Auction House — this item binds when equipped.")
        end
    end

    if entry.zone then
        table.insert(lines, "\nZone: " .. entry.zone)
    end
    if entry.questName then
        table.insert(lines, "Quest: " .. entry.questName)
    end
    if entry.npc then
        table.insert(lines, "NPC: " .. entry.npc)
    end
    table.insert(lines, "\nSource: " .. GQ:GetSourceLabel(entry.sourceType))

    local record = GetHuntRecord(entry.id)
    if record and NormalizeHuntStatus(record.status) == "completed" then
        local completedText = FormatCompletedDate(record.completedAt)
        if completedText then
            table.insert(lines, "\nCompleted: " .. completedText)
        end
    end

    return lines
end

function GQ.Log:EnsureItemInfoListener()
    if self.itemInfoListener then
        return
    end

    local frame = CreateFrame("Frame")
    frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    frame:SetScript("OnEvent", function()
        local log = _G.GearQuest and _G.GearQuest.Log
        if not log or not log.selectedHuntId or not log.frame or not log.frame:IsShown() then
            return
        end

        local entry = GQ.Data:GetEntryById(log.selectedHuntId)
        if not entry then
            return
        end

        log:UpdateDetailReward(entry.itemId)
        if entry.sourceType == "world_drop" then
            log:SelectHunt(log.selectedHuntId)
        end
    end)
    self.itemInfoListener = frame
end

function GQ.Log:SelectHunt(id, scrollToSelection)
    local targetTab = self:IsEntryObtained(id) and "completed" or "active"
    if self:GetListTab() ~= targetTab then
        GearQuestDB.ui = GearQuestDB.ui or {}
        GearQuestDB.ui.listTab = targetTab
    end

    self.selectedHuntId = id
    self.scrollListToSelected = scrollToSelection == true

    local entry = GQ.Data:GetEntryById(id)
    if not entry then
        return
    end

    if entry.slot then
        self:SetSlotCollapsed(GQ.Data:NormalizeSlotName(entry.slot), false)
    end

    local itemName = GetItemInfo(entry.itemId) or ("Item " .. entry.itemId)

    self:SetDetailEmpty(false)
    self.frame.detailTitle:SetText("|cff" .. DETAIL_TEXT_HEX .. itemName:upper() .. "|r")
    self.frame.detailTitle:SetTextColor(DETAIL_TEXT_COLOR[1], DETAIL_TEXT_COLOR[2], DETAIL_TEXT_COLOR[3])

    local lines = self:BuildDetailLines(entry)

    self.frame.detailBody:SetText(table.concat(lines, "\n"))

    self:UpdateDetailReward(entry.itemId)
    self:UpdateDetailScrollHeight()

    self:Refresh()
end

function GQ.Log:Refresh()
    local classFile = GQ:GetEffectiveClass()
    local slots = GQ.Data:GetSlotsForClass(classFile)
    local layoutRows = {}
    local rowIndex = 0
    local yOffset = 0
    local selectedLayoutIndex
    local tab = self:GetListTab()

    self:UpdateTabVisuals()
    self:UpdateFooterButtons()

    if tab == "completed" then
        local anyCompleted = false

        for _, slotName in ipairs(slots) do
            local completed = self:GetCompletedSlotListEntries(slotName)
            if #completed > 0 then
                anyCompleted = true
                table.insert(layoutRows, { type = "header", slotName = slotName })

                if not self:IsSlotCollapsed(slotName) then
                    for _, entry in ipairs(completed) do
                        table.insert(layoutRows, { type = "item", slotName = slotName, entry = entry })
                    end
                end
            end
        end

        if not anyCompleted then
            table.insert(layoutRows, { type = "empty_all" })
        end
    else
        for _, slotName in ipairs(slots) do
            local upgrades = self:GetActiveSlotListEntries(slotName)
            table.insert(layoutRows, { type = "header", slotName = slotName })

            if not self:IsSlotCollapsed(slotName) then
                if #upgrades == 0 then
                    table.insert(layoutRows, { type = "empty", slotName = slotName })
                else
                    for _, entry in ipairs(upgrades) do
                        table.insert(layoutRows, { type = "item", slotName = slotName, entry = entry })
                    end
                end
            end
        end
    end

    for i, spec in ipairs(layoutRows) do
        if not self.listRows[i] then
            self.listRows[i] = self:CreateListRow(i)
        end
        self:ConfigureRow(self.listRows[i], yOffset, spec.type, spec.slotName, spec.entry)
        if self.selectedHuntId and spec.type == "item" and spec.entry and spec.entry.id == self.selectedHuntId then
            selectedLayoutIndex = i
        end
        yOffset = yOffset + ROW_HEIGHT
        rowIndex = i
    end

    for i = rowIndex + 1, #self.listRows do
        self.listRows[i]:Hide()
    end

    self.frame.scrollChild:SetHeight(math.max(yOffset, 1))
    UpdateScrollChildRect(self.frame.scroll)

    ConfigurePanelScrollBar(self.frame.scroll)

    local detailVisible = self.frame.detailScroll:GetHeight() or 0
    local detailContent = self.frame.detailChild:GetHeight() or 0
    if detailContent < detailVisible then
        self.frame.detailChild:SetHeight(detailVisible + 2)
        UpdateScrollChildRect(self.frame.detailScroll)
    end
    LayoutDetailScroll(self.frame)

    if self.scrollListToSelected and selectedLayoutIndex then
        self:ScrollListToRow(selectedLayoutIndex)
        self.scrollListToSelected = false
    end

    if self.selectedHuntId then
        local record = GetHuntRecord(self.selectedHuntId)
        local entry = GQ.Data:GetEntryById(self.selectedHuntId)
        local status = record and NormalizeHuntStatus(record.status)
        local clearSelection = false

        if not entry then
            clearSelection = true
        elseif tab == "completed" and status ~= "completed" then
            clearSelection = true
        elseif tab == "active" and status == "completed" then
            clearSelection = true
        end

        if clearSelection then
            self.selectedHuntId = nil
            self:ClearDetail()
        end
    end
end

function GQ.Log:Show()
    if not self.frame then
        return
    end

    SetupQuestLogPortrait(self.frame)
    ApplyParchmentBackground(self.frame.detailBg)
    LayoutDetailScroll(self.frame)
    local ok, err = pcall(function()
        self:CheckAutoCompletion()
        self:Refresh()
    end)
    if not ok then
        print("|cffff0000GearQuest log error:|r " .. tostring(err))
    end

    BringLogWindowToFront(self.frame)
    self.frame:Show()
end

function GQ.Log:Hide()
    self:HideSpecPicker()
    if self.frame then
        self.frame:Hide()
    end
end

function GQ.Log:Toggle()
    if not self.frame then
        return
    end
    if self.frame:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end
