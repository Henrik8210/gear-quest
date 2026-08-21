local _, GQ = ...

GQ.Log = GQ.Log or {}

local FRAME_WIDTH = 384
local FRAME_HEIGHT = 512
local ROW_HEIGHT = 16
local PORTRAIT_TEXTURE = "Interface\\QuestFrame\\UI-QuestLog-BookIcon"
local PORTRAIT_TEX_INSET = 0.08
local PORTRAIT_SLOT_SIZE = 61
local PORTRAIT_SLOT_X = 8
local PORTRAIT_SLOT_Y = -8
local PORTRAIT_DISPLAY_SIZE = 58

-- Content area below title bar and above footer buttons.
local HEADER_OFFSET = 74
local FOOTER_OFFSET = 48
local CONTENT_HEIGHT = FRAME_HEIGHT - HEADER_OFFSET - FOOTER_OFFSET
local LIST_SECTION_HEIGHT = math.floor(CONTENT_HEIGHT * 0.40)
local CONTENT_LEFT = 4
local CONTENT_RIGHT_GUTTER = 30
local PANEL_WIDTH = FRAME_WIDTH - CONTENT_LEFT - CONTENT_RIGHT_GUTTER
local PANEL_INSET = 2
local GUTTER_INSET = 6
local SECTION_DIVIDER_HEIGHT = 3
local METAL_EDGE = "Interface\\Tooltips\\UI-Tooltip-Border"
local DETAIL_TEXT_COLOR = { 0.13, 0.09, 0.04 }
local DETAIL_TEXT_HEX = "21160a"
local QUEST_DETAIL_TITLE_FONTS = {
    "QuestFont_Large", "GameFontHighlightLarge", "GameFontNormalLarge",
}

local function GetHuntRecord(id)
    GearQuestDB.hunts = GearQuestDB.hunts or {}
    return GearQuestDB.hunts[id]
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

local function ConfigurePanelScrollBar(scroll, gutterFrame, mainFrame)
    if not scroll or not scroll.GetName or not gutterFrame then
        return
    end
    local scrollBar = _G[scroll:GetName() .. "ScrollBar"]
    if not scrollBar then
        return
    end
    scrollBar:ClearAllPoints()
    scrollBar:SetPoint("TOPLEFT", gutterFrame, "TOPLEFT", 0, -16)
    scrollBar:SetPoint("BOTTOMRIGHT", gutterFrame, "BOTTOMRIGHT", 0, 16)
    if mainFrame and mainFrame.GetFrameLevel then
        scrollBar:SetFrameLevel(mainFrame:GetFrameLevel() + 20)
    end
    scrollBar:Show()
end

local function CreatePanelScrollFrame(name, parent)
    local scrollOk, scroll = pcall(CreateFrame, "ScrollFrame", name, parent, "UIPanelScrollFrameTemplate")
    if not scrollOk or not scroll then
        scroll = CreateFrame("ScrollFrame", name, parent)
    end

    local scrollName = scroll:GetName()
    if scrollName then
        for _, suffix in ipairs({ "Top", "Bottom", "Middle", "Left", "Right" }) do
            local piece = _G[scrollName .. suffix]
            if piece and piece.SetAlpha then
                piece:SetAlpha(0)
            end
        end
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
    return #upgrades == 0 and #self:GetSlotListEntries(slotName) == 0
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

function GQ.Log:GetSlotListEntries(slotName)
    local results = {}
    local seen = {}

    for _, entry in ipairs(GQ.Data:GetTopUpgradesForSlot(slotName, 3)) do
        seen[entry.id] = true
        table.insert(results, entry)
    end

    for id, record in pairs(GearQuestDB.hunts or {}) do
        if not seen[id] then
            local status = NormalizeHuntStatus(record.status)
            if status == "tracked" or status == "completed" then
                local entry = GQ.Data:GetEntryById(id)
                if entry and GQ.Data:EntryMatchesSlot(entry, slotName) and GQ.Data:EntryMatchesPlayer(entry) then
                    seen[id] = true
                    table.insert(results, entry)
                end
            end
        end
    end

    return results
