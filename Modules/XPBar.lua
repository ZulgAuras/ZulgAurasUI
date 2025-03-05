------------------------------------------------------------
-- ZulgAurasUI XPBar Module for Classic
------------------------------------------------------------
local ZA = LibStub("AceAddon-3.0"):GetAddon("ZulgAurasUI")
local XPBar = ZA:NewModule("XPBar", "AceEvent-3.0")

function XPBar:OnInitialize()
    self.frame = CreateFrame("Frame", "ZulgAurasUI_XPBar", UIParent)
    self.frame:SetSize(300, 20)
    
    -- Use saved position if available, otherwise default to center position
    local xOffset = ZA.db.profile.xpBar.xOffset or 0
    local yOffset = ZA.db.profile.xpBar.yOffset or -200
    self.frame:SetPoint("CENTER", UIParent, "CENTER", xOffset, yOffset)
    
    -- Create background
    self.background = self.frame:CreateTexture(nil, "BACKGROUND")
    self.background:SetAllPoints()
    self.background:SetColorTexture(0, 0, 0, 0.7) -- Adjust color and alpha as needed
    
    -- Create actual XP bar
    self.xpBar = CreateFrame("StatusBar", nil, self.frame)
    self.xpBar:SetAllPoints()
    self.xpBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    self.xpBar:SetStatusBarColor(0.25, 0.25, 1.0)
    
    -- Create XP text
    self.xpText = self.xpBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    self.xpText:SetPoint("CENTER", self.xpBar, "CENTER", 0, 0)
    self.xpText:SetTextColor(1, 1, 1)
    
    -- Make the XP bar movable
    self.frame:SetMovable(true)
    self.frame:EnableMouse(true)
    self.frame:RegisterForDrag("LeftButton")
    self.frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    self.frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        -- Save the new position
        local point, _, _, xOfs, yOfs = self:GetPoint()
        ZA.db.profile.xpBar.xOffset = xOfs
        ZA.db.profile.xpBar.yOfs = yOfs
    end)
    
    -- Register events to update the XP bar
    self:RegisterEvent("PLAYER_XP_UPDATE", "UpdateXP")
    self:RegisterEvent("PLAYER_LEVEL_UP", "UpdateXP")
    
    print("ZulgAurasUI: XPBar module initialized.")
end

function XPBar:OnEnable()
    self.frame:Show()
    self:UpdateXP()
    self:HideBlizzardBars(true)
    print("ZulgAurasUI: XPBar module enabled.")
end

function XPBar:UpdateXP()
    local currXP = UnitXP("player")
    local maxXP = UnitXPMax("player")
    
    self.xpBar:SetMinMaxValues(0, maxXP)
    self.xpBar:SetValue(currXP)
    
    local percentXP = math.floor((currXP / maxXP) * 100)
    self.xpText:SetText(percentXP .. "% (" .. currXP .. "/" .. maxXP .. ")")

    -- Ensure Blizzard bars are hidden
    self:HideBlizzardBars(true)
end

function XPBar:UpdateBar(settings)
    if self.frame then
        self.frame:SetScale(settings.scale or 1)
        self.frame:SetAlpha(settings.alpha or 1)
        
        -- Preserve the current anchor instead of resetting it.
        local point, relativeTo, relativePoint, _, _ = self.frame:GetPoint(1)
        if point and relativeTo and relativePoint then
            -- Use the xOffset and yOffset values from settings if they exist,
            -- otherwise, keep the current offsets.
            local xOffset = settings.xOffset or 0
            local yOffset = settings.yOffset or 0
            self.frame:ClearAllPoints()
            self.frame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
        end
    end
end

function XPBar:HideBlizzardBars(firstTime)
    if ReputationWatchBar then
        ReputationWatchBar:Hide()
        if ReputationWatchBar.UnregisterAllEvents then
            ReputationWatchBar:UnregisterAllEvents()
        end
        ReputationWatchBar.Show = function() end
        if firstTime then
            ReputationWatchBar:HookScript("OnShow", ReputationWatchBar.Hide)
        end
    end
    if MainMenuExpBar then
        MainMenuExpBar:Hide()
        if MainMenuExpBar.UnregisterAllEvents then
            MainMenuExpBar:UnregisterAllEvents()
        end
        MainMenuExpBar.Show = function() end
        if firstTime then
            MainMenuExpBar:HookScript("OnShow", MainMenuExpBar.Hide)
        end
    end
    if MainMenuBarMaxLevelBar then
        MainMenuBarMaxLevelBar:Hide()
        if MainMenuBarMaxLevelBar.UnregisterAllEvents then
            MainMenuBarMaxLevelBar:UnregisterAllEvents()
        end
        MainMenuBarMaxLevelBar.Show = function() end
        if firstTime then
            MainMenuBarMaxLevelBar:HookScript("OnShow", MainMenuBarMaxLevelBar.Hide)
        end
    end
    for i = 0, 3 do
        local maxLevelBar = _G["MainMenuMaxLevelBar" .. i]
        if maxLevelBar then
            maxLevelBar:Hide()
            if maxLevelBar.UnregisterAllEvents then
                maxLevelBar:UnregisterAllEvents()
            end
            maxLevelBar.Show = function() end
            if firstTime then
                maxLevelBar:HookScript("OnShow", maxLevelBar.Hide)
            end
        end
    end
end

return XPBar