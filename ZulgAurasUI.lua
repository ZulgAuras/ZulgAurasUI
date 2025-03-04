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

    if MultiBarBottomLeft then MultiBarBottomLeft:Hide() end
    if MultiBarBottomRight then MultiBarBottomRight:Hide() end
    if MultiBarLeft then MultiBarLeft:Hide() end
    if MultiBarRight then MultiBarRight:Hide() end

    if MainMenuBar then
        MainMenuBar:Hide()
        MainMenuBar:UnregisterAllEvents()
    end

    if MainMenuBarArtFrame then
        MainMenuBarArtFrame:Hide()
        if MainMenuBarArtFrame.LeftEndCap then MainMenuBarArtFrame.LeftEndCap:Hide() end
        if MainMenuBarArtFrame.RightEndCap then MainMenuBarArtFrame.RightEndCap:Hide() end
    end

    if MainMenuBarBackpackButton then
        MainMenuBarBackpackButton:Hide()
        MainMenuBarBackpackButton:UnregisterAllEvents()
    end
    for i = 0, 3 do
        local bagButton = _G["CharacterBag" .. i .. "Slot"]
        if bagButton then
            bagButton:Hide()
            bagButton:UnregisterAllEvents()
        end
    end

    if MainMenuExpBar then
        MainMenuExpBar:Hide()
        MainMenuExpBar:UnregisterAllEvents()
    end

    if ReputationWatchBar then
        ReputationWatchBar:Hide()
        ReputationWatchBar:UnregisterAllEvents()
    end

    if CharacterMicroButton then CharacterMicroButton:Hide() end
    if SpellbookMicroButton then SpellbookMicroButton:Hide() end
    if TalentMicroButton then TalentMicroButton:Hide() end
    if QuestLogMicroButton then QuestLogMicroButton:Hide() end
    if SocialsMicroButton then SocialsMicroButton:Hide() end
    if LFGMicroButton then LFGMicroButton:Hide() end
    if MainMenuMicroButton then MainMenuMicroButton:Hide() end
    if HelpMicroButton then HelpMicroButton:Hide() end
    if MainMenuBarPerformanceBar then MainMenuBarPerformanceBar:Hide() end
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
                if InterfaceOptionsFrame then
                    InterfaceOptionsFrame:Show()
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