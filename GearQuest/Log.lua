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
local DETAIL_TEXT_COLOR = { 0.13, 0.09, 0.04 }
local DETAIL_TEXT_HEX = "21160a"

local function GetHuntRecord(id)
    GearQuestDB.hunts = GearQuestDB.hunts or {}
    return GearQuestDB.hunts[id]
end

local function EnsureHuntRecord(id)
    GearQuestDB.hunts = GearQuestDB.hunts or {}
    if not GearQuestDB.hunts[id] then
        GearQuestDB.hunts[id] = {
            status = "active",
            acceptedAt = time(),
        }
    end
    return GearQuestDB.hunts[id]
end

local function GetHuntStatus(id)
    local record = GetHuntRecord(id)
    if not record then
        return "available"
    end
    return record.status or "active"
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

local function EnableClipping(frame)
    if frame and frame.SetClipsChildren then
        frame:SetClipsChildren(true)
    end
end

local function ConfigurePanelScrollBar(scroll, show)
    if not scroll or not scroll.GetName then
        return
    end
    local scrollBar = _G[scroll:GetName() .. "ScrollBar"]
    if not scrollBar then
        return
    end
    scrollBar:ClearAllPoints()
    scrollBar:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", 2, -16)
    scrollBar:SetPoint("BOTTOMRIGHT", scroll, "BOTTOMRIGHT", 2, 16)
    if show then
        scrollBar:Show()
    else
        scrollBar:Hide()
    end
end

local function CreatePanelScrollFrame(name, parent)
    local scrollOk, scroll = pcall(CreateFrame, "ScrollFrame", name, parent, "UIPanelScrollFrameTemplate")
    if not scrollOk or not scroll then
        scroll = CreateFrame("ScrollFrame", name, parent)
    end
    EnableClipping(scroll)

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
    GearQuestDB.ui = GearQuestDB.ui or {}
    GearQuestDB.ui.collapsedSlots = GearQuestDB.ui.collapsedSlots or {}

    if GearQuestDB.ui.collapsedSlots[slotName] ~= nil then
        return GearQuestDB.ui.collapsedSlots[slotName]
    end

    -- Empty slots start collapsed so the list fits the upper pane.
    local upgrades = GQ.Data:GetTopUpgradesForSlot(slotName, 1)
    return #upgrades == 0
end

function GQ.Log:SetSlotCollapsed(slotName, collapsed)
    GearQuestDB.ui = GearQuestDB.ui or {}
    GearQuestDB.ui.collapsedSlots = GearQuestDB.ui.collapsedSlots or {}
    GearQuestDB.ui.collapsedSlots[slotName] = collapsed
end

function GQ.Log:ToggleSlotCollapsed(slotName)
    self:SetSlotCollapsed(slotName, not self:IsSlotCollapsed(slotName))
    self:Refresh()
end

function GQ.Log:ActivateHunt(id)
    local entry = GQ.Data:GetEntryById(id)
    if not entry then
        return
    end

    EnsureHuntRecord(id)
    print("|cff66ccffGearQuest|r: Hunt accepted — " .. (GetItemInfo(entry.itemId) or ("Item " .. entry.itemId)))
    self:Refresh()
end

function GQ.Log:CompleteHunt(id)
    local record = GetHuntRecord(id)
    if record then
        record.status = "completed"
        record.completedAt = time()
        self:Refresh()
    end
end

function GQ.Log:AbandonHunt(id)
    GearQuestDB.hunts[id] = nil
    if self.selectedHuntId == id then
        self.selectedHuntId = nil
        self:ClearDetail()
    end
    self:Refresh()
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

