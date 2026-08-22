local _, GQ = ...

GQ.Data = GQ.Data or {}

-- Curated BiS lists (user-defined order via curatedRank 1 = best).
-- Early Alliance mail melee band (~levels 1–8). Item required level gates visibility in Equip.lua.

local ALLIANCE = { Alliance = true }
local ALLIANCE_MAIL = { WARRIOR = true, PALADIN = true }
local EARLY_MIN = 1
local EARLY_MAX = 8
local EARLY4_MAX = 4
local LEVEL5_MIN = 5
local LEVEL5_MAX = 10
local LEVEL6_MIN = 6
local LEVEL6_MAX = 12
local LEVEL7_MIN = 7
local LEVEL7_MAX = 12
local LEVEL8_MIN = 8
local LEVEL8_MAX = 12
local MAIL_MELEE = ALLIANCE_MAIL

-- Crafted output names for trainer matching when GetItemInfo is not cached yet.
local PROFESSION_ITEM_NAMES = {
    [10421] = "Rough Copper Vest",
    [3469] = "Copper Chain Boots",
    [2852] = "Copper Chain Pants",
    [3471] = "Copper Chain Vest",
    [2851] = "Copper Chain Belt",
    [2580] = "Reinforced Linen Cape",
    [3472] = "Runed Copper Gauntlets",
    [2310] = "Embossed Leather Cloak",
    [3473] = "Runed Copper Pants",
    [3488] = "Copper Battle Axe",
}

local MIDSUMMER_CROWN =
    "During the Midsummer Fire Festival, complete A Thief's Reward in a capital city after stealing the opposing faction's bonfire flames (or turn in if you finished in a previous year). Usable from level 1."

