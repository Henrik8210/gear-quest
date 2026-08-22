local _, GQ = ...

GQ.Preview = GQ.Preview or {}

local CLASS_ALIASES = {
    warrior = "WARRIOR",
    paladin = "PALADIN",
    hunter = "HUNTER",
    rogue = "ROGUE",
    priest = "PRIEST",
    shaman = "SHAMAN",
    mage = "MAGE",
    warlock = "WARLOCK",
    druid = "DRUID",
}

local FACTION_ALIASES = {
    alliance = "Alliance",
    horde = "Horde",
}

local function NormalizeClass(input)
    if not input or input == "" then
        return nil
    end
    input = strtrim(input):lower()
    if CLASS_ALIASES[input] then
        return CLASS_ALIASES[input]
    end
    local upper = strtrim(input):upper()
    for _, classFile in pairs(CLASS_ALIASES) do
        if classFile == upper then
            return classFile
        end
    end
end

local function NormalizeFaction(input)
    if not input or input == "" then
        return nil
    end
    input = strtrim(input):lower()
    if FACTION_ALIASES[input] then
        return FACTION_ALIASES[input]
    end
    if input == "alliance" or input == "horde" then
        return FACTION_ALIASES[input]
    end
    local title = strtrim(input):sub(1, 1):upper() .. strtrim(input):sub(2):lower()
    if title == "Alliance" or title == "Horde" then
        return title
    end
end

function GQ.Preview:MigrateSettings()
    GearQuestDB.settings = GearQuestDB.settings or {}
    local settings = GearQuestDB.settings

    if settings.debugAsHunter37 ~= nil then
        settings.preview = settings.preview or {}
        if settings.preview.enabled == nil then
            settings.preview.enabled = settings.debugAsHunter37
        end
        settings.debugAsHunter37 = nil
    end
end

function GQ.Preview:GetSettings()
    self:MigrateSettings()
    GearQuestDB.settings.preview = GearQuestDB.settings.preview or {}

    local preview = GearQuestDB.settings.preview
    if preview.enabled == nil then
        preview.enabled = false
    end
    if not preview.class then
        preview.class = "PALADIN"
    end
    if not preview.level then
        preview.level = 4
    end
    if not preview.faction then
        local faction = UnitFactionGroup("player")
        preview.faction = faction or "Alliance"
    end

    return preview
end

function GQ.Preview:IsEnabled()
    return self:GetSettings().enabled
end

function GQ.Preview:SetEnabled(enabled)
    self:GetSettings().enabled = enabled
end

function GQ.Preview:SetClass(classFile)
    local normalized = NormalizeClass(classFile)
    if not normalized then
        return false, "Unknown class. Use: warrior, paladin, hunter, rogue, priest, shaman, mage, warlock, druid."
    end
    self:GetSettings().class = normalized
    return true
end

function GQ.Preview:SetLevel(level)
    local previousLevel = self:GetSettings().level
    level = tonumber(level)
    if not level or level < 1 or level > 70 then
        return false, "Level must be a number between 1 and 70."
    end
    level = math.floor(level)
    self:GetSettings().level = level
    if GQ.CheckLevelMilestones then
        GQ:CheckLevelMilestones(previousLevel, level)
    end
    return true
end

function GQ.Preview:SetFaction(faction)
    local normalized = NormalizeFaction(faction)
    if not normalized then
        return false, "Unknown faction. Use: alliance or horde."
    end
    self:GetSettings().faction = normalized
    return true
end

function GQ.Preview:ApplyCurrentCharacter()
    local _, classFile = UnitClass("player")
    local level = UnitLevel("player")
    local faction = UnitFactionGroup("player") or "Alliance"
    local preview = self:GetSettings()
    preview.enabled = true
    preview.class = classFile
    preview.level = level
    preview.faction = faction
end

function GQ.Preview:GetEffectiveClass()
    if self:IsEnabled() then
        return self:GetSettings().class
    end
    local _, classFile = UnitClass("player")
    return classFile
end

function GQ.Preview:GetEffectiveLevel()
    if self:IsEnabled() then
        return self:GetSettings().level
    end
    return UnitLevel("player")
end

function GQ.Preview:GetEffectiveFaction()
    if self:IsEnabled() then
        return self:GetSettings().faction
    end
    return UnitFactionGroup("player") or "Alliance"
end

function GQ.Preview:GetEffectiveSpec()
    if GQ.Spec and GQ.Spec.GetEffectiveSpec then
        return GQ.Spec:GetEffectiveSpec()
    end
    return nil
end

function GQ.Preview:GetLabel()
    if not self:IsEnabled() then
        return "using your character"
    end
    local preview = self:GetSettings()
    return string.format(
        "preview: lvl %d %s (%s)",
        preview.level,
        self:FormatClassName(preview.class),
        preview.faction
    )
end

function GQ.Preview:FormatClassName(classFile)
    return classFile:sub(1, 1) .. classFile:sub(2):lower()
end

