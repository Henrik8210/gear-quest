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
    vendor = "Vendor",
    auction_house = "Auction House",
}

local SOURCE_COLORS = {
    world_drop = "|cff66ccff",
    boss_drop = "|cffff4444",
    quest_reward = "|cff00ff00",
    vendor = "|cffffcc00",
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
        self.Log:Init()
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

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function()
    GQ:PLAYER_LOGIN()
end)
