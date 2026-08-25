# Changelog

## v0.1.0 (unreleased)

### Level 70 stand-in specs
- **Six curated copies** via `scripts/clone-level70-specs.mjs`: Discipline ← Holy, Frost ← Arcane, Affliction/Demonology ← Destruction, Assassination/Subtlety ← Combat (+ dagger weapons for rogue). Stand-ins share armour pools; not stat-priority tuned.
- **All specs selectable** in `Spec.lua` — removed `comingLater` from Frost, Affliction, Demonology, Assassination, Subtlety.
- **Gap:** Hunter **Marksmanship** still has no level-70 curated band (BM/SV only).

### Minimap simulate UI
- **Right-click minimap** opens simulate panel: class dropdown, specialization dropdown, level field (1–70), **Simulate** / **Reset** (`/gq me`), **X** close. Left-click still opens the log.
- Does not close on outside click; removed from `UISpecialFrames`.
- Login + simulate chat hints updated (`By Weber8210`, minimap simulate tip, gear-slot hint after simulate).

### Preview / login fixes
- **Character switch:** preview simulation clears on login when the character GUID changes (SavedVariables are account-wide); `/reload` on the same toon keeps an active simulation.
- **`GetTalentTabInfo`:** TBC Anniversary returns `pointsSpent` as the 5th value (not 3rd) — fixes load error and talent-based spec detection on login.

### Priest generated BiS (10–69)
- Seventh pipeline class: `Data.Priest.generated.lua`, `Data.Priest.Early.1to9.generated.lua`, weights/guides JSON.
- **`Compare.lua`:** Priest/Mage/Warlock keep pipeline `curatedRank` (no ilvl re-sort) — fixes staff vs 1H+off-hand ordering.

### Pipeline / data (prior in this batch)
- **Faction / reputation gating:** ~7,587 cells corrected across generated 10–69; `npc_faction.json`, `pvp_prefix_faction.json`.
- **Weapon-slot scoring:** off-hand DW fixes, ranged `dpsWeightRanged`, held-in-off-hand rules; six-class weapon-slot refresh.
- **`DataAdapter.lua`:** compact backfill row format; Priest source wired in `GearQuest.toc`.
- **Compare.lua:** preserve `curatedRank` for `origin="guide"` level-60 bands.
- **Verify target:** **55,355 total** (1,439 curated + 53,916 generated) — `node scripts/verify-generated-bis.mjs`.

### UI / performance (prior)
- Async indicator cache; staggered `RefreshUI`; spec cache invalidation; notable lookup by id; tracker wrap fixes; log spec picker highlight; art assets + `sync-addon.ps1`.

### Level 70 Phase 3 (base import)
- Original **21 AtlasLoot BT/Hyjal** spec lists (~891 entries); import via `import-atlasloot-p3-bis.mjs` / `merge-all-p3-into-data.mjs`.

## v0.1.0

- MVP: Hunter Main Hand weapon upgrades (levels 30–45)
- Click Main Hand slot on character panel → popup with ~3 upgrade options
- GearQuest log (`/gq`) — accept, track, complete, and abandon hunts
- Static gear quest data for Uldaman boss drops, STV quest reward, and world drops
