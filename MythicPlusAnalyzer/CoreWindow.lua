-- Mythic Plus Analyzer Addon
-- Author: alvy023
-- File: CoreWindow.lua
-- Description: Core window functionality for the Mythic Plus Analyzer addon.
-- License:
-- For more information, visit the project repository.

local AceGUI = LibStub("AceGUI-3.0")

-- Create Core Window
CoreWindow = AceGUI:Create("Window-MPA")
CoreWindow:SetLayout("List")
CoreWindow:Hide()
CoreWindow.trackButton = nil

-- Set Core Window Title
CoreWindow:SetTitle("|cffffcc00M+ Analyzer|r")
CoreWindow:SetTitleFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
CoreWindow:SetTitleAlignment("LEFT")

--- Description: Function to update tabs.
--- @param: tabOrder - The order of the tabs to update.
--- @return:
function CoreWindow:UpdateTabs(tabOrder)
    -- TODO: Implement this function
    print("MPA-Core Window: UpdateTabs() called")
end

-- Settings Button (Gear ⚙️)
local settingsButton = AceGUI:Create("IconButton-MPA")
settingsButton:SetImage("Interface\\AddOns\\MythicPlusAnalyzer\\Assets\\CustomIcon-White-Gear.tga")
settingsButton:SetTooltip("Settings")
settingsButton:SetSize(18, 18)
settingsButton:SetCallback("OnClick", function()
    CoreSettings:Show()
end)
CoreWindow:AddButton(settingsButton)

-- Reset Button (Undo Arrow ♻️)
local resetButton = AceGUI:Create("IconButton-MPA")
resetButton:SetImage("Interface\\AddOns\\MythicPlusAnalyzer\\Assets\\CustomIcon-White-Reset.tga")
resetButton:SetTooltip("Reset")
resetButton:SetSize(18, 18)
resetButton:SetCallback("OnClick", function()
    MythicPlusAnalyzer:ResetTrackingMetrics()
end)
CoreWindow:AddButton(resetButton)

-- Start/Stop Button (Play ▶️ / Stop ⏹️)
CoreWindow.trackButton = AceGUI:Create("IconButton-MPA")
CoreWindow.trackButton:SetImage("Interface\\AddOns\\MythicPlusAnalyzer\\Assets\\CustomIcon-White-Play.tga")
CoreWindow.trackButton:SetTooltip("Start")
CoreWindow.trackButton:SetSize(16, 16)
CoreWindow.trackButton:SetCallback("OnClick", function()
    MythicPlusAnalyzer:ToggleTrackingState()
    if MythicPlusAnalyzer.isTracking then
        CoreWindow.trackButton:SetImage("Interface\\AddOns\\MythicPlusAnalyzer\\Assets\\CustomIcon-White-Stop.tga")
        CoreWindow.trackButton:SetTooltip("Stop")
    else
        CoreWindow.trackButton:SetImage("Interface\\AddOns\\MythicPlusAnalyzer\\Assets\\CustomIcon-White-Play.tga")
        CoreWindow.trackButton:SetTooltip("Start")
    end
end)
CoreWindow:AddButton(CoreWindow.trackButton)

-- Create a container for tab content
local tabContainer = AceGUI:Create("SimpleGroup")
tabContainer:SetFullWidth(true)
tabContainer:SetFullHeight(true)
tabContainer:SetLayout("Flow")

-- Core Tab Content
local coreTabs = AceGUI:Create("TabGroup")
coreTabs:SetFullWidth(true)
coreTabs:SetFullHeight(true)
coreTabs:SetLayout("Flow")

-- Populate tabs dynamically from plugins
local tabList = {}
for _, plugin in pairs(MythicPlusAnalyzer.plugins) do
    if plugin.GetContent then
        table.insert(tabList, { text = plugin.name, value = plugin.name })
    end
end
coreTabs:SetTabs(tabList)

--- Description: Handle tab selection and load plugin content.
--- @param: \_ - Unused parameter.
--- @param: \_ - Unused parameter.
--- @param: tabName - The name of the tab to select.
coreTabs:SetCallback("OnGroupSelected", function(_, _, tabName)
    tabContainer:ReleaseChildren()
    local plugin = MythicPlusAnalyzer:GetPlugin(tabName)
    if plugin and plugin.GetContent then
        tabContainer:AddChild(plugin:GetContent())
    end
end)

coreTabs:AddChild(tabContainer)
CoreWindow:AddChild(coreTabs)

-- Set default tab if available
if #tabList > 0 then
    coreTabs:SelectTab(tabList[1].value)
end
