local _, GQ = ...

GQ.Data = GQ.Data or {}

-- Static gear quests: pre-made entries, not generated at runtime.
-- Early Alliance Paladin leveling — Elwynn Forest through Westfall (~levels 4–15).
-- Level-4 band verified via Wowhead Classic + classicdb.ch (Northshire / Goldshire vendors).
-- Paladin armor entries use mail only below level 40; cloaks/back are class-neutral.
-- No entries at level 4 for Head, Shoulder, Neck, Finger, or Trinket (nothing realistic in Elwynn yet).

GQ.Data.entries = {
    -- Main Hand — level 4 Human Paladin (maces from Janos / Corina Steele; no sword skill yet)
    {
        id = "paladin4_mainhand_wooden_mallet",
        itemId = 2493,
        slot = "MainHand",
        minLevel = 4,
        maxLevel = 8,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "vendor",
        instructions = "Buy a Wooden Mallet from Corina Steele at the Goldshire forge. Best two-handed mace upgrade at level 4.",
        zone = "Elwynn Forest",
        npc = "Corina Steele",
    },
    {
        id = "paladin4_mainhand_cudgel",
        itemId = 2492,
        slot = "MainHand",
        minLevel = 1,
        maxLevel = 8,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "vendor",
        instructions = "Buy a Cudgel from Corina Steele in Goldshire if you use a shield. Strong one-handed mace for your level.",
        zone = "Elwynn Forest",
        npc = "Corina Steele",
    },
    {
        id = "paladin4_mainhand_large_club",
        itemId = 2480,
        slot = "MainHand",
        minLevel = 1,
        maxLevel = 6,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "vendor",
        instructions = "Buy a Large Club from Janos Hammerknuckle in Northshire Abbey before you reach Goldshire. Two-handed mace, weaker than a Wooden Mallet but available immediately.",
        zone = "Elwynn Forest",
        npc = "Janos Hammerknuckle",
    },
    {
        id = "paladin4_mainhand_club",
        itemId = 2130,
        slot = "MainHand",
        minLevel = 1,
        maxLevel = 8,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "vendor",
        instructions = "Buy a Club from Janos Hammerknuckle in Northshire for a cheap one-handed mace while you still use a shield.",
        zone = "Elwynn Forest",
        npc = "Janos Hammerknuckle",
    },
    {
        id = "paladin4_mainhand_copper_mace",
        itemId = 2844,
        slot = "MainHand",
        minLevel = 4,
        maxLevel = 10,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "profession",
        profession = "Blacksmithing",
        instructions = "Train Blacksmithing from Smith Argus in Goldshire, learn Copper Mace, and craft at an anvil. Requires level 4; strong one-handed option if you use a shield.",
        zone = "Elwynn Forest",
        npc = "Smith Argus",
    },

    -- Main Hand — after sword training (~level 6+)
    {
        id = "paladin_mainhand_gladius",
        itemId = 2488,
        slot = "MainHand",
        minLevel = 6,
        maxLevel = 12,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "vendor",
        instructions = "Train One-Handed Swords from a weapon master, then buy a Gladius from Corina Steele at the Goldshire forge.",
        zone = "Elwynn Forest",
        npc = "Corina Steele",
    },
    {
        id = "early_mainhand_defias_shortsword",
        itemId = 2209,
        slot = "MainHand",
        minLevel = 6,
        maxLevel = 12,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "world_drop",
        instructions = "After learning swords, farm Defias bandits in Elwynn and Westfall for a Cracked Defias Shortsword.",
        zone = "Elwynn Forest",
    },

    -- Off Hand — level 4 (quest shield + Northshire vendor shields)
    {
        id = "paladin4_offhand_pikeman_shield",
        itemId = 6078,
        slot = "SecondaryHand",
        minLevel = 4,
        maxLevel = 10,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "quest_reward",
        instructions = "Complete Report to Goldshire: deliver Marshal McBride's Documents to Marshal Dughan in Goldshire. You receive a Pikeman Shield.",
        zone = "Elwynn Forest",
        npc = "Marshal Dughan",
        questId = 54,
    },
    {
        id = "paladin4_offhand_large_round_shield",
        itemId = 2129,
        slot = "SecondaryHand",
        minLevel = 1,
        maxLevel = 8,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "vendor",
        instructions = "Buy a Large Round Shield from Godric Rothgar in Northshire Abbey (or Andrew Krighton in Goldshire).",
        zone = "Elwynn Forest",
        npc = "Godric Rothgar",
    },
    {
        id = "paladin4_offhand_small_shield",
        itemId = 2133,
        slot = "SecondaryHand",
        minLevel = 1,
        maxLevel = 8,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "vendor",
        instructions = "Buy a Small Shield from Godric Rothgar in Northshire if you want a lighter off-hand before the quest reward.",
        zone = "Elwynn Forest",
        npc = "Godric Rothgar",
    },
    {
        id = "paladin4_offhand_stone_buckler",
        itemId = 2900,
        slot = "SecondaryHand",
        minLevel = 1,
        maxLevel = 10,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "profession",
        profession = "Blacksmithing",
        instructions = "Train Blacksmithing and craft a Stone Buckler at an anvil. No level requirement — a solid crafted shield before or after the Pikeman Shield quest.",
        zone = "Elwynn Forest",
        npc = "Smith Argus",
    },

    -- Chest — level 4 (mail only for paladins)
    {
        id = "paladin4_chest_tarnished_vest",
        itemId = 2379,
        slot = "Chest",
        minLevel = 1,
        maxLevel = 8,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "vendor",
        instructions = "Buy a Tarnished Chain Vest from Godric Rothgar in Northshire. Best vendor mail chest at this level.",
        zone = "Elwynn Forest",
        npc = "Godric Rothgar",
    },
    {
        id = "paladin4_chest_flimsy_vest",
        itemId = 2656,
        slot = "Chest",
        minLevel = 1,
        maxLevel = 8,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "world_drop",
        instructions = "Flimsy Chain Vest drops from kobolds and other humanoids in Elwynn Forest.",
        zone = "Elwynn Forest",
    },
    {
        id = "paladin4_chest_copper_chain_vest",
        itemId = 3471,
        slot = "Chest",
        minLevel = 5,
        maxLevel = 10,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "profession",
        profession = "Blacksmithing",
        instructions = "At level 5, learn Copper Chain Vest from a blacksmith trainer and craft mail at an anvil. Buy the recipe from a trainer if needed.",
        zone = "Elwynn Forest",
        npc = "Smith Argus",
    },
    {
        id = "paladin4_chest_light_mail",
        itemId = 2392,
        slot = "Chest",
        minLevel = 5,
        maxLevel = 10,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "vendor",
        instructions = "At level 5, buy Light Mail Armor from Andrew Krighton at the Goldshire forge.",
        zone = "Elwynn Forest",
        npc = "Andrew Krighton",
    },
    {
        id = "early_chest_tunic_westfall",
        itemId = 2041,
        slot = "Chest",
        minLevel = 9,
        maxLevel = 18,
        factions = { Alliance = true },
        sourceType = "quest_reward",
        instructions = "Work through the Defias Brotherhood quest line in Westfall. The Tunic of Westfall is a strong reward once you reach Sentinel Hill.",
        zone = "Westfall",
    },

    -- Legs — level 4
    {
        id = "paladin4_legs_tarnished_leggings",
        itemId = 2381,
        slot = "Legs",
        minLevel = 1,
        maxLevel = 8,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "vendor",
        instructions = "Buy Tarnished Chain Leggings from Godric Rothgar in Northshire.",
        zone = "Elwynn Forest",
        npc = "Godric Rothgar",
    },
    {
        id = "paladin4_legs_flimsy_pants",
        itemId = 2654,
        slot = "Legs",
        minLevel = 1,
        maxLevel = 8,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "world_drop",
        instructions = "Flimsy Chain Pants drop from humanoids in Elwynn Forest.",
        zone = "Elwynn Forest",
    },
    {
        id = "paladin4_legs_copper_chain_pants",
        itemId = 2852,
        slot = "Legs",
        minLevel = 4,
        maxLevel = 10,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "profession",
        profession = "Blacksmithing",
        instructions = "Learn Copper Chain Pants from a blacksmith trainer and craft at an anvil (requires level 4). Best mail legs at this level if you can smith or buy from the AH.",
        zone = "Elwynn Forest",
        npc = "Smith Argus",
    },
    {
        id = "paladin4_legs_loose_pants",
        itemId = 2646,
        slot = "Legs",
        minLevel = 3,
        maxLevel = 10,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "world_drop",
        instructions = "Loose Chain Pants are uncommon mail world drops in Elwynn (requires level 3).",
        zone = "Elwynn Forest",
    },

    -- Feet — level 4
    {
        id = "paladin4_feet_tarnished_boots",
        itemId = 2383,
        slot = "Feet",
        minLevel = 1,
        maxLevel = 8,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "vendor",
        instructions = "Buy Tarnished Chain Boots from Godric Rothgar in Northshire.",
        zone = "Elwynn Forest",
        npc = "Godric Rothgar",
    },
    {
        id = "paladin4_feet_flimsy_boots",
        itemId = 2650,
        slot = "Feet",
        minLevel = 1,
        maxLevel = 8,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "world_drop",
        instructions = "Flimsy Chain Boots drop from humanoids in Elwynn Forest.",
        zone = "Elwynn Forest",
    },
    {
        id = "paladin4_feet_copper_chain_boots",
        itemId = 3469,
        slot = "Feet",
        minLevel = 4,
        maxLevel = 10,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "profession",
        profession = "Blacksmithing",
        instructions = "Learn Copper Chain Boots and craft mail at an anvil (requires level 4).",
        zone = "Elwynn Forest",
        npc = "Smith Argus",
    },
    {
        id = "paladin4_feet_loose_boots",
        itemId = 2642,
        slot = "Feet",
        minLevel = 4,
        maxLevel = 10,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "world_drop",
        instructions = "Loose Chain Boots are uncommon mail world drops in Elwynn (requires level 4).",
        zone = "Elwynn Forest",
    },

    -- Hands — level 4
    {
        id = "paladin4_hands_tarnished_gloves",
        itemId = 2385,
        slot = "Hands",
        minLevel = 1,
        maxLevel = 8,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "vendor",
        instructions = "Buy Tarnished Chain Gloves from Godric Rothgar in Northshire.",
        zone = "Elwynn Forest",
        npc = "Godric Rothgar",
    },
    {
        id = "paladin4_hands_flimsy_gloves",
        itemId = 2653,
        slot = "Hands",
        minLevel = 1,
        maxLevel = 8,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "world_drop",
        instructions = "Flimsy Chain Gloves drop from humanoids in Elwynn Forest.",
        zone = "Elwynn Forest",
    },
    {
        id = "paladin4_hands_loose_gloves",
        itemId = 2645,
        slot = "Hands",
        minLevel = 2,
        maxLevel = 10,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "world_drop",
        instructions = "Loose Chain Gloves are uncommon mail world drops in Elwynn (requires level 2).",
        zone = "Elwynn Forest",
    },

    -- Wrist — level 4
    {
        id = "paladin4_wrist_tarnished_bracers",
        itemId = 2384,
        slot = "Wrist",
        minLevel = 1,
        maxLevel = 8,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "vendor",
        instructions = "Buy Tarnished Chain Bracers from Godric Rothgar in Northshire.",
        zone = "Elwynn Forest",
        npc = "Godric Rothgar",
    },
    {
        id = "paladin4_wrist_flimsy_bracers",
        itemId = 2651,
        slot = "Wrist",
        minLevel = 1,
        maxLevel = 8,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "world_drop",
        instructions = "Flimsy Chain Bracers drop from humanoids in Elwynn Forest.",
        zone = "Elwynn Forest",
    },
    {
        id = "paladin4_wrist_copper_bracers",
        itemId = 2853,
        slot = "Wrist",
        minLevel = 2,
        maxLevel = 10,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "profession",
        profession = "Blacksmithing",
        instructions = "Learn Copper Bracers and craft at an anvil (requires level 2).",
        zone = "Elwynn Forest",
        npc = "Smith Argus",
    },
    {
        id = "paladin4_wrist_loose_bracers",
        itemId = 2643,
        slot = "Wrist",
        minLevel = 5,
        maxLevel = 10,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "world_drop",
        instructions = "Loose Chain Bracers are uncommon mail world drops in Elwynn (requires level 5).",
        zone = "Elwynn Forest",
    },

    -- Waist — level 4
    {
        id = "paladin4_waist_tarnished_belt",
        itemId = 2380,
        slot = "Waist",
        minLevel = 1,
        maxLevel = 8,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "vendor",
        instructions = "Buy a Tarnished Chain Belt from Godric Rothgar in Northshire.",
        zone = "Elwynn Forest",
        npc = "Godric Rothgar",
    },
    {
        id = "paladin4_waist_flimsy_belt",
        itemId = 2649,
        slot = "Waist",
        minLevel = 1,
        maxLevel = 8,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "world_drop",
        instructions = "Flimsy Chain Belt drops from humanoids in Elwynn Forest.",
        zone = "Elwynn Forest",
    },
    {
        id = "paladin4_waist_loose_belt",
        itemId = 2635,
        slot = "Waist",
        minLevel = 3,
        maxLevel = 10,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "world_drop",
        instructions = "Loose Chain Belt is an uncommon mail world drop in Elwynn (requires level 3).",
        zone = "Elwynn Forest",
    },

    -- Back — level 4 (cloaks are cloth for all classes; chain-named drops from Elwynn)
    {
        id = "paladin4_back_flimsy_chain_cloak",
        itemId = 2652,
        slot = "Back",
        minLevel = 1,
        maxLevel = 8,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "world_drop",
        instructions = "Flimsy Chain Cloak drops from humanoids in Elwynn Forest.",
        zone = "Elwynn Forest",
    },
    {
        id = "paladin4_back_loose_chain_cloak",
        itemId = 2644,
        slot = "Back",
        minLevel = 1,
        maxLevel = 8,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "world_drop",
        instructions = "Loose Chain Cloak is an uncommon world drop in Elwynn Forest.",
        zone = "Elwynn Forest",
    },
    {
        id = "paladin4_back_linen_cloak",
        itemId = 2570,
        slot = "Back",
        minLevel = 1,
        maxLevel = 8,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "profession",
        profession = "Tailoring",
        instructions = "Train Tailoring, learn Linen Cloak, and craft at a tailoring bench. Cloaks are cloth for every class.",
        zone = "Elwynn Forest",
    },
    {
        id = "paladin4_back_patchwork_cloak",
        itemId = 1429,
        slot = "Back",
        minLevel = 1,
        maxLevel = 8,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "world_drop",
        instructions = "Patchwork Cloak is a common grey world drop from kobolds and other starter-zone mobs.",
        zone = "Elwynn Forest",
    },

    -- Paladin class quest horizon (still relevant while leveling)
    {
        id = "paladin_mainhand_hogger_blade",
        itemId = 6331,
        slot = "MainHand",
        minLevel = 6,
        maxLevel = 15,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "boss_drop",
        instructions = "Group for Hogger in Elwynn Forest (Wanted: Hogger quest). Howling Blade is a rare drop from the boss himself.",
        zone = "Elwynn Forest",
        npc = "Hogger",
    },
    {
        id = "paladin_mainhand_verigans_fist",
        itemId = 6953,
        slot = "MainHand",
        minLevel = 20,
        maxLevel = 30,
        classes = { PALADIN = true },
        factions = { Alliance = true },
        sourceType = "quest_reward",
        instructions = "Complete the Paladin Test of Righteousness chain starting with The Tome of Valor in Stormwind. Gather Jordan's materials from Deadmines, Loch Modan, Shadowfang Keep, and Darkshore, then return to Jordan Stilwell in Ironforge.",
        zone = "Stormwind City",
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

-- Log categories: both finger/trinket inventory slots share one upgrade list each.
GQ.Data.MERGED_SLOT_INVENTORY = {
    Finger = { 11, 12 },
    Trinket = { 13, 14 },
}

function GQ.Data:NormalizeSlotName(slotName)
    if slotName == "Finger0" or slotName == "Finger1" then
        return "Finger"
    end
    if slotName == "Trinket0" or slotName == "Trinket1" then
        return "Trinket"
    end
    return slotName
end

function GQ.Data:GetInventorySlots(slotName)
    slotName = self:NormalizeSlotName(slotName)
    if self.MERGED_SLOT_INVENTORY[slotName] then
        return self.MERGED_SLOT_INVENTORY[slotName]
    end

    local inv = SLOT_TO_INVENTORY[slotName]
    if inv then
        return { inv }
    end
    return {}
end

function GQ.Data:GetInventorySlot(slotName)
    local slots = self:GetInventorySlots(slotName)
    return slots[1]
end

function GQ.Data:EntryMatchesSlot(entry, slotName)
    if not entry or not entry.slot then
        return false
    end
    return self:NormalizeSlotName(entry.slot) == self:NormalizeSlotName(slotName)
end

function GQ.Data:GetCandidateSlotKeys(slotName)
    slotName = self:NormalizeSlotName(slotName)
    if slotName == "Finger" then
        return { "Finger", "Finger0", "Finger1" }
    end
    if slotName == "Trinket" then
        return { "Trinket", "Trinket0", "Trinket1" }
    end
    return { slotName }
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

    local faction = GQ:GetEffectiveFaction()
    if entry.factions and not entry.factions[faction] then
        return false
    end

    if not GQ.Equip:EntryWithinLevelBand(entry) then
        return false
    end

    if not GQ.Equip:EntryMatchesItemRules(entry) then
        return false
    end

    return true
end

function GQ.Data:GetCandidatesForSlot(slotName)
    local results = {}
    local seen = {}

    for _, key in ipairs(self:GetCandidateSlotKeys(slotName)) do
        for _, entry in ipairs(self.bySlot[key] or {}) do
            if not seen[entry.id] and self:EntryMatchesPlayer(entry) then
                seen[entry.id] = true
                table.insert(results, entry)
            end
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
    Finger = "Finger",
    Trinket = "Trinket",
    MainHand = "Main Hand",
    SecondaryHand = "Off Hand",
    Ranged = "Ranged",
}

GQ.Data.BASE_SLOTS = {
    "Head", "Neck", "Shoulder", "Back", "Chest", "Wrist", "Hands",
    "Waist", "Legs", "Feet", "Finger", "Trinket",
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
    local seen = {}

    for _, slotName in ipairs(self.BASE_SLOTS) do
        slotName = self:NormalizeSlotName(slotName)
        if not seen[slotName] then
            seen[slotName] = true
            table.insert(slots, slotName)
        end
    end

    if self.CLASS_RANGED[classFile] and not seen.Ranged then
        table.insert(slots, "Ranged")
    end

    return slots
end

function GQ.Data:GetTopUpgradesForSlot(slotName, maxResults)
    slotName = self:NormalizeSlotName(slotName)
    local candidates = self:GetCandidatesForSlot(slotName)
    return GQ.Compare:RankEntries(candidates, slotName, maxResults or 3)
end

function GQ.Data:SlotLabel(slotName)
    return self.SLOT_LABELS[self:NormalizeSlotName(slotName)] or slotName
end
