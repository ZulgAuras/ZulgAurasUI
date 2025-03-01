local addonName, ZA = ...
local ZUI = _G[addonName]
local UnitFrames = ZUI:NewModule("UnitFrames", "AceEvent-3.0")

function UnitFrames:OnInitialize()
    self.frames = {}
    self.config = ZUI.db.profile.unitframes
    ZUI:Debug("UnitFrames initialized")
end

function UnitFrames:OnEnable()
    ZUI:Debug("UnitFrames enabled")
    self:CreateFrames()
    self:RegisterEvents()
end

function UnitFrames:OnDisable()
    ZUI:Debug("UnitFrames disabled")
    self:UnregisterAllEvents()
    for _, frame in pairs(self.frames) do
        frame:Hide()
    end
end

function UnitFrames:CreateFrames()
    self:CreatePlayerFrame()
    self:CreateTargetFrame()
end

function UnitFrames:CreatePlayerFrame()
    local cfg = self.config.player
    
    -- Create main frame
    local frame = CreateFrame("Button", "ZUIPlayerFrame", UIParent, "SecureUnitButtonTemplate")
    frame:SetSize(cfg.width, cfg.height)
    frame:SetPoint(unpack(cfg.point))
    frame:SetScale(self.config.scale)
    
    -- Create health bar
    local healthBar = CreateFrame("StatusBar", nil, frame)
    healthBar:SetPoint("TOPLEFT")
    healthBar:SetPoint("TOPRIGHT")
    healthBar:SetHeight(cfg.height * (1 - cfg.powerHeight))
    healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    healthBar:SetStatusBarColor(0, 1, 0)
    frame.healthBar = healthBar
    
    -- Create power bar
    local powerBar = CreateFrame("StatusBar", nil, frame)
    powerBar:SetPoint("BOTTOMLEFT")
    powerBar:SetPoint("BOTTOMRIGHT")
    powerBar:SetHeight(cfg.height * cfg.powerHeight)
    powerBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    powerBar:SetStatusBarColor(0, 0, 1)
    frame.powerBar = powerBar
    
    -- Create text elements
    local healthText = healthBar:CreateFontString(nil, "OVERLAY")
    healthText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    healthText:SetPoint("CENTER")
    frame.healthText = healthText
    
    local powerText = powerBar:CreateFontString(nil, "OVERLAY")
    powerText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    powerText:SetPoint("CENTER")
    frame.powerText = powerText
    
    -- Set attributes
    frame:SetAttribute("unit", "player")
    frame:SetAttribute("*type1", "target")
    
    -- Store frame
    self.frames.player = frame
    
    -- Initial update
    self:UpdatePlayerFrame()
end

function UnitFrames:UpdatePlayerFrame()
    local frame = self.frames.player
    if not frame then return end
    
    local health = UnitHealth("player")
    local maxHealth = UnitHealthMax("player")
    local power = UnitPower("player")
    local maxPower = UnitPowerMax("player")
    
    frame.healthBar:SetMinMaxValues(0, maxHealth)
    frame.healthBar:SetValue(health)
    frame.healthText:SetText(health .. "/" .. maxHealth)
    
    frame.powerBar:SetMinMaxValues(0, maxPower)
    frame.powerBar:SetValue(power)
    frame.powerText:SetText(power .. "/" .. maxPower)
end

function UnitFrames:RegisterEvents()
    self:RegisterUnitEvent("UNIT_HEALTH", "player", "target")
    self:RegisterUnitEvent("UNIT_POWER_UPDATE", "player", "target")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
end

function UnitFrames:UNIT_HEALTH(event, unit)
    if unit == "player" then
        self:UpdatePlayerFrame()
    elseif unit == "target" then
        self:UpdateTargetFrame()
    end
end

function UnitFrames:UNIT_POWER_UPDATE(event, unit)
    if unit == "player" then
        self:UpdatePlayerFrame()
    elseif unit == "target" then
        self:UpdateTargetFrame()
    end
end

function UnitFrames:PLAYER_TARGET_CHANGED()
    self:UpdateTargetFrame()
end