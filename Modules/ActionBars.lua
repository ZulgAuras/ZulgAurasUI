------------------------------------------------------------
-- ZulgAurasUI ActionBars Module for Classic
------------------------------------------------------------
local ZA = LibStub("AceAddon-3.0"):GetAddon("ZulgAurasUI")
local ActionBars = ZA:NewModule("ActionBars", "AceEvent-3.0")

local ActionBarsConfig = {
    [1] = { ids = { 1,2,3,4,5,6,7,8,9,10,11,12 } },
    [2] = { ids = {25,26,27,28,29,30,31,32,33,34,35,36} },
    [3] = { ids = {37,38,39,40,41,42,43,44,45,46,47,48} },
    [4] = { ids = {49,50,51,52,53,54,55,56,57,58,59,60} },
    [5] = { ids = {61,62,63,64,65,66,67,68,69,70,71,72} },
}

function ActionBars:OnInitialize()
    self.bars = {}
    for i = 1, 5 do
        local bar = CreateFrame("Frame", "ZulgAurasUI_ActionBarFrame" .. i, UIParent)
        bar:SetSize(400, 40)
        bar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, (i - 1) * 50)
        bar:SetScale(1)
        bar:SetAlpha(1)
        -- Classic WoW does not ship with a native SetBackdrop; if you have a backport installed, this will work.
        if bar.SetBackdrop then
            bar:SetBackdrop({
                bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 16,
            })
            bar:SetBackdropColor(0, 0, 0, 0.7)
            bar:SetBackdropBorderColor(0, 0, 0, 1)
        end
        self.bars[i] = bar

        local config = ActionBarsConfig[i]
        if config and config.ids then
            for j, buttonID in ipairs(config.ids) do
                local btnName = "ZulgAurasUI_Button_" .. buttonID
                local button = CreateFrame("CheckButton", btnName, bar, "ActionBarButtonTemplate")
                button:SetID(buttonID)
                button:SetSize(36, 36)
                button:SetPoint("LEFT", bar, "LEFT", (j - 1) * 38, 0)
                button:SetAttribute("type", "action")
                button:SetAttribute("action", buttonID)
                button:Show()
            end
        end
    end

    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")
    print("ZulgAurasUI: ActionBars module initialized.")
end

function ActionBars:OnPlayerEnteringWorld()
    for i, bar in ipairs(self.bars) do
        bar:Show()
    end
end

-- UpdateBar applies updated settings to the specified action bar.
function ActionBars:UpdateBar(index, settings)
    if not self.bars[index] then return end
    local bar = self.bars[index]
    bar:SetScale(settings.scale or 1)
    bar:SetAlpha(settings.alpha or 1)
    bar:ClearAllPoints()
    bar:SetPoint("BOTTOM", UIParent, "BOTTOM", settings.xOffset or 0, settings.yOffset or ((index - 1) * 50))
    if settings.visible then 
        bar:Show()
    else 
        bar:Hide()
    end
    if settings.border and bar.SetBackdrop then
        bar:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 16,
        })
        bar:SetBackdropBorderColor(unpack(settings.borderColor or {0, 0, 0, 1}))
    elseif bar.SetBackdrop then
        bar:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background" })
    end
    print("ZulgAurasUI: Updated ActionBar " .. index ..
          " (scale=" .. (settings.scale or 1) ..
          ", alpha=" .. (settings.alpha or 1) ..
          ", xOffset=" .. (settings.xOffset or 0) ..
          ", yOffset=" .. (settings.yOffset or ((index - 1) * 50)) .. ")")
end

return ActionBars