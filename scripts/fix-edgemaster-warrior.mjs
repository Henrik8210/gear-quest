/**
 * Edgemaster's Handguards (14551) should be rank 1 for all warrior specs
 * on Hands from level 44 through 59. At level 60: rank 2 arms/fury (already),
 * rank 3 protection (replace Dreadnaught Gauntlets).
 *
 * Also removes broken warriorNotable rows for item 8346 (wrong id, no facts).
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const file = path.join(__dirname, "..", "GearQuest", "_generated", "Data.Warrior.generated.lua");
let text = fs.readFileSync(file, "utf8");

const EDGEMASTER = 14551;
const SPECS = ["arms", "fury", "protection"];
const FACTIONS = ["Alliance", "Horde"];

function parseRow(line) {
  const m = line.match(
    /^\s*\{(\d+),"([^"]+)",(\d+),(\d+),(\d+),"([^"]+)","([^"]+)",([\d.]+)(.*)\},?$/,
  );
  if (!m) return null;
  return {
    line,
    itemId: +m[1],
    slot: m[2],
    minLevel: +m[3],
    maxLevel: +m[4],
    rank: +m[5],
    spec: m[6],
    faction: m[7],
    score: +m[8],
    tail: m[9],
  };
}

function formatRow(r) {
  return `    {${r.itemId},"${r.slot}",${r.minLevel},${r.maxLevel},${r.rank},"${r.spec}","${r.faction}",${r.score}${r.tail}},`;
}

const picksStart = text.indexOf("GQ.Data.warriorPicks = {");
const picksMatch = text.slice(picksStart).match(/\{([\s\S]*?)\n\}(?=\s*(?:\n|$|--|GQ\.Data\.))/);
const picksBody = picksMatch ? picksMatch[1] : "";
const picksEnd = picksStart + (picksMatch ? picksMatch[0].length : 0);
const head = text.slice(0, picksStart + "GQ.Data.warriorPicks = {".length);
const tail = text.slice(picksStart + (picksMatch ? picksMatch[0].length : 0));

const lines = picksBody.split("\n");
const rows = [];
for (const line of lines) {
  if (!line.trim().startsWith("{")) {
    rows.push({ kind: "raw", line });
    continue;
  }
  const r = parseRow(line);
  if (!r) {
    rows.push({ kind: "raw", line });
    continue;
  }
  rows.push({ kind: "row", ...r });
}

function groupKey(r) {
  return [r.slot, r.minLevel, r.maxLevel, r.spec, r.faction].join("|");
}

const groups = new Map();
for (const r of rows) {
  if (r.kind !== "row" || r.slot !== "Hands") continue;
  const k = groupKey(r);
  if (!groups.has(k)) groups.set(k, []);
  groups.get(k).push(r);
}

let promoted = 0;
let inserted = 0;

for (const [, group] of groups) {
  const minL = group[0].minLevel;
  const maxL = group[0].maxLevel;
  if (minL < 44 || minL > 59) continue;
  if (maxL > 59) continue;

  let edge = group.find((r) => r.itemId === EDGEMASTER);
  if (!edge) {
    edge = {
      kind: "row",
      itemId: EDGEMASTER,
      slot: "Hands",
      minLevel: minL,
      maxLevel: maxL,
      rank: 1,
      spec: group[0].spec,
      faction: group[0].faction,
      score: 28.81,
      tail: "",
    };
    rows.push(edge);
    group.push(edge);
    inserted++;
  }

  const oldRank = edge.rank;
  if (oldRank === 1) continue;

  edge.rank = 1;
  promoted++;

  const others = group.filter((r) => r.itemId !== EDGEMASTER).sort((a, b) => a.rank - b.rank);
  let next = 2;
  for (const o of others) {
    if (next > 3) {
      o.rank = 4; // drop out of top 3
    } else {
      o.rank = next++;
    }
  }
}

// Protection 60: Edgemaster's rank 3 instead of Dreadnaught Gauntlets (22421)
for (const r of rows) {
  if (
    r.kind === "row" &&
    r.slot === "Hands" &&
    r.minLevel === 60 &&
    r.maxLevel === 60 &&
    r.spec === "protection" &&
    r.itemId === 22421
  ) {
    r.itemId = EDGEMASTER;
    r.rank = 3;
    r.score = 28.81;
    r.tail = ',origin="guide"';
  }
}

const outLines = rows.map((r) => (r.kind === "raw" ? r.line : formatRow(r)));
const newPicks = outLines.join("\n");
text = head + "\n" + newPicks + tail;

// Remove wrong notable id 8346 for Hands (Edgemaster's belongs in top picks, not notables)
const notableStart = text.indexOf("GQ.Data.warriorNotable = {");
const notableEnd = text.indexOf("\n}", notableStart);
const notableBlock = text.slice(notableStart, notableEnd);
const cleanedNotable = notableBlock
  .split("\n")
  .filter((line) => !(line.includes("{8346,") && line.includes('"Hands"')))
  .join("\n");
text = text.slice(0, notableStart) + cleanedNotable + text.slice(notableEnd);

fs.writeFileSync(file, text);
console.log(`Promoted Edgemaster's to rank 1 in ${promoted} existing bands`);
console.log(`Inserted Edgemaster's into ${inserted} protection bands`);
console.log("Fixed protection level-60 rank 3 and removed Hands 8346 notables");
