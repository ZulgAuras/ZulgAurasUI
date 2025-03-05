local ZA = LibStub("AceAddon-3.0"):GetAddon("ZulgAurasUI")
ZA.Fonts = {}

-- Font paths
ZA.Fonts.COOLVETICA = "Interface\\AddOns\\ZulgAurasUI\\Media\\Fonts\\coolvetica.otf"
ZA.Fonts.DEFAULT = "Fonts\\FRIZQT__.TTF"

-- Font objects cache
local fontObjects = {}

-- Create and cache a font object with specific parameters
function ZA.Fonts:GetFont(family, size, flags)
    local key = string.format("%s_%d_%s", family, size or 12, flags or "")
    
    if not fontObjects[key] then
        local font = CreateFont("ZulgAurasUI" .. key)
        font:SetFont(family, size or 12, flags or "")
        fontObjects[key] = font
    end
    
    return fontObjects[key]
end

-- Apply font to a frame's text
function ZA.Fonts:ApplyFont(frame, size, flags)
    if not frame then return end
    
    local font = self:GetFont(self.COOLVETICA, size, flags)
    if frame.SetFontObject then
        frame:SetFontObject(font)
    end
end

-- Apply font to all text elements in a frame and its children
function ZA.Fonts:ApplyFontToTree(frame, size, flags)
    if not frame then return end
    
    -- Apply to frame if it has text
    self:ApplyFont(frame, size, flags)
    
    -- Apply to children
    local children = { frame:GetChildren() }
    for _, child in ipairs(children) do
        self:ApplyFontToTree(child, size, flags)
    end
end