# Changelog

## v0.1.1-beta.3-bcc

### Stat-based BiS reordering (sub-60)
- **`Compare.lua`:** Re-rank generated sub-60 picks and notables using TBC stat priorities from Wowhead guides — spec-aware from level 10, `levelling_1_9` below that.
- **`StatWeights.generated.lua`:** Generated weights for all nine classes/specs; wired via `scripts/generate-stat-weights-lua.mjs`.
- Hit/crit/haste/expertise rating scoring; hunter gear AP scored at RAP weight; pet-tank classes (hunter/warlock) skip armor-class multiplier for DPS ranking.
- Tooltip fallback parses equip stats (Hit/AP) when `GetItemStats` misses green lines.
- Level 60 guide bands and level 70 curated lists are **not** reordered.

### Hunter BiS fixes
- Fixed legs ordering around L45–56 (Blackstorm vs Infernal Trickster vs Windrunner) by scoring hit and attack power, not raw Agi alone.

### Profession craft skill (BoP only)
- BoP crafted items show the correct recipe skill (e.g. Blackstorm Leggings → Leatherworking 260) from **`CraftSkills.generated.lua`** (Wowhead recipe spells).
- BoE profession gear is unchanged — still buyable on the AH; log adds an AH note for BoE profession items.
- **`scripts/generate-craft-skills.mjs`:** Build-time generator for craft skill lookup (item tooltips do not include recipe skill).

### Source / drop labelling
- **BRD Chest of The Seven** loot (Deathdealer Breastplate, Hammer of Grace, etc.) reclassified from generic `object_drop` to **`boss_drop`** — boss reward chest after the Seven encounter.
- **`scripts/fix-brd-seven-chest.mjs`:** Data fix for Seven chest entries across generated class files.

## v0.1.0-beta.3

- Fix CurseForge zip layout (`move-folders: GearQuest/GearQuest`).

## v0.1.0-beta.2

- Fix CurseForge packager TOC discovery (addon in `GearQuest/` subfolder).

## v0.1.0-beta

First CurseForge beta for **WoW 2.5.6** (TBC Anniversary).

### Bug fixes
- **Ranged slot:** wire `CharacterRangedSlot` for BiS bar (librams, idols, totems, wands, bows/guns).
- **Tracker:** only show tracked hunts for the current character's class, level band, and faction.

### BiS display order (R39)
- **`Compare.lua`:** Trust pipeline `curatedRank` for every class with a rank — removes runtime ilvl re-sort that showed Edgemaster's third on L47 fury Hands despite rank 1 in data. L60 `origin="guide"` bands still follow guide order; notables (no rank) stay last.
- **`Log.lua`:** Completed tab sorts by BiS rank first, then acquisition time (was newest-first only).

### Edgemaster / hit-expertise weights (R38)
- Regenerated warrior + paladin files with corrected TBC hit/expertise weights (arms/fury/ret).
- **Deleted** `scripts/fix-edgemaster-warrior.mjs` — Edgemaster's now earns rank 1 for arms/fury L44–59 from the model; protection never gets it; L60 goes to Gauntlets of Annihilation.
- Verify target: **68,520** (1,487 curated + 67,033 generated).

### Mage & Warlock generated BiS (10–69)
- Final two pipeline classes: `Data.Mage.*`, `Data.Warlock.*`, weights/guides JSON; wired in `GearQuest.toc` and `DataAdapter.lua`.

### School suffix + early 1–9 suffix ids (R36 / R37)
- Per-spec spell-school suffix differentiation (Fiery / Frozen / Shadow / Nature / Arcane Wrath).
- All 137 early-band suffix rows carry `suffixId` + `suffixRange`; curated Charger's Pants aligned (`suffixId = 23`).

### Data fixes
- **Hunter Marksmanship @ 70:** restored via `scripts/restore-marksmanship-l70.mjs` (clone from BM).
- **Warrior prot shields:** three `slot = "Shield"` rows → `SecondaryHand`.
- **Shaman enhancement L70 off-hand:** Syphon, Vengeful Cleaver, Claw of Molten Fury.
- **`fix-rare-elite-sourcetype.mjs`:** reclassified remaining `(rare elite)` world drops across all classes.

### Performance
- **`Data.lua`:** `byClassSlot` index (~9× faster per-slot lookups).
- **`Core.lua` / `Indicator.lua` / `Preview.lua`:** deferred log refresh, coalesced spec clicks, async rebuild (5 slots/frame).

### Level 70 stand-in specs
- **Six curated copies** via `scripts/clone-level70-specs.mjs`: Discipline ← Holy, Frost ← Arcane, Affliction/Demonology ← Destruction, Assassination/Subtlety ← Combat (+ dagger weapons for rogue). Stand-ins share armour pools; not stat-priority tuned.
- **All specs selectable** in `Spec.lua` — removed `comingLater` from Frost, Affliction, Demonology, Assassination, Subtlety.

### Minimap simulate UI
- **Right-click minimap** opens simulate panel: class dropdown, specialization dropdown, level field (1–70), **Simulate** / **Reset** (`/gq me`), **X** close. Left-click still opens the log.
- Does not close on outside click; removed from `UISpecialFrames`.
- Login + simulate chat hints updated (`By Weber8210`, minimap simulate tip, gear-slot hint after simulate).

### Preview / login fixes
- **Character switch:** preview simulation clears on login when the character GUID changes (SavedVariables are account-wide); `/reload` on the same toon keeps an active simulation.
- **`GetTalentTabInfo`:** TBC Anniversary returns `pointsSpent` as the 5th value (not 3rd) — fixes load error and talent-based spec detection on login.

### Priest generated BiS (10–69)
- Seventh pipeline class: `Data.Priest.generated.lua`, `Data.Priest.Early.1to9.generated.lua`, weights/guides JSON.

### Pipeline / data (prior in this batch)
- **Faction / reputation gating:** ~7,587 cells corrected across generated 10–69; `npc_faction.json`, `pvp_prefix_faction.json`.
- **Weapon-slot scoring:** off-hand DW fixes, ranged `dpsWeightRanged`, held-in-off-hand rules; six-class weapon-slot refresh.
- **`DataAdapter.lua`:** compact backfill row format; all nine classes wired in `GearQuest.toc`.
- **Compare.lua:** preserve `curatedRank` for `origin="guide"` level-60 bands.

### UI / performance (prior)
- Async indicator cache; staggered `RefreshUI`; spec cache invalidation; notable lookup by id; tracker wrap fixes; log spec picker highlight; art assets + `sync-addon.ps1`.

### Level 70 Phase 3 (base import)
- Original **21 AtlasLoot BT/Hyjal** spec lists (~891 entries); import via `import-atlasloot-p3-bis.mjs` / `merge-all-p3-into-data.mjs`.

## v0.1.0

- MVP: Hunter Main Hand weapon upgrades (levels 30–45)
- Click Main Hand slot on character panel → popup with ~3 upgrade options
- GearQuest log (`/gq`) — accept, track, complete, and abandon hunts
- Static gear quest data for Uldaman boss drops, STV quest reward, and world drops
