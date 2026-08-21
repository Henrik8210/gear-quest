local _, GQ = ...

GQ.PaperDoll = GQ.PaperDoll or {}

-- Slots wired for MVP; expand as data coverage grows.
local SUPPORTED_SLOTS = {
    "MainHand",
}

function GQ.PaperDoll:Init()
    for _, slotName in ipairs(SUPPORTED_SLOTS) do
        local button = _G["Character" .. slotName .. "Slot"]
        if button then
            button:HookScript("OnClick", function(self, mouseButton)
                if mouseButton == "RightButton" and CharacterFrame and CharacterFrame:IsShown() then
                    GQ.Popup:ShowForSlot(slotName, self)
                end
            end)
        end
    end
end
