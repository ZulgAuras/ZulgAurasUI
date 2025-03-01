local addonName, ZA = ...
local ZUI = ZulgAurasUI
local Minimap = ZUI:NewModule("Minimap", "AceEvent-3.0", "AceHook-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

function Minimap:OnInitialize()
    self.config = ZUI.db.profile.minimap
    self.buttons = {}
    self.framePool = {}
end

function Minimap:OnEnable()
    self:StyleMinimap()
    self:CreateTrackingButton()
    self:CreateMailButton()
    self:HookMinimapFunctions()
    self:RegisterEvents()
end

function Minimap:StyleMinimap()
    -- Create our custom border
    local border = CreateFrame("Frame", "ZUIMinimapBorder", Minimap)
    border:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -3, 3)
    border:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 3, -3)
    border:SetBackdrop({
        edgeFile = "Interface\\AddOns\\ZulgAurasUI\\Media\\border",
        edgeSize = 3,
    })
    border:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    
    -- Make minimap square
    Minimap:SetMaskTexture("Interface\\ChatFrame\\ChatFrameBackground")
    
    -- Remove default border
    MinimapBorder:Hide()
    MinimapCluster:EnableMouse(false)
    
    -- Position minimap
    Minimap:ClearAllPoints()
    Minimap:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -20, -20)
    
    -- Make it movable
    Minimap:SetMovable(true)
    Minimap:EnableMouse(true)
    Minimap:RegisterForDrag("LeftButton")
    Minimap:SetScript("OnDragStart", function()
        if IsAltKeyDown() then
            Minimap:StartMoving()
        end
    end)
    Minimap:SetScript("OnDragStop", function()
        Minimap:StopMovingOrSizing()
        self:SaveMinimapPosition()
    end)
end

function Minimap:CreateTrackingButton()
    local button = CreateFrame("Button", "ZUIMinimapTracking", Minimap)
    button:SetSize(20, 20)
    button:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 5, -5)
    
    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetAllPoints()
    button.icon:SetTexture("Interface\\Minimap\\Tracking\\None")
    
    button:SetScript("OnClick", function()
        ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, "cursor")
    end)
    
    self.buttons.tracking = button
end

function Minimap:CreateMailButton()
    local button = CreateFrame("Button", "ZUIMinimapMail", Minimap)
    button:SetSize(20, 20)
    button:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -5, -5)
    
    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetAllPoints()
    button.icon:SetTexture("Interface\\Icons\\INV_Letter_15")
    button:Hide()
    
    button:SetScript("OnClick", function()
        CheckInbox()
    end)
    
    self.buttons.mail = button
end

function Minimap:HookMinimapFunctions()
    -- Hook minimap ping
    self:RawHook("Minimap_SetPing", function(x, y, playSound)
        if self.config.showPing then
            self.hooks["Minimap_SetPing"](x, y, playSound)
        end
    end, true)
    
    -- Hook minimap zoom
    self:SecureHook(Minimap, "SetZoom", function()
        if self.config.rememberZoom then
            self.config.zoom = Minimap:GetZoom()
        end
    end)
end

function Minimap:RegisterEvents()
    self:RegisterEvent("MAIL_SHOW", function()
        self.buttons.mail:Show()
    end)
    
    self:RegisterEvent("MAIL_CLOSED", function()
        self.buttons.mail:Hide()
    end)
    
    self:RegisterEvent("UPDATE_PENDING_MAIL", function()
        self.buttons.mail:SetShown(HasNewMail())
    end)
    
    self:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        if self.config.rememberZoom then
            Minimap:SetZoom(self.config.zoom or 0)
        end
    end)
end

function Minimap:SaveMinimapPosition()
    local point, _, relativePoint, xOfs, yOfs = Minimap:GetPoint()
    self.config.position = {
        point = point,
        relativePoint = relativePoint,
        x = xOfs,
        y = yOfs,
    }
end

function Minimap:GetOptions()
    return {
        enabled = {
            type = "toggle",
            name = "Enable",
            desc = "Enable/disable the minimap modifications",
            get = function() return self.config.enabled end,
            set = function(_, value)
                self.config.enabled = value
                if value then
                    self:Enable()
                else
                    self:Disable()
                end
            end,
            order = 1,
        },
        showPing = {
            type = "toggle",
            name = "Show Ping",
            desc = "Show minimap ping animation",
            get = function() return self.config.showPing end,
            set = function(_, value)
                self.config.showPing = value
            end,
            order = 2,
        },
        rememberZoom = {
            type = "toggle",
            name = "Remember Zoom",
            desc = "Remember minimap zoom level between sessions",
            get = function() return self.config.rememberZoom end,
            set = function(_, value)
                self.config.rememberZoom = value
            end,
            order = 3,
        },
    }
end