end

function GQ.Log:TrackHunt(id)
    local entry = GQ.Data:GetEntryById(id)
    if not entry then
        return
    end

    local record = EnsureHuntRecord(id)
    record.status = "tracked"
    record.trackedAt = time()
    print("|cff66ccffGearQuest|r: Tracking — " .. (GetItemInfo(entry.itemId) or ("Item " .. entry.itemId)))
    self:CheckAutoCompletion()
    self:Refresh()
end

function GQ.Log:ActivateHunt(id)
    self:TrackHunt(id)
end

function GQ.Log:CompleteHunt(id)
    local record = GetHuntRecord(id)
    if record then
        record.status = "completed"
        record.completedAt = time()
        self:Refresh()
    end
end

function GQ.Log:UntrackHunt(id)
    GearQuestDB.hunts[id] = nil
    if self.selectedHuntId == id then
        self.selectedHuntId = nil
        self:ClearDetail()
    end
    self:Refresh()
end

function GQ.Log:AbandonHunt(id)
    self:UntrackHunt(id)
end

function GQ.Log:CheckAutoCompletion()
    local changed = false

    for id, record in pairs(GearQuestDB.hunts or {}) do
        if NormalizeHuntStatus(record.status) == "tracked" then
            local entry = GQ.Data:GetEntryById(id)
            if entry and PlayerOwnsItem(entry.itemId) then
                record.status = "completed"
                record.completedAt = time()
                changed = true
                local itemName = GetItemInfo(entry.itemId) or ("Item " .. entry.itemId)
                print("|cff66ccffGearQuest|r: Completed — " .. itemName .. " obtained.")
            end
        end
    end

    if changed and self.frame and self.frame:IsShown() then
        self:Refresh()
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
    row.highlight:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
    if row.highlight.SetBlendMode then
        row.highlight:SetBlendMode("ADD")
    end
    row.highlight:Hide()

    row:SetScript("OnEnter", function(self)
        if self.entry then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink("item:" .. self.entry.itemId)
            GameTooltip:Show()
        end
    end)

    row:SetScript("OnLeave", function()
        GameTooltip:Hide()
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
    tracker:SetScript("OnEvent", function()
        local log = _G.GearQuest and _G.GearQuest.Log
        if log then
            log:ScheduleAutoCompletionCheck()
        end
    end)
    self.trackerFrame = tracker
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
            log:UntrackHunt(log.selectedHuntId)
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
    self.listRows = {}
    self.selectedHuntId = nil
    frame.scroll = frame.scroll or _G.GearQuestLogListScrollFrame
    frame.scrollChild = frame.scrollChild or _G.GearQuestLogListScrollChild
    frame.detailScroll = frame.detailScroll or _G.GearQuestLogDetailScrollFrame
    frame.detailChild = frame.detailChild or _G.GearQuestLogDetailScrollChild
    if frame.trackBtn and frame.untrackBtn and frame.exitBtn then
        self:WireControls(frame)
    end
    self:EnsureTrackerEvents()
end

function GQ.Log:Init()
    if self.frame then
        return
    end

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
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    tinsert(UISpecialFrames, frame:GetName())

    SetFrameTitle(frame, "GearQuest Log")
    SetupQuestLogPortrait(frame)

    frame.listInset = CreateFrame("Frame", nil, frame)
    frame.listInset:SetPoint("TOPLEFT", frame, "TOPLEFT", CONTENT_LEFT, -HEADER_OFFSET)
    frame.listInset:SetSize(PANEL_WIDTH, LIST_SECTION_HEIGHT)
    ApplyBlackBackground(frame.listInset)
    ApplyMetalEdge(frame.listInset, 12)

    frame.scroll = CreatePanelScrollFrame("GearQuestLogListScrollFrame", frame)
    frame.scroll:SetPoint("TOPLEFT", frame.listInset, "TOPLEFT", PANEL_INSET, -PANEL_INSET)
    frame.scroll:SetPoint("BOTTOMRIGHT", frame.listInset, "BOTTOMRIGHT", 0, PANEL_INSET)

    frame.scrollChild = CreateFrame("Frame", "GearQuestLogListScrollChild", frame.scroll)
    frame.scrollChild:SetWidth(PANEL_WIDTH - PANEL_INSET)
    frame.scrollChild:SetHeight(1)
    frame.scroll:SetScrollChild(frame.scrollChild)

    frame.listGutter = CreateFrame("Frame", nil, frame)
    frame.listGutter:SetPoint("TOPLEFT", frame.listInset, "TOPRIGHT", 0, 0)
    frame.listGutter:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -GUTTER_INSET, -(HEADER_OFFSET + LIST_SECTION_HEIGHT))

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
    frame.detailScroll:SetPoint("TOPLEFT", frame.detailBg, "TOPLEFT", PANEL_INSET, -PANEL_INSET)
    frame.detailScroll:SetPoint("BOTTOMRIGHT", frame.detailBg, "BOTTOMRIGHT", 0, PANEL_INSET)
    frame.detailScroll:SetFrameLevel(frame.detailBg:GetFrameLevel() + 2)

    frame.detailChild = CreateFrame("Frame", "GearQuestLogDetailScrollChild", frame.detailScroll)
    frame.detailChild:SetWidth(PANEL_WIDTH - PANEL_INSET - 8)
    frame.detailScroll:SetScrollChild(frame.detailChild)

    frame.detailGutter = CreateFrame("Frame", nil, frame)
    frame.detailGutter:SetPoint("TOPLEFT", frame.detailBg, "TOPRIGHT", 0, 0)
    frame.detailGutter:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -GUTTER_INSET, FOOTER_OFFSET)

    ConfigurePanelScrollBar(frame.scroll, frame.listGutter, frame)
    ConfigurePanelScrollBar(frame.detailScroll, frame.detailGutter, frame)

    frame.detailTitle = CreateFontStringWithFallback(frame.detailChild, QUEST_DETAIL_TITLE_FONTS)
    frame.detailTitle:SetPoint("TOPLEFT", frame.detailChild, "TOPLEFT", 8, -8)
    frame.detailTitle:SetPoint("RIGHT", frame.detailChild, "RIGHT", -8, 0)
    frame.detailTitle:SetJustifyH("LEFT")
    frame.detailTitle:SetTextColor(DETAIL_TEXT_COLOR[1], DETAIL_TEXT_COLOR[2], DETAIL_TEXT_COLOR[3])
    frame.detailTitle:Hide()

    frame.detailHeader = CreateFontStringWithFallback(frame.detailChild, QUEST_DETAIL_TITLE_FONTS)
    frame.detailHeader:SetPoint("TOPLEFT", frame.detailTitle, "BOTTOMLEFT", 0, -16)
    frame.detailHeader:SetText("DESCRIPTION")
    frame.detailHeader:SetTextColor(DETAIL_TEXT_COLOR[1], DETAIL_TEXT_COLOR[2], DETAIL_TEXT_COLOR[3])
    frame.detailHeader:Hide()

    frame.detailBody = CreateFontStringWithFallback(frame.detailChild, {
        "QuestFont", "GameFontHighlight", "GameFontNormal",
    })
    frame.detailBody:SetPoint("TOPLEFT", frame.detailHeader, "BOTTOMLEFT", 0, -8)
    frame.detailBody:SetPoint("RIGHT", frame.detailChild, "RIGHT", -8, 0)
    frame.detailBody:SetJustifyH("LEFT")
    frame.detailBody:SetWordWrap(true)
    frame.detailBody:SetTextColor(DETAIL_TEXT_COLOR[1], DETAIL_TEXT_COLOR[2], DETAIL_TEXT_COLOR[3])
    frame.detailBody:Hide()

    frame.detailEmpty = CreateFontStringWithFallback(frame.detailChild, {
        "QuestFont", "GameFontHighlight", "GameFontNormal",
    })
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
        row.text:SetText("No upgrades for your level yet.")
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

        if status == "completed" then
            row.text:SetText(name .. " |cff888888(Completed)|r")
            row.text:SetTextColor(0.55, 0.55, 0.55)
        elseif status == "tracked" then
            row.text:SetText(name .. " |cff00ff00(Tracked)|r")
            row.text:SetTextColor(r, g, b)
        else
            row.text:SetText(name)
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

