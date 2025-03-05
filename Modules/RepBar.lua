------------------------------------------------------------
-- ZulgAurasUI RepBar Module for Classic
------------------------------------------------------------
local ZA = LibStub("AceAddon-3.0"):GetAddon("ZulgAurasUI")
local RepBar = ZA:NewModule("RepBar", "AceEvent-3.0")

function RepBar:OnInitialize()
    self.frame = CreateFrame("Frame", "ZulgAurasUI_RepBar", UIParent)
    self.frame:SetSize(300, 20)
    
    -- Use saved position if available, otherwise default to center position
    local xOffset = ZA.db.profile.repBar.xOffset or 0
    local yOffset = ZA.db.profile.repBar.yOffset or -300
    self.frame:SetPoint("CENTER", UIParent, "CENTER", xOffset, yOffset)

    -- Create background
    self.background = self.frame:CreateTexture(nil, "BACKGROUND")
    self.background:SetAllPoints()
    self.background:SetColorTexture(0, 0, 0, 0.7) -- Adjust color and alpha as needed
    
    -- Create reputation bar
    self.repBar = CreateFrame("StatusBar", nil, self.frame)
    self.repBar:SetAllPoints()
    self.repBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    self.repBar:SetStatusBarColor(0.8, 0.8, 0.1)
    
    -- Create reputation text
    self.repText = self.repBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    self.repText:SetPoint("CENTER", self.repBar, "CENTER", 0, 0)
    self.repText:SetTextColor(1, 1, 1)
    
    -- Make the rep bar movable
    self.frame:SetMovable(true)
    self.frame:EnableMouse(true)
    self.frame:RegisterForDrag("LeftButton")
    self.frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    self.frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        -- Save the new position
        local point, _, _, xOfs, yOfs = self:GetPoint()
        ZA.db.profile.repBar.xOffset = xOfs
        ZA.db.profile.repBar.yOffset = yOfs
    end)
    
    -- Register events to update the reputation bar
    self:RegisterEvent("UPDATE_FACTION", "UpdateReputation")
    
    print("ZulgAurasUI: RepBar module initialized.")
end

function RepBar:OnEnable()
    self.frame:Show()
    self:UpdateReputation()
    self:HideBlizzardBars(true)
    print("ZulgAurasUI: RepBar module enabled.")
end

function RepBar:UpdateReputation()
    local name, standing, min, max, current = GetWatchedFactionInfo()
    
    if name then
        self.repBar:SetMinMaxValues(min, max)
        self.repBar:SetValue(current)
        
        -- Get the standing name (Friendly, Honored, etc.)
        local standingName
        if standing == 1 then
            standingName = "Hated"
        elseif standing == 2 then
            standingName = "Hostile"
        elseif standing == 3 then
            standingName = "Unfriendly"
        elseif standing == 4 then
            standingName = "Neutral"
        elseif standing == 5 then
            standingName = "Friendly"
        elseif standing == 6 then
            standingName = "Honored"
        elseif standing == 7 then
            standingName = "Revered"
        elseif standing == 8 then
            standingName = "Exalted"
        end
        
        local value = current - min
        local maximum = max - min
        local percent = math.floor((value / maximum) * 100)
        
        self.repText:SetText(name .. " - " .. standingName .. " " .. percent .. "%")
        self.frame:Show()
    else
        self.repText:SetText("No faction watched")
        self.frame:Hide()
    end

    -- Ensure Blizzard bars are hidden
    self:HideBlizzardBars(true)
end

function RepBar:UpdateBar(settings)
    if self.frame then
        self.frame:SetScale(settings.scale or 1)
        self.frame:SetAlpha(settings.alpha or 1)
        
        local point, relativeTo, relativePoint, _, _ = self.frame:GetPoint(1)
        if point and relativeTo and relativePoint then
            local xOffset = settings.xOffset or 0
            local yOffset = settings.yOffset or -250
            self.frame:ClearAllPoints()
            self.frame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
        end
    end
end

function RepBar:HideBlizzardBars(firstTime)
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

return RepBar