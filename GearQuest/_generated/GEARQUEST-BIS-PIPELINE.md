# GearQuest BiS pipeline — ruleset and playbook

How the generated BiS lists are built, every rule that was arrived at the hard
way, and what to do when the next class comes along. Written after Paladin, which
was the first class through and therefore paid for all the mistakes.

**Read the "Rules" section before touching weights.** Most of it exists because a
plausible-looking shortcut produced wrong data and Henrik caught it.

---

## 1. What this produces

Three top-ranked items per gear slot, per level, per spec, per faction, for
levels **1–69**. Level 70 is out of scope on purpose (§Rules R1).

| output | contents |
|---|---|
| `Data.Paladin.generated.lua` | 9,622 picks, levels 1–69, 3 specs, both factions |
| `Data.Paladin.Horde.1to9.generated.lua` | 221 picks, Horde only, levels 1–9 |

Levels collapse into bands: adjacent levels whose top three are byte-identical
merge into one `minLevel`/`maxLevel` row. Computed per level, emitted per band —
so the candidate pool at level 18 is everything with required level ≤ 18, and a
level-15 item still competes and can sit at rank 3.

---

## 2. Data sources, and which to trust

| source | used for | trust |
|---|---|---|
| **Wowhead tooltip dump** (`wowsims/tbc`, 30,005 items, cached from tbc.wowhead.com) | stats, item level, required level, slot, armour type, weapon damage/speed, sockets, phase, class restrictions, **effect and proc text** | **High.** This is what the player sees. |
| **cmangos tbc-db 1.11** (2.4.3 world DB) | item_template joins, loot tables, quests, vendors, professions, `AllowableClass`/`AllowableRace`, `RandomProperty`/`RandomSuffix`, **`quest_template.RequiredClasses` / `RequiredRaces`** | **Mixed.** Structural data good. Roll tables and some restrictions wrong — see R4, R7. |
| **wago.tools DB2 export**, build 2.5.4.44833 | `RandPropPoints`, `SpellItemEnchantment`, `SkillLineAbility` → crafted-item map | High. Diffed against 2.5.1: 1 row of 75 differed. |
| **Wowhead item pages**, scraped per enchant group | random-enchantment tables (589 requests, 0 failures) | **Authoritative.** Replaced the emulator data entirely. |
| **cmangos classic-db 1.12** | the set of 17,718 item IDs that existed in Classic | High. Used only to answer "is this a TBC item?" |
| **Wowhead Classic BiS guides** (3, one per spec) | the level-60 answer | Authoritative *for level 60*. Wrong era for anything else — see R9. |
| Henrik's curated level-70 AtlasLoot Phase 3 data | level 70 | Authoritative. Do not generate over it. |

### Scraping Wowhead random enchantments

Two non-obvious requirements, both essential:

1. The canonical item URL **403s from a datacenter IP**. Appending `?power`
   returns the same full HTML and is not blocked.
2. **Do not send a realistic Chrome User-Agent** — CloudFront blocks it. A plain
   honest UA passes.

```bash
curl -sSL --compressed -A 'wow-tbc-data-research/1.0' \
  'https://www.wowhead.com/tbc/item=1207?power'
```

Key by **enchant group**, not by item: chances and (for `RandomProperty` items)
stat values are group-constant, so one request per group covers every item in it.
`RandomSuffix` items scale with item level, quality and slot, so those need one
request each. For Paladin that was 589 requests instead of 887 items, ~15 minutes.

---

## 3. Rules

### R1 — Do not generate level 70
Measured: 0/44 exact match against Henrik's curated AtlasLoot data, 0.55/3
overlap. Phase-gating alone tripled overlap (158 of 252 picks were Sunwell items
in a Phase 3 list), and crediting sockets and penalising PvP gear still left
0/41 exact. It is structural, not tuning: at 70, BiS turns on **gem sockets, tier
set bonuses, libram/relic effects, weapon speed breakpoints, phase tier and
PvE-vs-PvP intent**. All 34 librams have empty stat blocks — their entire value
is spell effects. None of that exists below 60, which is why the model is
credible there and not here.