function GQ.Log:Init()
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
    frame.listInset:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -HEADER_OFFSET)
    frame.listInset:SetSize(FRAME_WIDTH - 18 - 28, LIST_SECTION_HEIGHT)
    EnableClipping(frame.listInset)
    ApplyBlackBackground(frame.listInset)
    if frame.listInset.SetBackdrop then
        frame.listInset:SetBackdrop({
            bgFile = nil,
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
    end

    frame.scroll = CreatePanelScrollFrame("GearQuestLogListScrollFrame", frame.listInset)
    frame.scroll:SetPoint("TOPLEFT", frame.listInset, "TOPLEFT", 6, -6)
    frame.scroll:SetPoint("BOTTOMRIGHT", frame.listInset, "BOTTOMRIGHT", -24, 6)

    frame.scrollChild = CreateFrame("Frame", "GearQuestLogListScrollChild", frame.scroll)
    frame.scrollChild:SetWidth(300)
    frame.scrollChild:SetHeight(1)
    frame.scroll:SetScrollChild(frame.scrollChild)

    frame.detailBg = CreateFrame("Frame", nil, frame)
    frame.detailBg:SetPoint("TOPLEFT", frame.listInset, "BOTTOMLEFT", 0, -4)
    frame.detailBg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -28, FOOTER_OFFSET)
    EnableClipping(frame.detailBg)
    ApplyParchmentBackground(frame.detailBg)

    frame.detailScroll = CreatePanelScrollFrame("GearQuestLogDetailScrollFrame", frame.detailBg)
    frame.detailScroll:SetPoint("TOPLEFT", frame.detailBg, "TOPLEFT", 8, -8)
    frame.detailScroll:SetPoint("BOTTOMRIGHT", frame.detailBg, "BOTTOMRIGHT", -24, 8)
    frame.detailScroll:SetFrameLevel(frame.detailBg:GetFrameLevel() + 2)

    frame.detailChild = CreateFrame("Frame", "GearQuestLogDetailScrollChild", frame.detailScroll)
    frame.detailChild:SetWidth(260)
    frame.detailScroll:SetScrollChild(frame.detailChild)

    frame.detailTitle = CreateFontStringWithFallback(frame.detailChild, {
        "QuestFont", "GameFontHighlight", "GameFontNormal",
    })
    frame.detailTitle:SetPoint("TOPLEFT", frame.detailChild, "TOPLEFT", 8, -8)
    frame.detailTitle:SetPoint("RIGHT", frame.detailChild, "RIGHT", -8, 0)
    frame.detailTitle:SetJustifyH("LEFT")
    frame.detailTitle:SetTextColor(DETAIL_TEXT_COLOR[1], DETAIL_TEXT_COLOR[2], DETAIL_TEXT_COLOR[3])

    frame.detailHeader = CreateFontStringWithFallback(frame.detailChild, { "GameFontNormal" })
    frame.detailHeader:SetPoint("TOPLEFT", frame.detailTitle, "BOTTOMLEFT", 0, -12)
    frame.detailHeader:SetText("DESCRIPTION")
    frame.detailHeader:SetTextColor(DETAIL_TEXT_COLOR[1], DETAIL_TEXT_COLOR[2], DETAIL_TEXT_COLOR[3])

    frame.detailBody = CreateFontStringWithFallback(frame.detailChild, {
        "QuestFont", "GameFontHighlight", "GameFontNormal",
    })
    frame.detailBody:SetPoint("TOPLEFT", frame.detailHeader, "BOTTOMLEFT", 0, -8)
    frame.detailBody:SetPoint("RIGHT", frame.detailChild, "RIGHT", -8, 0)
    frame.detailBody:SetJustifyH("LEFT")
    frame.detailBody:SetWordWrap(true)
    frame.detailBody:SetTextColor(DETAIL_TEXT_COLOR[1], DETAIL_TEXT_COLOR[2], DETAIL_TEXT_COLOR[3])

    frame.detailEmpty = CreateFontStringWithFallback(frame.detailChild, {
        "QuestFont", "GameFontHighlight", "GameFontNormal",
    })
    frame.detailEmpty:SetPoint("TOPLEFT", frame.detailChild, "TOPLEFT", 8, -8)
    frame.detailEmpty:SetText("Select an upgrade to see how to get it.")
    frame.detailEmpty:SetTextColor(DETAIL_TEXT_COLOR[1], DETAIL_TEXT_COLOR[2], DETAIL_TEXT_COLOR[3])
    frame.detailEmpty:Show()

    frame.abandonBtn = CreateFrame("Button", "GearQuestLogAbandonButton", frame, "UIPanelButtonTemplate")
    frame.abandonBtn:SetSize(106, 22)
    frame.abandonBtn:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 18, 12)
    frame.abandonBtn:SetText("Abandon")

    frame.completeBtn = CreateFrame("Button", "GearQuestLogCompleteButton", frame, "UIPanelButtonTemplate")
    frame.completeBtn:SetSize(106, 22)
    frame.completeBtn:SetPoint("LEFT", frame.abandonBtn, "RIGHT", 2, 0)
    frame.completeBtn:SetText("Complete")

    frame.exitBtn = CreateFrame("Button", "GearQuestLogExitButton", frame, "UIPanelButtonTemplate")
    frame.exitBtn:SetSize(106, 22)
    frame.exitBtn:SetPoint("LEFT", frame.completeBtn, "RIGHT", 2, 0)
    frame.exitBtn:SetText("Exit")

    frame.abandonBtn:SetScript("OnClick", function()
        if GQ.Log.selectedHuntId then
            GQ.Log:AbandonHunt(GQ.Log.selectedHuntId)
        end
    end)

    frame.completeBtn:SetScript("OnClick", function()
        if GQ.Log.selectedHuntId then
            GQ.Log:CompleteHunt(GQ.Log.selectedHuntId)
        end
    end)

    frame.exitBtn:SetScript("OnClick", function()
        GQ.Log:Hide()
    end)

    self.listRows = {}
    self.frame = frame
    self.selectedHuntId = nil
    self:ClearDetail()
