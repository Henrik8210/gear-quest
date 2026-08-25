# GearQuest

**GearQuest** (`/gq`) is a WoW Classic / TBC Anniversary addon that answers: *"What should I upgrade next, and how do I get it?"*

Click a gear slot on your character panel (right-click), browse from the log, or **right-click the minimap icon** to simulate another class/level/spec.

## MVP (v0.1.0)

- **Slots:** All gear slots (character panel right-click or log browse)
- **Leveling data:** **Seven classes** with generated **10–69** BiS (Paladin, Warrior, Hunter, Druid, Shaman, Rogue, Priest) + Alliance **1–9** curated bands + Horde early bands where generated
- **Level 70 endgame:** **27 specs** with curated data (21 AtlasLoot Phase 3 imports + 6 stand-in copies); **Hunter Marksmanship** still missing
- **Specs:** All specs selectable from level 10 when data exists; per-class picker in the log
- **Entry points:** character panel slot click, `/gq` log, minimap simulate panel
- **Data:** curated entries in `GearQuest/Data.lua`; generated 10–69 merged at load via `DataAdapter.lua`

### Level 70 — Phase 3 BT/Hyjal

Imported from **AtlasLootClassic_TBC_Phase_3_BT_Hyjal** for the original 21 specs. Six additional specs use stand-in copies (`scripts/clone-level70-specs.mjs`): Discipline, Frost, Affliction, Demonology, Assassination, Subtlety.

**Gap:** Hunter **Marksmanship** — no level-70 curated band yet (BM/SV covered).

### Generated BiS (levels 10–69)

Stat-weight pipeline for all seven classes. Level **70 is never generated** — curated data only. See [GearQuest/_generated/GEARQUEST-BIS-PIPELINE.md](GearQuest/_generated/GEARQUEST-BIS-PIPELINE.md) and [docs/DATA_RULES.md](docs/DATA_RULES.md).

```powershell
node scripts/verify-generated-bis.mjs   # expect 55,355 entries (1,439 curated + 53,916 generated)
```

## Commands

| Command | Action |
|---------|--------|
| `/gq` or `/gearquest` | Toggle GearQuest log |
| `/gq log` | Toggle log |
| `/gq class hunter` | Set preview class |
| `/gq level 37` | Set preview level |
| `/gq spec holy` | Set preview specialization |
| `/gq faction alliance` | Set preview faction |
| `/gq set on` / `/gq set off` | Enable or disable preview mode |
| `/gq set me` | Copy your real character into preview (Reset in simulate panel) |
| `/gq help` | List commands |

**Minimap:** left-click → log; right-click → simulate panel (class, spec, level).

After simulating, chat confirms what you're viewing and reminds you to right-click a gear slot or use `/gq`.

## Local WoW install

After editing addon files, sync to your game folder:

```powershell
.\scripts\sync-addon.ps1
```

Target: `C:\Program Files (x86)\World of Warcraft\_anniversary_\Interface\AddOns\GearQuest`

## Development

- Addon lives in `GearQuest/` (folder matches toc name for CurseForge packager)
- TBC Anniversary interface: `## Interface: 20505`
- Project brief: [docs/PROJECT_BRIEF.md](docs/PROJECT_BRIEF.md)
- Data rules (curated vs generated, simulate UI, green ↑ indicators): [docs/DATA_RULES.md](docs/DATA_RULES.md)
- Changelog: [CHANGELOG.md](CHANGELOG.md)

### QA scripts (level 70 data)

```powershell
node scripts/import-atlasloot-p3-bis.mjs              # all Phase 3 lists → scripts/output/
node scripts/merge-all-p3-into-data.mjs               # replace level-70 band in Data.lua
node scripts/clone-level70-specs.mjs                  # stand-in copies for six specs
node scripts/qa-level70-drops.mjs
node scripts/verify-generated-bis.mjs
```

## License

See repository license file when added.
