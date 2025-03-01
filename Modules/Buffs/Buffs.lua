local addonName, ZA = ...
local ZUI = ZulgAurasUI
local Chat = ZUI:NewModule("Chat", "AceEvent-3.0", "AceHook-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

local CHAT_FRAME_TEXTURES = {
    "Background",
    "TopLeftTexture",
    "TopRightTexture",
    "BottomLeftTexture",
    "BottomRightTexture",
    "TopTexture",
    "BottomTexture",
    "LeftTexture",
    "RightTexture",
}

function Chat:OnInitialize()
    self.config = ZUI.db.profile.chat
    self.frames = {}
end

function Chat:OnEnable()
    self:StyleChat()
    self:SetupChatFilters()
    self:RegisterEvents()
end

function Chat:StyleChat()
    -- Style all chat frames
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame"..i]
        self:StyleChatFrame(chatFrame)
    end
    
    -- Style temporary windows as they're created
    self:SecureHook("FCF_OpenTemporaryWindow", function()
        for _, chatFrameName in pairs(CHAT_FRAMES) do
            local frame = _G[chatFrameName]
            if frame and not self.frames[frame] then
                self:StyleChatFrame(frame)
            end
        end
    end)
end

function Chat:StyleChatFrame(frame)
    if self.frames[frame] then return end
    self.frames[frame] = true
    
    -- Remove textures
    for _, texture in ipairs(CHAT_FRAME_TEXTURES) do
        local tex = _G[frame:GetName()..texture]
        if tex then
            tex:SetTexture(nil)
        end
    end
    
    -- Create custom backdrop
    local backdrop = frame.backdrop or CreateFrame("Frame", nil, frame)
    backdrop:SetPoint("TOPLEFT", frame, "TOPLEFT", -3, 3)
    backdrop:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 3, -3)
    backdrop:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\AddOns\\ZulgAurasUI\\Media\\border",
        edgeSize = 3,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })
    backdrop:SetBackdropColor(0, 0, 0, 0.6)
    backdrop:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    frame.backdrop = backdrop
    
    -- Set frame options
    frame:SetClampRectInsets(0, 0, 0, 0)
    frame:SetMaxResize(UIParent:GetWidth(), UIParent:GetHeight())
    frame:SetMinResize(100, 50)
    
    -- Set font
    local font = LSM:Fetch("font", self.config.font or "Friz Quadrata TT")
    local size = self.config.fontSize or 12
    frame:SetFont(font, size, "")
    
    -- Make movable
    frame:SetMovable(true)
    frame:SetResizable(true)
    frame:SetUserPlaced(true)
end

function Chat:SetupChatFilters()
    -- Filter system messages
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(_, _, message)
        if self.config.filterSystem then
            -- Add your system message filters here
            return
        end
    end)
    
    -- Timestamp format
    if self.config.timestamps then
        self:RawHook("ChatFrame_MessageEventHandler", function(...)
            local timestamp = date(self.config.timestampFormat or "%H:%M")
            local message = select(1, ...)
            message = string.format("|cff666666%s|r %s", timestamp, message)
            return self.hooks["ChatFrame_MessageEventHandler"](message, select(2, ...))
        end, true)
    end
end

function Chat:RegisterEvents()
    self:RegisterEvent("CHAT_MSG_CHANNEL", "OnChatMessage")
    self:RegisterEvent("CHAT_MSG_SAY", "OnChatMessage")
    self:RegisterEvent("CHAT_MSG_YELL", "OnChatMessage")
    self:RegisterEvent("CHAT_MSG_WHISPER", "OnChatMessage")
    self:RegisterEvent("CHAT_MSG_PARTY", "OnChatMessage")
    self:RegisterEvent("CHAT_MSG_RAID", "OnChatMessage")
    self:RegisterEvent("CHAT_MSG_GUILD", "OnChatMessage")
end

function Chat:OnChatMessage(event, message, author, ...)
    -- Handle chat messages here
    -- This is where you can add custom chat features
end

function Chat:GetOptions()
    return {
        enabled = {
            type = "toggle",
            name = "Enable",
            desc = "Enable/disable chat modifications",
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
        font = {
            type = "select",
            name = "Font",
            desc = "Select chat font",
            values = LSM:HashTable("font"),
            get = function() return self.config.font end,
            set = function(_, value)
                self.config.font = value
                self:UpdateAllChatFrames()
            end,
            order = 2,
        },
        fontSize = {
            type = "range",
            name = "Font Size",
            desc = "Set chat font size",
            min = 8,
            max = 20,
            step = 1,
            get = function() return self.config.fontSize end,
            set = function(_, value)
                self.config.fontSize = value
                self:UpdateAllChatFrames()
            end,
            order = 3,
        },
        timestamps = {
            type = "toggle",
            name = "Show Timestamps",
            desc = "Show timestamps in chat",
            get = function() return self.config.timestamps end,
            set = function(_, value)
                self.config.timestamps = value
                ReloadUI()
            end,
            order = 4,
        },
    }
end

function Chat:UpdateAllChatFrames()
    for frame in pairs(self.frames) do
        self:StyleChatFrame(frame)
    end
end