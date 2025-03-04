------------------------------------------------------------
-- ZulgAurasUI BagBar Module for Classic
------------------------------------------------------------
local ZA = LibStub("AceAddon-3.0"):GetAddon("ZulgAurasUI")
local BagBar = ZA:NewModule("BagBar", "AceEvent-3.0")

local FALLBACK_TEXTURE = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Bag"

function BagBar:OnInitialize()
    self.frame = CreateFrame("Frame", "ZulgAurasUI_BagBar", UIParent)
    self.frame:SetSize(300, 40)
    
    -- Use saved position if available, otherwise default to center position
    local xOffset = ZA.db.profile.bagBar.xOffset or 0
    local yOffset = ZA.db.profile.bagBar.yOffset or -250
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
    
    -- Create bag buttons
    self.buttons = {}
    -- Backpack (bagID 0, non-draggable)
    self.buttons[0] = self:CreateBagButton(0, self.frame, "Interface\\Buttons\\Button-Backpack-Up")
    self.buttons[0]:SetPoint("RIGHT", self.frame, "RIGHT", -10, 0)
    
    -- Regular bags (1-4)
    for bagID = 1, 4 do
        local slotName = "Bag" .. (bagID - 1) .. "Slot"
        local slotID = GetInventorySlotInfo(slotName)
        local texture = (slotID and GetInventoryItemTexture("player", slotID)) or FALLBACK_TEXTURE
        
        self.buttons[bagID] = self:CreateBagButton(bagID, self.frame, texture)
        self.buttons[bagID]:SetPoint("RIGHT", self.buttons[bagID-1], "LEFT", -5, 0)
    end
    
    -- Make the bag bar movable
    self.frame:SetMovable(true)
    self.frame:EnableMouse(true)
    self.frame:RegisterForDrag("LeftButton")
    self.frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    self.frame:SetScript("OnDragStop", function(self) 
        self:StopMovingOrSizing()
        -- Save the new position
        local point, _, _, xOfs, yOfs = self:GetPoint()
        ZA.db.profile.bagBar.xOffset = xOfs
        ZA.db.profile.bagBar.yOffset = yOfs
    end)
    
    print("ZulgAurasUI: BagBar module initialized.")
end

function BagBar:CreateBagButton(bagID, parent, texture)
    local button = CreateFrame("Button", "ZulgAurasUI_BagButton" .. bagID, parent)
    button:SetSize(35, 35)
    button:SetID(bagID)
    button:EnableMouse(true)  -- Ensure mouse events are received
    
    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints()
    icon:SetTexture(texture)
    button.icon = icon
    
    -- Add a border to make it look like a regular button
    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    border:SetBlendMode("ADD")
    border:SetAlpha(0.8)
    border:SetPoint("CENTER", button, "CENTER", 0, 1)
    border:SetWidth(button:GetWidth() * 1.5)
    border:SetHeight(button:GetHeight() * 1.5)
    border:Hide()
    button.border = border
    
    -- Show border on hover and set tooltip info
    button:SetScript("OnEnter", function() 
        border:Show() 
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        if bagID == 0 then
            GameTooltip:SetText("Backpack")
        else
            local slotName = "Bag" .. (bagID - 1) .. "Slot"
            local slotID = GetInventorySlotInfo(slotName)
            GameTooltip:SetInventoryItem("player", slotID)
            if GetContainerNumSlots then
                local numSlots = GetContainerNumSlots(bagID)
                if numSlots then
                    GameTooltip:AddLine("Slots: " .. numSlots, 1, 1, 1)
                end
            end
        end
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() 
        border:Hide() 
        GameTooltip:Hide()
    end)
    
    -- Open/close bag on click
    button:SetScript("OnClick", function()
        if bagID == 0 then
            ToggleBackpack()
        else
            ToggleBag(bagID)
        end
    end)
    
    -- For non-backpack buttons, enable drag-and-drop to swap bags.
    if bagID > 0 then
        button:RegisterForDrag("LeftButton")
        button:SetScript("OnDragStart", function(self)
            local bagID = self:GetID()
            local slotName = "Bag" .. (bagID - 1) .. "Slot"
            local slotID = GetInventorySlotInfo(slotName)
            if slotID then
                PickupInventoryItem(slotID)
            end
        end)
        button:SetScript("OnReceiveDrag", function(self)
            local bagID = self:GetID()
            local slotName = "Bag" .. (bagID - 1) .. "Slot"
            local slotID = GetInventorySlotInfo(slotName)
            if CursorHasItem() and slotID then
                PickupInventoryItem(slotID)
            end
        end)
    end
    
    return button
end

function BagBar:OnEnable()
    self.frame:Show()
    -- Update textures when bags update and when the player enters the world
    self:RegisterEvent("BAG_UPDATE", "UpdateBagTextures")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateBagTextures")
    
    print("ZulgAurasUI: BagBar module enabled.")
end

function BagBar:UpdateBagTextures()
    for bagID = 1, 4 do
        local slotName = "Bag" .. (bagID - 1) .. "Slot"
        local slotID = GetInventorySlotInfo(slotName)
        local texture = (slotID and GetInventoryItemTexture("player", slotID)) or FALLBACK_TEXTURE
        if self.buttons[bagID] and self.buttons[bagID].icon then
            self.buttons[bagID].icon:SetTexture(texture)
        end
    end
end

function BagBar:UpdateBar(settings)
    if self.frame then
        self.frame:SetScale(settings.scale or 1)
        self.frame:SetAlpha(settings.alpha or 1)
        

    end
end

return BagBar