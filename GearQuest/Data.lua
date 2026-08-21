local _, GQ = ...

GQ.Data = GQ.Data or {}

-- Static gear quests: pre-made entries, not generated at runtime.
-- MVP: Main Hand weapons for Hunter, levels 30-45 (TBC Anniversary / Classic).

GQ.Data.entries = {
    {
        id = "hunter_mainhand_rockpiercer",
        itemId = 9411,
        slot = "MainHand",
        minLevel = 36,
        maxLevel = 45,
        classes = { HUNTER = true },
        sourceType = "boss_drop",
        instructions = "Form a group and clear Uldaman. Baelog guards the treasure room — defeat him for a chance at Rockpiercer.",
        zone = "Uldaman",
        npc = "Baelog",
    },
    {
        id = "hunter_mainhand_galgann",
        itemId = 9419,
        slot = "MainHand",
        minLevel = 36,
        maxLevel = 45,
        classes = { HUNTER = true },
        sourceType = "boss_drop",
        instructions = "Run Uldaman and defeat Galgann Firehammer in the Stone Chamber for Galgann's Firehammer.",
        zone = "Uldaman",
        npc = "Galgann Firehammer",
    },
    {
        id = "hunter_mainhand_stonevault",
        itemId = 9378,
        slot = "MainHand",
        minLevel = 36,
        maxLevel = 45,
        classes = { HUNTER = true },
        sourceType = "boss_drop",
        instructions = "Form a group for Uldaman. The Ancient Stone Keeper drops Stonevault Shiv.",
        zone = "Uldaman",
        npc = "Ancient Stone Keeper",
    },
    {
        id = "hunter_mainhand_vanquisher",
        itemId = 10823,
        slot = "MainHand",
        minLevel = 38,
        maxLevel = 45,
        classes = { HUNTER = true },
        sourceType = "quest_reward",
        instructions = "Complete the Mok'thardin's Enchantment chain in Stranglethorn Vale. The final step rewards Vanquisher's Sword.",
        zone = "Stranglethorn Vale",
        questId = 3376,
    },
    {
        id = "hunter_mainhand_moodring",
        itemId = 9484,
        slot = "MainHand",
        minLevel = 34,
        maxLevel = 45,
        classes = { HUNTER = true },
        sourceType = "world_drop",
        instructions = "Moodring Mace is a rare world drop in the 35–45 level range. Check the Auction House or farm humanoid mobs in Stranglethorn or Tanaris.",
        zone = "Stranglethorn Vale",
    },
    {
        id = "hunter_mainhand_facesmasher",
        itemId = 13148,
        slot = "MainHand",
        minLevel = 36,
        maxLevel = 45,
        classes = { HUNTER = true },
        sourceType = "world_drop",
        instructions = "The Face Smasher is a rare world drop. Keep an eye on the Auction House or farm high-level mobs in the low-40s zones.",
        zone = "Various",
    },
}

local SLOT_TO_INVENTORY = {
    Head = 1,
    Neck = 2,
    Shoulder = 3,
    Back = 15,
    Chest = 5,
    Shirt = 4,
    Tabard = 19,
    Wrist = 9,
    Hands = 10,
    Waist = 6,
    Legs = 7,
    Feet = 8,
    Finger0 = 11,
    Finger1 = 12,
    Trinket0 = 13,
    Trinket1 = 14,
    MainHand = 16,
    SecondaryHand = 17,
    Ranged = 18,
}

function GQ.Data:GetInventorySlot(slotName)
    return SLOT_TO_INVENTORY[slotName]
end

function GQ.Data:BuildIndex()
    self.bySlot = {}
    for _, entry in ipairs(self.entries) do
        self.bySlot[entry.slot] = self.bySlot[entry.slot] or {}
        table.insert(self.bySlot[entry.slot], entry)
    end
end

function GQ.Data:GetEntryById(id)
    for _, entry in ipairs(self.entries) do
        if entry.id == id then
            return entry
        end
    end
end

function GQ.Data:EntryMatchesPlayer(entry)
    local classFile = GQ:GetEffectiveClass()
    if entry.classes and not entry.classes[classFile] then
        return false
    end

    local level = GQ:GetEffectiveLevel()
    if level < entry.minLevel or level > entry.maxLevel then
        return false
    end

    local faction = GQ:GetEffectiveFaction()
    if entry.factions and not entry.factions[faction] then
        return false
    end

    return true
end

function GQ.Data:GetCandidatesForSlot(slotName)
    local candidates = self.bySlot[slotName] or {}
    local results = {}

    for _, entry in ipairs(candidates) do
        if self:EntryMatchesPlayer(entry) then
            table.insert(results, entry)
        end
    end

    return results
end

GQ.Data.SLOT_LABELS = {
    Head = "Head",
    Neck = "Neck",
    Shoulder = "Shoulder",
    Back = "Back",
    Chest = "Chest",
    Wrist = "Wrist",
    Hands = "Hands",
    Waist = "Waist",
    Legs = "Legs",
    Feet = "Feet",
    Finger0 = "Finger",
    Finger1 = "Finger",
    Trinket0 = "Trinket",
    Trinket1 = "Trinket",
    MainHand = "Main Hand",
    SecondaryHand = "Off Hand",
    Ranged = "Ranged",
}

GQ.Data.BASE_SLOTS = {
    "Head", "Neck", "Shoulder", "Back", "Chest", "Wrist", "Hands",
    "Waist", "Legs", "Feet", "Finger0", "Finger1", "Trinket0", "Trinket1",
    "MainHand", "SecondaryHand",
}

GQ.Data.CLASS_RANGED = {
    HUNTER = true,
    MAGE = true,
    PRIEST = true,
    WARLOCK = true,
}

function GQ.Data:GetSlotsForClass(classFile)
    local slots = {}
    for _, slotName in ipairs(self.BASE_SLOTS) do
        table.insert(slots, slotName)
    end
    if self.CLASS_RANGED[classFile] then
        table.insert(slots, "Ranged")
    end
    return slots
end

function GQ.Data:GetTopUpgradesForSlot(slotName, maxResults)
    local candidates = self:GetCandidatesForSlot(slotName)
    return GQ.Compare:RankEntries(candidates, slotName, maxResults or 3)
end

function GQ.Data:SlotLabel(slotName)
    return self.SLOT_LABELS[slotName] or slotName
end
