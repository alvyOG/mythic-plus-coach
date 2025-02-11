-- Mythic Plus Analyzer Addon
-- Author: alvy023
-- File: ProgressPlugin.lua
-- Description: Progress tracking functionality for the Mythic Plus Analyzer addon.
-- License:
-- For more information, visit the project repository.

-- Load Libraries
local AceGUI = LibStub("AceGUI-3.0")

-- Create a frame for the plugin
local ProgressPlugin = CreateFrame("Frame")
ProgressPlugin.name = "ProgressPlugin"
ProgressPlugin.events = {}
ProgressPlugin.progressSegments = {}
ProgressPlugin.startTime = nil
ProgressPlugin.progressTime = nil

--- Description: Reset tracking metrics.
--- @param:
--- @return:
function ProgressPlugin:ResetTrackingMetrics()
    self.progressSegments = {}
    self.startTime = GetTime()
    self.progressTime = nil
    print("MPA-Progress: Progress tracking reset!")
end

--- Description: Getter for startTime.
--- @param:
--- @return: The start time.
function ProgressPlugin:GetStartTime()
    return self.startTime or 0
end

--- Description: Getter for progressTime.
--- @param:
--- @return: The progress time.
function ProgressPlugin:GetProgressTime()
    return self.progressTime or 0
end

--- Description: Setter for progressTime.
--- @param: time - The new progress time.
--- @return:
function ProgressPlugin:SetProgressTime(time)
    if time >= 0 then
        self.progressTime = time
    end
end

--- Description: Formats progress time as a string.
--- @param:
--- @return: The formatted progress time string.
function ProgressPlugin:FormatProgressMetrics()
    local pTime = self:GetProgressTime()
    local hours = math.floor(pTime / 3600)
    local minutes = math.floor((pTime % 3600) / 60)
    local seconds = math.floor(pTime % 60)
    local millis = math.floor((pTime % 60 - math.floor(pTime % 60)) * 1000)
    return string.format("|cffffffffProgress Time: %02d:%02d:%02d.%03d|r", hours, minutes, seconds, millis)
end

--- Description: Function to return the UI content for this plugin.
--- @param:
--- @return: The UI content container.
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

--- Description: Command to print formatted progress time.
--- @param:
--- @return:
function ProgressPlugin:PrintProgressTime()
    print("MPA-Progress: " .. self:FormatProgressMetrics())
end

--- Description: Command to reset progress metrics.
--- @param:
--- @return:
function ProgressPlugin:ResetProgressMetrics()
    self:ResetTrackingMetrics()
end

-- Register the plugin with the Core module
MythicPlusAnalyzer:RegisterPlugin(ProgressPlugin)

-- Register slash commands
MythicPlusAnalyzer:RegisterChatCommand("mpa-progress-print", function()
    ProgressPlugin:PrintProgressTime()
end)

MythicPlusAnalyzer:RegisterChatCommand("mpa-progress-reset", function()
    ProgressPlugin:ResetProgressMetrics()
end)
