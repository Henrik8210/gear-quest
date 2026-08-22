# Changelog

## v0.1.0 (unreleased)

- Level 70 **Elemental Shaman** endgame BiS list (all slots, ~42 curated entries)
- Class/spec system for all 9 TBC classes; Enhancement/Restoration shaman and Holy/Protection paladin marked “coming later” until data exists
- `raid_trash` source type for Black Temple / Hyjal trash epics
- Log UI: `DIALOG` frame strata so other addons don’t draw over the list; gold selection highlight for readable epic (purple) text
- Audited all level 70 ele shaman drop descriptions (T6 token bosses, Sun King’s Talisman quest reward, Mechanar cache totem)
- QA scripts: `scripts/qa-level70-drops.mjs`, `scripts/qa-level70-verify-bosses.mjs`
- BiS upgrade indicators (green ↑) on loot, vendor, quest rewards, trainer detail icon, and tradeskill detail icon
- Auto-complete hunts on obtain; persistent obtained state; celebration toast
- Profession hunts complete on craft only (not recipe learn)
- Document trainer/tradeskill indicator behavior and WoW UI quirks in DATA_RULES.md

## v0.1.0

- MVP: Hunter Main Hand weapon upgrades (levels 30–45)
- Click Main Hand slot on character panel → popup with ~3 upgrade options
- GearQuest log (`/gq`) — accept, track, complete, and abandon hunts
- Static gear quest data for Uldaman boss drops, STV quest reward, and world drops