function GQ.Preview:PrintNowViewing()
    if not self:IsEnabled() then
        local _, classFile = UnitClass("player")
        local specSuffix = ""
        if GQ.Spec and GQ.Spec.IsActive and GQ.Spec:IsActive() then
            specSuffix = string.format(", %s", GQ.Spec:GetSelectedSpecLabel())
        end
        print(string.format(
            "|cff66ccffGearQuest|r: Now viewing upgrades as |cff00ff00your character|r — level %d %s (%s%s).",
            UnitLevel("player"),
            self:FormatClassName(classFile),
            UnitFactionGroup("player") or "?",
            specSuffix
        ))
        return
    end

    local preview = self:GetSettings()
    local specSuffix = ""
    if GQ.Spec and GQ.Spec.IsActive and GQ.Spec:IsActive() then
        specSuffix = string.format(", %s", GQ.Spec:GetSelectedSpecLabel())
    end
    print(string.format(
        "|cff66ccffGearQuest|r: Now viewing upgrades as a |cff00ff00level %d %s|r (%s%s).",
        preview.level,
        self:FormatClassName(preview.class),
        preview.faction,
        specSuffix
    ))
end

function GQ.Preview:PrintHelp()
    print("|cff66ccffGearQuest|r commands:")
    print("  |cff00ff00/gq set|r — show preview settings")
    print("  |cff00ff00/gq class hunter|r — set preview class")
    print("  |cff00ff00/gq level 37|r — set preview level")
    print("  |cff00ff00/gq faction alliance|r — set preview faction")
    print("  |cff00ff00/gq set on|r / |cff00ff00/gq set off|r — enable or disable preview")
    print("  |cff00ff00/gq set me|r — copy your real character into preview")
    print("  |cff00ff00/gq spec holy|r — set specialization (level 10+, paladin)")
    print("  |cff00ff00/gq log|r — toggle GearQuest log window")
    print("  |cff00ff00/gq wipe data|r — reset hunt progress (for testing obtain/toast)")
end

function GQ.Preview:PrintStatus()
    local preview = self:GetSettings()
    if preview.enabled then
        print(string.format(
            "|cff66ccffGearQuest|r preview |cff00ff00on|r — level %d, %s, %s.",
            preview.level,
            preview.class,
            preview.faction
        ))
    else
        local _, classFile = UnitClass("player")
        print(string.format(
            "|cff66ccffGearQuest|r preview |cff888888off|r — using your character (lvl %d %s, %s).",
            UnitLevel("player"),
            classFile,
            UnitFactionGroup("player") or "?"
        ))
    end
    self:PrintHelp()
end

function GQ.Preview:HandleCommand(msg)
    msg = strtrim(msg:lower())

    if msg == "debug" then
        self:SetEnabled(not self:IsEnabled())
        self:PrintNowViewing()
        return
    end

    if msg == "set" then
        self:PrintStatus()
        self:PrintNowViewing()
        return
    end

    if msg == "status" or msg == "preview" then
        self:PrintStatus()
        self:PrintNowViewing()
        return
    end

    if msg == "me" then
        self:ApplyCurrentCharacter()
        self:PrintNowViewing()
        return
    end

    local rest = msg:match("^set%s+(.*)$") or msg
    rest = strtrim(rest)

    if rest == "" or rest == "show" or rest == "status" then
        self:PrintStatus()
        self:PrintNowViewing()
        return
    end

    if rest == "on" then
        self:SetEnabled(true)
        self:PrintNowViewing()
        return
    end

    if rest == "off" then
        self:SetEnabled(false)
        self:PrintNowViewing()
        return
    end

    if rest == "me" or rest == "char" or rest == "character" then
        self:ApplyCurrentCharacter()
        self:PrintNowViewing()
        return
    end

    local key, value = rest:match("^(%S+)%s+(.+)$")
    if not key then
        self:PrintStatus()
        return
    end

    key = key:lower()
    value = strtrim(value)

    if key == "class" then
        local ok, err = self:SetClass(value)
        if ok then
            self:PrintNowViewing()
        else
            print("|cff66ccffGearQuest|r: " .. err)
        end
        return
    end

    if key == "level" or key == "lvl" then
        local ok, err = self:SetLevel(value)
        if ok then
            self:PrintNowViewing()
            if GQ.RefreshUI then
                GQ:RefreshUI()
            end
        else
            print("|cff66ccffGearQuest|r: " .. err)
        end
        return
    end

    if key == "faction" then
        local ok, err = self:SetFaction(value)
        if ok then
            self:PrintNowViewing()
            if GQ.RefreshUI then
                GQ:RefreshUI()
            end
        else
            print("|cff66ccffGearQuest|r: " .. err)
        end
        return
    end

    if key == "spec" or key == "specialization" or key == "talent" then
        if GQ.Spec and GQ.Spec.SetSelectedSpec then
            local ok, err = GQ.Spec:SetSelectedSpec(value)
            if ok then
                print(string.format(
                    "|cff66ccffGearQuest|r: Now viewing |cff00ff00%s|r upgrades.",
                    GQ.Spec:GetSelectedSpecLabel()
                ))
            else
                print("|cff66ccffGearQuest|r: " .. (err or "Could not set specialization."))
            end
        end
        return
    end

    self:PrintStatus()
end

-- Backwards-compatible helpers used elsewhere in the addon.
function GQ:IsPreviewEnabled()
    return self.Preview:IsEnabled()
end

function GQ:GetEffectiveClass()
    return self.Preview:GetEffectiveClass()
end

function GQ:GetEffectiveFaction()
    return self.Preview:GetEffectiveFaction()
end

function GQ:GetEffectiveSpec()
    return self.Preview:GetEffectiveSpec()
end

function GQ:GetPreviewLabel()
    return self.Preview:GetLabel()
end
