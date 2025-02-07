-- Mythic Plus Analyzer Core Window (With Custom AceGUI Window Override)
local AceGUI = LibStub("AceGUI-3.0")

-- Create Core Window
CoreWindow = AceGUI:Create("Window-MPA")
CoreWindow:SetLayout("List")
CoreWindow:Hide()  -- Start hidden
CoreWindow.trackButton = nil

-- Function to Create Icon Buttons with Tooltip
local function CreateIconButton(icon, tooltipText, width, onClick)
    local button = AceGUI:Create("Icon")
    button:SetImage(icon)
    button:SetImageSize(24, 24)
    button:SetWidth(width)
    button:SetCallback("OnClick", onClick)
    button:SetCallback("OnEnter", function(widget)
        GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPRIGHT")
        GameTooltip:SetText(tooltipText, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    button:SetCallback("OnLeave", function()
        GameTooltip:Hide()
    end)
    return button
end

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
CoreWindow.trackButton = CreateIconButton("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up",
        "Start", 24, function()
    MythicPlusAnalyzer:ToggleTrackingState()
    if MythicPlusAnalyzer.isTracking then
        CoreWindow.trackButton:SetImage("Interface\\Buttons\\UI-StopButton")
        CoreWindow.trackButton:SetCallback("OnEnter", function(widget)
            GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPRIGHT")
            GameTooltip:SetText("Start", 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
    else
        CoreWindow.trackButton:SetImage("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
        CoreWindow.trackButton:SetCallback("OnEnter", function(widget)
            GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPRIGHT")
            GameTooltip:SetText("Stop", 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
    end
end)
topBar:AddChild(CoreWindow.trackButton)

-- Reset Button (Undo Arrow ♻️)
local resetButton = CreateIconButton("Interface\\Buttons\\UI-RefreshButton",
        "Reset", 24, function()
    MythicPlusAnalyzer:ResetTrackingMetrics()
end)
topBar:AddChild(resetButton)

-- Settings Button (Gear ⚙️)
local settingsButton = CreateIconButton("Interface\\GossipFrame\\BinderGossipIcon",
        "Settings", 24, function()
    CoreSettings:Show()
    CoreWindow:Hide()
end)
topBar:AddChild(settingsButton)

-- Close Button (X ❌)
local closeButton = CreateIconButton("Interface\\Buttons\\UI-Panel-MinimizeButton-Up",
        "Close", 24, function()
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

coreContent:AddChild(tabContainer)
CoreWindow:AddChild(coreTabs)

-- Set default tab if available
if #tabList > 0 then
    coreTabs:SelectTab(tabList[1].value)
end

-- Slash Command to Toggle GUI
SLASH_MPACOREFRAME1 = "/mpa"
SlashCmdList["MPACOREFRAME"] = function()
    if CoreWindow:IsVisible() then
        CoreWindow:Hide()
    else
        CoreWindow:Show()
    end
end

print("MPA-Core Window: Loaded successfully")