### R2 — A stated RequiredLevel is authoritative
Nothing may delay an item past its own required level. An earlier version added
an obtainability gate — for BoP items, the level of the creature that drops it,
minus two — which pushed **3,748 items** later than Wowhead says they are usable.
Might of Menethil (*Requires Level 60*, dropped by a level-63 Kel'Thuzad)
vanished from 60 and reappeared at 61.

The narrow exception: **1,369 items of item level 60+ genuinely state no required
level.** Taking that at face value put an item-level-55 chest at rank 1 for level
1. For those only, fall back to the source gate, backstopped by the median
required level of items at that item level (measured over the ~28,500 that state
one). Never for items that state one.

### R3 — Ranking is pure stat score, regardless of obtainability
Henrik's call: always show the genuinely best options; at least one of three is
usually gettable, and the auction house covers the rest. Random-enchantment items
are scored on their **best roll**, with the roll chance surfaced.

Consequence to accept: a level-60 player's BiS chest is legitimately a
Naxxramas drop. 542 picks (5.9%) come from vanilla 60-raid content. Naxxramas is
not removed until WotLK and Zul'Gurub not until Cataclysm, so they are live on
TBC realms — verified, not assumed.

### R4 — Random enchantments come from Wowhead, never from an emulator DB
`item_enchantment_template` is a community reconstruction and it is wrong in both
directions. For Murphstar's group it listed **32 suffixes summing to 128.48%**
against Wowhead's **11 summing to 99.8%**, put *of Intellect* at 0.1% instead of
7.3%, and invented two extra *of Healing* tiers. On a 66-item sample it was
*missing* suffixes Wowhead lists on 44 of them.

cmangos TBC, cmangos Classic and AzerothCore ship **byte-identical** rows, so no
emulator DB helps, and no client DBC carries the group mapping at all — which is
why every emulator hand-reconstructed it and they all share the errors. A
probability distribution cannot sum to 128%; that is the tell.

Also: 178 of 824 groups exceed 100%, and because cmangos truncates at 100% with
no `ORDER BY`, 30 of one group's 82 rows are unreachable on a live server. The
table does not even describe its own server's behaviour.

### R5 — Weights are ordinal-derived from TBC sources, adapted for levelling
TBC rewrote the mechanics the Classic weights were built on. Classic Seal of
Righteousness scaled off spell damage (`0.044/SP` per swing); TBC Retribution
uses **Seal of Blood** ("35% of your weapon damage") or **Seal of Command**, plus
**Crusader Strike** ("110% of weapon damage") — all weapon damage, none spell
damage. A spell-damage weight of 0.30 for Ret was an artefact of the wrong
expansion.

| spec | TBC priority (Icy Veins) |
|---|---|
| Retribution | hit → expertise → str → AP → haste → armour pen |
| Protection | defense (490 cap) → avoidance, **block > dodge > parry** → sta → **spell damage** → hit |
| Holy | healing → mp5 → spell crit → int → spell haste |

**Adapt, don't copy.** Those are level-70 raid priorities. Hit-to-cap, expertise
and armour penetration dominate a raid parse but barely appear on levelling gear,
and a linear weight cannot model a cap. Strength and weapon damage stay ahead of
them for 1–69.

### R6 — Weapon DPS is derived, not guessed
For a paladin: 1 Strength = 2 attack power, which buys `2/14` = 0.143 white dps,
`0.022 × 2` = 0.044 seal dps, and `0.225 × 2 / 10` = 0.045 judgement dps —
**0.232 dps per Strength**. So **1 weapon dps = 4.31 Strength**, independent of
weapon speed. Set `dpsWeight = str_weight × 4.31`.

**Protection is the exception.** The same derivation gave 2.37, which put pure-DPS
Naxxramas one-handers at the top of the *tank* weapon list. A tank's threat comes
from Holy damage — Seal and Judgement of Righteousness, Consecration, Holy Shield
— which scales off spell power and attack power, not weapon swings. Set to 0.5.

### R7 — Armour class is a multiplier, never a filter
Prot heavily favours plate, Ret mildly, Holy is near-indifferent and will take
cloth when the stats are better. Without this, Hunter and Rogue tier 3 outranked
Paladin tier 2 — plate versus leather at level 60 is ~200 armour, worth 3 points
to Ret, nothing against a tier set's stat budget.

| | Plate | Mail | Leather | Cloth |
|---|---|---|---|---|
| Retribution | 1.00 | 0.86 | 0.72 | 0.55 |
| Protection | 1.00 | 0.55 | 0.35 | 0.18 |
| Holy | 1.00 | 0.99 | 0.97 | 0.95 |

Holy's near-indifference is validated: 100% of its level-60 top picks are
endorsed by the Classic healing guide.

### R8 — Class and race gates live on the quest, not always on the item
Vanilla tier-3 pieces carry `AllowableClass = 32767` ("anyone"), so nothing on
the item stops a paladin list picking Warrior, Druid, Hunter, Rogue, Priest and
Shaman tier 3. The real gate is `quest_template.RequiredClasses` on the quest that
hands the piece over — 1 / 1024 / 4 / 8 / 16 / 64 respectively, and **2** for
Redemption, the paladin set. 969 quests carry a class lock; 422 items affected.
Fixing this took Holy from 62% to 81% agreement in one step.

Three more gates, all of which leaked at first:

- **`quest_template.RequiredRaces`** — captured for a long time and never used.
- **Class race sets are narrower than faction sets.** A Horde paladin is a Blood
  Elf and nothing else, so Orc, Tauren, Troll and Undead starting quests are as
  unreachable as Alliance ones. Using the blanket faction mask put Durotar and
  Mulgore gear in a Blood Elf's list. Same shape for Alliance Shaman (Draenei
  only) and Horde Druid (Tauren only).
