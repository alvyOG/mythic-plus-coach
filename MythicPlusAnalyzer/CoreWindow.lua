-- MPA Core Window
-- Load AceGUI
local AceGUI = LibStub("AceGUI-3.0")

-- Create the main window
local CoreWindow = AceGUI:Create("Frame")
CoreWindow:SetTitle("Mythic Plus Analyzer")
CoreWindow:SetStatusText("Track and analyze your Mythic+ performance")
CoreWindow:SetLayout("Flow")
CoreWindow:SetWidth(300)
CoreWindow:SetHeight(200)
CoreWindow:EnableResize(true)
CoreWindow:Hide()  -- Start hidden

-- Enable/Disable Tracking Button
local trackButton = AceGUI:Create("Button")
trackButton:SetText("Start")
trackButton:SetWidth(140)
trackButton:SetCallback("OnClick", function()
    MythicPlusAnalyzer:ToggleTrackingState()
    if MythicPlusAnalyzer.isTracking then
        trackButton:SetText("Stop")
    else
        trackButton:SetText("Start")
    end
    print("MPA-Core Window: Tracking state changed")
end)
CoreWindow:AddChild(trackButton)

-- Reset Data Button
local resetButton = AceGUI:Create("Button")
resetButton:SetText("Reset")
resetButton:SetWidth(140)
resetButton:SetCallback("OnClick", function()
    MythicPlusAnalyzer:ResetTrackingMetrics()
    print("MPA-Core Window: Reset tracking metrics")
end)
CoreWindow:AddChild(resetButton)

-- Slash Command to Toggle GUI
SLASH_MPACOREFRAME1 = "/mpagui"
SlashCmdList["MPACOREFRAME"] = function()
    if CoreWindow:IsVisible() then
        CoreWindow:Hide()
    else
        CoreWindow:Show()
    end
end

print("MPA-Core Window: Loaded successfully")