end

function GQ.Log:ClearDetail()
    if not self.frame then
        return
    end
    self.frame.detailTitle:SetText("")
    self.frame.detailBody:SetText("")
    self.frame.detailEmpty:Show()
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
            GQ.Log:ToggleSlotCollapsed(slotName)
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
        elseif status == "active" then
            row.text:SetText(name .. " |cff00ff00(Active)|r")
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
            GQ.Log:SelectHunt(entry.id)
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

    self.frame.detailEmpty:Hide()
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

    local status = GetHuntStatus(entry.id)
    if status == "completed" then
        table.insert(lines, "\n|cff888888Status: Completed|r")
    elseif status == "active" then
        table.insert(lines, "\n|cff00ff00Status: Active hunt|r")
    end

    self.frame.detailBody:SetText(table.concat(lines, "\n"))

    local bodyHeight = self.frame.detailBody:GetStringHeight() + 80
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
        local upgrades = GQ.Data:GetTopUpgradesForSlot(slotName, 3)
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

    local listVisible = self.frame.scroll:GetHeight() or 0
    ConfigurePanelScrollBar(self.frame.scroll, yOffset > listVisible + 1)

    local detailVisible = self.frame.detailScroll:GetHeight() or 0
    local detailContent = self.frame.detailChild:GetHeight() or 0
    ConfigurePanelScrollBar(self.frame.detailScroll, detailContent > detailVisible + 1)

    if self.selectedHuntId and not GetHuntRecord(self.selectedHuntId) and not GQ.Data:GetEntryById(self.selectedHuntId) then
        self.selectedHuntId = nil
        self:ClearDetail()
    end
end

function GQ.Log:Show()
    SetupQuestLogPortrait(self.frame)
    ApplyParchmentBackground(self.frame.detailBg)
    self:Refresh()
    self.frame:Show()
end

function GQ.Log:Hide()
    self.frame:Hide()
end

function GQ.Log:Toggle()
    if self.frame:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end