- **Faction-exclusive zones.** A vendor standing in Darnassus is not
  race-restricted — the city is. Gate by zone name; only genuinely one-faction
  zones, since contested and Outland zones are reachable by both.

**Do not tighten this further, and do not loosen it.** Same-faction cross-race
travel is legitimate and must keep working: a Blood Elf can quest in Mulgore or
Tirisfal, a Draenei in Teldrassil. In the Blood Elf paladin 1–9 list, **46 of 69
zone-attributed picks come from other Horde races' zones** against 23 from its
own — that ratio is the check that the gate is not over-tight.

The reason it works: `RequiredRaces` is almost never race-narrow. 17,540 items
have mask `0` (no restriction), 498 have `1101` (all Alliance), 475 have `690`
(all Horde), 295 have `1791` (everyone). Genuinely race-narrow masks cover a few
dozen items in total.

Those few are real and must stay excluded — only 15 items for a Blood Elf and 7
for a Draenei:

- mask `16` / `32` — Undead-only quests in Deathknell, Tauren-only quests in
  Mulgore (*Ceremonial Tomahawk*, *Thunderhorn Cloak*).
- mask `178` (Horde minus Blood Elf) — the Valley of Trials racial intro chain.
- **Per-race reward variants of one quest.** *Umbral Axe/Dagger/Mace/Sword* are
  mask `68` (Dwarf|Gnome), *Moon Robes of Elune* mask `8` (Night Elf). A Draenei
  doing that quest receives the Draenei version. Dropping the race gate here
  would put four duplicate weapons in the same slot.

