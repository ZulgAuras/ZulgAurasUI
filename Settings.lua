------------------------------------------------------------
-- ZulgAurasUI Advanced Settings for Classic
------------------------------------------------------------
local ZA = LibStub("AceAddon-3.0"):GetAddon("ZulgAurasUI")
local AceGUI = LibStub("AceGUI-3.0")

-- Retrieve module references (expect these to be non-nil since they're loaded earlier)
local ActionBarsModule = ZA:GetModule("ActionBars")
local XPBarModule = ZA:GetModule("XPBar")
local BagBarModule = ZA:GetModule("BagBar")
local RepBarModule = ZA:GetModule("RepBar")

if not ActionBarsModule then
  print("ZulgAurasUI: ActionBars module not found. Ensure Modules/ActionBars.lua is loaded before Settings.lua.")
end
if not XPBarModule then
  print("ZulgAurasUI: XPBar module not found. Ensure Modules/XPBar.lua is loaded before Settings.lua.")
end
if not BagBarModule then
  print("ZulgAurasUI: BagBar module not found. Ensure Modules/BagBar.lua is loaded before Settings.lua.")
end
if not RepBarModule then
  print("ZulgAurasUI: RepBar module not found. Ensure Modules/RepBar.lua is loaded before Settings.lua.")
end

-- Initialize default settings if not already set.
local function InitializeDefaults()
  ZA.db = ZA.db or {}
  ZA.db.profile = ZA.db.profile or {}

  -- ActionBars defaults (for bars 1 through 5)
  ZA.db.profile.actionBars = ZA.db.profile.actionBars or {}
  for i = 1, 5 do
    if not ZA.db.profile.actionBars[i] then
      ZA.db.profile.actionBars[i] = {}
    end
    local barSettings = ZA.db.profile.actionBars[i]
    barSettings.scale = barSettings.scale or 1
    barSettings.alpha = barSettings.alpha or 1
    barSettings.xOffset = barSettings.xOffset or 0
    barSettings.yOffset = barSettings.yOffset or ((i - 1) * 50)
    barSettings.visible = barSettings.visible or true
    barSettings.border = barSettings.border or true
    barSettings.borderColor = barSettings.borderColor or {0, 0, 0, 1}
  end

  -- XPBar, BagBar, RepBar defaults
  ZA.db.profile.xpBar = ZA.db.profile.xpBar or { scale = 1, alpha = 1, xOffset = 0, yOffset = -200 }
  ZA.db.profile.bagBar = ZA.db.profile.bagBar or { scale = 1, alpha = 1, xOffset = 0, yOffset = -250 }
  ZA.db.profile.repBar = ZA.db.profile.repBar or { scale = 1, alpha = 1, xOffset = 0, yOffset = -300 }
end

local currentAB = 1  -- currently selected ActionBar index

-- This function creates the dynamic content for a given module category.
-- It only clears the dynamic content container so the persistent tab control remains.
local function CreateContentGroup(category, contentContainer)
  contentContainer:ReleaseChildren() -- Clear previous dynamic content.
  local group = AceGUI:Create("InlineGroup")
  group:SetFullWidth(true)
  group:SetLayout("Flow")
  
  if category == "actionBars" then
    group:SetTitle("Action Bars")
    -- Dropdown for selecting which ActionBar to adjust.
    local dropdown = AceGUI:Create("Dropdown")
    dropdown:SetLabel("Choose Action Bar")
    local list = {}
    for i = 1, 5 do 
      list[tostring(i)] = "Action Bar " .. i 
    end
    dropdown:SetList(list)
    dropdown:SetValue(tostring(currentAB))
    dropdown:SetCallback("OnValueChanged", function(widget, event, value)
      currentAB = tonumber(value)
      CreateContentGroup("actionBars", contentContainer)
    end)
    group:AddChild(dropdown)
    
    local abSettings = ZA.db.profile.actionBars[currentAB]
    -- Slider: Scale
    local scaleSlider = AceGUI:Create("Slider")
    scaleSlider:SetLabel("Scale")
   	local scaleValue = (type(abSettings.scale) == "number") and abSettings.scale or 1
    scaleSlider:SetValue(scaleValue)
    scaleSlider:SetSliderValues(0.5, 2.0, 0.1)
    scaleSlider:SetFullWidth(true)
    scaleSlider:SetCallback("OnValueChanged", function(widget, event, val)
      abSettings.scale = val
      if ActionBarsModule and ActionBarsModule.UpdateBar then
        ActionBarsModule:UpdateBar(currentAB, abSettings)
      end
    end)
    group:AddChild(scaleSlider)
    
    -- Slider: Opacity
    local alphaSlider = AceGUI:Create("Slider")
    alphaSlider:SetLabel("Opacity")
    local alphaValue = (type(abSettings.alpha) == "number") and abSettings.alpha or 1
    alphaSlider:SetValue(alphaValue)
    alphaSlider:SetSliderValues(0.1, 1.0, 0.1)
    alphaSlider:SetFullWidth(true)
    alphaSlider:SetCallback("OnValueChanged", function(widget, event, val)
      abSettings.alpha = val
      if ActionBarsModule and ActionBarsModule.UpdateBar then
        ActionBarsModule:UpdateBar(currentAB, abSettings)
      end
    end)
    group:AddChild(alphaSlider)
    
    -- Slider: X Offset
    local xOffsetSlider = AceGUI:Create("Slider")
    xOffsetSlider:SetLabel("X Offset")
    local xOffsetValue = (type(abSettings.xOffset) == "number") and abSettings.xOffset or 0
    xOffsetSlider:SetValue(xOffsetValue)
    xOffsetSlider:SetSliderValues(-200, 200, 1)
    xOffsetSlider:SetFullWidth(true)
    xOffsetSlider:SetCallback("OnValueChanged", function(widget, event, val)
      abSettings.xOffset = val
      if ActionBarsModule and ActionBarsModule.UpdateBar then
        ActionBarsModule:UpdateBar(currentAB, abSettings)
      end
    end)
    group:AddChild(xOffsetSlider)
    
    -- Slider: Y Offset
    local yOffsetSlider = AceGUI:Create("Slider")
    yOffsetSlider:SetLabel("Y Offset")
    local yOffsetValue = (type(abSettings.yOffset) == "number") and abSettings.yOffset or ((currentAB - 1) * 50)
    yOffsetSlider:SetValue(yOffsetValue)
    yOffsetSlider:SetSliderValues(-200, 200, 1)
    yOffsetSlider:SetFullWidth(true)
    yOffsetSlider:SetCallback("OnValueChanged", function(widget, event, val)
      abSettings.yOffset = val
      if ActionBarsModule and ActionBarsModule.UpdateBar then
        ActionBarsModule:UpdateBar(currentAB, abSettings)
      end
    end)
    group:AddChild(yOffsetSlider)
    
    -- Checkbox: Visible
    local visCheckbox = AceGUI:Create("CheckBox")
    visCheckbox:SetLabel("Visible")
    visCheckbox:SetValue(abSettings.visible)
    visCheckbox:SetCallback("OnValueChanged", function(widget, event, val)
      abSettings.visible = val
      if ActionBarsModule and ActionBarsModule.UpdateBar then
        ActionBarsModule:UpdateBar(currentAB, abSettings)
      end
    end)
    group:AddChild(visCheckbox)
    
    -- Checkbox: Border
    local borderCheckbox = AceGUI:Create("CheckBox")
    borderCheckbox:SetLabel("Show Border")
    borderCheckbox:SetValue(abSettings.border)
    borderCheckbox:SetCallback("OnValueChanged", function(widget, event, val)
      abSettings.border = val
      if ActionBarsModule and ActionBarsModule.UpdateBar then
        ActionBarsModule:UpdateBar(currentAB, abSettings)
      end
    end)
    group:AddChild(borderCheckbox)
    
    -- Button: Set Border Color (uses ColorPickerFrame)
    local borderColorPicker = AceGUI:Create("Button")
    borderColorPicker:SetText("Set Border Color")
    borderColorPicker:SetCallback("OnClick", function()
      local r, g, b = unpack(abSettings.borderColor)
      ColorPickerFrame.hasOpacity = true
      ColorPickerFrame:SetColorRGB(r, g, b)
      ColorPickerFrame.opacity = 1 - abSettings.borderColor[4]
      ColorPickerFrame.previousValues = { r, g, b, abSettings.borderColor[4] }
      ColorPickerFrame.func = function(newR, newG, newB)
        abSettings.borderColor = { newR, newG, newB, abSettings.borderColor[4] }
        if ActionBarsModule and ActionBarsModule.UpdateBar then
          ActionBarsModule:UpdateBar(currentAB, abSettings)
        end
      end
      ColorPickerFrame.opacityFunc = function(newOpacity)
        abSettings.borderColor[4] = 1 - newOpacity
        if ActionBarsModule and ActionBarsModule.UpdateBar then
          ActionBarsModule:UpdateBar(currentAB, abSettings)
        end
      end
      ColorPickerFrame.cancelFunc = function(prevR, prevG, prevB, prevA)
        abSettings.borderColor = { prevR, prevG, prevB, prevA }
        if ActionBarsModule and ActionBarsModule.UpdateBar then
          ActionBarsModule:UpdateBar(currentAB, abSettings)
        end
      end
      ColorPickerFrame:Hide() -- Reinitialize.
      ColorPickerFrame:Show()
    end)
    group:AddChild(borderColorPicker)
    
  elseif category == "xpBar" then
    group:SetTitle("XP Bar")
    -- Slider: Scale
    local scaleSlider = AceGUI:Create("Slider")
    scaleSlider:SetLabel("Scale")
    local xpScale = (type(ZA.db.profile.xpBar.scale) == "number") and ZA.db.profile.xpBar.scale or 1
    scaleSlider:SetValue(xpScale)
    scaleSlider:SetSliderValues(0.5, 2.0, 0.1)
    scaleSlider:SetFullWidth(true)
    scaleSlider:SetCallback("OnValueChanged", function(widget, event, val)
      ZA.db.profile.xpBar.scale = val
      if XPBarModule and XPBarModule.UpdateBar then
        XPBarModule:UpdateBar(ZA.db.profile.xpBar)
      end
    end)
    group:AddChild(scaleSlider)
    
    -- Slider: Opacity
    local alphaSlider = AceGUI:Create("Slider")
    alphaSlider:SetLabel("Opacity")
    local xpAlpha = (type(ZA.db.profile.xpBar.alpha) == "number") and ZA.db.profile.xpBar.alpha or 1
    alphaSlider:SetValue(xpAlpha)
    alphaSlider:SetSliderValues(0.1, 1.0, 0.1)
    alphaSlider:SetFullWidth(true)
    alphaSlider:SetCallback("OnValueChanged", function(widget, event, val)
      ZA.db.profile.xpBar.alpha = val
      if XPBarModule and XPBarModule.UpdateBar then
        XPBarModule:UpdateBar(ZA.db.profile.xpBar)
      end
    end)
    group:AddChild(alphaSlider)
    
  elseif category == "bagBar" then
    group:SetTitle("Bag Bar")
    -- Slider: Scale
    local scaleSlider = AceGUI:Create("Slider")
    scaleSlider:SetLabel("Scale")
    local bagScale = (type(ZA.db.profile.bagBar.scale) == "number") and ZA.db.profile.bagBar.scale or 1
    scaleSlider:SetValue(bagScale)
    scaleSlider:SetSliderValues(0.5, 2.0, 0.1)
    scaleSlider:SetFullWidth(true)
    scaleSlider:SetCallback("OnValueChanged", function(widget, event, val)
      ZA.db.profile.bagBar.scale = val
      if BagBarModule and BagBarModule.UpdateBar then
        BagBarModule:UpdateBar(ZA.db.profile.bagBar)
      end
    end)
    group:AddChild(scaleSlider)
    
    -- Slider: Opacity
    local alphaSlider = AceGUI:Create("Slider")
    alphaSlider:SetLabel("Opacity")
    local bagAlpha = (type(ZA.db.profile.bagBar.alpha) == "number") and ZA.db.profile.bagBar.alpha or 1
    alphaSlider:SetValue(bagAlpha)
    alphaSlider:SetSliderValues(0.1, 1.0, 0.1)
    alphaSlider:SetFullWidth(true)
    alphaSlider:SetCallback("OnValueChanged", function(widget, event, val)
      ZA.db.profile.bagBar.alpha = val
      if BagBarModule and BagBarModule.UpdateBar then
        BagBarModule:UpdateBar(ZA.db.profile.bagBar)
      end
    end)
    group:AddChild(alphaSlider)
    
  elseif category == "repBar" then
    group:SetTitle("Rep Bar")
    -- Slider: Scale
    local scaleSlider = AceGUI:Create("Slider")
    scaleSlider:SetLabel("Scale")
    local repScale = (type(ZA.db.profile.repBar.scale) == "number") and ZA.db.profile.repBar.scale or 1
    scaleSlider:SetValue(repScale)
    scaleSlider:SetSliderValues(0.5, 2.0, 0.1)
    scaleSlider:SetFullWidth(true)
    scaleSlider:SetCallback("OnValueChanged", function(widget, event, val)
      ZA.db.profile.repBar.scale = val
      if RepBarModule and RepBarModule.UpdateBar then
        RepBarModule:UpdateBar(ZA.db.profile.repBar)
      end
    end)
    group:AddChild(scaleSlider)
    
    -- Slider: Opacity
    local alphaSlider = AceGUI:Create("Slider")
    alphaSlider:SetLabel("Opacity")
    local repAlpha = (type(ZA.db.profile.repBar.alpha) == "number") and ZA.db.profile.repBar.alpha or 1
    alphaSlider:SetValue(repAlpha)
    alphaSlider:SetSliderValues(0.1, 1.0, 0.1)
    alphaSlider:SetFullWidth(true)
    alphaSlider:SetCallback("OnValueChanged", function(widget, event, val)
      ZA.db.profile.repBar.alpha = val
      if RepBarModule and RepBarModule.UpdateBar then
        RepBarModule:UpdateBar(ZA.db.profile.repBar)
      end
    end)
    group:AddChild(alphaSlider)
    
  elseif category == "profiles" then
    group:SetTitle("Profiles")
    local label = AceGUI:Create("Label")
    label:SetText("Use /zulgaprofiles to manage profiles.")
    group:AddChild(label)
  end

  contentContainer:AddChild(group)
end

-- Create the main settings window with persistent tab controls and a separate content container.
local function CreateSettingsWindow()
  local frame = AceGUI:Create("Frame")
  frame:SetTitle("ZulgAurasUI Advanced Settings")
  frame:SetStatusText("Configure your UI modules")
  frame:SetLayout("Flow")
  frame:SetWidth(520)
  frame:SetHeight(600)
  frame.frame:SetPoint("CENTER", UIParent, "CENTER")

  local mainContainer = AceGUI:Create("SimpleGroup")
  mainContainer:SetLayout("List")
  mainContainer:SetFullWidth(true)
  mainContainer:SetFullHeight(true)
  frame:AddChild(mainContainer)

  -- Create a persistent container for the tab group.
  local tabContainer = AceGUI:Create("SimpleGroup")
  tabContainer:SetLayout("Flow")
  tabContainer:SetFullWidth(true)
  tabContainer:SetFullHeight(false)
  mainContainer:AddChild(tabContainer)

  -- Create a separate container for dynamic content.
  local contentContainer = AceGUI:Create("SimpleGroup")
  contentContainer:SetLayout("Flow")
  contentContainer:SetFullWidth(true)
  contentContainer:SetFullHeight(true)
  mainContainer:AddChild(contentContainer)

  local tabGroup = AceGUI:Create("TabGroup")
  tabGroup:SetLayout("Flow")
  tabGroup:SetFullWidth(true)
  tabGroup:SetFullHeight(false)
  local tabs = {
    { text = "Action Bars", value = "actionBars" },
    { text = "XP Bar", value = "xpBar" },
    { text = "Bag Bar", value = "bagBar" },
    { text = "Rep Bar", value = "repBar" },
    { text = "Profiles", value = "profiles" },
  }
  tabGroup:SetTabs(tabs)
  tabGroup:SetCallback("OnGroupSelected", function(self, event, group)
    CreateContentGroup(group, contentContainer)
  end)
  tabContainer:AddChild(tabGroup)
  tabGroup:SelectTab("actionBars")

  return frame
end

-- Public function: Toggle the settings window.
function ZA:ToggleAdvancedSettings()
  InitializeDefaults()
  if self.advancedSettingsFrame and self.advancedSettingsFrame:IsVisible() then
    self.advancedSettingsFrame:Hide()
  else
    self.advancedSettingsFrame = CreateSettingsWindow()
  end
end

return ZA