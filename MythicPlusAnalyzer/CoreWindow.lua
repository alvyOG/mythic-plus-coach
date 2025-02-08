-- Mythic Plus Analyzer Core Window (With Custom AceGUI Window Override)
local AceGUI = LibStub("AceGUI-3.0")

-- Create Core Window
CoreWindow = AceGUI:Create("Window-MPA")
CoreWindow:SetLayout("List")
CoreWindow:Hide()  -- Start hidden
CoreWindow.trackButton = nil

-- Set Core Window Title
CoreWindow:SetTitle("|cffffcc00M+ Analyzer|r")
CoreWindow:SetTitleFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
CoreWindow:SetTitleAlignment("LEFT")

-- Function to update tabs
function CoreWindow:UpdateTabs(tabOrder)
    -- TODO: Implement this function
    print("MPA-Core Window: UpdateTabs() called")
end

-- Settings Button (Gear ⚙️)
local settingsButton = AceGUI:Create("IconButton-MPA")
settingsButton:SetImage("Interface\\AddOns\\MythicPlusAnalyzer\\Assets\\CustomIcon-White-Gear.tga")
settingsButton:SetTooltip("Settings")
settingsButton:SetSize(18, 18)  -- Use SetSize instead of SetWidth
settingsButton:SetCallback("OnClick", function()
    CoreSettings:Show()
end)
CoreWindow:AddButton(settingsButton)  -- Add to button bar

-- Reset Button (Undo Arrow ♻️)
local resetButton = AceGUI:Create("IconButton-MPA")
resetButton:SetImage("Interface\\AddOns\\MythicPlusAnalyzer\\Assets\\CustomIcon-White-Reset.tga")
resetButton:SetTooltip("Reset")
resetButton:SetSize(18, 18)  -- Use SetSize instead of SetWidth
resetButton:SetCallback("OnClick", function()
    MythicPlusAnalyzer:ResetTrackingMetrics()
end)
CoreWindow:AddButton(resetButton)  -- Add to button bar

-- Start/Stop Button (Play ▶️ / Stop ⏹️)
CoreWindow.trackButton = AceGUI:Create("IconButton-MPA")
CoreWindow.trackButton:SetImage("Interface\\AddOns\\MythicPlusAnalyzer\\Assets\\CustomIcon-White-Play.tga")
CoreWindow.trackButton:SetTooltip("Start")
CoreWindow.trackButton:SetSize(16, 16)  -- Use SetSize instead of SetWidth
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
CoreWindow:AddButton(CoreWindow.trackButton)  -- Add to button bar

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

-- Handle tab selection and load plugin content
coreTabs:SetCallback("OnGroupSelected", function(_, _, tabName)
    tabContainer:ReleaseChildren() -- Clear previous content
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

print("MPA-Core Window: Loaded successfully")