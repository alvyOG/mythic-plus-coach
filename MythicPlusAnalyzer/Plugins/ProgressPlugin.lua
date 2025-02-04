-- MPA ProgressPlugin
local ProgressPlugin = CreateFrame("Frame")  -- Create a frame for the plugin
ProgressPlugin.name = "ProgressPlugin"
ProgressPlugin.events = {}
ProgressPlugin.progressSlices = {}  -- List to store progress slices with progress data
ProgressPlugin.startTime = nil
ProgressPlugin.progressTime = nil

-- Reset tracking metrics
function ProgressPlugin:ResetTrackingMetrics()
    self.progressSlices = {}  -- Reset the progress slices
    self.startTime = GetTime()
    self.progressTime = nil
    print("MPA-Progress: Progress tracking reset!")
end

-- Getter for startTime
function ProgressPlugin:GetStartTime()
    if self.startTime then
        return self.startTime
    end
    return 0
end

-- Getter for progressTime
function ProgressPlugin:GetProgressTime()
    if self.progressTime then
        return self.progressTime
    end
    return 0
end

-- Setter for progressTime
function ProgressPlugin:SetProgressTime(time)
    if time >= 0 then
        self.progressTime = time
    end
end

-- Print progress metrics
function ProgressPlugin:PrintProgressMetrics()
    local pTime = ProgressPlugin:GetProgressTime()
    local hours = math.floor(pTime / 3600)
    local minutes = math.floor((pTime % 3600) / 60)
    local seconds = math.floor(pTime % 60)
    local millis = math.floor((pTime % 60 - math.floor(pTime % 60)) * 1000)
    local pString = string.format("%02d:%02d:%02d.%03d", hours, minutes, seconds, millis)
    print("MPA-Progress: Progress Time: ", pString)
end

-- Track dungeon progress time
local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", function(self)
    local startTime = ProgressPlugin:GetStartTime()
    if MythicPlusAnalyzer.isTracking and startTime > 0 then
        ProgressPlugin:SetProgressTime(GetTime() - startTime)
    end
end)

-- Command to print damage metrics
SLASH_PROGRESSPLUGINPRINT1 = "/mpapprint"
SlashCmdList["PROGRESSPLUGINPRINT"] = function()
    ProgressPlugin:PrintProgressMetrics()
end

-- Command to reset damage metrics
SLASH_PROGRESSPLUGINRESET1 = "/mpapreset"
SlashCmdList["PROGRESSPLUGINRESET"] = function()
    ProgressPlugin:ResetTrackingMetrics()
end

-- Register the plugin with the Core module
MythicPlusAnalyzer:RegisterPlugin(ProgressPlugin)

print("MPA-Progress: Progress Plugin loaded!")