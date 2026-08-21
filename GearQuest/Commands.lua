local _, GQ = ...

GQ.Commands = GQ.Commands or {}

local PREVIEW_PREFIXES = {
    "set ",
    "class ",
    "level ",
    "lvl ",
    "faction ",
    "preview ",
}

local function IsPreviewCommand(lower)
    if lower == "set"
        or lower == "debug"
        or lower == "status"
        or lower == "preview"
        or lower == "me"
    then
        return true
    end

    for _, prefix in ipairs(PREVIEW_PREFIXES) do
        if lower:sub(1, #prefix) == prefix then
            return true
        end
    end

    return false
end

function GQ.Commands:Init()
    SLASH_GEARQUEST1 = "/gearquest"
    SLASH_GEARQUEST2 = "/gq"

    SlashCmdList["GEARQUEST"] = function(msg)
        msg = strtrim(msg or "")
        local lower = msg:lower()

        if lower == "" then
            GQ.Log:Toggle()
        elseif IsPreviewCommand(lower) then
            GQ.Preview:HandleCommand(lower)
        elseif lower == "log" then
            GQ.Log:Toggle()
        elseif lower == "complete" then
            if GQ.Log.selectedHuntId then
                GQ.Log:CompleteHunt(GQ.Log.selectedHuntId)
            else
                print("|cff66ccffGearQuest|r: No hunt selected. Open |cff00ff00/gq log|r and pick one.")
            end
        elseif lower == "abandon" then
            if GQ.Log.selectedHuntId then
                GQ.Log:AbandonHunt(GQ.Log.selectedHuntId)
            else
                print("|cff66ccffGearQuest|r: No hunt selected.")
            end
        elseif lower == "help" then
            GQ.Preview:PrintHelp()
        else
            print("|cff66ccffGearQuest|r: Unknown command. Try |cff00ff00/gq help|r, |cff00ff00/gq set|r, or |cff00ff00/gq log|r.")
        end
    end
end
