# GearQuest

**GearQuest** (`/gq`) is a WoW Classic / TBC Anniversary addon that answers: *"What should I upgrade next, and how do I get it?"*

Click a gear slot on your character panel (right-click Main Hand), or browse from the log.

## MVP (v0.1.0)

- **Slots:** All gear slots (character panel right-click or log browse)
- **Leveling data:** Alliance Warrior & Paladin, levels **1–21** (Horde-specific entries not yet curated)
- **Level 70 endgame:** **All 21 TBC Phase 3 (BT/Hyjal) specs** from AtlasLoot — top 3 items per slot (~890 entries)
- **Specs:** Per-class talent specs from level 10; specs with P3 data are selectable; others show “coming later” (e.g. Frost Mage, MM Hunter, Assa/Sub Rogue)
- **Entry points:** click a gear slot on the character panel (`C`), or `/gq` / `/gearquest` for the log
- **Data:** static Lua table in `GearQuest/Data.lua`

### Level 70 — Phase 3 BT/Hyjal (all AtlasLoot specs)

Imported from **AtlasLootClassic_TBC_Phase_3_BT_Hyjal** (Sliccer BiS lists, not in the Hoizame GitHub repo). Covers:

Rogue Combat · Hunter BM/SV · Druid Balance/Bear/Cat/Resto · Mage Arcane/Fire · Paladin Holy/Prot/Ret · Priest Holy/Shadow · Shaman Ele/Enh/Resto · Warlock Destruction · Warrior Arms/Fury/Prot

Drop text comes from Wowhead enrichment + T5/T6 token rules. ~145 items may still need manual review (`needsReview` in import JSON).

**Gaps:** Levels **22–69** have no entries for any class. Leveling slots (Head/Neck/Trinket) are sparse below 70.

### Level 70 — earlier manual pass

Elemental Shaman was hand-audited first (T6 token bosses, Sun King’s Talisman quest, Mechanar cache totem). The bulk import replaced that block; token rules in the import script follow the same tables in [docs/DATA_RULES.md](docs/DATA_RULES.md).

## Commands

| Command | Action |
|---------|--------|
| `/gq` or `/gearquest` | Toggle GearQuest log |
| `/gq log` | Toggle log |
| `/gq complete` | Mark selected hunt complete |
| `/gq abandon` | Abandon selected hunt |
| `/gq set` | Show preview settings |
| `/gq class hunter` | Set preview class (also works as `/gq set class hunter`) |
| `/gq level 37` | Set preview level |
| `/gq faction alliance` | Set preview faction (`alliance` or `horde`) |
| `/gq set on` / `/gq set off` | Enable or disable preview mode |
| `/gq set me` | Copy your real character into preview settings |
| `/gq help` | List commands |

After changing class, level, or faction, chat confirms what you're now viewing (e.g. "Now viewing upgrades as a level 37 Hunter").

## Local WoW install

After editing addon files, sync to your game folder:

```powershell
.\scripts\sync-addon.ps1
```

Target: `C:\Program Files (x86)\World of Warcraft\_anniversary_\Interface\AddOns\GearQuest`

## Development

- Addon lives in `GearQuest/` (folder matches toc name for CurseForge packager)
- TBC Anniversary interface: `## Interface: 20505`
- Project brief for agents: [docs/PROJECT_BRIEF.md](docs/PROJECT_BRIEF.md)
- Data curation & UI rules (including green ↑ indicators on vendors, loot, and **profession recipes**): [docs/DATA_RULES.md](docs/DATA_RULES.md)

### QA scripts (level 70 data)

After editing endgame entries in `Data.lua`, verify drops against Wowhead:

```powershell
node scripts/import-atlasloot-p3-bis.mjs              # all 21 Phase 3 lists → scripts/output/
node scripts/import-atlasloot-p3-bis.mjs Rogue_P3       # single list
node scripts/merge-all-p3-into-data.mjs               # replace level-70 band in Data.lua
node scripts/qa-level70-drops.mjs
node scripts/qa-level70-verify-bosses.mjs
```

See [docs/DATA_RULES.md](docs/DATA_RULES.md) for TBC token boss assignments, AtlasLoot import workflow, data coverage gaps, and endgame description rules.

## CurseForge release

See [RELEASE.md](RELEASE.md) for one-time setup (`CF_API_KEY`, project ID) and tag-based releases via GitHub Actions.

**Do not push release tags unless explicitly publishing.**

## Reference addons (behavior, not copy)

- **Questie** — quest log UI patterns
- **AtlasLoot** — loot/source browsing
- **Wick's TBC BIS Tracker** — acquisition tracking per slot
- **Zygor Gear Finder** — upgrade-per-slot concept (paid, different UX)
