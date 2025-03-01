local addonName, ZA = ...
local ZUI = _G[addonName]
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local options = {
    type = "group",
    name = "ZulgAurasUI",
    args = {
        general = {
            type = "group",
            name = "General",
            order = 1,
            args = {
                enabled = {
                    type = "toggle",
                    name = "Enable",
                    desc = "Enable/disable the entire addon",
                    get = function() return ZUI.db.profile.enabled end,
                    set = function(_, value)
                        ZUI.db.profile.enabled = value
                        if value then
                            ZUI:Enable()
                        else
                            ZUI:Disable()
                        end
                    end,
                    order = 1,
                },
                debug = {
                    type = "toggle",
                    name = "Debug Mode",
                    desc = "Enable/disable debug messages",
                    get = function() return ZUI.db.profile.debug end,
                    set = function(_, value)
                        ZUI.db.profile.debug = value
                    end,
                    order = 2,
                },
            },
        },
        unitframes = {
            type = "group",
            name = "Unit Frames",
            order = 2,
            args = {
                enabled = {
                    type = "toggle",
                    name = "Enable",
                    desc = "Enable/disable unit frames",
                    get = function() return ZUI.db.profile.modules.unitframes end,
                    set = function(_, value)
                        ZUI.db.profile.modules.unitframes = value
                        ZUI:RefreshConfig()
                    end,
                    order = 1,
                },
                scale = {
                    type = "range",
                    name = "Scale",
                    desc = "Set the scale of unit frames",
                    min = 0.5,
                    max = 2,
                    step = 0.1,
                    get = function() return ZUI.db.profile.unitframes.scale end,
                    set = function(_, value)
                        ZUI.db.profile.unitframes.scale = value
                        ZUI:RefreshConfig()
                    end,
                    order = 2,
                },
            },
        },
        actionbars = {
            type = "group",
            name = "Action Bars",
            order = 3,
            args = {
                enabled = {
                    type = "toggle",
                    name = "Enable",
                    desc = "Enable/disable action bars",
                    get = function() return ZUI.db.profile.modules.actionbars end,
                    set = function(_, value)
                        ZUI.db.profile.modules.actionbars = value
                        ZUI:RefreshConfig()
                    end,
                    order = 1,
                },
                scale = {
                    type = "range",
                    name = "Scale",
                    desc = "Set the scale of action bars",
                    min = 0.5,
                    max = 2,
                    step = 0.1,
                    get = function() return ZUI.db.profile.actionbars.scale end,
                    set = function(_, value)
                        ZUI.db.profile.actionbars.scale = value
                        ZUI:RefreshConfig()
                    end,
                    order = 2,
                },
                spacing = {
                    type = "range",
                    name = "Button Spacing",
                    desc = "Set the spacing between buttons",
                    min = 0,
                    max = 10,
                    step = 1,
                    get = function() return ZUI.db.profile.actionbars.spacing end,
                    set = function(_, value)
                        ZUI.db.profile.actionbars.spacing = value
                        ZUI:RefreshConfig()
                    end,
                    order = 3,
                },
            },
        },
    },
}

function ZUI:SetupConfig()
    AceConfig:RegisterOptionsTable("ZulgAurasUI", options)
    self.optionsFrame = AceConfigDialog:AddToBlizOptions("ZulgAurasUI", "ZulgAurasUI")
end