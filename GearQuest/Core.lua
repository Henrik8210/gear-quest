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
    obtained = {},
    crafted = {},
    dismissedCompleted = {},
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
        GearQuestDB.obtained = GearQuestDB.obtained or {}
        GearQuestDB.crafted = GearQuestDB.crafted or {}
        GearQuestDB.dismissedCompleted = GearQuestDB.dismissedCompleted or {}
        GearQuestDB.settings = GearQuestDB.settings or {}
        self.Preview:MigrateSettings()
        self.Data:BuildIndex()
        self.Indicator:Init()
        self.Log:Init()
        self.Toast:Init()
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
    self:CheckLevelMilestones(nil, self:GetEffectiveLevel())
    self.Log:ScheduleAutoCompletionCheck()
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

function GQ:NotifyMilestoneOnce(key, message)
    GearQuestDB.settings = GearQuestDB.settings or {}
    GearQuestDB.settings.milestones = GearQuestDB.settings.milestones or {}
    local milestones = GearQuestDB.settings.milestones

    -- Legacy key from first ring-slot message.
    if key == "ringSlot1" and milestones.ringSlots then
        milestones.ringSlot1 = true
    end

    if milestones[key] then
        return
    end

    milestones[key] = true
    print(message)
end

function GQ:CheckLevelMilestones(previousLevel, newLevel)
    -- Slot unlock messages — see docs/DATA_RULES.md § Slot unlock & level-up messages.
    if not newLevel then
        return
    end

    previousLevel = previousLevel or 0

    -- Level 9 band: one Finger entry (Minor Channeling Ring) — first ring slot.
    if newLevel >= 9 and previousLevel < 9 then
        self:NotifyMilestoneOnce(
            "ringSlot1",
            "|cff66ccffGearQuest|r: You've reached level 9 — one of your ring slots is now eligible for an upgrade! Open |cff00ff00/gq log|r to browse finger upgrades."
        )
    end

    -- Set GQ.Data.RING_SLOT_2_MILESTONE_LEVEL when a second Finger upgrade is added to Data.lua.
    local ringSlot2Level = GQ.Data and GQ.Data.RING_SLOT_2_MILESTONE_LEVEL
    if ringSlot2Level and newLevel >= ringSlot2Level and previousLevel < ringSlot2Level then
        self:NotifyMilestoneOnce(
            "ringSlot2",
            "|cff66ccffGearQuest|r: You've reached level " .. ringSlot2Level .. " — your other ring slot is now eligible for an upgrade! Open |cff00ff00/gq log|r to browse finger upgrades."
        )
    end

    -- Level 10: talent specs — log button and /gq spec filter gear lists.
    if newLevel >= 10 and previousLevel < 10 then
        if GQ.Spec and GQ.Spec.HasSpecs and GQ.Spec:HasSpecs(GQ:GetEffectiveClass()) then
            self:NotifyMilestoneOnce(
                "specSwitch",
                "|cff66ccffGearQuest|r: Congratulations — you've reached level 10! Specializations are now available in GearQuest. Open |cff00ff00/gq log|r to browse spec-specific upgrades; |cff00ff00Retribution|r is selected by default."
            )
        end
    end
end

function GQ:PLAYER_LEVEL_UP(_, newLevel)
    local previousLevel = newLevel and (newLevel - 1) or nil
    if newLevel and not self:IsPreviewEnabled() then
        self._playerLevelOverride = newLevel
    end
    self:CheckLevelMilestones(previousLevel, newLevel)
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
