local addonName, ZA = ...
local ZUI = _G[addonName]
local ActionBars = ZUI:NewModule("ActionBars", "AceEvent-3.0")

function ActionBars:OnInitialize()
    self.bars = {}
    self.config = ZUI.db.profile.actionbars
    ZUI:Debug("ActionBars initialized")
end

function ActionBars:OnEnable()
    ZUI:Debug("ActionBars enabled")
    self:CreateBars()
    self:RegisterEvents()
end

function ActionBars:OnDisable()
    ZUI:Debug("ActionBars disabled")
    self:UnregisterAllEvents()
    for _, bar in pairs(self.bars) do
        bar:Hide()
    end
end

function ActionBars:CreateBars()
    self:CreateMainBar()
    self:CreateBottomBar()
end

function ActionBars:CreateMainBar()
    local cfg = self.config.bars.main
    if not cfg.enabled then return end
    
    -- Create main container
    local bar = CreateFrame("Frame", "ZUIMainActionBar", UIParent)
    bar:SetSize(
        (self.config.buttonSize + self.config.spacing) * cfg.buttons - self.config.spacing,
        (self.config.buttonSize + self.config.spacing) * cfg.rows - self.config.spacing
    )
    bar:SetPoint(unpack(cfg.point))
    bar:SetScale(self.config.scale)
    
    -- Create buttons
    bar.buttons = {}
    for i = 1, cfg.buttons do
        local button = self:CreateActionButton(i, bar)
        local row = math.floor((i-1) / cfg.buttons)
        local col = (i-1) % cfg.buttons
        
        button:SetPoint(
            "TOPLEFT",
            col * (self.config.buttonSize + self.config.spacing),
            -row * (self.config.buttonSize + self.config.spacing)
        )
        
        bar.buttons[i] = button
    end
    
    self.bars.main = bar
end

function ActionBars:CreateBottomBar()
    local cfg = self.config.bars.bottom
    if not cfg.enabled then return end
    
    -- Create bottom bars container
    local bar = CreateFrame("Frame", "ZUIBottomActionBar", UIParent)
    bar:SetSize(
        (self.config.buttonSize + self.config.spacing) * cfg.buttons - self.config.spacing,
        (self.config.buttonSize + self.config.spacing) * cfg.rows - self.config.spacing
    )
    bar:SetPoint(unpack(cfg.point))
    bar:SetScale(self.config.scale)
    
    -- Create buttons
    bar.buttons = {}
    local buttonIndex = 13 -- Start after main bar buttons
    for i = 1, (cfg.buttons * cfg.rows) do
        local button = self:CreateActionButton(buttonIndex, bar)
        local row = math.floor((i-1) / cfg.buttons)
        local col = (i-1) % cfg.buttons
        
        button:SetPoint(
            "TOPLEFT",
            col * (self.config.buttonSize + self.config.spacing),
            -row * (self.config.buttonSize + self.config.spacing)
        )
        
        bar.buttons[i] = button
        buttonIndex = buttonIndex + 1
    end
    
    self.bars.bottom = bar
end

function ActionBars:CreateActionButton(id, parent)
    -- Create the button
    local button = CreateFrame("Button", "ZUIActionButton" .. id, parent, "SecureActionButtonTemplate")
    button:SetSize(self.config.buttonSize, self.config.buttonSize)
    
    -- Create icon texture
    button.icon = button:CreateTexture(nil, "BACKGROUND")
    button.icon:SetAllPoints()
    
    -- Create cooldown frame
    button.cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    button.cooldown:SetAllPoints()
    
    -- Create count text
    button.count = button:CreateFontString(nil, "OVERLAY")
    button.count:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    button.count:SetPoint("BOTTOMRIGHT", -2, 2)
    
    -- Create hotkey text
    button.hotkey = button:CreateFontString(nil, "OVERLAY")
    button.hotkey:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    button.hotkey:SetPoint("TOPRIGHT", -2, -2)
    
    -- Create border
    button.border = button:CreateTexture(nil, "OVERLAY")
    button.border:SetAllPoints()
    button.border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    button.border:SetBlendMode("ADD")
    button.border:Hide()
    
    -- Set up attributes
    button:SetAttribute("type", "action")
    button:SetAttribute("action", id)
    
    -- Register for clicks
    button:RegisterForClicks("AnyUp")
    
    -- Register for drag
    button:RegisterForDrag("LeftButton")
    
    return button
end

function ActionBars:UpdateActionButton(button)
    local action = button:GetAttribute("action")
    if not action then return end
    
    -- Update icon
    local texture = GetActionTexture(action)
    button.icon:SetTexture(texture)
    
    -- Update count
    local count = GetActionCount(action)
    if count > 1 then
        button.count:SetText(count)
        button.count:Show()
    else
        button.count:Hide()
    end
    
    -- Update cooldown
    local start, duration, enable = GetActionCooldown(action)
    if duration > 0 then
        button.cooldown:SetCooldown(start, duration)
        button.cooldown:Show()
    else
        button.cooldown:Hide()
    end
    
    -- Update hotkey
    local key = GetBindingKey("ACTIONBUTTON" .. action)
    if key then
        button.hotkey:SetText(GetBindingText(key, "KEY_"))
        button.hotkey:Show()
    else
        button.hotkey:Hide()
    end
    
    -- Update usable state
    local isUsable, notEnoughMana = IsUsableAction(action)
    if isUsable then
        button.icon:SetVertexColor(1, 1, 1)
    elseif notEnoughMana then
        button.icon:SetVertexColor(0.5, 0.5, 1)
    else
        button.icon:SetVertexColor(0.4, 0.4, 0.4)
    end
end

function ActionBars:UpdateAllButtons()
    for _, bar in pairs(self.bars) do
        for _, button in pairs(bar.buttons) do
            self:UpdateActionButton(button)
        end
    end
end

function ActionBars:RegisterEvents()
    self:RegisterEvent("ACTIONBAR_UPDATE_STATE", "UpdateAllButtons")
    self:RegisterEvent("ACTIONBAR_UPDATE_USABLE", "UpdateAllButtons")
    self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN", "UpdateAllButtons")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateAllButtons")
    self:RegisterEvent("UPDATE_BINDINGS", "UpdateAllButtons")
end