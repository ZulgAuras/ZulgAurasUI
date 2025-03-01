-- Create addon namespace
local addonName, ZA = ...

-- Initialize addon with Ace3
local ZUI = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")
_G[addonName] = ZUI

-- Default settings
local defaults = {
    profile = {
        enabled = true,
        debug = false,
        modules = {
            unitframes = true,
            actionbars = true,
            buffs = true,
            minimap = true,
            chat = true,
        },
        unitframes = {
            scale = 1,
            player = {
                width = 200,
                height = 50,
                point = {"CENTER", UIParent, "CENTER", -200, 0},
                powerHeight = 0.3, -- 30% of total height
            },
            target = {
                width = 200,
                height = 50,
                point = {"CENTER", UIParent, "CENTER", 200, 0},
                powerHeight = 0.3,
            },
        },
        actionbars = {
            scale = 1,
            spacing = 2,
            padding = 2,
            buttonSize = 36,
            barSpacing = 5,
            bars = {
                main = {
                    enabled = true,
                    point = {"BOTTOM", UIParent, "BOTTOM", 0, 20},
                    buttons = 12,
                    rows = 1,
                },
                bottom = {
                    enabled = true,
                    point = {"BOTTOM", UIParent, "BOTTOM", 0, 60},
                    buttons = 12,
                    rows = 2,
                },
            },
        },
    },
}

function ZUI:OnInitialize()
    -- Initialize database
    self.db = LibStub("AceDB-3.0"):New("ZulgAurasUIDB", defaults)
    
    -- Register profile callbacks
    self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
    
    -- Register chat commands
    self:RegisterChatCommand("zui", "HandleSlashCommand")
    
    -- Setup config
    self:SetupConfig()
    
    -- Initialize modules
    self:InitializeModules()
    
    self:Debug("OnInitialize completed")
end

function ZUI:OnEnable()
    self:Debug("OnEnable started")
    
    -- Enable modules
    for moduleName, enabled in pairs(self.db.profile.modules) do
        if enabled then
            local module = self:GetModule(moduleName)
            if module then
                module:Enable()
            end
        end
    end
    
    self:Print("ZulgAurasUI loaded. Type /zui for options.")
end

function ZUI:InitializeModules()
    self:Debug("Initializing modules")
    
    -- Create modules
    self.modules = {}
    
    -- Initialize each module
    for moduleName, enabled in pairs(self.db.profile.modules) do
        local module = self:GetModule(moduleName)
        if module then
            module:Initialize()
        end
    end
end

function ZUI:RefreshConfig()
    self:Debug("Refreshing configuration")
    
    for moduleName, enabled in pairs(self.db.profile.modules) do
        local module = self:GetModule(moduleName)
        if module then
            if enabled then
                module:Disable()
                module:Enable()
            else
                module:Disable()
            end
        end
    end
end

function ZUI:HandleSlashCommand(input)
    if not input or input:trim() == "" then
        self:OpenConfigPanel()
    else
        self:HandleCommand(input)
    end
end

function ZUI:HandleCommand(input)
    local command, rest = input:match("^(%S+)%s*(.*)$")
    if command then
        command = command:lower()
        
        if command == "config" then
            self:OpenConfigPanel()
        elseif command == "reset" then
            self:ResetConfig()
        else
            self:PrintHelp()
        end
    end
end

function ZUI:OpenConfigPanel()
    InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
end

function ZUI:ResetConfig()
    self.db:ResetProfile()
    self:RefreshConfig()
    self:Print("Configuration reset to defaults.")
end

function ZUI:PrintHelp()
    self:Print("ZulgAurasUI Commands:")
    self:Print("  /zui - Open configuration panel")
    self:Print("  /zui config - Open configuration panel")
    self:Print("  /zui reset - Reset configuration to defaults")
end

function ZUI:Debug(...)
    if self.db and self.db.profile.debug then
        self:Print("|cFF666666Debug:|r", ...)
    end
end

-- Return the addon table
ZA.ZUI = ZUI
return ZUI