function GQ.Log:SelectHunt(id)
    self.selectedHuntId = id
    local entry = GQ.Data:GetEntryById(id)
    if not entry then
        return
    end

    local itemName = GetItemInfo(entry.itemId) or ("Item " .. entry.itemId)

    self:SetDetailEmpty(false)
    self.frame.detailTitle:SetText("|cff" .. DETAIL_TEXT_HEX .. itemName:upper() .. "|r")
    self.frame.detailTitle:SetTextColor(DETAIL_TEXT_COLOR[1], DETAIL_TEXT_COLOR[2], DETAIL_TEXT_COLOR[3])

    local lines = { entry.instructions }
    if entry.zone then
        table.insert(lines, "\nZone: " .. entry.zone)
    end
    if entry.npc then
        table.insert(lines, "Target: " .. entry.npc)
    end
    if entry.questId then
        table.insert(lines, "Quest ID: " .. entry.questId)
    end
    table.insert(lines, "\nSource: " .. GQ:GetSourceLabel(entry.sourceType))

    self.frame.detailBody:SetText(table.concat(lines, "\n"))

    local bodyHeight = self.frame.detailBody:GetStringHeight() + 100
    local visibleHeight = self.frame.detailScroll:GetHeight() or 120
    self.frame.detailChild:SetHeight(math.max(bodyHeight, visibleHeight))
    UpdateScrollChildRect(self.frame.detailScroll)

    self:Refresh()
