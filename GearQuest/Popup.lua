local _, GQ = ...

GQ.Popup = GQ.Popup or {}

local MAX_OPTIONS = 3
local ICON_GAP = 4
local SLOT_GAP = 4
local BAR_PAD = 5
local DEFAULT_ICON_SIZE = 37

local function GetSlotIconSize(slotButton)
    local size = slotButton and math.floor(slotButton:GetWidth() + 0.5) or 0
    if size < 1 then
        size = DEFAULT_ICON_SIZE
    end
    return size
end

local function CreateUpgradeIcon(parent, index)
    local btn = CreateFrame("Button", "GearQuestUpgradeIcon" .. index, parent)
    btn:Hide()

    btn.bg = btn:CreateTexture(nil, "BACKGROUND")
    btn.bg:SetAllPoints()
    btn.bg:SetTexture("Interface\\Buttons\\UI-EmptySlot")

    btn.icon = btn:CreateTexture(nil, "ARTWORK")
    btn.icon:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -2)
    btn.icon:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 2)

    btn.border = btn:CreateTexture(nil, "OVERLAY")
    btn.border:SetPoint("TOPLEFT", btn, "TOPLEFT", -1, 1)
    btn.border:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 1, -1)
    btn.border:SetTexture("Interface\\Common\\WhiteIconFrame")

    btn.highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    btn.highlight:SetAllPoints()
    btn.highlight:SetColorTexture(1, 1, 1, 0.18)

    btn:SetScript("OnEnter", function(self)
        if not self.entry then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink("item:" .. self.entry.itemId)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(GQ:GetSourceTag(self.entry.sourceType), 1, 1, 1)
        GameTooltip:AddLine("Click to track this upgrade in GearQuest.", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)

    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    btn:SetScript("OnClick", function(self)
        if not self.entry then
            return
        end
        GQ.Log:ActivateHunt(self.entry.id)
        GQ.Popup:Hide()
        GQ.Log:Show()
        GQ.Log:SelectHunt(self.entry.id)
    end)

    return btn
end

function GQ.Popup:Init()
    local parent = CharacterFrame or UIParent
    local container = CreateFrame("Frame", "GearQuestSlotPopup", parent)
    container:SetFrameStrata("HIGH")
    if CharacterFrame then
        container:SetFrameLevel(CharacterFrame:GetFrameLevel() + 10)
    end
    container:Hide()

    local bar = CreateFrame("Frame", "GearQuestUpgradeBar", container)
    bar:Hide()
    if bar.SetBackdrop then
        bar:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        bar:SetBackdropColor(0.05, 0.05, 0.05, 0.88)
        bar:SetBackdropBorderColor(0.4, 0.35, 0.25, 1)
    else
        local bg = bar:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.05, 0.05, 0.05, 0.88)
    end

    container.bar = bar
    container.icons = {}
    for i = 1, MAX_OPTIONS do
        container.icons[i] = CreateUpgradeIcon(bar, i)
    end

    self.container = container
    self.activeSlotName = nil
    self.activeSlotButton = nil
    self.pendingItemIds = {}

    local refreshFrame = CreateFrame("Frame")
    refreshFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    refreshFrame:SetScript("OnEvent", function()
        if GQ.Popup.container:IsShown() then
            GQ.Popup:RefreshIcons()
        end
    end)

    if CharacterFrame and CharacterFrame.HookScript then
        CharacterFrame:HookScript("OnHide", function()
            GQ.Popup:Hide()
        end)
    end
end

function GQ.Popup:PositionBar(slotButton, count)
    local iconSize = GetSlotIconSize(slotButton)
    local barWidth = (BAR_PAD * 2) + (count * iconSize) + ((count - 1) * ICON_GAP)
    local barHeight = iconSize + (BAR_PAD * 2)

    self.container.bar:SetSize(barWidth, barHeight)
    -- Bar sits to the right of the slot; icons read left -> right (best first).
    self.container.bar:ClearAllPoints()
    self.container.bar:SetPoint("LEFT", slotButton, "RIGHT", SLOT_GAP, 0)

    for i = 1, MAX_OPTIONS do
        local icon = self.container.icons[i]
        icon:SetSize(iconSize, iconSize)
        icon:ClearAllPoints()
        if i <= count then
            local x = BAR_PAD + (i - 1) * (iconSize + ICON_GAP)
            icon:SetPoint("TOPLEFT", self.container.bar, "TOPLEFT", x, -BAR_PAD)
        end
    end
end

function GQ.Popup:ApplyIconData(icon, entry)
    icon.entry = entry
    local _, _, quality, _, _, _, _, _, _, texture = GetItemInfo(entry.itemId)
    if not texture then
        GetItemInfo(entry.itemId)
    end

    icon.icon:SetTexture(texture or "Interface\\Icons\\INV_Misc_QuestionMark")

    local r, g, b = GetItemQualityColor(quality or 1)
    icon.border:SetVertexColor(r, g, b)
end

function GQ.Popup:RefreshIcons()
    if not self.container:IsShown() or not self.currentUpgrades then
        return
    end

    for i, entry in ipairs(self.currentUpgrades) do
        local icon = self.container.icons[i]
        if icon and icon:IsShown() then
            self:ApplyIconData(icon, entry)
        end
    end
end

function GQ.Popup:Hide()
    self.container:Hide()
    self.container.bar:Hide()
    for i = 1, MAX_OPTIONS do
        self.container.icons[i]:Hide()
        self.container.icons[i].entry = nil
    end
    self.activeSlotName = nil
    self.activeSlotButton = nil
    self.currentUpgrades = nil
    self.pendingItemIds = {}
end

function GQ.Popup:ShowForSlot(slotName, slotButton)
    if self.activeSlotName == slotName and self.container:IsShown() then
        self:Hide()
        return
    end

    local slotLabel = slotName:gsub("(%l)(%u)", "%1 %2")
    local candidates = GQ.Data:GetCandidatesForSlot(slotName)
    local upgrades = select(1, GQ.Compare:RankEntries(candidates, slotName, MAX_OPTIONS))

    if #upgrades == 0 then
        self:Hide()
        local hint = GQ:IsPreviewEnabled() and "" or " Try |cff00ff00/gq set|r to configure class, level, and faction."
        print("|cff66ccffGearQuest|r: No upgrade hunts found for " .. slotLabel .. "." .. hint)
        return
    end

    self.activeSlotName = slotName
    self.activeSlotButton = slotButton
    self.currentUpgrades = upgrades
    self.pendingItemIds = {}

    self:PositionBar(slotButton, #upgrades)

    for i = 1, MAX_OPTIONS do
        local icon = self.container.icons[i]
        local entry = upgrades[i]
        if entry then
            self:ApplyIconData(icon, entry)
            icon:Show()
        else
            icon.entry = nil
            icon:Hide()
        end
    end

    self.container.bar:Show()
    self.container:Show()
end

function GQ.Popup:Toggle()
    if self.container:IsShown() then
        self:Hide()
    end
end
