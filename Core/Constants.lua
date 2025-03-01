local _, ZA = ...

ZA.Constants = {
    COLORS = {
        WHITE = {r = 1, g = 1, b = 1},
        RED = {r = 1, g = 0, b = 0},
        GREEN = {r = 0, g = 1, b = 0},
        BLUE = {r = 0, g = 0, b = 1},
    },
    
    POWER_TYPES = {
        MANA = 0,
        RAGE = 1,
        ENERGY = 3,
    },
    
    EVENTS = {
        PLAYER_ENTERING_WORLD = "PLAYER_ENTERING_WORLD",
        UNIT_HEALTH = "UNIT_HEALTH",
        UNIT_POWER_UPDATE = "UNIT_POWER_UPDATE",
        PLAYER_TARGET_CHANGED = "PLAYER_TARGET_CHANGED",
    },
    
    FONTS = {
        DEFAULT = "Fonts\\FRIZQT__.TTF",
        DAMAGE = "Fonts\\ARIALN.TTF",
    },
    
    TEXTURES = {
        BAR = "Interface\\TargetingFrame\\UI-StatusBar",
        BACKDROP = "Interface\\Tooltips\\UI-Tooltip-Background",
    },
}