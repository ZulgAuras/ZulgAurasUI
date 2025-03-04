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
    
    if self.frame.SetBackdrop then
        self.frame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 16,
        })
        self.frame:SetBackdropColor(0, 0, 0, 0.7)
        self.frame:SetBackdropBorderColor(0, 0, 0, 1)
    end
    
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
        ZA.db.profile.xpBar.yOffset = yOfs
        print("ZulgAurasUI: XPBar position saved (xOffset=" .. xOfs .. ", yOffset=" .. yOfs .. ")")
    end)
    
    -- Register events to update the XP bar
    self:RegisterEvent("PLAYER_XP_UPDATE", "UpdateXP")
    self:RegisterEvent("PLAYER_LEVEL_UP", "UpdateXP")
    
    print("ZulgAurasUI: XPBar module initialized.")
end

function XPBar:OnEnable()
    self.frame:Show()
    self:UpdateXP()
    print("ZulgAurasUI: XPBar module enabled.")
end

function XPBar:UpdateXP()
    local currXP = UnitXP("player")
    local maxXP = UnitXPMax("player")
    
    self.xpBar:SetMinMaxValues(0, maxXP)
    self.xpBar:SetValue(currXP)
    
    local percentXP = math.floor((currXP / maxXP) * 100)
    self.xpText:SetText(percentXP .. "% (" .. currXP .. "/" .. maxXP .. ")")
end

function XPBar:UpdateBar(settings)
    if self.frame then
        self.frame:SetScale(settings.scale or 1)
        self.frame:SetAlpha(settings.alpha or 1)
        
        -- Update position if provided
        if settings.xOffset ~= nil and settings.yOffset ~= nil then
            self.frame:ClearAllPoints()
            self.frame:SetPoint("CENTER", UIParent, "CENTER", settings.xOffset, settings.yOffset)
        end
        
        print("ZulgAurasUI: Updated XPBar (scale=" .. (settings.scale or 1) .. 
              ", alpha=" .. (settings.alpha or 1) .. 
              ", xOffset=" .. (settings.xOffset or 0) .. 
              ", yOffset=" .. (settings.yOffset or -200) .. ")")
    end
end

return XPBar