local ADDON_NAME, GQ = ...

if not strtrim then
    function strtrim(s)
        return (s:gsub("^%s*(.-)%s*$", "%1"))
    end
end

GQ = GQ or {}
_G.GearQuest = GQ

GQ.VERSION = "0.1.0"
GQ.ADDON_NAME = ADDON_NAME

GearQuestDB = GearQuestDB or {
    hunts = {},
    settings = {},
}

local SOURCE_LABELS = {
    world_drop = "World drop",
    boss_drop = "Boss drop",
    quest_reward = "Quest reward",
    seasonal_quest = "Seasonal quest",
    vendor = "Vendor",
    profession = "Profession",
    auction_house = "Auction House",
}

local SOURCE_COLORS = {
    world_drop = "|cff66ccff",
    boss_drop = "|cffff4444",
    quest_reward = "|cff00ff00",
    seasonal_quest = "|cffff8800",
    vendor = "|cffffcc00",
    profession = "|cffcc66ff",
    auction_house = "|cffffa500",
}

function GQ:GetSourceLabel(sourceType)
    return SOURCE_LABELS[sourceType] or sourceType
end

function GQ:GetSourceTag(sourceType)
    local color = SOURCE_COLORS[sourceType] or "|cffcccccc"
    return color .. (SOURCE_LABELS[sourceType] or sourceType) .. "|r"
end

function GQ:PLAYER_LOGIN()
    local ok, err = pcall(function()
        GearQuestDB.hunts = GearQuestDB.hunts or {}
        GearQuestDB.settings = GearQuestDB.settings or {}
        self.Preview:MigrateSettings()
        self.Data:BuildIndex()
        self.Indicator:Init()
        self.Log:Init()
        self.Tracker:Init()
        self.Popup:Init()
        self.PaperDoll:Init()
        self.Minimap:Init()
        self.Commands:Init()
    end)

    if not ok then
        print("|cffff0000GearQuest failed to load:|r " .. tostring(err))
        return
    end

    local previewNote = self.Preview:IsEnabled() and (" (" .. self:GetPreviewLabel() .. ")") or ""
    print("|cff66ccffGearQuest|r v" .. self.VERSION .. " loaded" .. previewNote .. ". Right-click a gear slot on your character panel, or |cff00ff00/gq|r.")
    print("|cff66ccffGearQuest|r: Configure test character with |cff00ff00/gq set|r (class, level, faction).")
end

function GQ:SyncLevelOverride()
    if not self._playerLevelOverride then
        return
    end
    if self:IsPreviewEnabled() then
        self._playerLevelOverride = nil
        return
    end
    local actual = UnitLevel("player")
    if actual and actual >= self._playerLevelOverride then
        self._playerLevelOverride = nil
    end
end

function GQ:GetEffectiveLevel()
    self:SyncLevelOverride()
    if self._playerLevelOverride and not self:IsPreviewEnabled() then
        return self._playerLevelOverride
    end
    return self.Preview:GetEffectiveLevel()
end

function GQ:RefreshUI()
    if self.Indicator then
        pcall(function()
            self.Indicator:RebuildCache()
            self.Indicator:RefreshAll()
        end)
    end

    if self.Log and self.Log.frame and self.Log.frame:IsShown() then
        pcall(function()
            self.Log:Refresh()
        end)
    end

    if self.Popup and self.Popup.container and self.Popup.container:IsShown() then
        pcall(function()
            if self.Popup.activeSlotName and self.Popup.activeSlotButton then
                self.Popup:ShowForSlot(self.Popup.activeSlotName, self.Popup.activeSlotButton)
            else
                self.Popup:Hide()
            end
        end)
    end

    if self.Tracker then
        pcall(function()
            self.Tracker:Refresh()
        end)
    end
end

function GQ:PLAYER_LEVEL_UP(_, newLevel)
    if newLevel and not self:IsPreviewEnabled() then
        self._playerLevelOverride = newLevel
    end
    self:RefreshUI()
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        GQ:PLAYER_LOGIN()
    elseif event == "PLAYER_LEVEL_UP" then
        GQ:PLAYER_LEVEL_UP(event, ...)
    end
end)
