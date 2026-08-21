# GearQuest

**GearQuest** (`/gq`) is a WoW Classic / TBC Anniversary addon that answers: *"What should I upgrade next, and how do I get it?"*

Click a gear slot on your character panel (right-click Main Hand), or browse from the log.

## MVP (v0.1.0)

- **Slot:** Main Hand weapons
- **Class:** Hunter, levels 30–45
- **Entry points:** click Main Hand on character panel (`C`), or `/gq` / `/gearquest` for the log
- **Data:** static Lua table in `GearQuest/Data.lua`

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

## CurseForge release

See [RELEASE.md](RELEASE.md) for one-time setup (`CF_API_KEY`, project ID) and tag-based releases via GitHub Actions.

**Do not push release tags unless explicitly publishing.**

## Reference addons (behavior, not copy)

- **Questie** — quest log UI patterns
- **AtlasLoot** — loot/source browsing
- **Wick's TBC BIS Tracker** — acquisition tracking per slot
- **Zygor Gear Finder** — upgrade-per-slot concept (paid, different UX)
