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

-- Start/Stop Button
local trackButton = AceGUI:Create("Button")
trackButton:SetText("|cffffcc00Start|r")
trackButton:SetWidth(70)
trackButton:SetCallback("OnClick", function()
    MythicPlusAnalyzer:ToggleTrackingState()
    if MythicPlusAnalyzer.isTracking then
        trackButton:SetText("|cffffcc00Stop|r")
    else
        trackButton:SetText("|cffffcc00Start|r")
    end
end)
topBar:AddChild(trackButton)

-- Reset Button
local resetButton = AceGUI:Create("Button")
resetButton:SetText("|cffffcc00Reset|r")
resetButton:SetWidth(70)
resetButton:SetCallback("OnClick", function()
    MythicPlusAnalyzer:ResetTrackingMetrics()
end)
topBar:AddChild(resetButton)

-- Close Button
local closeButton = AceGUI:Create("Button")
closeButton:SetText("|cffffcc00Close|r")
closeButton:SetWidth(70)
closeButton:SetCallback("OnClick", function()
    CoreWindow:Hide()
end)
topBar:AddChild(closeButton)

-- Core Main Content
local coreContent = AceGUI:Create("TabGroup")
coreContent:SetFullWidth(true)
coreContent:SetLayout("Flow")
CoreWindow:AddChild(coreContent)

-- Total Time Label (Large White Text)
local totalTimeLabel = AceGUI:Create("Label")
totalTimeLabel:SetText("|cffffffffTotal Time: 00:00:00|r")
totalTimeLabel:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE")
totalTimeLabel:SetFullWidth(true)
coreContent:AddChild(totalTimeLabel)

-- Timer Update Logic
local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", function()
    local ProgressPlugin = MythicPlusAnalyzer:GetPlugin("ProgressPlugin")
    local pTime = ProgressPlugin:GetProgressTime()
    local hours = math.floor(pTime / 3600)
    local minutes = math.floor((pTime % 3600) / 60)
    local seconds = math.floor(pTime % 60)
    local millis = math.floor((pTime % 60 - math.floor(pTime % 60)) * 1000)
    local pString = string.format("|cffffffffProgress Time: %02d:%02d:%02d.%03d|r", hours, minutes, seconds, millis)
    totalTimeLabel:SetText(pString)
end)

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
