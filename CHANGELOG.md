# Changelog

## v0.1.0 (unreleased)

- **Level 70 Phase 3 BiS:** all 21 AtlasLoot BT/Hyjal specs (~890 entries) via import scripts
- Import tooling: `import-atlasloot-p3-bis.mjs`, `merge-all-p3-into-data.mjs`
- Spec system: all P3 specs selectable; Druid **Bear Tank**; Frost/MM/Aff/Demo/Assa/Sub marked coming later
- **Fixes:** spec picker icons (curated per class, no wrong talent-tab bleed); party loot no longer writes `crafted`; Hunter/Shaman mail at 40+; preview spec stored separately; duplicate spec-arrow frame removed
- Docs: data coverage, AtlasLoot source notes, import workflow in DATA_RULES.md
- Level 70 **Elemental Shaman** hand-audit (prior commit) superseded by bulk import; token rules retained in import script
- `raid_trash` source type for Black Temple / Hyjal trash epics
- Log UI: `DIALOG` frame strata; gold selection highlight for epic text
- QA scripts: `scripts/qa-level70-drops.mjs`, `scripts/qa-level70-verify-bosses.mjs`
- BiS upgrade indicators (green ↑) on loot, vendor, quest rewards, trainer/tradeskill detail icons
- Auto-complete hunts on obtain; profession hunts complete on craft only
- Document trainer/tradeskill indicator behavior in DATA_RULES.md

## v0.1.0

- MVP: Hunter Main Hand weapon upgrades (levels 30–45)
- Click Main Hand slot on character panel → popup with ~3 upgrade options
- GearQuest log (`/gq`) — accept, track, complete, and abandon hunts
- Static gear quest data for Uldaman boss drops, STV quest reward, and world drops
