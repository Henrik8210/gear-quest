# Changelog

## v0.1.0 (unreleased)

- **Faction / reputation gating (pipeline):** vendor- and rep-based faction locks for generated 10–69 data (~7,587 cells corrected, ~7–8% per class); Tranquillien rep, BG reward sets (Highlander’s / Defiler’s, AV runes/cloaks), mirror-paired Outland reps; `npc_faction.json` added; zone-only gating avoided (e.g. Mor’shan Base Camp hosts both BG quartermasters)
- **Generated BiS import:** all six classes 10–69 refreshed — **47,066 generated + 1,178 curated = 48,244** entries; verify script targets updated
- **Compare.lua:** preserve `curatedRank` for `origin="guide"` level-60 bands (never re-sort by score); runtime ilvl re-ranking for other generated picks
- **Rogue:** Assassination and Subtlety specs enabled (removed coming later)
- **Performance:** async indicator cache rebuild; staggered `RefreshUI`; spec cache invalidation without full notable re-index
- **Fixes:** notable entry lookup by id; tracker text wrap/clipping; `GetItemFact` includes rogue fact tables
- **Paladin generated BiS (10–69):** stat-weight pipeline, `DataAdapter.lua`, `_generated/` tables (~9,180 + 221 Horde 1–9 picks)
- **Notables:** proc-driven items beside top 3 (Paladin); hidden at level 70
- **Log UI:** spec picker hover highlight; notable `!` icon; suffix/origin/proc in detail; list truncation; shift/ctrl+click item links
- **Performance:** query cache, deferred `RefreshUI`, spec-switch no longer freezes; scoped auto-completion
- **Fixes:** Shield→Off Hand slot mapping; Protection level-70 shields; `LIST_NEW_LABEL` declaration order; notable selection; tooltip hover restored
- **Tracker:** resize grip only on hover; tracker section hover wiring
- **Art:** logo, portrait, minimap icon; `scripts/png-to-tga.mjs`, `scripts/verify-paladin-bis.mjs`
- **Docs:** DATA_RULES.md dual-source rules (curated vs generated); README coverage update; `.gitattributes` for LF normalization
- **Level 70 Phase 3 BiS:** all 21 AtlasLoot BT/Hyjal specs (~891 entries) via import scripts
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
