local _, GQ = ...

-- Expands the generated BiS tables into GQ.Data.entries, the array that
-- Indicator.lua, Log.lua and Tracker.lua already iterate. Nothing in those files
-- needs to change: generated rows arrive in exactly the shape the curated ones use.
--
-- The four data sources do not overlap:
--   1-9 Alliance   hand-made entries in Data.lua
--   1-9 Horde      GQ.Data.paladinHorde1to9        (this file expands it)
--   10-69          GQ.Data.paladinPicks            (this file expands it)
--   70             curated AtlasLoot entries in Data.lua

local PALADIN = { PALADIN = true }
local SPEC    = { retribution = { retribution = true },
                  protection  = { protection  = true },
                  holy        = { holy        = true } }
local FACTION = { Alliance = { Alliance = true }, Horde = { Horde = true } }

-- The two row shapes differ, so it is passed in rather than inferred:
--   main       { itemId, slot, minLevel, maxLevel, rank, spec, faction, score }
--   Horde 1-9  { itemId, slot, minLevel, maxLevel, rank, score }
-- Reading r[6] as the spec in both would read the Horde file's SCORE as its spec.
local function Expand(rows, facts, shape, out)
    if not rows or not facts then return 0 end
    local added = 0
    for i = 1, #rows do
        local r = rows[i]
        local itemId = r[1]
        local f = facts[itemId]
        if f then
            local spec    = shape.hasSpec and r[6] or shape.spec
            local faction = shape.hasSpec and r[7] or shape.faction
            out[#out + 1] = {
                id           = "gen:" .. itemId .. ":" .. r[2] .. ":" .. r[3]
                                 .. ":" .. tostring(spec) .. ":" .. tostring(faction),
                itemId       = itemId,
                slot         = r[2],
                minLevel     = r[3],
                maxLevel     = r[4],
                curatedRank  = r[5],
                classes      = PALADIN,
                specs        = spec and SPEC[spec] or nil,
                factions     = faction and FACTION[faction] or nil,
                sourceType   = f.sourceType,
                instructions = f.instructions,
                zone         = f.zone,
                npc          = f.npc,
                questName    = f.questName,
                profession   = f.profession,
                -- generated-only extras; existing consumers ignore unknown keys
                suffix       = r.suffix,
                suffixChance = r.suffixChance,
                origin       = r.origin,
                proc         = f.proc,
                generated    = true,
            }
            added = added + 1
        end
    end
    return added
end

function GQ.Data:LoadGenerated()
    if self._generatedLoaded then return 0 end
    self._generatedLoaded = true
    self.entries = self.entries or {}
    local n = 0
    n = n + Expand(self.paladinPicks,     self.itemFacts,
                   { hasSpec = true }, self.entries)
    n = n + Expand(self.paladinHorde1to9, self.paladinHorde1to9Facts,
                   { hasSpec = false, spec = nil, faction = "Horde" }, self.entries)
    self._generatedCount = n
    return n
end

-- Self-wiring, so Core.lua needs no edit. The .toc loads this file after Data.lua
-- and both generated files, so GQ.Data.entries and the generated tables all exist
-- by now. Indicator:PrimeDataItemInfo() runs later, on login, and will see these.
GQ.Data:LoadGenerated()
