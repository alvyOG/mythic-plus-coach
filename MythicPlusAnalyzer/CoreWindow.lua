-- Mythic Plus Analyzer Core Window (With Custom AceGUI Window Override)
local AceGUI = LibStub("AceGUI-3.0")

-- Override AceGUI Window to Remove Default Title Bar
do
    local Type = "MPACoreWindow"
    local Version = 1

    local function Hide(self)
        self.frame:Hide()
    end

    local function Show(self)
        self.frame:Show()
    end

    local function OnAcquire(self)
        self:SetWidth(370)
        self:SetHeight(200)
        self.frame:Show()
    end

    local function OnRelease(self)
        self.frame:Hide()
    end

    local function SetTitle(self, title)
        -- Do nothing (prevents default title bar)
    end

    local function CloseWindow(self)
        self.frame:Hide()
    end

    local function Constructor()
        local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
        frame:SetSize(370, 200)
        frame:SetPoint("CENTER")
        frame:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background" })
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

        -- Create the 'content' frame that AceGUI expects
        local content = CreateFrame("Frame", nil, frame)
        content:SetPoint("TOPLEFT", 10, -10)
        content:SetPoint("BOTTOMRIGHT", -10, 10)

        local widget = {
            frame = frame,
            content = content,  -- Important: AceGUI expects this field
            type = Type,
            Close = CloseWindow,
            SetTitle = SetTitle,
            OnAcquire = OnAcquire,
            OnRelease = OnRelease,
            Hide = Hide,
            Show = Show,
        }

        -- Ensure the widget properly inherits from AceGUI.WidgetContainerBase
        AceGUI:RegisterAsContainer(widget)
        return widget
    end

    AceGUI:RegisterWidgetType(Type, Constructor, Version)
end

-- Create Core Window
local CoreWindow = AceGUI:Create("MPACoreWindow")
CoreWindow:SetLayout("List")
CoreWindow:Hide()  -- Start hidden

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

-- Function to Create Icon Buttons with Tooltip
local function CreateIconButton(icon, tooltipText, width, onClick)
    local button = AceGUI:Create("Icon")
    button:SetImage(icon)
    button:SetImageSize(16, 16)
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

-- Start/Stop Button (Play ▶️ / Stop ⏹️)
local trackButton = CreateIconButton("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up", "Start", 24, function()
    MythicPlusAnalyzer:ToggleTrackingState()
    if MythicPlusAnalyzer.isTracking then
        trackButton:SetImage("Interface\\Buttons\\UI-StopButton")
        trackButton:SetCallback("OnEnter", function(widget)
            GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPRIGHT")
            GameTooltip:SetText("Stop", 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
    else
        trackButton:SetImage("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
        trackButton:SetCallback("OnEnter", function(widget)
            GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPRIGHT")
            GameTooltip:SetText("Start", 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
    end
end)
topBar:AddChild(trackButton)

-- Reset Button (Undo Arrow ♻️)
local resetButton = CreateIconButton("Interface\\Buttons\\UI-RefreshButton", "Reset", 24, function()
    MythicPlusAnalyzer:ResetTrackingMetrics()
end)
topBar:AddChild(resetButton)

-- Settings Button (Gear ⚙️)
local settingsButton = CreateIconButton("Interface\\GossipFrame\\BinderGossipIcon", "Settings", 24, function()
    -- Placeholder for future settings window functionality
    print("Settings button clicked (Functionality coming soon!)")
end)
topBar:AddChild(settingsButton)

-- Close Button (X ❌)
local closeButton = CreateIconButton("Interface\\Buttons\\UI-Panel-MinimizeButton-Up", "Close", 24, function()
    CoreWindow:Hide()
end)
topBar:AddChild(closeButton)

-- Core Main Content
local coreContent = AceGUI:Create("TabGroup")
coreContent:SetFullWidth(true)
coreContent:SetLayout("Flow")
CoreWindow:AddChild(coreContent)

-- Populate tabs dynamically from plugins
local tabList = {}
for _, plugin in pairs(MythicPlusAnalyzer.plugins) do
    if plugin.GetContent then
        table.insert(tabList, { text = plugin.name, value = plugin.name })
    end
end
coreContent:SetTabs(tabList)

-- Handle tab selection and load plugin content
coreContent:SetCallback("OnGroupSelected", function(container, _, tabName)
    container:ReleaseChildren() -- Clear previous content
    local plugin = MythicPlusAnalyzer:GetPlugin(tabName)
    if plugin and plugin.GetContent then
        container:AddChild(plugin:GetContent())
    end
end)

-- Set default tab if available
if #tabList > 0 then
    coreContent:SelectTab(tabList[1].value)
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