### R9 — Never calibrate against a Classic-era guide
The three Classic BiS guides are excellent *for level 60* and misleading anywhere
else. Agreement going **down** can mean the model got more TBC-correct: cutting
Ret's Classic spell-damage scaling dropped guide agreement from 77% to 54%, and
every one of the remaining misses was the guide buying an Avenger's **set bonus**
or an invisible **proc**, not a spell-damage item.

A calibration was run against these guides once — a Prot `dpsWeight` sweep. Wrong
method. The conclusion survived on independent TBC evidence, but the evidence
cited was the wrong kind.

**Measure precision fairly.** Raw hit-rate made Ret look terrible (36%) purely
because that guide lists ~1.7 items per slot while Holy's lists ~9.6 — three
picks cannot score against a one-item list. Use *"is the guide's BiS in my top
3"* and *"is my #1 anywhere in the guide's list"*.

### R10 — Level 60 comes from the guides, not the model
At exactly 60, the guide's order wins. A non-guide item may displace an entry
only if it beats the guide's **own top pick** by 20% **and did not exist in
Classic**.

That last clause is the crux. A first pass allowed 8 displacements and every one
was a Classic Naxxramas item — *Plated Abomination Ribcage*, *Mark of the
Champion*, *Wraith Blade*. The guide authors saw the whole of Classic itemisation
and ranked those below anyway, buying set bonuses the model cannot see. That is a
considered judgement and it stands. A TBC item is different: they never saw it.
Membership from the Classic 1.12 ID set.

Result: **41/41** guide BiS picks present, six legitimate TBC displacements, all
required-level 60 from Hellfire Ramparts or Outland world drops.

### R11 — Procs get a number, routed through existing currency
See `procs.py`. Damage → dps → × `dpsWeight`. Stat buff → stat × uptime × that
stat's weight. Mitigation → effective HP → × stamina weight ÷ 10 HP per point.
Nothing invents a new scale; a proc is priced against the same yardstick as a
point of Strength.

Proc rate uses the real TBC mechanic: **`chance = PPM × speed / 60`**, so
procs-per-minute is speed-independent and is the right unit. (The commonly cited
write-up prints this formula inverted; its own 44% worked example confirms the
form above.)

Every assumption is a named constant at the top of that file — `PPM_DEFAULT`,
`FIGHT_SECONDS`, `MELEE_SHARE`, `MIT_RELEVANCE`, `AOE_TARGETS`. They are
estimates, not sim output. **Amortise cooldowns**: a `max(1.0, …)` floor once
cancelled the divisor entirely and priced a 15-minute absorb as permanently up,
at 107.8 points — enough to displace the guide's tank trinket. And scale AoE off
the line's own damage; a flat bonus scored a 25-damage tick the same as
Thunderfury's 300-damage chain.

**Known limit:** the proc strip is itself ordered by printed stats, so it cannot
tell a world-class proc from a mediocre one. Thunderfury reaches 78.9 from 30.9
but still does not beat a 95-spell-power sword on the model alone. That is why
R10 exists.

### R12 — Exclude on evidence, never on absence of it
Two exclusion rules only, both requiring positive evidence of a dead end:

1. **Craft dead end** — a pattern/recipe *item* exists for the spell but has no
   source. *Plans: Onyxia Scale Breastplate* exists, requires Leatherworking 300,
   and drops from nothing. If **no** pattern item exists the recipe is
   trainer-taught and fine — that distinction is what wrongly deleted *Linen
   Cloak* and *Rough Copper Vest*.
2. **Test quest** — the only source is a quest titled `BETA…`/`TEST…`. Three
   rings worth 144 picks came from *"BETA Provoking the Warboss"*.

Plus a flat filter for **conjured/duration-limited items** — *Andonisus, Reaper
of Souls* exists for 5 real-time minutes and drains 5% health per second.

Items with no source anywhere are **flagged, never deleted**: `npc_vendor` holds
only 6.4k rows and `npc_trainer` only 388, so absence proves nothing.

