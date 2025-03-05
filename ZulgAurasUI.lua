local ZA = LibStub("AceAddon-3.0"):NewAddon("ZulgAurasUI", "AceEvent-3.0", "AceConsole-3.0")

function ZA:OnInitialize()
    -- Hide Blizzard's default UI elements
    self:HideBlizzardUI()

    -- Init DB with defaults
    self.db = LibStub("AceDB-3.0"):New("ZulgAurasUIDB", {
        profile = {
            minimap = { hide = false },
            actionBars = { scales = { 1 }, visibility = { true } },
            xpBar = { scale = 1, alpha = 1 },
            bagBar = { scale = 1, alpha = 1 },
            repBar = { scale = 1, alpha = 1 },
        },
    })

    -- Setup modules (using IterateModules to capture all modules)
    self:SetupModules()

    -- Setup LDB
    self:SetupLDB()

    -- Register chat command.
    self:RegisterChatCommand("zulgaui", "ChatCommand")

    -- Initialize modules.
    self:EnableModules()
end

function ZA:HideBlizzardUI()
    for i = 1, 12 do
        local button = _G["ActionButton" .. i]
        if button then
            button:Hide()
            button:UnregisterAllEvents()
            button:SetAttribute("statehidden", true)
        end
    end

    if _G["MultiBarBottomLeft"] then _G["MultiBarBottomLeft"]:Hide() end
    if _G["MultiBarBottomRight"] then _G["MultiBarBottomRight"]:Hide() end
    if _G["MultiBarLeft"] then _G["MultiBarLeft"]:Hide() end
    if _G["MultiBarRight"] then _G["MultiBarRight"]:Hide() end

    if _G["MainMenuBar"] then
        _G["MainMenuBar"]:Hide()
        _G["MainMenuBar"]:UnregisterAllEvents()
    end

    if _G["MainMenuBarArtFrame"] then
        _G["MainMenuBarArtFrame"]:Hide()
        if _G["MainMenuBarArtFrame"].LeftEndCap then _G["MainMenuBarArtFrame"].LeftEndCap:Hide() end
        if _G["MainMenuBarArtFrame"].RightEndCap then _G["MainMenuBarArtFrame"].RightEndCap:Hide() end
    end

    if _G["MainMenuBarBackpackButton"] then
        _G["MainMenuBarBackpackButton"]:Hide()
        _G["MainMenuBarBackpackButton"]:UnregisterAllEvents()
    end
    for i = 0, 3 do
        local bagButton = _G["CharacterBag" .. i .. "Slot"]
        if bagButton then
            bagButton:Hide()
            bagButton:UnregisterAllEvents()
        end
    end

    if _G["MainMenuExpBar"] then
        _G["MainMenuExpBar"]:Hide()
        _G["MainMenuExpBar"]:UnregisterAllEvents()
    end

    if _G["ReputationWatchBar"] then
        _G["ReputationWatchBar"]:Hide()
        _G["ReputationWatchBar"]:UnregisterAllEvents()
    end

    if _G["CharacterMicroButton"] then _G["CharacterMicroButton"]:Hide() end
    if _G["SpellbookMicroButton"] then _G["SpellbookMicroButton"]:Hide() end
    if _G["TalentMicroButton"] then _G["TalentMicroButton"]:Hide() end
    if _G["QuestLogMicroButton"] then _G["QuestLogMicroButton"]:Hide() end
    if _G["SocialsMicroButton"] then _G["SocialsMicroButton"]:Hide() end
    if _G["LFGMicroButton"] then _G["LFGMicroButton"]:Hide() end
    if _G["MainMenuMicroButton"] then _G["MainMenuMicroButton"]:Hide() end
    if _G["HelpMicroButton"] then _G["HelpMicroButton"]:Hide() end
    if _G["MainMenuBarPerformanceBar"] then _G["MainMenuBarPerformanceBar"]:Hide() end
end

function ZA:SetupModules()
    self.modules = {}
    for _, module in self:IterateModules() do
        self.modules[module.moduleName] = module
    end
end

function ZA:SetupLDB()
    local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("ZulgAurasUI", {
        type = "launcher",
        text = "ZulgAurasUI",
        icon = "Interface\\Icons\\Ability_Warrior_BattleShout",
        OnClick = function(_, msg)
            if msg == "LeftButton" then
                if _G["InterfaceOptionsFrame"] then
                    _G["InterfaceOptionsFrame"]:Show()
                    LibStub("AceConfigDialog-3.0"):Open("ZulgAurasUI")
                else
                    print("Interface options frame is not available.")
                end
            elseif msg == "RightButton" then
                self:ChatCommand("config")
            end
        end,
    })
    LibStub("LibDBIcon-1.0"):Register("ZulgAurasUI", LDB, self.db.profile.minimap)
end

function ZA:ChatCommand(input)
    if not input or input:trim() == "" then
        -- Instead of opening the default Blizzard options, we use our advanced settings window.
        self:ToggleAdvancedSettings()
    else
        LibStub("AceConfigCmd-3.0").HandleCommand(ZA, "zulgaui", "ZulgAurasUI", input)
    end
end

function ZA:EnableModules()
    for _, module in pairs(self.modules) do
        if module and module.Enable then
            module:Enable()
        end
    end
end

-- Instead of delegating settings toggling to ActionBars (which created the ugly window on load),
-- we always call our advanced settings window.
function ZA:ToggleSettingsWindow()
    self:ToggleAdvancedSettings()
end

SLASH_ZULGAURASUI1 = "/za"
SlashCmdList["ZULGAURASUI"] = function(msg)
    ZA:ToggleSettingsWindow()
end