end

function GQ.Log:Refresh()
    local classFile = GQ:GetEffectiveClass()
    local slots = GQ.Data:GetSlotsForClass(classFile)
    local layoutRows = {}
    local rowIndex = 0
    local yOffset = 0

    for _, slotName in ipairs(slots) do
        local upgrades = self:GetSlotListEntries(slotName)
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

    for i, spec in ipairs(layoutRows) do
        if not self.listRows[i] then
            self.listRows[i] = self:CreateListRow(i)
        end
        self:ConfigureRow(self.listRows[i], yOffset, spec.type, spec.slotName, spec.entry)
        yOffset = yOffset + ROW_HEIGHT
        rowIndex = i
    end

    for i = rowIndex + 1, #self.listRows do
        self.listRows[i]:Hide()
    end

    self.frame.scrollChild:SetHeight(math.max(yOffset, 1))
    UpdateScrollChildRect(self.frame.scroll)

    ConfigurePanelScrollBar(self.frame.scroll, self.frame.listGutter, self.frame)

    local detailVisible = self.frame.detailScroll:GetHeight() or 0
    local detailContent = self.frame.detailChild:GetHeight() or 0
    if detailContent <= detailVisible + 1 then
        self.frame.detailChild:SetHeight(detailVisible + 2)
        UpdateScrollChildRect(self.frame.detailScroll)
    end
    ConfigurePanelScrollBar(self.frame.detailScroll, self.frame.detailGutter, self.frame)

    if self.selectedHuntId and not GetHuntRecord(self.selectedHuntId) and not GQ.Data:GetEntryById(self.selectedHuntId) then
        self.selectedHuntId = nil
        self:ClearDetail()
    end
end

function GQ.Log:Show()
    if not self.frame then
        return
    end

    SetupQuestLogPortrait(self.frame)
    ApplyParchmentBackground(self.frame.detailBg)
    ConfigurePanelScrollBar(self.frame.scroll, self.frame.listGutter, self.frame)
    ConfigurePanelScrollBar(self.frame.detailScroll, self.frame.detailGutter, self.frame)

    local ok, err = pcall(function()
        self:CheckAutoCompletion()
        self:Refresh()
    end)
    if not ok then
        print("|cffff0000GearQuest log error:|r " .. tostring(err))
    end

    self.frame:Show()
end

function GQ.Log:Hide()
    self.frame:Hide()
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