The unresolved-source set is ~4,400 items and mostly developer junk (`Paladin 150
Epic Test Chest`, `Tom's Legs 3`, `Indalamar's Ring of 200 Crit`, `zzold`), so
excluding it by default is right. A **hand-verified allowlist** is the escape
hatch for real items whose chain the DB cannot express — legendary craft chains
like Sulfuras (Eye of Sulfuras + Sulfuron Hammer, not a `SkillLineAbility`
recipe). **Verify every ID against `item_template` by name before adding it.** An
ID went into that list labelled "Ashbringer" that was actually Andonisus.

### R13 — Do not put drop chances in the instruction text
The loot-table percentages are per-row group weights, not the drop rate a player
sees. Kel'Thuzad's Might of Menethil came out as "~100.0%" against Wowhead's
~14%. Name the source and stop there.

### R14 — Validate against something, and say what
Standing checks, all runnable per class:

| script | asserts |
|---|---|
| `check_levels.py` | no pick offered before its required level; lists anything first offered later |
| `guide_check.py` | agreement with per-spec BiS guides, both fair metrics |
| `compare.py` | generated vs Henrik's hand-curated data |
| `obtainability.py` | acquisition-chain audit, with false-positive controls |
| `out/verify.py` | renders the review page headless, both themes, asserts no console errors and no horizontal overflow |

Control sets matter more than scores. Every rule change is checked against
Henrik's 453 curated level-70 items and 184 curated 1–69 items; a change that
deletes any of them is wrong regardless of how good its reasoning sounds.

---

## 4. Doing the next class

1. **`ARMOR_PROF`** — add the class's armour proficiencies and the level the
   heaviest unlocks. Paladin/Warrior get plate at 40, Hunter/Shaman mail at 40.
2. **`CLASS_RACES`** — already filled in for all nine classes. Sanity-check the
   pair you are about to use.
3. **`_weaponSubclasses`** and `weaponStyle` per spec — `twohand`,
   `onehand_shield`, `onehand_dual`, etc.
4. **Weights per spec.** Find that class's TBC stat-priority pages first, then
   adapt for levelling per R5. Derive `dpsWeight` per R6, and check whether the
   spec is a threat/healing exception like Prot.
5. **`armorClass` multipliers** per spec (R7). A healer is near-indifferent; a
   tank is not.
6. **Find per-spec BiS guides for level 60** and add them to `guides.json` in
   rank order. Without them, level 60 falls back to the model, which R1's
   reasoning says is the weakest point in the range.
7. **Run the checks in R14** and read the displacement log — it is the most
   informative single output in the pipeline.
8. **Spot-check 10 items against Wowhead by hand.** Every serious bug in this
   project was found that way, not by a passing test.

### Class-specific traps to expect
- **Relics** — librams, idols, totems all have empty stat blocks. Whatever
  happened to Paladin librams at 70 will happen to Druid idols and Shaman totems.
- **Feral attack power** parses as a stat but is Druid-only; make sure no other
  class scores it.
- **Hunter** needs ranged weapon DPS as the primary weapon channel, not melee.
- **Dual-wield specs** need main-hand and off-hand handled as distinct slots with
  different weapon-damage value.
- **Spell-school-locked damage** (`spSchool`) is worthless outside that school —
  keep it separate from generic spell damage.

---

## 5. Honest state of it

**Solid:** item stats, required levels, sources, obtainability, class/race/faction
gating, random enchantments, the level-60 lists.

**Modelled, arguable:** every stat weight; every constant in `procs.py`; the
armour-class multipliers.

**Known blind:** tier set bonuses, gem sockets, relative proc quality, stat caps
(hit, defense, uncrushable), on-use cooldown stacking, weapon speed breakpoints.

**Unvalidated:** levels 1–59 and 61–69 for every spec. There is no professional
BiS list for TBC levelling — which is the whole reason this addon has a reason to
exist, and equally the reason nothing in that range has been checked by anyone
but Henrik.
