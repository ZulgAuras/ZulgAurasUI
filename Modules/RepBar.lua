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
    
    if self.frame.SetBackdrop then
        self.frame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 16,
        })
        self.frame:SetBackdropColor(0, 0, 0, 0.7)
        self.frame:SetBackdropBorderColor(0, 0, 0, 1)
    end
    
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
        print("ZulgAurasUI: RepBar position saved (xOffset=" .. xOfs .. ", yOffset=" .. yOfs .. ")")
    end)
    
    -- Register events to update the reputation bar
    self:RegisterEvent("UPDATE_FACTION", "UpdateReputation")
    
    print("ZulgAurasUI: RepBar module initialized.")
end

function RepBar:OnEnable()
    self.frame:Show()
    self:UpdateReputation()
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
end

function RepBar:UpdateBar(settings)
    if self.frame then
        self.frame:SetScale(settings.scale or 1)
        self.frame:SetAlpha(settings.alpha or 1)
        
        -- Update position if provided
        if settings.xOffset ~= nil and settings.yOffset ~= nil then
            self.frame:ClearAllPoints()
            self.frame:SetPoint("CENTER", UIParent, "CENTER", settings.xOffset, settings.yOffset)
        end
        
        print("ZulgAurasUI: Updated RepBar (scale=" .. (settings.scale or 1) .. 
              ", alpha=" .. (settings.alpha or 1) .. 
              ", xOffset=" .. (settings.xOffset or 0) .. 
              ", yOffset=" .. (settings.yOffset or -300) .. ")")
    end
end

return RepBar