GQ.Data.entries = {
    -- Head — all classes / factions (seasonal)
    {
        id = "early4_all_head_crown_fire_festival",
        itemId = 23323,
        slot = "Head",
        minLevel = EARLY_MIN,
        maxLevel = EARLY_MAX,
        curatedRank = 1,
        sourceType = "seasonal_quest",
        instructions = MIDSUMMER_CROWN,
        zone = "Capital Cities",
        questName = "A Thief's Reward",
    },

    -- Back — Alliance mail melee
    {
        id = "early4_back_infantry_cloak",
        itemId = 6508,
        slot = "Back",
        minLevel = EARLY_MIN,
        maxLevel = EARLY4_MAX,
        classes = ALLIANCE_MAIL,
        factions = ALLIANCE,
        curatedRank = 1,
        sourceType = "world_drop",
        instructions = "Infantry Cloak (8 armor, req 4) is a green world drop or vendor find in starter zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early4_back_pioneer_cloak",
        itemId = 6520,
        slot = "Back",
        minLevel = EARLY_MIN,
        maxLevel = EARLY4_MAX,
        classes = ALLIANCE_MAIL,
        factions = ALLIANCE,
        curatedRank = 2,
        sourceType = "world_drop",
        instructions = "Pioneer Cloak (8 armor, req 4) is a green world drop in low-level zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early4_back_battle_chain_cloak",
        itemId = 4668,
        slot = "Back",
        minLevel = EARLY_MIN,
        maxLevel = EARLY4_MAX,
        classes = ALLIANCE_MAIL,
        factions = ALLIANCE,
        curatedRank = 3,
        sourceType = "world_drop",
        instructions = "Battle Chain Cloak (8 armor, req 4) drops from humanoids in starter zones.",
        zone = "Elwynn Forest",
    },

    -- Chest
    {
        id = "early4_chest_rough_copper_vest",
        itemId = 10421,
        slot = "Chest",
        minLevel = EARLY_MIN,
        maxLevel = EARLY4_MAX,
        classes = ALLIANCE_MAIL,
        factions = ALLIANCE,
        curatedRank = 1,
        sourceType = "profession",
        profession = "Blacksmithing",
        instructions = "Learn Rough Copper Vest from a blacksmith trainer and craft at an anvil (requires level 2). Best early mail chest.",
        zone = "Elwynn Forest",
        npc = "Smith Argus",
    },
    {
        id = "early4_chest_mountaineer_chestpiece",
        itemId = 2898,
        slot = "Chest",
        minLevel = EARLY_MIN,
        maxLevel = EARLY4_MAX,
        classes = ALLIANCE_MAIL,
        factions = ALLIANCE,
        curatedRank = 2,
        sourceType = "world_drop",
        instructions = "Mountaineer Chestpiece (req 2) drops from low-level mobs such as Ice Claw Bears in Dun Morogh.",
        zone = "Dun Morogh",
    },
    {
        id = "early4_chest_tarnished_vest",
        itemId = 2379,
        slot = "Chest",
        minLevel = EARLY_MIN,
        maxLevel = EARLY4_MAX,
        classes = ALLIANCE_MAIL,
        factions = ALLIANCE,
        curatedRank = 3,
        sourceType = "vendor",
        instructions = "Buy Tarnished Chain Vest from Godric Rothgar in Northshire Abbey.",
        zone = "Elwynn Forest",
        npc = "Godric Rothgar",
    },

    -- Wrist
    {
        id = "early4_wrist_battle_chain_bracers",
        itemId = 3280,
        slot = "Wrist",
        minLevel = EARLY_MIN,
        maxLevel = EARLY4_MAX,
        classes = ALLIANCE_MAIL,
        factions = ALLIANCE,
        curatedRank = 1,
        sourceType = "world_drop",
        instructions = "Battle Chain Bracers (req 4) are green mail world drops in starter zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early4_wrist_warriors_bracers",
        itemId = 3214,
        slot = "Wrist",
        minLevel = EARLY_MIN,
        maxLevel = EARLY4_MAX,
        classes = ALLIANCE_MAIL,
        factions = ALLIANCE,
        curatedRank = 2,
        sourceType = "world_drop",
        instructions = "Warrior's Bracers (req 4) are green mail world drops in low-level zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early4_wrist_graystone_bracers",
        itemId = 6061,
        slot = "Wrist",
        minLevel = EARLY_MIN,
        maxLevel = EARLY4_MAX,
        classes = ALLIANCE_MAIL,
        factions = ALLIANCE,
        curatedRank = 3,
        sourceType = "quest_reward",
        instructions = "Complete Timberling Sprouts in Teldrassil: collect 12 Timberling Sprouts for Denalan at Lake Al'Ameth and choose Graystone Bracers over Gardening Gloves.",
        zone = "Teldrassil",
        npc = "Denalan",
        questName = "Timberling Sprouts",
    },

    -- Main Hand (two-hand)
    {
        id = "early4_mainhand_thicket_hammer",
        itemId = 5595,
        slot = "MainHand",
        minLevel = EARLY_MIN,
        maxLevel = EARLY4_MAX,
        classes = ALLIANCE_MAIL,
        factions = ALLIANCE,
        curatedRank = 1,
        sourceType = "quest_reward",
        instructions = "Complete Crown of the Earth in Teldrassil and choose Thicket Hammer over the Walking Stick when Tarindrella offers the reward.",
        zone = "Teldrassil",
        npc = "Tarindrella",
        questName = "Crown of the Earth",
    },
    {
        id = "early4_mainhand_vile_fin_battle_axe",
        itemId = 3325,
        slot = "MainHand",
        minLevel = EARLY_MIN,
        maxLevel = EARLY4_MAX,
        classes = ALLIANCE_MAIL,
        factions = ALLIANCE,
        curatedRank = 2,
        sourceType = "world_drop",
        instructions = "Vile Fin Battle Axe (req 4) drops from murlocs in starter zones. Train Two-Handed Axes from a weapon master first.",
        zone = "Elwynn Forest",
    },
    {
        id = "early4_mainhand_rusted_claymore",
        itemId = 2497,
        slot = "MainHand",
        minLevel = EARLY_MIN,
        maxLevel = EARLY4_MAX,
        classes = ALLIANCE_MAIL,
        factions = ALLIANCE,
        curatedRank = 3,
        sourceType = "vendor",
        instructions = "Buy a Rusted Claymore from a weapons vendor. Train Two-Handed Swords from a weapon master first.",
        zone = "Elwynn Forest",
    },

    -- Off Hand (shield)
    {
        id = "early4_offhand_pioneer_buckler",
        itemId = 7109,
        slot = "SecondaryHand",
        minLevel = EARLY_MIN,
        maxLevel = EARLY4_MAX,
        classes = ALLIANCE_MAIL,
        factions = ALLIANCE,
        curatedRank = 1,
        sourceType = "world_drop",
        instructions = "Pioneer Buckler (req 4) is a green shield world drop in low-level zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early4_offhand_primal_buckler",
        itemId = 15006,
        slot = "SecondaryHand",
        minLevel = EARLY_MIN,
        maxLevel = EARLY4_MAX,
        classes = ALLIANCE_MAIL,
        factions = ALLIANCE,
        curatedRank = 2,
        sourceType = "world_drop",
        instructions = "Primal Buckler (req 4) is a green shield world drop in starter zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early4_offhand_warriors_buckler",
        itemId = 3648,
        slot = "SecondaryHand",
        minLevel = EARLY_MIN,
        maxLevel = EARLY4_MAX,
        classes = ALLIANCE_MAIL,
        factions = ALLIANCE,
        curatedRank = 3,
        sourceType = "vendor",
        instructions = "Buy a Warrior's Buckler (req 4) from Godric Rothgar in Northshire or Andrew Krighton in Goldshire.",
        zone = "Elwynn Forest",
        npc = "Godric Rothgar",
    },

    -- Feet
    {
        id = "early4_feet_copper_chain_boots",
        itemId = 3469,
        slot = "Feet",
        minLevel = EARLY_MIN,
        maxLevel = EARLY4_MAX,
        classes = ALLIANCE_MAIL,
        factions = ALLIANCE,
        curatedRank = 1,
        sourceType = "profession",
        profession = "Blacksmithing",
        instructions = "Learn Copper Chain Boots and craft at an anvil (requires level 4). Best mail boots at this band.",
        zone = "Elwynn Forest",
        npc = "Smith Argus",
    },
    {
        id = "early4_feet_loose_chain_boots",
        itemId = 2642,
        slot = "Feet",
        minLevel = EARLY_MIN,
        maxLevel = EARLY4_MAX,
        classes = ALLIANCE_MAIL,
        factions = ALLIANCE,
        curatedRank = 2,
        sourceType = "world_drop",
        instructions = "Loose Chain Boots (req 4) are uncommon mail world drops in Elwynn Forest.",
        zone = "Elwynn Forest",
    },
    {
        id = "early4_feet_bloody_chain_boots",
        itemId = 18612,
        slot = "Feet",
        minLevel = EARLY_MIN,
        maxLevel = EARLY4_MAX,
        classes = ALLIANCE_MAIL,
        factions = ALLIANCE,
        curatedRank = 3,
        sourceType = "boss_drop",
        instructions = "Bloody Chain Boots (req 3) drop from Fury Shelda, a rare spawn in southern Teldrassil.",
        zone = "Teldrassil",
        npc = "Fury Shelda",
    },

    -- Legs
    {
        id = "early4_legs_barkmail_leggings",
        itemId = 9599,
        slot = "Legs",
        minLevel = EARLY_MIN,
        maxLevel = EARLY4_MAX,
        classes = ALLIANCE_MAIL,
        factions = ALLIANCE,
        curatedRank = 1,
        sourceType = "quest_reward",
        instructions = "Complete The Relics of Wakening in Teldrassil: retrieve the four relics from Ban'ethil Barrow Den for Athridas Bearmantle in Dolanaar, then choose Barkmail Leggings over the Gritroot Staff.",
        zone = "Teldrassil",
        npc = "Athridas Bearmantle",
        questName = "The Relics of Wakening",
    },
    {
        id = "early4_legs_copper_chain_pants",
        itemId = 2852,
        slot = "Legs",
        minLevel = EARLY_MIN,
        maxLevel = EARLY4_MAX,
        classes = ALLIANCE_MAIL,
        factions = ALLIANCE,
        curatedRank = 2,
        sourceType = "profession",
        profession = "Blacksmithing",
        instructions = "Learn Copper Chain Pants and craft at an anvil (requires level 4).",
        zone = "Elwynn Forest",
        npc = "Smith Argus",
    },
    {
        id = "early4_legs_loose_chain_pants",
        itemId = 2646,
        slot = "Legs",
        minLevel = EARLY_MIN,
        maxLevel = EARLY4_MAX,
        classes = ALLIANCE_MAIL,
        factions = ALLIANCE,
        curatedRank = 3,
        sourceType = "world_drop",
        instructions = "Loose Chain Pants (req 3) are uncommon mail world drops in Elwynn Forest.",
        zone = "Elwynn Forest",
    },

    -- Waist
    {
        id = "early4_waist_chargers_belt",
        itemId = 15472,
        slot = "Waist",
        minLevel = EARLY_MIN,
        maxLevel = EARLY4_MAX,
        classes = ALLIANCE_MAIL,
        factions = ALLIANCE,
        curatedRank = 1,
        sourceType = "world_drop",
        instructions = "Charger's Belt (req 4) is a green mail world drop in low-level zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early4_waist_warriors_girdle",
        itemId = 4659,
        slot = "Waist",
        minLevel = EARLY_MIN,
        maxLevel = EARLY4_MAX,
        classes = ALLIANCE_MAIL,
        factions = ALLIANCE,
        curatedRank = 2,
        sourceType = "world_drop",
        instructions = "Warrior's Girdle (req 3) is a green mail world drop in starter zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early4_waist_loose_chain_belt",
        itemId = 2635,
        slot = "Waist",
        minLevel = EARLY_MIN,
        maxLevel = EARLY4_MAX,
        classes = ALLIANCE_MAIL,
        factions = ALLIANCE,
        curatedRank = 3,
        sourceType = "world_drop",
        instructions = "Loose Chain Belt (req 3) is an uncommon mail world drop in Elwynn Forest.",
        zone = "Elwynn Forest",
    },

    -- Hands
    {
        id = "early4_hands_moss_covered_gauntlets",
        itemId = 5589,
        slot = "Hands",
        minLevel = EARLY_MIN,
        maxLevel = EARLY4_MAX,
        classes = ALLIANCE_MAIL,
        factions = ALLIANCE,
        curatedRank = 1,
        sourceType = "quest_reward",
        instructions = "Complete Oakenscowl in Teldrassil: kill Oakenscowl and bring the Gargantuan Tumor to Denalan at Lake Al'Ameth, then choose Moss-covered Gauntlets over the Dirtwood Belt.",
        zone = "Teldrassil",
        npc = "Denalan",
        questName = "Oakenscowl",
    },
    {
        id = "early4_hands_warriors_gloves",
        itemId = 2968,
        slot = "Hands",
        minLevel = EARLY_MIN,
        maxLevel = EARLY4_MAX,
        classes = ALLIANCE_MAIL,
        factions = ALLIANCE,
        curatedRank = 2,
        sourceType = "world_drop",
        instructions = "Warrior's Gloves (req 4) are green mail world drops in low-level zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early4_hands_loose_chain_gloves",
        itemId = 2645,
        slot = "Hands",
        minLevel = EARLY_MIN,
        maxLevel = EARLY4_MAX,
        classes = ALLIANCE_MAIL,
        factions = ALLIANCE,
        curatedRank = 3,
        sourceType = "world_drop",
        instructions = "Loose Chain Gloves (req 2) are uncommon mail world drops in Elwynn Forest.",
        zone = "Elwynn Forest",
    },

    -- Level 5 band — Head unchanged (early4_all_head_* above). No Shoulder entries (no armor value at low levels).

    -- Back — Alliance, all classes (level 5)
    {
        id = "early5_back_worn_hide_cloak",
        itemId = 1421,
        slot = "Back",
        minLevel = LEVEL5_MIN,
        maxLevel = LEVEL5_MAX,
        factions = ALLIANCE,
        curatedRank = 1,
        sourceType = "world_drop",
        instructions = "Worn Hide Cloak (9 armor, req 5) is a green world drop from humanoids in starter zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early5_back_grizzly_cape",
        itemId = 15299,
        slot = "Back",
        minLevel = LEVEL5_MIN,
        maxLevel = LEVEL5_MAX,
        factions = ALLIANCE,
        curatedRank = 2,
        sourceType = "world_drop",
        instructions = "Grizzly Cape (9 armor, req 5) is a green world drop in low-level Alliance zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early5_back_goat_fur_cloak",
        itemId = 2905,
        slot = "Back",
        minLevel = LEVEL5_MIN,
        maxLevel = LEVEL5_MAX,
        factions = ALLIANCE,
        curatedRank = 3,
        sourceType = "world_drop",
        instructions = "Goat Fur Cloak (9 armor) drops from goats and other beasts in Dun Morogh and similar zones.",
        zone = "Dun Morogh",
    },

    -- Chest — Alliance mail melee (level 5)
    {
        id = "early5_chest_copper_chain_vest",
        itemId = 3471,
        slot = "Chest",
        minLevel = LEVEL5_MIN,
        maxLevel = LEVEL5_MAX,
        classes = MAIL_MELEE,
        factions = ALLIANCE,
        curatedRank = 1,
        sourceType = "profession",
        profession = "Blacksmithing",
        instructions = "Learn Copper Chain Vest and craft at an anvil (requires level 5). Best mail chest at this level (+1 Strength).",
        zone = "Elwynn Forest",
        npc = "Smith Argus",
    },
    {
        id = "early5_chest_footman_tunic",
        itemId = 6085,
        slot = "Chest",
        minLevel = LEVEL5_MIN,
        maxLevel = LEVEL5_MAX,
        classes = MAIL_MELEE,
        factions = ALLIANCE,
        curatedRank = 2,
        sourceType = "quest_reward",
        instructions = "Complete Wanted: Hogger in Elwynn Forest and choose the Footman Tunic over the other quest rewards. Leather chest with +Agility and +Stamina.",
        zone = "Elwynn Forest",
        npc = "Marshal Dughan",
        questName = "Wanted: \"Hogger\"",
    },
    {
        id = "early5_chest_light_mail_armor",
        itemId = 2392,
        slot = "Chest",
        minLevel = LEVEL5_MIN,
        maxLevel = LEVEL5_MAX,
        classes = MAIL_MELEE,
        factions = ALLIANCE,
        curatedRank = 3,
        sourceType = "vendor",
        instructions = "Buy Light Mail Armor (req 5) from Andrew Krighton in Goldshire or another mail vendor in a starter city.",
        zone = "Elwynn Forest",
        npc = "Andrew Krighton",
    },

    -- Wrist — mail melee, both factions (level 5)
    {
        id = "early5_wrist_light_chain_bracers",
        itemId = 2402,
        slot = "Wrist",
        minLevel = LEVEL5_MIN,
        maxLevel = LEVEL5_MAX,
        classes = MAIL_MELEE,
        curatedRank = 1,
        sourceType = "vendor",
        instructions = "Buy Light Chain Bracers (req 5) from a mail armor vendor in your starter city.",
        zone = "Elwynn Forest",
    },
    {
        id = "early5_wrist_light_mail_bracers",
        itemId = 2396,
        slot = "Wrist",
        minLevel = LEVEL5_MIN,
        maxLevel = LEVEL5_MAX,
        classes = MAIL_MELEE,
        curatedRank = 2,
        sourceType = "vendor",
        instructions = "Buy Light Mail Bracers (req 5) from a mail armor vendor in your starter city.",
        zone = "Elwynn Forest",
    },
    {
        id = "early5_wrist_infantry_bracers",
        itemId = 6507,
        slot = "Wrist",
        minLevel = LEVEL5_MIN,
        maxLevel = LEVEL5_MAX,
        classes = MAIL_MELEE,
        curatedRank = 3,
        sourceType = "world_drop",
        instructions = "Infantry Bracers (req 5) are a green mail world drop in low-level zones.",
        zone = "Elwynn Forest",
    },

    -- Main Hand — mail melee, both factions (level 5)
    {
        id = "early5_mainhand_training_sword",
        itemId = 8178,
        slot = "MainHand",
        minLevel = LEVEL5_MIN,
        maxLevel = LEVEL5_MAX,
        classes = MAIL_MELEE,
        curatedRank = 1,
        sourceType = "world_drop",
        instructions = "Training Sword (req 5) is a green two-handed sword world drop. Train Two-Handed Swords from a weapon master first.",
        zone = "Elwynn Forest",
    },
    {
        id = "early5_mainhand_severing_axe",
        itemId = 4562,
        slot = "MainHand",
        minLevel = LEVEL5_MIN,
        maxLevel = LEVEL5_MAX,
        classes = MAIL_MELEE,
        curatedRank = 2,
        sourceType = "world_drop",
        instructions = "Severing Axe (req 5) is a green two-handed axe world drop. Train Two-Handed Axes from a weapon master first.",
        zone = "Elwynn Forest",
    },
    {
        id = "early5_mainhand_thicket_hammer",
        itemId = 5595,
        slot = "MainHand",
        minLevel = LEVEL5_MIN,
        maxLevel = LEVEL5_MAX,
        classes = MAIL_MELEE,
        curatedRank = 3,
        sourceType = "quest_reward",
        instructions = "Complete Crown of the Earth in Teldrassil and choose Thicket Hammer over the Walking Stick when Tarindrella offers the reward.",
        zone = "Teldrassil",
        npc = "Tarindrella",
        questName = "Crown of the Earth",
    },

    -- Off Hand — mail melee, both factions (level 5)
    {
        id = "early5_offhand_dull_heater_shield",
        itemId = 1201,
        slot = "SecondaryHand",
        minLevel = LEVEL5_MIN,
        maxLevel = LEVEL5_MAX,
        classes = MAIL_MELEE,
        curatedRank = 1,
        sourceType = "vendor",
        instructions = "Buy a Dull Heater Shield (req 5) from a shield vendor in your starter city.",
        zone = "Elwynn Forest",
    },
    {
        id = "early5_offhand_worn_heater_shield",
        itemId = 2376,
        slot = "SecondaryHand",
        minLevel = LEVEL5_MIN,
        maxLevel = LEVEL5_MAX,
        classes = MAIL_MELEE,
        curatedRank = 2,
        sourceType = "vendor",
        instructions = "Buy a Worn Heater Shield (req 5) from Godric Rothgar in Northshire or Andrew Krighton in Goldshire.",
        zone = "Elwynn Forest",
        npc = "Godric Rothgar",
    },
    {
        id = "early5_offhand_small_targe",
        itemId = 1167,
        slot = "SecondaryHand",
        minLevel = LEVEL5_MIN,
        maxLevel = LEVEL5_MAX,
        classes = MAIL_MELEE,
        curatedRank = 3,
        sourceType = "vendor",
        instructions = "Buy a Small Targe (req 5) from a shield vendor in your starter city.",
        zone = "Elwynn Forest",
    },

    -- Feet — mail melee, both factions (level 5)
    {
        id = "early5_feet_light_chain_boots",
        itemId = 2401,
        slot = "Feet",
        minLevel = LEVEL5_MIN,
        maxLevel = LEVEL5_MAX,
        classes = MAIL_MELEE,
        curatedRank = 1,
        sourceType = "vendor",
        instructions = "Buy Light Chain Boots (req 5) from a mail armor vendor in your starter city.",
        zone = "Elwynn Forest",
    },
    {
        id = "early5_feet_light_mail_boots",
        itemId = 2395,
        slot = "Feet",
        minLevel = LEVEL5_MIN,
        maxLevel = LEVEL5_MAX,
        classes = MAIL_MELEE,
        curatedRank = 2,
        sourceType = "vendor",
        instructions = "Buy Light Mail Boots (req 5) from a mail armor vendor in your starter city.",
        zone = "Elwynn Forest",
    },
    {
        id = "early5_feet_chargers_boots",
        itemId = 15473,
        slot = "Feet",
        minLevel = LEVEL5_MIN,
        maxLevel = LEVEL5_MAX,
        classes = MAIL_MELEE,
        curatedRank = 3,
        sourceType = "world_drop",
        instructions = "Charger's Boots (req 5) are a green mail world drop in low-level zones.",
        zone = "Elwynn Forest",
    },

    -- Legs — Alliance mail melee (level 5)
    {
        id = "early5_legs_stormwind_guard_leggings",
        itemId = 6084,
        slot = "Legs",
        minLevel = LEVEL5_MIN,
        maxLevel = LEVEL5_MAX,
        classes = MAIL_MELEE,
        factions = ALLIANCE,
        curatedRank = 1,
        sourceType = "quest_reward",
        instructions = "Complete Wanted: Hogger in Elwynn Forest and choose Stormwind Guard Leggings (+3 Strength) over the other quest rewards.",
        zone = "Elwynn Forest",
        npc = "Marshal Dughan",
        questName = "Wanted: \"Hogger\"",
    },
    {
        id = "early5_legs_warriors_pants",
        itemId = 2966,
        slot = "Legs",
        minLevel = LEVEL5_MIN,
        maxLevel = LEVEL5_MAX,
        classes = MAIL_MELEE,
        factions = ALLIANCE,
        curatedRank = 2,
        sourceType = "world_drop",
        instructions = "Warrior's Pants (req 5) are a green mail world drop in starter zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early5_legs_light_mail_leggings",
        itemId = 2394,
        slot = "Legs",
        minLevel = LEVEL5_MIN,
        maxLevel = LEVEL5_MAX,
        classes = MAIL_MELEE,
        factions = ALLIANCE,
        curatedRank = 3,
        sourceType = "vendor",
        instructions = "Buy Light Mail Leggings (req 5) from Andrew Krighton in Goldshire or another mail vendor in a starter city.",
        zone = "Elwynn Forest",
        npc = "Andrew Krighton",
    },

    -- Waist — mail melee, both factions (level 5)
    {
        id = "early5_waist_light_chain_belt",
        itemId = 2399,
        slot = "Waist",
        minLevel = LEVEL5_MIN,
        maxLevel = LEVEL5_MAX,
        classes = MAIL_MELEE,
        curatedRank = 1,
        sourceType = "vendor",
        instructions = "Buy Light Chain Belt (req 5) from a mail armor vendor in your starter city.",
        zone = "Elwynn Forest",
    },
    {
        id = "early5_waist_light_mail_belt",
        itemId = 2393,
        slot = "Waist",
        minLevel = LEVEL5_MIN,
        maxLevel = LEVEL5_MAX,
        classes = MAIL_MELEE,
        curatedRank = 2,
        sourceType = "vendor",
        instructions = "Buy Light Mail Belt (req 5) from a mail armor vendor in your starter city.",
        zone = "Elwynn Forest",
    },
    {
        id = "early5_waist_battle_chain_girdle",
        itemId = 4669,
        slot = "Waist",
        minLevel = LEVEL5_MIN,
        maxLevel = LEVEL5_MAX,
        classes = MAIL_MELEE,
        curatedRank = 3,
        sourceType = "world_drop",
        instructions = "Battle Chain Girdle (req 5) is a green mail world drop in low-level zones.",
        zone = "Elwynn Forest",
    },

    -- Hands — mail melee, both factions (level 5)
    {
        id = "early5_hands_light_mail_gloves",
        itemId = 2397,
        slot = "Hands",
        minLevel = LEVEL5_MIN,
        maxLevel = LEVEL5_MAX,
        classes = MAIL_MELEE,
        curatedRank = 1,
        sourceType = "vendor",
        instructions = "Buy Light Mail Gloves (req 5) from a mail armor vendor in your starter city.",
        zone = "Elwynn Forest",
    },
    {
        id = "early5_hands_chargers_handwraps",
        itemId = 15476,
        slot = "Hands",
        minLevel = LEVEL5_MIN,
        maxLevel = LEVEL5_MAX,
        classes = MAIL_MELEE,
        curatedRank = 2,
        sourceType = "world_drop",
        instructions = "Charger's Handwraps (req 5) are a green mail world drop in low-level zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early5_hands_light_chain_gloves",
        itemId = 2403,
        slot = "Hands",
        minLevel = LEVEL5_MIN,
        maxLevel = LEVEL5_MAX,
        classes = MAIL_MELEE,
        curatedRank = 3,
        sourceType = "vendor",
        instructions = "Buy Light Chain Gloves (req 5) from a mail armor vendor in your starter city.",
        zone = "Elwynn Forest",
    },

    -- Level 6 band — Head unchanged (early4_all_head_*). No Shoulder entries.

    -- Back — Alliance, all classes (level 6)
    {
        id = "early6_back_cadet_cloak",
        itemId = 9761,
        slot = "Back",
        minLevel = LEVEL6_MIN,
        maxLevel = LEVEL6_MAX,
        factions = ALLIANCE,
        curatedRank = 1,
        sourceType = "vendor",
        instructions = "Buy Cadet Cloak (req 6) from a cloth vendor in a starter city.",
        zone = "Elwynn Forest",
    },
    {
        id = "early6_back_rain_spotted_cape",
        itemId = 5591,
        slot = "Back",
        minLevel = LEVEL6_MIN,
        maxLevel = LEVEL6_MAX,
        factions = ALLIANCE,
        curatedRank = 2,
        sourceType = "world_drop",
        instructions = "Rain-spotted Cape is a green world drop from humanoids in low-level Alliance zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early6_back_simple_cape",
        itemId = 9745,
        slot = "Back",
        minLevel = LEVEL6_MIN,
        maxLevel = LEVEL6_MAX,
        factions = ALLIANCE,
        curatedRank = 3,
        sourceType = "vendor",
        instructions = "Buy Simple Cape (req 6) from a cloth vendor in a starter city.",
        zone = "Elwynn Forest",
    },

    -- Chest — Alliance mail melee (level 6)
    {
        id = "early6_chest_warriors_tunic",
        itemId = 2965,
        slot = "Chest",
        minLevel = LEVEL6_MIN,
        maxLevel = LEVEL6_MAX,
        classes = MAIL_MELEE,
        factions = ALLIANCE,
        curatedRank = 1,
        sourceType = "world_drop",
        instructions = "Warrior's Tunic (req 6) is a green mail world drop in starter zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early6_chest_chargers_armor",
        itemId = 15479,
        slot = "Chest",
        minLevel = LEVEL6_MIN,
        maxLevel = LEVEL6_MAX,
        classes = MAIL_MELEE,
        factions = ALLIANCE,
        curatedRank = 2,
        sourceType = "world_drop",
        instructions = "Charger's Armor (req 6) is a green mail world drop in starter zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early6_chest_soft_leather_tunic",
        itemId = 2817,
        slot = "Chest",
        minLevel = LEVEL6_MIN,
        maxLevel = LEVEL6_MAX,
        classes = MAIL_MELEE,
        factions = ALLIANCE,
        curatedRank = 3,
        sourceType = "quest_reward",
        instructions = "Complete Protecting the Herd in Dun Morogh and choose Soft Leather Tunic over the other rewards. Leather chest with +2 Stamina.",
        zone = "Dun Morogh",
        npc = "Rudra Amberstill",
        questName = "Protecting the Herd",
    },

    -- Wrist — mail melee, both factions (level 6)
    {
        id = "early6_wrist_war_torn_bands",
        itemId = 15482,
        slot = "Wrist",
        minLevel = LEVEL6_MIN,
        maxLevel = LEVEL6_MAX,
        classes = MAIL_MELEE,
        curatedRank = 1,
        sourceType = "world_drop",
        instructions = "War-torn Bands (req 6) are a green mail world drop in low-level zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early6_wrist_light_chain_bracers",
        itemId = 2402,
        slot = "Wrist",
        minLevel = LEVEL6_MIN,
        maxLevel = LEVEL6_MAX,
        classes = MAIL_MELEE,
        curatedRank = 2,
        sourceType = "vendor",
        instructions = "Buy Light Chain Bracers (req 5) from a mail armor vendor in your starter city.",
        zone = "Elwynn Forest",
    },
    {
        id = "early6_wrist_light_mail_bracers",
        itemId = 2396,
        slot = "Wrist",
        minLevel = LEVEL6_MIN,
        maxLevel = LEVEL6_MAX,
        classes = MAIL_MELEE,
        curatedRank = 3,
        sourceType = "vendor",
        instructions = "Buy Light Mail Bracers (req 5) from a mail armor vendor in your starter city.",
        zone = "Elwynn Forest",
    },

    -- Main Hand — mail melee, both factions (level 6)
    {
        id = "early6_mainhand_coldridge_hammer",
        itemId = 3103,
        slot = "MainHand",
        minLevel = LEVEL6_MIN,
        maxLevel = LEVEL6_MAX,
        classes = MAIL_MELEE,
        curatedRank = 1,
        sourceType = "quest_reward",
        instructions = "Complete Protecting the Herd in Dun Morogh and choose Coldridge Hammer over the other rewards. Train Two-Handed Maces first.",
        zone = "Dun Morogh",
        npc = "Rudra Amberstill",
        questName = "Protecting the Herd",
    },
    {
        id = "early6_mainhand_training_sword",
        itemId = 8178,
        slot = "MainHand",
        minLevel = LEVEL6_MIN,
        maxLevel = LEVEL6_MAX,
        classes = MAIL_MELEE,
        curatedRank = 2,
        sourceType = "world_drop",
        instructions = "Training Sword (req 5) is a green two-handed sword world drop. Train Two-Handed Swords from a weapon master first.",
        zone = "Elwynn Forest",
    },
    {
        id = "early6_mainhand_severing_axe",
        itemId = 4562,
        slot = "MainHand",
        minLevel = LEVEL6_MIN,
        maxLevel = LEVEL6_MAX,
        classes = MAIL_MELEE,
        curatedRank = 3,
        sourceType = "world_drop",
        instructions = "Severing Axe (req 5) is a green two-handed axe world drop. Train Two-Handed Axes from a weapon master first.",
        zone = "Elwynn Forest",
    },

    -- Off Hand — mail melee, both factions (level 6)
    {
        id = "early6_offhand_infantry_shield",
        itemId = 7108,
        slot = "SecondaryHand",
        minLevel = LEVEL6_MIN,
        maxLevel = LEVEL6_MAX,
        classes = MAIL_MELEE,
        curatedRank = 1,
        sourceType = "world_drop",
        instructions = "Infantry Shield (req 6) is a green mail shield world drop with random stat bonuses.",
        zone = "Elwynn Forest",
    },
    {
        id = "early6_offhand_thuggish_shield",
        itemId = 6203,
        slot = "SecondaryHand",
        minLevel = LEVEL6_MIN,
        maxLevel = LEVEL6_MAX,
        classes = MAIL_MELEE,
        curatedRank = 2,
        sourceType = "world_drop",
        instructions = "Thuggish Shield (req 6) is a green shield world drop in low-level zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early6_offhand_tribal_buckler",
        itemId = 3649,
        slot = "SecondaryHand",
        minLevel = LEVEL6_MIN,
        maxLevel = LEVEL6_MAX,
        classes = MAIL_MELEE,
        curatedRank = 3,
        sourceType = "vendor",
        instructions = "Buy Tribal Buckler (req 6) from a shield vendor in your starter city.",
        zone = "Elwynn Forest",
    },

    -- Feet — mail melee, both factions (level 6)
    {
        id = "early6_feet_infantry_boots",
        itemId = 6506,
        slot = "Feet",
        minLevel = LEVEL6_MIN,
        maxLevel = LEVEL6_MAX,
        classes = MAIL_MELEE,
        curatedRank = 1,
        sourceType = "vendor",
        instructions = "Buy Infantry Boots (req 6) from a mail armor vendor in your starter city.",
        zone = "Elwynn Forest",
    },
    {
        id = "early6_feet_light_chain_boots",
        itemId = 2401,
        slot = "Feet",
        minLevel = LEVEL6_MIN,
        maxLevel = LEVEL6_MAX,
        classes = MAIL_MELEE,
        curatedRank = 2,
        sourceType = "vendor",
        instructions = "Buy Light Chain Boots (req 5) from a mail armor vendor in your starter city.",
        zone = "Elwynn Forest",
    },
    {
        id = "early6_feet_light_mail_boots",
        itemId = 2395,
        slot = "Feet",
        minLevel = LEVEL6_MIN,
        maxLevel = LEVEL6_MAX,
        classes = MAIL_MELEE,
        curatedRank = 3,
        sourceType = "vendor",
        instructions = "Buy Light Mail Boots (req 5) from a mail armor vendor in your starter city.",
        zone = "Elwynn Forest",
    },

    -- Legs — Alliance mail melee (level 6)
    {
        id = "early6_legs_stormwind_guard_leggings",
        itemId = 6084,
        slot = "Legs",
        minLevel = LEVEL6_MIN,
        maxLevel = LEVEL6_MAX,
        classes = MAIL_MELEE,
        factions = ALLIANCE,
        curatedRank = 1,
        sourceType = "quest_reward",
        instructions = "Complete Wanted: Hogger in Elwynn Forest and choose Stormwind Guard Leggings (+3 Strength, 113 armor) over the other quest rewards.",
        zone = "Elwynn Forest",
        npc = "Marshal Dughan",
        questName = "Wanted: \"Hogger\"",
    },
    {
        id = "early6_legs_chargers_pants",
        itemId = 15477,
        slot = "Legs",
        minLevel = LEVEL6_MIN,
        maxLevel = LEVEL6_MAX,
        classes = MAIL_MELEE,
        factions = ALLIANCE,
        curatedRank = 2,
        sourceType = "world_drop",
        instructions = "Charger's Pants (req 6) are a green mail world drop in starter zones (101 armor, random stats).",
        zone = "Elwynn Forest",
    },
    {
        id = "early6_legs_warriors_pants",
        itemId = 2966,
        slot = "Legs",
        minLevel = LEVEL6_MIN,
        maxLevel = LEVEL6_MAX,
        classes = MAIL_MELEE,
        factions = ALLIANCE,
        curatedRank = 3,
        sourceType = "world_drop",
        instructions = "Warrior's Pants (req 5) are a green mail world drop in starter zones.",
        zone = "Elwynn Forest",
    },

    -- Waist — mail melee, both factions (level 6)
    {
        id = "early6_waist_copper_chain_belt",
        itemId = 2851,
        slot = "Waist",
        minLevel = LEVEL6_MIN,
        maxLevel = LEVEL6_MAX,
        classes = MAIL_MELEE,
        curatedRank = 1,
        sourceType = "profession",
        profession = "Blacksmithing",
        instructions = "Learn Copper Chain Belt and craft at an anvil (requires level 6), or buy from a vendor if available.",
        zone = "Elwynn Forest",
        npc = "Smith Argus",
    },
    {
        id = "early6_waist_royal_frostmane_girdle",
        itemId = 2546,
        slot = "Waist",
        minLevel = LEVEL6_MIN,
        maxLevel = LEVEL6_MAX,
        classes = MAIL_MELEE,
        curatedRank = 2,
        sourceType = "world_drop",
        instructions = "Royal Frostmane Girdle (req 6) drops from Frostmane trolls in Dun Morogh.",
        zone = "Dun Morogh",
    },
    {
        id = "early6_waist_shackled_girdle",
        itemId = 5592,
        slot = "Waist",
        minLevel = LEVEL6_MIN,
        maxLevel = LEVEL6_MAX,
        classes = MAIL_MELEE,
        curatedRank = 3,
        sourceType = "world_drop",
        instructions = "Shackled Girdle is a green mail world drop from humanoids in low-level zones.",
        zone = "Elwynn Forest",
    },

    -- Hands — mail melee, both factions (level 6)
    {
        id = "early6_hands_battle_chain_gloves",
        itemId = 3281,
        slot = "Hands",
        minLevel = LEVEL6_MIN,
        maxLevel = LEVEL6_MAX,
        classes = MAIL_MELEE,
        curatedRank = 1,
        sourceType = "world_drop",
        instructions = "Battle Chain Gloves (req 6) are a green mail world drop in low-level zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early6_hands_infantry_gauntlets",
        itemId = 6510,
        slot = "Hands",
        minLevel = LEVEL6_MIN,
        maxLevel = LEVEL6_MAX,
        classes = MAIL_MELEE,
        curatedRank = 2,
        sourceType = "vendor",
        instructions = "Buy Infantry Gauntlets (req 6) from a mail armor vendor in your starter city.",
        zone = "Elwynn Forest",
    },
    {
        id = "early6_hands_worn_mail_gloves",
        itemId = 1734,
        slot = "Hands",
        minLevel = LEVEL6_MIN,
        maxLevel = LEVEL6_MAX,
        classes = MAIL_MELEE,
        curatedRank = 3,
        sourceType = "vendor",
        instructions = "Buy Worn Mail Gloves from a mail armor vendor in your starter city.",
        zone = "Elwynn Forest",
    },

    -- Level 7 band — Head unchanged (early4_all_head_*). No Shoulder entries.

    -- Back — Alliance, all classes (level 7)
    {
        id = "early7_back_reinforced_linen_cape",
        itemId = 2580,
        slot = "Back",
        minLevel = LEVEL7_MIN,
        maxLevel = LEVEL7_MAX,
        factions = ALLIANCE,
        curatedRank = 1,
        sourceType = "profession",
        profession = "Tailoring",
        instructions = "Learn Reinforced Linen Cape from a Tailoring trainer and craft at a loom (Tailoring 60). +1 Intellect.",
        zone = "Stormwind City",
    },
    {
        id = "early7_back_veteran_cloak",
        itemId = 4677,
        slot = "Back",
        minLevel = LEVEL7_MIN,
        maxLevel = LEVEL7_MAX,
        factions = ALLIANCE,
        curatedRank = 2,
        sourceType = "world_drop",
        instructions = "Veteran Cloak (req 7, 11 armor) is a common world drop from humanoids in low-level Alliance zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early7_back_ceremonial_cloak",
        itemId = 4692,
        slot = "Back",
        minLevel = LEVEL7_MIN,
        maxLevel = LEVEL7_MAX,
        factions = ALLIANCE,
        curatedRank = 3,
        sourceType = "world_drop",
        instructions = "Ceremonial Cloak (req 7, 11 armor) is a common world drop from humanoids in starter zones.",
        zone = "Elwynn Forest",
    },

    -- Chest — Alliance mail melee (level 7)
    {
        id = "early7_chest_warriors_tunic",
        itemId = 2965,
        slot = "Chest",
        minLevel = LEVEL7_MIN,
        maxLevel = LEVEL7_MAX,
        classes = MAIL_MELEE,
        factions = ALLIANCE,
        curatedRank = 1,
        sourceType = "world_drop",
        instructions = "Warrior's Tunic (req 6) is a green mail world drop in starter zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early7_chest_explorers_vest",
        itemId = 7229,
        slot = "Chest",
        minLevel = LEVEL7_MIN,
        maxLevel = LEVEL7_MAX,
        classes = MAIL_MELEE,
        factions = ALLIANCE,
        curatedRank = 2,
        sourceType = "quest_reward",
        instructions = "Complete the Bashal'Aran quest chain in Darkshore (final turn-in to Asterion) and choose Explorer's Vest (+2 Stamina, +1 Intellect) over the other rewards.",
        zone = "Darkshore",
        npc = "Asterion",
        questName = "Bashal'Aran",
    },
    {
        id = "early7_chest_ravager_chitin_tunic",
        itemId = 24107,
        slot = "Chest",
        minLevel = LEVEL7_MIN,
        maxLevel = LEVEL7_MAX,
        classes = MAIL_MELEE,
        factions = ALLIANCE,
        curatedRank = 3,
        sourceType = "quest_reward",
        instructions = "Complete Beasts of the Apocalypse! on Azuremyst Isle (Draenei starter zone) and choose Ravager Chitin Tunic (+1 Strength) over the other rewards.",
        zone = "Azuremyst Isle",
        questName = "Beasts of the Apocalypse!",
    },

    -- Wrist — mail melee, both factions (level 7)
    {
        id = "early7_wrist_ironwrought_bracers",
        itemId = 6177,
        slot = "Wrist",
        minLevel = LEVEL7_MIN,
        maxLevel = LEVEL7_MAX,
        classes = MAIL_MELEE,
        curatedRank = 1,
        sourceType = "quest_reward",
        instructions = "Complete Tundra MacGrann's Stolen Stash in Dun Morogh (req 7) and choose Ironwrought Bracers over Wooly Mittens.",
        zone = "Dun Morogh",
        npc = "Tundra MacGrann",
        questName = "Tundra MacGrann's Stolen Stash",
    },
    {
        id = "early7_wrist_cadet_bracers",
        itemId = 9760,
        slot = "Wrist",
        minLevel = LEVEL7_MIN,
        maxLevel = LEVEL7_MAX,
        classes = MAIL_MELEE,
        curatedRank = 2,
        sourceType = "world_drop",
        instructions = "Cadet Bracers (req 7) are a common mail world drop from humanoids in low-level zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early7_wrist_brackwater_bracers",
        itemId = 3303,
        slot = "Wrist",
        minLevel = LEVEL7_MIN,
        maxLevel = LEVEL7_MAX,
        classes = MAIL_MELEE,
        curatedRank = 3,
        sourceType = "world_drop",
        instructions = "Brackwater Bracers (req 7) are a common mail world drop from humanoids in starter zones.",
        zone = "Elwynn Forest",
    },

    -- Main Hand — mail melee, both factions (level 7)
    {
        id = "early7_mainhand_icepane_warhammer",
        itemId = 2254,
        slot = "MainHand",
        minLevel = LEVEL7_MIN,
        maxLevel = LEVEL7_MAX,
        classes = MAIL_MELEE,
        curatedRank = 1,
        sourceType = "boss_drop",
        instructions = "Farm Icepane Warhammer (+2 Strength) from Hammerspine in the Gol'Bolar Quarry mine in Dun Morogh. Train Two-Handed Maces first.",
        zone = "Dun Morogh",
        npc = "Hammerspine",
    },
    {
        id = "early7_mainhand_short_bastard_sword",
        itemId = 3192,
        slot = "MainHand",
        minLevel = LEVEL7_MIN,
        maxLevel = LEVEL7_MAX,
        classes = MAIL_MELEE,
        curatedRank = 2,
        sourceType = "world_drop",
        instructions = "Short Bastard Sword (req 7) is a green two-handed sword world drop. Train Two-Handed Swords from a weapon master first.",
        zone = "Elwynn Forest",
    },
    {
        id = "early7_mainhand_coldridge_hammer",
        itemId = 3103,
        slot = "MainHand",
        minLevel = LEVEL7_MIN,
        maxLevel = LEVEL7_MAX,
        classes = MAIL_MELEE,
        curatedRank = 3,
        sourceType = "quest_reward",
        instructions = "Complete Protecting the Herd in Dun Morogh and choose Coldridge Hammer over the other rewards. Train Two-Handed Maces first.",
        zone = "Dun Morogh",
        npc = "Rudra Amberstill",
        questName = "Protecting the Herd",
    },

    -- Off Hand — mail melee, both factions (level 7)
    {
        id = "early7_offhand_gypsy_buckler",
        itemId = 9753,
        slot = "SecondaryHand",
        minLevel = LEVEL7_MIN,
        maxLevel = LEVEL7_MAX,
        classes = MAIL_MELEE,
        curatedRank = 1,
        sourceType = "world_drop",
        instructions = "Gypsy Buckler (req 7) is a green shield world drop with random stat bonuses.",
        zone = "Elwynn Forest",
    },
    {
        id = "early7_offhand_war_torn_shield",
        itemId = 15486,
        slot = "SecondaryHand",
        minLevel = LEVEL7_MIN,
        maxLevel = LEVEL7_MAX,
        classes = MAIL_MELEE,
        curatedRank = 2,
        sourceType = "world_drop",
        instructions = "War-torn Shield (req 7) is a green shield world drop from humanoids in low-level zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early7_offhand_infantry_shield",
        itemId = 7108,
        slot = "SecondaryHand",
        minLevel = LEVEL7_MIN,
        maxLevel = LEVEL7_MAX,
        classes = MAIL_MELEE,
        curatedRank = 3,
        sourceType = "world_drop",
        instructions = "Infantry Shield (req 6) is a green mail shield world drop with random stat bonuses.",
        zone = "Elwynn Forest",
    },

    -- Feet — mail melee, both factions (level 7)
    {
        id = "early7_feet_battle_chain_boots",
        itemId = 3279,
        slot = "Feet",
        minLevel = LEVEL7_MIN,
        maxLevel = LEVEL7_MAX,
        classes = MAIL_MELEE,
        curatedRank = 1,
        sourceType = "world_drop",
        instructions = "Battle Chain Boots (req 7) are a common mail world drop from humanoids in starter zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early7_feet_infantry_boots",
        itemId = 6506,
        slot = "Feet",
        minLevel = LEVEL7_MIN,
        maxLevel = LEVEL7_MAX,
        classes = MAIL_MELEE,
        curatedRank = 2,
        sourceType = "vendor",
        instructions = "Buy Infantry Boots (req 6) from a mail armor vendor in your starter city.",
        zone = "Elwynn Forest",
    },
    {
        id = "early7_feet_light_chain_boots",
        itemId = 2401,
        slot = "Feet",
        minLevel = LEVEL7_MIN,
        maxLevel = LEVEL7_MAX,
        classes = MAIL_MELEE,
        curatedRank = 3,
        sourceType = "vendor",
        instructions = "Buy Light Chain Boots (req 5) from a mail armor vendor in your starter city.",
        zone = "Elwynn Forest",
    },

    -- Legs — Alliance mail melee (level 7)
    {
        id = "early7_legs_stormwind_guard_leggings",
        itemId = 6084,
        slot = "Legs",
        minLevel = LEVEL7_MIN,
        maxLevel = LEVEL7_MAX,
        classes = MAIL_MELEE,
        factions = ALLIANCE,
        curatedRank = 1,
        sourceType = "quest_reward",
        instructions = "Complete Wanted: Hogger in Elwynn Forest and choose Stormwind Guard Leggings (+3 Strength) over the other quest rewards.",
        zone = "Elwynn Forest",
        npc = "Marshal Dughan",
        questName = "Wanted: \"Hogger\"",
    },
    {
        id = "early7_legs_infantry_leggings",
        itemId = 6337,
        slot = "Legs",
        minLevel = LEVEL7_MIN,
        maxLevel = LEVEL7_MAX,
        classes = MAIL_MELEE,
        factions = ALLIANCE,
        curatedRank = 2,
        sourceType = "world_drop",
        instructions = "Infantry Leggings (req 7) are a green mail world drop in starter zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early7_legs_battle_chain_pants",
        itemId = 3282,
        slot = "Legs",
        minLevel = LEVEL7_MIN,
        maxLevel = LEVEL7_MAX,
        classes = MAIL_MELEE,
        factions = ALLIANCE,
        curatedRank = 3,
        sourceType = "world_drop",
        instructions = "Battle Chain Pants (req 7) are a common mail world drop from humanoids in starter zones.",
        zone = "Elwynn Forest",
    },

    -- Waist — mail melee, both factions (level 7)
    {
        id = "early7_waist_cadet_belt",
        itemId = 9758,
        slot = "Waist",
        minLevel = LEVEL7_MIN,
        maxLevel = LEVEL7_MAX,
        classes = MAIL_MELEE,
        curatedRank = 1,
        sourceType = "world_drop",
        instructions = "Cadet Belt (req 7) is a common mail world drop from humanoids in low-level zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early7_waist_worn_mail_belt",
        itemId = 1730,
        slot = "Waist",
        minLevel = LEVEL7_MIN,
        maxLevel = LEVEL7_MAX,
        classes = MAIL_MELEE,
        curatedRank = 2,
        sourceType = "vendor",
        instructions = "Buy Worn Mail Belt (req 7) from a mail armor vendor in your starter city.",
        zone = "Elwynn Forest",
    },
    {
        id = "early7_waist_copper_chain_belt",
        itemId = 2851,
        slot = "Waist",
        minLevel = LEVEL7_MIN,
        maxLevel = LEVEL7_MAX,
        classes = MAIL_MELEE,
        curatedRank = 3,
        sourceType = "profession",
        profession = "Blacksmithing",
        instructions = "Learn Copper Chain Belt and craft at an anvil (requires level 6), or buy from a vendor if available.",
        zone = "Elwynn Forest",
        npc = "Smith Argus",
    },

    -- Hands — mail melee, both factions (level 7)
    {
        id = "early7_hands_runed_copper_gauntlets",
        itemId = 3472,
        slot = "Hands",
        minLevel = LEVEL7_MIN,
        maxLevel = LEVEL7_MAX,
        classes = MAIL_MELEE,
        curatedRank = 1,
        sourceType = "profession",
        profession = "Blacksmithing",
        instructions = "Learn Runed Copper Gauntlets from a Blacksmithing trainer and craft at an anvil (Blacksmithing 40). Random +Agility or +Intellect.",
        zone = "Stormwind City",
    },
    {
        id = "early7_hands_war_torn_handgrips",
        itemId = 15484,
        slot = "Hands",
        minLevel = LEVEL7_MIN,
        maxLevel = LEVEL7_MAX,
        classes = MAIL_MELEE,
        curatedRank = 2,
        sourceType = "world_drop",
        instructions = "War-torn Handgrips (req 7) are a green mail world drop from humanoids in low-level zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early7_hands_battle_chain_gloves",
        itemId = 3281,
        slot = "Hands",
        minLevel = LEVEL7_MIN,
        maxLevel = LEVEL7_MAX,
        classes = MAIL_MELEE,
        curatedRank = 3,
        sourceType = "world_drop",
        instructions = "Battle Chain Gloves (req 6) are a green mail world drop in low-level zones.",
        zone = "Elwynn Forest",
    },

    -- Level 8 band — Head unchanged (early4_all_head_*). No Shoulder entries.

    -- Back — Alliance, all classes (level 8)
    {
        id = "early8_back_embossed_leather_cloak",
        itemId = 2310,
        slot = "Back",
        minLevel = LEVEL8_MIN,
        maxLevel = LEVEL8_MAX,
        factions = ALLIANCE,
        curatedRank = 1,
        sourceType = "profession",
        profession = "Leatherworking",
        instructions = "Learn Embossed Leather Cloak from a Leatherworking trainer and craft at a workbench (Leatherworking 60). +1 Stamina.",
        zone = "Stormwind City",
    },
    {
        id = "early8_back_brackwater_cloak",
        itemId = 4680,
        slot = "Back",
        minLevel = LEVEL8_MIN,
        maxLevel = LEVEL8_MAX,
        factions = ALLIANCE,
        curatedRank = 2,
        sourceType = "world_drop",
        instructions = "Brackwater Cloak (req 8, 12 armor) is a common world drop from humanoids in low-level Alliance zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early8_back_hunting_cloak",
        itemId = 4689,
        slot = "Back",
        minLevel = LEVEL8_MIN,
        maxLevel = LEVEL8_MAX,
        factions = ALLIANCE,
        curatedRank = 3,
        sourceType = "world_drop",
        instructions = "Hunting Cloak (req 8, 12 armor) is a common world drop from humanoids in starter zones.",
        zone = "Elwynn Forest",
    },

    -- Chest — Alliance mail melee (level 8)
    {
        id = "early8_chest_infantry_tunic",
        itemId = 6336,
        slot = "Chest",
        minLevel = LEVEL8_MIN,
        maxLevel = LEVEL8_MAX,
        classes = MAIL_MELEE,
        factions = ALLIANCE,
        curatedRank = 1,
        sourceType = "world_drop",
        instructions = "Infantry Tunic (req 8) is a green mail world drop with random Strength or Stamina bonuses.",
        zone = "Elwynn Forest",
    },
    {
        id = "early8_chest_dargols_hauberk",
        itemId = 3330,
        slot = "Chest",
        minLevel = LEVEL8_MIN,
        maxLevel = LEVEL8_MAX,
        classes = MAIL_MELEE,
        factions = ALLIANCE,
        curatedRank = 2,
        sourceType = "boss_drop",
        instructions = "Farm Dargol's Hauberk (+2 Strength, +1 Stamina) from Captain Dargol in the Agamand Family Crypt in Tirisfal Glades (~2% drop).",
        zone = "Tirisfal Glades",
        npc = "Captain Dargol",
    },
    {
        id = "early8_chest_battle_chain_tunic",
        itemId = 3283,
        slot = "Chest",
        minLevel = LEVEL8_MIN,
        maxLevel = LEVEL8_MAX,
        classes = MAIL_MELEE,
        factions = ALLIANCE,
        curatedRank = 3,
        sourceType = "world_drop",
        instructions = "Battle Chain Tunic (req 8) is a common mail world drop from humanoids in starter zones.",
        zone = "Elwynn Forest",
    },

    -- Wrist — mail melee, both factions (level 8)
    {
        id = "early8_wrist_veteran_bracers",
        itemId = 3213,
        slot = "Wrist",
        minLevel = LEVEL8_MIN,
        maxLevel = LEVEL8_MAX,
        classes = MAIL_MELEE,
        curatedRank = 1,
        sourceType = "world_drop",
        instructions = "Veteran Bracers (req 8) are a common mail world drop from humanoids in low-level zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early8_wrist_ironwrought_bracers",
        itemId = 6177,
        slot = "Wrist",
        minLevel = LEVEL8_MIN,
        maxLevel = LEVEL8_MAX,
        classes = MAIL_MELEE,
        curatedRank = 2,
        sourceType = "quest_reward",
        instructions = "Complete Tundra MacGrann's Stolen Stash in Dun Morogh (req 7) and choose Ironwrought Bracers over Wooly Mittens.",
        zone = "Dun Morogh",
        npc = "Tundra MacGrann",
        questName = "Tundra MacGrann's Stolen Stash",
    },
    {
        id = "early8_wrist_cadet_bracers",
        itemId = 9760,
        slot = "Wrist",
        minLevel = LEVEL8_MIN,
        maxLevel = LEVEL8_MAX,
        classes = MAIL_MELEE,
        curatedRank = 3,
        sourceType = "world_drop",
        instructions = "Cadet Bracers (req 7) are a common mail world drop from humanoids in low-level zones.",
        zone = "Elwynn Forest",
    },

    -- Main Hand — mail melee, both factions (level 8)
    {
        id = "early8_mainhand_spiked_club",
        itemId = 4564,
        slot = "MainHand",
        minLevel = LEVEL8_MIN,
        maxLevel = LEVEL8_MAX,
        classes = MAIL_MELEE,
        curatedRank = 1,
        sourceType = "world_drop",
        instructions = "Spiked Club (req 8) is a green two-handed mace world drop with random stat bonuses. Train Two-Handed Maces first.",
        zone = "Westfall",
    },
    {
        id = "early8_mainhand_copper_battle_axe",
        itemId = 3488,
        slot = "MainHand",
        minLevel = LEVEL8_MIN,
        maxLevel = LEVEL8_MAX,
        classes = MAIL_MELEE,
        curatedRank = 2,
        sourceType = "profession",
        profession = "Blacksmithing",
        instructions = "Learn Copper Battle Axe from a Blacksmithing trainer and craft at an anvil (Blacksmithing 35). Train Two-Handed Axes first.",
        zone = "Stormwind City",
    },
    {
        id = "early8_mainhand_icepane_warhammer",
        itemId = 2254,
        slot = "MainHand",
        minLevel = LEVEL8_MIN,
        maxLevel = LEVEL8_MAX,
        classes = MAIL_MELEE,
        curatedRank = 3,
        sourceType = "boss_drop",
        instructions = "Farm Icepane Warhammer (+2 Strength) from Hammerspine in the Gol'Bolar Quarry mine in Dun Morogh. Train Two-Handed Maces first.",
        zone = "Dun Morogh",
        npc = "Hammerspine",
    },

    -- Off Hand — mail melee, both factions (level 8)
    {
        id = "early8_offhand_cadet_shield",
        itemId = 9764,
        slot = "SecondaryHand",
        minLevel = LEVEL8_MIN,
        maxLevel = LEVEL8_MAX,
        classes = MAIL_MELEE,
        curatedRank = 1,
        sourceType = "world_drop",
        instructions = "Cadet Shield (req 8) is a green shield world drop with random stat bonuses.",
        zone = "Elwynn Forest",
    },
    {
        id = "early8_offhand_grizzly_buckler",
        itemId = 15298,
        slot = "SecondaryHand",
        minLevel = LEVEL8_MIN,
        maxLevel = LEVEL8_MAX,
        classes = MAIL_MELEE,
        curatedRank = 2,
        sourceType = "world_drop",
        instructions = "Grizzly Buckler (req 8) is a green shield world drop from humanoids in low-level zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early8_offhand_gypsy_buckler",
        itemId = 9753,
        slot = "SecondaryHand",
        minLevel = LEVEL8_MIN,
        maxLevel = LEVEL8_MAX,
        classes = MAIL_MELEE,
        curatedRank = 3,
        sourceType = "world_drop",
        instructions = "Gypsy Buckler (req 7) is a green shield world drop with random stat bonuses.",
        zone = "Elwynn Forest",
    },

    -- Feet — mail melee, both factions (level 8)
    {
        id = "early8_feet_cadet_boots",
        itemId = 9759,
        slot = "Feet",
        minLevel = LEVEL8_MIN,
        maxLevel = LEVEL8_MAX,
        classes = MAIL_MELEE,
        curatedRank = 1,
        sourceType = "world_drop",
        instructions = "Cadet Boots (req 8) are a common mail world drop from humanoids in low-level zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early8_feet_war_torn_greaves",
        itemId = 15481,
        slot = "Feet",
        minLevel = LEVEL8_MIN,
        maxLevel = LEVEL8_MAX,
        classes = MAIL_MELEE,
        curatedRank = 2,
        sourceType = "world_drop",
        instructions = "War-Torn Greaves (req 8) are a green mail world drop from humanoids in low-level zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early8_feet_battle_chain_boots",
        itemId = 3279,
        slot = "Feet",
        minLevel = LEVEL8_MIN,
        maxLevel = LEVEL8_MAX,
        classes = MAIL_MELEE,
        curatedRank = 3,
        sourceType = "world_drop",
        instructions = "Battle Chain Boots (req 7) are a common mail world drop from humanoids in starter zones.",
        zone = "Elwynn Forest",
    },

    -- Legs — Alliance mail melee (level 8)
    {
        id = "early8_legs_runed_copper_pants",
        itemId = 3473,
        slot = "Legs",
        minLevel = LEVEL8_MIN,
        maxLevel = LEVEL8_MAX,
        classes = MAIL_MELEE,
        factions = ALLIANCE,
        curatedRank = 1,
        sourceType = "profession",
        profession = "Blacksmithing",
        instructions = "Learn Runed Copper Pants from a Blacksmithing trainer and craft at an anvil (Blacksmithing 45). +2 Strength, +2 Stamina.",
        zone = "Stormwind City",
    },
    {
        id = "early8_legs_stormwind_guard_leggings",
        itemId = 6084,
        slot = "Legs",
        minLevel = LEVEL8_MIN,
        maxLevel = LEVEL8_MAX,
        classes = MAIL_MELEE,
        factions = ALLIANCE,
        curatedRank = 2,
        sourceType = "quest_reward",
        instructions = "Complete Wanted: Hogger in Elwynn Forest and choose Stormwind Guard Leggings (+3 Strength) over the other quest rewards.",
        zone = "Elwynn Forest",
        npc = "Marshal Dughan",
        questName = "Wanted: \"Hogger\"",
    },
    {
        id = "early8_legs_infantry_leggings",
        itemId = 6337,
        slot = "Legs",
        minLevel = LEVEL8_MIN,
        maxLevel = LEVEL8_MAX,
        classes = MAIL_MELEE,
        factions = ALLIANCE,
        curatedRank = 3,
        sourceType = "world_drop",
        instructions = "Infantry Leggings (req 7) are a green mail world drop in starter zones.",
        zone = "Elwynn Forest",
    },

    -- Waist — mail melee, both factions (level 8)
    {
        id = "early8_waist_belt_of_peoples_militia",
        itemId = 1154,
        slot = "Waist",
        minLevel = LEVEL8_MIN,
        maxLevel = LEVEL8_MAX,
        classes = MAIL_MELEE,
        curatedRank = 1,
        sourceType = "quest_reward",
        instructions = "Complete Patrolling Westfall on Sentinel Hill and choose Belt of the People's Militia over Bracers of the People's Militia.",
        zone = "Westfall",
        npc = "Captain Danuvin",
        questName = "Patrolling Westfall",
    },
    {
        id = "early8_waist_war_torn_girdle",
        itemId = 15480,
        slot = "Waist",
        minLevel = LEVEL8_MIN,
        maxLevel = LEVEL8_MAX,
        classes = MAIL_MELEE,
        curatedRank = 2,
        sourceType = "world_drop",
        instructions = "War-Torn Girdle (req 8) is a green mail world drop from humanoids in low-level zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early8_waist_cadet_belt",
        itemId = 9758,
        slot = "Waist",
        minLevel = LEVEL8_MIN,
        maxLevel = LEVEL8_MAX,
        classes = MAIL_MELEE,
        curatedRank = 3,
        sourceType = "world_drop",
        instructions = "Cadet Belt (req 7) is a common mail world drop from humanoids in low-level zones.",
        zone = "Elwynn Forest",
    },

    -- Hands — mail melee, both factions (level 8)
    {
        id = "early8_hands_cadet_gauntlets",
        itemId = 9762,
        slot = "Hands",
        minLevel = LEVEL8_MIN,
        maxLevel = LEVEL8_MAX,
        classes = MAIL_MELEE,
        curatedRank = 1,
        sourceType = "world_drop",
        instructions = "Cadet Gauntlets (req 8) are a common mail world drop from humanoids in low-level zones.",
        zone = "Elwynn Forest",
    },
    {
        id = "early8_hands_runed_copper_gauntlets",
        itemId = 3472,
        slot = "Hands",
        minLevel = LEVEL8_MIN,
        maxLevel = LEVEL8_MAX,
        classes = MAIL_MELEE,
        curatedRank = 2,
        sourceType = "profession",
        profession = "Blacksmithing",
        instructions = "Learn Runed Copper Gauntlets from a Blacksmithing trainer and craft at an anvil (Blacksmithing 40). Random +Agility or +Intellect.",
        zone = "Stormwind City",
    },
    {
        id = "early8_hands_war_torn_handgrips",
        itemId = 15484,
        slot = "Hands",
        minLevel = LEVEL8_MIN,
        maxLevel = LEVEL8_MAX,
        classes = MAIL_MELEE,
        curatedRank = 3,
        sourceType = "world_drop",
        instructions = "War-torn Handgrips (req 7) are a green mail world drop from humanoids in low-level zones.",
        zone = "Elwynn Forest",
    },

    -- Later Alliance leveling (unchanged horizon)
    {
        id = "early_chest_tunic_westfall",
        itemId = 2041,
        slot = "Chest",
        minLevel = 9,
        maxLevel = 18,
        factions = ALLIANCE,
        sourceType = "quest_reward",
        instructions = "Finish The Defias Brotherhood quest chain in Westfall. Turn in VanCleef's Head to Gryan Stoutmantle at Sentinel Hill and choose the Tunic of Westfall (leather chest).",
        zone = "Westfall",
        npc = "Gryan Stoutmantle",
        questName = "The Defias Brotherhood",
    },
    {
        id = "paladin_mainhand_hogger_blade",
        itemId = 6331,
        slot = "MainHand",
        minLevel = 6,
        maxLevel = 15,
        classes = { PALADIN = true },
        factions = ALLIANCE,
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
        factions = ALLIANCE,
        sourceType = "quest_reward",
        instructions = "Complete the Paladin Test of Righteousness chain starting with The Tome of Valor in Stormwind. Gather Jordan's materials from Deadmines, Loch Modan, Shadowfang Keep, and Darkshore, then return to Jordan Stilwell in Ironforge.",
        zone = "Stormwind City",
        questName = "The Tome of Valor",
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
    self.byItemId = {}
    for _, entry in ipairs(self.entries) do
        self.bySlot[entry.slot] = self.bySlot[entry.slot] or {}
        table.insert(self.bySlot[entry.slot], entry)
        self.byItemId[entry.itemId] = self.byItemId[entry.itemId] or {}
        table.insert(self.byItemId[entry.itemId], entry)
    end
end

function GQ.Data:GetEntriesByItemId(itemId)
    if not itemId then
        return {}
    end
    return self.byItemId and self.byItemId[itemId] or {}
end

function GQ.Data:GetItemDisplayName(itemId)
    if not itemId then
        return nil
    end

    local name = GetItemInfo(itemId)
    if name then
        return name
    end

    return PROFESSION_ITEM_NAMES[itemId]
end

function GQ.Data:GetEntryById(id)
    for _, entry in ipairs(self.entries) do
        if entry.id == id then
            return entry
        end
    end
end

function GQ.Data:EntryMatchesPlayerBand(entry)
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

    return true
end

function GQ.Data:EntryMatchesPlayer(entry)
    if not self:EntryMatchesPlayerBand(entry) then
        return false
    end

    if not GQ.Equip:EntryMatchesItemRules(entry) then
        return false
    end

    return true
end

function GQ.Data:FilterToActiveBand(entries)
    if not entries or #entries == 0 then
        return entries
    end

    local playerLevel = GQ:GetEffectiveLevel()
    local activeMinLevel

    for _, entry in ipairs(entries) do
        local minLevel = entry.minLevel or 1
        if playerLevel >= minLevel then
            if not activeMinLevel or minLevel > activeMinLevel then
                activeMinLevel = minLevel
            end
        end
    end

    if not activeMinLevel then
        return entries
    end

    local filtered = {}
    for _, entry in ipairs(entries) do
        if (entry.minLevel or 1) == activeMinLevel then
            table.insert(filtered, entry)
        end
    end

    return filtered
end

function GQ.Data:GetActiveBandMinLevel()
    local playerLevel = GQ:GetEffectiveLevel()
    local activeMinLevel

    for _, entry in ipairs(self.entries or {}) do
        if self:EntryMatchesPlayerBand(entry) then
            local minLevel = entry.minLevel or 1
            if playerLevel >= minLevel then
                if not activeMinLevel or minLevel > activeMinLevel then
                    activeMinLevel = minLevel
                end
            end
        end
    end

    return activeMinLevel
end

function GQ.Data:IsEntryNewForPlayer(entry)
    if not entry then
        return false
    end

    local activeMinLevel = self:GetActiveBandMinLevel()
    if not activeMinLevel then
        return false
    end

    return (entry.minLevel or 1) == activeMinLevel
end

function GQ.Data:GetCandidatesForSlot(slotName)
    local results = {}
    local seen = {}

    for _, key in ipairs(self:GetCandidateSlotKeys(slotName)) do
        for _, entry in ipairs(self.bySlot[key] or {}) do
            if entry.itemId then
                GetItemInfo(entry.itemId)
            end
        end
    end

    for _, key in ipairs(self:GetCandidateSlotKeys(slotName)) do
        for _, entry in ipairs(self.bySlot[key] or {}) do
            if not seen[entry.id] and self:EntryMatchesPlayerBand(entry) then
                seen[entry.id] = true
                table.insert(results, entry)
            end
        end
    end

    results = self:FilterToActiveBand(results)

    local filtered = {}
    for _, entry in ipairs(results) do
        if GQ.Equip:EntryMatchesItemRules(entry) then
            table.insert(filtered, entry)
        end
    end

    return filtered
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
