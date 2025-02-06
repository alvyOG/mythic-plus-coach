-- MPA ProgressPlugin
local ProgressPlugin = CreateFrame("Frame")  -- Create a frame for the plugin
ProgressPlugin.name = "ProgressPlugin"
ProgressPlugin.events = {}
ProgressPlugin.progressSegments = {}  -- List to store progress slices with progress data
ProgressPlugin.startTime = nil
ProgressPlugin.progressTime = nil

-- Reset tracking metrics
function ProgressPlugin:ResetTrackingMetrics()
    self.progressSegments = {}  -- Reset the progress slices
    self.startTime = GetTime()
    self.progressTime = nil
    print("MPA-Progress: Progress tracking reset!")
end

-- Getter for startTime
function ProgressPlugin:GetStartTime()
    return self.startTime or 0
end

-- Getter for progressTime
function ProgressPlugin:GetProgressTime()
    return self.progressTime or 0
end

-- Setter for progressTime
function ProgressPlugin:SetProgressTime(time)
    if time >= 0 then
        self.progressTime = time
    end
end

-- Formats progress time as a string
function ProgressPlugin:FormatProgressMetrics()
    local pTime = self:GetProgressTime()
    local hours = math.floor(pTime / 3600)
    local minutes = math.floor((pTime % 3600) / 60)
    local seconds = math.floor(pTime % 60)
    local millis = math.floor((pTime % 60 - math.floor(pTime % 60)) * 1000)
    return string.format("|cffffffffProgress Time: %02d:%02d:%02d.%03d|r", hours, minutes, seconds, millis)
end

-- Function to return the UI content for this plugin
function ProgressPlugin:GetContent()
    local container = AceGUI:Create("SimpleGroup")
    container:SetFullWidth(true)
    container:SetLayout("Flow")

    -- Progress Time Label
    local progressLabel = AceGUI:Create("Label")
    progressLabel:SetText(self:FormatProgressMetrics())
    progressLabel:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE")
    progressLabel:SetFullWidth(true)
    container:AddChild(progressLabel)

    -- Timer Update Logic
    local updateFrame = CreateFrame("Frame")
    updateFrame:SetScript("OnUpdate", function()
        local startTime = self:GetStartTime()
        if MythicPlusAnalyzer.isTracking and startTime > 0 then
            self:SetProgressTime(GetTime() - startTime)
        end
        progressLabel:SetText(self:FormatProgressMetrics())
    end)

    return container
end

-- Command to print formatted progress time
SLASH_PROGRESSPLUGINPRINT1 = "/mpapprint"
SlashCmdList["PROGRESSPLUGINPRINT"] = function()
    print("MPA-Progress: " .. ProgressPlugin:FormatProgressMetrics())
end

-- Command to reset progress metrics
SLASH_PROGRESSPLUGINRESET1 = "/mpapreset"
SlashCmdList["PROGRESSPLUGINRESET"] = function()
    ProgressPlugin:ResetTrackingMetrics()
end

-- Register the plugin with the Core module
MythicPlusAnalyzer:RegisterPlugin(ProgressPlugin)

print("MPA-Progress: Progress Plugin loaded!")
