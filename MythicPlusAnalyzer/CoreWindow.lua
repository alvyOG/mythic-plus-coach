-- Mythic Plus Analyzer Core Window (With Custom AceGUI Window Override)
local AceGUI = LibStub("AceGUI-3.0")

-- Create Core Window
CoreWindow = AceGUI:Create("Window-MPA")
CoreWindow:SetLayout("List")
CoreWindow:Hide()  -- Start hidden
CoreWindow.trackButton = nil

-- Function to update tabs
function CoreWindow:UpdateTabs(tabOrder)
    -- TODO: Implement this function
    print("MPA-Core Window: UpdateTabs() called")
end

-- Top Bar (Title + Buttons)
local topBar = AceGUI:Create("SimpleGroup")
topBar:SetFullWidth(true)
topBar:SetLayout("Flow")
CoreWindow:AddChild(topBar)

-- Title Label
local titleLabel = AceGUI:Create("Label")
titleLabel:SetText("|cffffcc00M+ Analyzer|r")
titleLabel:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
titleLabel:SetWidth(130)
topBar:AddChild(titleLabel)

-- Start/Stop Button (Play ▶️ / Stop ⏹️)
CoreWindow.trackButton = AceGUI:Create("IconButton-MPA")
CoreWindow.trackButton:SetImage("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
CoreWindow.trackButton:SetTooltip("Start")
CoreWindow.trackButton:SetWidth(24)
CoreWindow.trackButton:SetCallback("OnClick", function()
    MythicPlusAnalyzer:ToggleTrackingState()
    if MythicPlusAnalyzer.isTracking then
        CoreWindow.trackButton:SetImage("Interface\\Buttons\\UI-StopButton")
        CoreWindow.trackButton:SetTooltip("Stop")
    else
        CoreWindow.trackButton:SetImage("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
        CoreWindow.trackButton:SetTooltip("Start")
    end
end)
topBar:AddChild(CoreWindow.trackButton)

-- Reset Button (Undo Arrow ♻️)
local resetButton = AceGUI:Create("IconButton-MPA")
resetButton:SetImage("Interface\\Buttons\\UI-RefreshButton")
resetButton:SetTooltip("Reset")
resetButton:SetWidth(24)
resetButton:SetCallback("OnClick", function()
    MythicPlusAnalyzer:ResetTrackingMetrics()
end)
topBar:AddChild(resetButton)

-- Settings Button (Gear ⚙️)
local settingsButton = AceGUI:Create("IconButton-MPA")
settingsButton:SetImage("Interface\\GossipFrame\\BinderGossipIcon")
settingsButton:SetTooltip("Settings")
settingsButton:SetWidth(24)
settingsButton:SetCallback("OnClick", function()
    CoreSettings:Show()
    CoreWindow:Hide()
end)
topBar:AddChild(settingsButton)

-- Close Button (X ❌)
local closeButton = AceGUI:Create("IconButton-MPA")
closeButton:SetImage("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
closeButton:SetTooltip("Close")
closeButton:SetWidth(24)
closeButton:SetCallback("OnClick", function()
    CoreWindow:Hide()
end)
topBar:AddChild(closeButton)

-- Create a container for tab content
local tabContainer = AceGUI:Create("SimpleGroup")
tabContainer:SetFullWidth(true)
tabContainer:SetFullHeight(true)
tabContainer:SetLayout("Flow")

-- Core Tab Content
local coreTabs = AceGUI:Create("TabGroup")
coreTabs:SetFullWidth(true)
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

-- Slash Command to Toggle GUI
Core:RegisterChatCommand("mpa", "ToggleCoreWindow")

print("MPA-Core Window: Loaded successfully")
