local _, GQ = ...

GQ.PaperDoll = GQ.PaperDoll or {}

-- Slots wired for MVP; expand as data coverage grows.
local SUPPORTED_SLOTS = {
    "MainHand",
}

function GQ.PaperDoll:Init()
    if self.initialized then
        return
    end
    self.initialized = true

    for _, slotName in ipairs(SUPPORTED_SLOTS) do
        local button = _G["Character" .. slotName .. "Slot"]
        if button and not button.GearQuestHooked then
            button.GearQuestHooked = true
            button:HookScript("OnClick", function(self, mouseButton)
                if mouseButton == "RightButton" and CharacterFrame and CharacterFrame:IsShown() then
                    local gq = _G.GearQuest
                    if gq and gq.Popup then
                        gq.Popup:ShowForSlot(slotName, self)
                    end
                end
            end)
        end
    end
end
