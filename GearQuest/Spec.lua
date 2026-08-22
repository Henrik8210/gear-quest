local _, GQ = ...

GQ.Spec = GQ.Spec or {}

GQ.Spec.TALENT_LEVEL = 10

-- classFile -> ordered spec options (id, label, default for leveling BiS)
GQ.Spec.CLASS_SPECS = {
    PALADIN = {
        { id = "retribution", label = "Retribution", icon = "Interface\\Icons\\Spell_Holy_AuraOfLight", default = true },
        { id = "holy", label = "Holy", icon = "Interface\\Icons\\Spell_Holy_HolyBolt", comingLater = true },
        { id = "protection", label = "Protection", icon = "Interface\\Icons\\Spell_Holy_DevotionAura", comingLater = true },
    },
}

local PALADIN_SPEC_BY_TAB = {
    [1] = "holy",
    [2] = "protection",
    [3] = "retribution",
}

function GQ.Spec:GetOptions(classFile)
    return self.CLASS_SPECS[classFile]
end

function GQ.Spec:HasSpecs(classFile)
    classFile = classFile or GQ:GetEffectiveClass()
    return self.CLASS_SPECS[classFile] ~= nil
end

function GQ.Spec:IsActive()
    return GQ:GetEffectiveLevel() >= self.TALENT_LEVEL and self:HasSpecs()
end

function GQ.Spec:GetDefaultSpec(classFile)
    local options = self:GetOptions(classFile)
    if not options then
        return nil
    end

    for _, opt in ipairs(options) do
        if opt.default then
            return opt.id
        end
    end

    return options[1] and options[1].id
end

function GQ.Spec:GetSpecOption(specId, classFile)
    classFile = classFile or GQ:GetEffectiveClass()
    for _, opt in ipairs(self:GetOptions(classFile) or {}) do
        if opt.id == specId then
            return opt
        end
    end
end

function GQ.Spec:IsSpecSelectable(specId, classFile)
    local opt = self:GetSpecOption(specId, classFile)
    return opt ~= nil and not opt.comingLater
end

function GQ.Spec:GetSpecLabel(specId, classFile)
    classFile = classFile or GQ:GetEffectiveClass()
    local options = self:GetOptions(classFile)
    if not options or not specId then
        return nil
    end

    for _, opt in ipairs(options) do
        if opt.id == specId then
            return opt.label
        end
    end
end

function GQ.Spec:GetSpecIcon(specId, classFile)
    classFile = classFile or GQ:GetEffectiveClass()
    local options = self:GetOptions(classFile)
    if options and specId then
        for _, opt in ipairs(options) do
            if opt.id == specId and opt.icon then
                return opt.icon
            end
        end
    end

    if classFile == "PALADIN" and GetTalentTabInfo then
        local tabBySpec = { holy = 1, protection = 2, retribution = 3 }
        local tab = tabBySpec[specId]
        if tab then
            local _, _, _, icon = GetTalentTabInfo(tab)
            if icon then
                return icon
            end
        end
    end

    return "Interface\\Icons\\INV_Misc_QuestionMark"
end

function GQ.Spec:GetSavedSpec(classFile)
    classFile = classFile or GQ:GetEffectiveClass()
    GearQuestDB.settings = GearQuestDB.settings or {}
    GearQuestDB.settings.specByClass = GearQuestDB.settings.specByClass or {}
    return GearQuestDB.settings.specByClass[classFile]
end

function GQ.Spec:SetSelectedSpec(specId, classFile)
    classFile = classFile or GQ:GetEffectiveClass()
    local options = self:GetOptions(classFile)
    if not options then
        return false, "This class has no specialization options in GearQuest yet."
    end

    specId = strtrim((specId or ""):lower())
    local aliases = {
        ret = "retribution",
        holy = "holy",
        prot = "protection",
        protection = "protection",
        retribution = "retribution",
    }
    specId = aliases[specId] or specId
    local matched
    for _, opt in ipairs(options) do
        if opt.id == specId then
            matched = opt
            break
        end
    end

    if not matched then
        local names = {}
        for _, opt in ipairs(options) do
            if self:IsSpecSelectable(opt.id, classFile) then
                table.insert(names, opt.id)
            end
        end
        return false, "Unknown spec. Use: " .. table.concat(names, ", ")
    end

    if not self:IsSpecSelectable(matched.id, classFile) then
        return false, matched.label .. " is coming later."
    end

    GearQuestDB.settings = GearQuestDB.settings or {}
    GearQuestDB.settings.specByClass = GearQuestDB.settings.specByClass or {}
    GearQuestDB.settings.specByClass[classFile] = matched.id

    if GQ.RefreshUI then
        GQ:RefreshUI()
    end

    return true
end

function GQ.Spec:DetectSpecFromTalents(classFile)
    if classFile ~= "PALADIN" or not GetTalentTabInfo then
        return nil
    end

    local bestTab, bestPoints = nil, 0
    for tab = 1, 3 do
        local _, _, points = GetTalentTabInfo(tab)
        points = points or 0
        if points > bestPoints then
            bestPoints = points
            bestTab = tab
        end
    end

    if bestTab and bestPoints > 0 then
        return PALADIN_SPEC_BY_TAB[bestTab]
    end

    return nil
end

function GQ.Spec:GetEffectiveSpec()
    local level = GQ:GetEffectiveLevel()
    if level < self.TALENT_LEVEL then
        return nil
    end

    local classFile = GQ:GetEffectiveClass()
    if not self:HasSpecs(classFile) then
        return nil
    end

    local spec

    local saved = self:GetSavedSpec(classFile)
    if saved and self:IsSpecSelectable(saved, classFile) then
        spec = saved
    end

    if not spec and not GQ:IsPreviewEnabled() then
        local fromTalents = self:DetectSpecFromTalents(classFile)
        if fromTalents and self:IsSpecSelectable(fromTalents, classFile) then
            spec = fromTalents
        end
    end

    if not spec then
        spec = self:GetDefaultSpec(classFile)
    end

    return spec
end

function GQ.Spec:GetSelectedSpecLabel()
    local classFile = GQ:GetEffectiveClass()
    local specId = self:GetEffectiveSpec()
    return self:GetSpecLabel(specId, classFile) or "Specialization"
end
