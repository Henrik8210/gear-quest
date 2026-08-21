# GearQuest data rules

Rules for adding, importing, and maintaining gear quest entries in `GearQuest/Data.lua`. Follow these when curating data from Wowhead, in-game research, or leveling guides.

## Goal

At any given level, show the **top 3 realistic upgrades per slot** for the player's **class, faction, and spec** — nothing they cannot equip, nothing far above their level.

---

## 1. Source research (Wowhead and others)

Before adding an entry, verify **all** of the following on the item's Wowhead (or in-game) page:

| Check | Rule |
|-------|------|
| **Required level** | Must be ≤ the `maxLevel` band you assign. Never tag a level-19 item for a level-4 band. |
| **Item ID** | Confirm on [Wowhead Classic](https://www.wowhead.com/classic) or classicdb.ch — wrong IDs silently show the wrong item in-game. |
| **Class / armor type** | Confirm the class can wear it at that level (e.g. Paladins cannot use daggers; plate unlocks at 40). |
| **Faction** | Set `factions = { Alliance = true }` or `{ Horde = true }` when the source is faction-locked. |
| **Spec** (level 10+) | After talents unlock, note whether the item suits Holy / Protection / Retribution (etc.). Use optional `specs` on the entry when an item is spec-specific. |
| **Slot** | Item equip slot must match the entry `slot` (MainHand, SecondaryHand, Chest, …). |
| **Source type** | One of: `world_drop`, `boss_drop`, `quest_reward`, `vendor`, `profession`, `auction_house`. |
| **Instructions** | 1–3 sentences: where to go, what to kill, which vendor, or how to craft — written for a player at that level. |

### Check every source category

When curating a level band, **search all obtainable categories** before moving on:

| # | Source type | What to look for |
|---|-------------|------------------|
| 1 | **Vendor** | Starter-zone armorers, weapon smiths, and general goods sellers. |
| 2 | **Quest reward** | Quests reachable at that level. Verify reward item IDs on Wowhead Classic (not wiki summaries alone). |
| 3 | **World drop** | Grey and green BoE from zone mobs. |
| 4 | **Boss drop** | Dungeon and world bosses reachable at that level. |
| 5 | **Profession** | Crafted gear the class can wear at that level (Blacksmithing mail for paladins, Tailoring cloaks, etc.). |

You do not need all five in every slot, but do not stop after vendors alone if another category has a valid item.

For **profession** entries, also set optional `profession = "Blacksmithing"` (or Tailoring, Leatherworking, …) and mention the trainer, recipe, and where to craft in `instructions`.

### Armor type (class best tier)

Prefer the **highest armor tier the class can wear** at that level:

| Class | Below 40 | Level 40+ |
|-------|----------|-----------|
| Paladin, Warrior | **Mail** | **Plate** |
| Hunter, Shaman | **Leather** | **Mail** |
| Druid, Rogue | **Leather** | **Leather** |
| Priest, Mage, Warlock | **Cloth** | **Cloth** |

**Data rule:** entries for a class/level band should use that class's best tier (mail for a level-4 paladin). Do not add cloth/leather filler unless the item is a genuine stat exception (see below).

**Ranking rule:** `Compare.lua` heavily penalizes lower-tier armor in Head/Chest/Legs/Feet/Hands/Wrist/Waist/Shoulder slots. A cloth or leather piece only appears in the top 3 if its item level is **≥ 8 above** the best preferred-tier option for that slot — meaning it has unusually strong stats for the level/spec. Cloaks (`Back`) and non-armor slots are exempt.

Prefer items that are **actually obtainable** at the target level (quest available, vendor visited, materials reachable, dungeon reachable), not theoretical end-of-band BiS from a generic list.

### Wowhead TBC item search (research workflow)

Use [Wowhead TBC items](https://www.wowhead.com/tbc/items) with filters, then narrow to what your class can **equip and obtain** at that level.

**Example — Alliance Paladin main-hand weapons, req level 1–4:**

```
https://www.wowhead.com/tbc/items/min-req-level:1/max-req-level:4/side:1/class:2/slot:21:13:17
```

| Filter | Meaning |
|--------|---------|
| `min-req-level` / `max-req-level` | Item required level band |
| `side:1` | Alliance |
| `class:2` | Paladin (Wowhead class id) |
| `slot:21:13:17` | Main Hand, One-Hand, Two-Hand |

From the results:

1. Drop items your class **cannot use** (daggers, axes/swords before skill training, etc.).
2. Confirm **vendor NPC** and zone on the item page (Janos ≠ Corina Steele — check “Sold by”).
3. For crafts, confirm **profession**, recipe source, and **required level** on the item tooltip.
4. Match **item ID**, **name**, and **instructions** exactly in `Data.lua`.
5. At level 4, Human Paladins start with **mace** skill only — swords need a weapon master first.

Work **one slot per level band** (e.g. Main Hand at 4, Chest at 4, …) before expanding.

Each slot should have **at least three entries** in `Data.lua` for that level band so the popup and log can always show three choices. Ranking picks the best three by score; they stay visible even if one is already equipped.

---

## 2. Never import unusable items

**Do not add** an entry if the character cannot equip the item:

- Wrong weapon type (e.g. dagger, bow, wand for Paladin)
- Armor tier not yet available (e.g. plate on a low-level Paladin before 40)
- Required level above the entry's intended band
- Wrong faction or class-only gear for other classes
- Wrong item ID (always verify — many numeric IDs map to unrelated items)

The addon validates at runtime with `IsEquippableItem` and required level from `GetItemInfo`. Bad data should still be caught in review using this checklist.

---

## 3. Level bands and visibility

Each entry has:

```lua
minLevel = 4,   -- first level this hunt is relevant
maxLevel = 12,  -- last level it is normally shown
```

**While leveling:**

- New entries appear when the player reaches `minLevel` and can equip the item (`required level ≤ player level`).
- Entries **stop appearing** in the top-3 popup when the player is more than **5 levels above** `maxLevel` (`LEVEL_GRACE` in `Equip.lua`).
- Between `maxLevel + 1` and `maxLevel + 5`, an entry may **remain** only if it still ranks in the **top 3** for that slot (still a meaningful upgrade).
- Tracked/completed hunts follow the same level band rules in the log.

**Ranking** uses item level vs equipped item level, class-appropriate armor tier (`Equip.lua` + `Compare.lua`), and small bonuses for quest/boss/vendor/profession sources — not full sims.

---

## 4. Spec (talents, level 10+)

- Below level 10: no spec filter; all class-valid entries compete.
- Level 10+: prefer items that match the player's **active talent focus** (e.g. Retribution vs Holy for Paladin).
- Optional entry field:

```lua
specs = { holy = true, retribution = true },  -- omit = all specs
```

Spec detection uses talent points when preview mode is off; preview mode may add a `spec` setting later.

---

## 5. Entry template

```lua
{
    id = "unique_snake_case_id",
    itemId = 12345,
    slot = "MainHand",
    minLevel = 4,
    maxLevel = 12,
    classes = { PALADIN = true },           -- omit if any class can use
    factions = { Alliance = true },         -- omit if both factions
    specs = { retribution = true },         -- omit if not spec-specific
    sourceType = "quest_reward",            -- or vendor, world_drop, boss_drop, profession, auction_house
    profession = "Blacksmithing",           -- optional; use with sourceType = "profession"
    instructions = "Short how-to for the player.",
    zone = "Elwynn Forest",
    npc = "Optional NPC name",
    questId = 54,                           -- optional
},
```

---

## 6. Review checklist (before commit)

- [ ] Item ID opens the correct item in Wowhead Classic
- [ ] In-game item name matches the entry instructions (same weapon/armor name throughout)
- [ ] Required level fits the `minLevel`–`maxLevel` band
- [ ] Class can equip weapon/armor type at that level
- [ ] Armor entries use the class's best tier (mail for paladin/warrior below 40, etc.)
- [ ] Checked vendor, quest, world drop, boss, and profession sources where items exist
- [ ] Faction and spec filters are correct or omitted
- [ ] Instructions match the source type and zone
- [ ] Test in-game at `/gq preview set class paladin level N` (or on a real character) and confirm top 3 look sane

---

## Related code

| File | Role |
|------|------|
| `GearQuest/Data.lua` | Static entries |
| `GearQuest/Equip.lua` | Equippability, required level, armor tier, spec, level grace |
| `GearQuest/Compare.lua` | Top-3 ranking vs equipped item |
| `GearQuest/Preview.lua` | Effective class / level / faction (and spec) |
| `GearQuest/Core.lua` | Source type labels and colors |

See also [PROJECT_BRIEF.md](./PROJECT_BRIEF.md).
