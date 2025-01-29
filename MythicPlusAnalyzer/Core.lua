-- Mythic Plus Analyzer Core Addon
local MythicPlusAnalyzer = CreateFrame("Frame")
MythicPlusAnalyzer.events = {}
MythicPlusAnalyzer.plugins = {}
MythicPlusAnalyzer.testMode = false  -- Test mode flag
MythicPlusAnalyzer.startTime = nil  -- Track dungeon start time
MythicPlusAnalyzer.isTracking = false  -- Track if metrics are already being tracked

-- Register core events
MythicPlusAnalyzer:RegisterEvent("PLAYER_ENTERING_WORLD")
MythicPlusAnalyzer:RegisterEvent("CHALLENGE_MODE_START")
MythicPlusAnalyzer:RegisterEvent("CHALLENGE_MODE_COMPLETED")
MythicPlusAnalyzer:RegisterEvent("PLAYER_LEAVING_WORLD")

-- Table to store run data
MythicPlusAnalyzer.data = {
    totalTime = 0,  -- Track total dungeon completion time
}

-- Event handler function
MythicPlusAnalyzer:SetScript("OnEvent", function(self, event, ...)
    if self.events[event] then
        self.events[event](self, ...)
    end
    for _, plugin in pairs(MythicPlusAnalyzer.plugins) do
        if plugin.events and plugin.events[event] then
            plugin.events[event](plugin, ...)
        end
    end
end)

-- Function to check if we should track the dungeon
local function ShouldTrackDungeon()
    return MythicPlusAnalyzer.testMode or C_ChallengeMode.IsChallengeModeActive()
end

-- Handle dungeon start (CHALLENGE_MODE_START)
function MythicPlusAnalyzer.events:CHALLENGE_MODE_START()
    if ShouldTrackDungeon() and not MythicPlusAnalyzer.isTracking then
        MythicPlusAnalyzer.startTime = GetTime()
        MythicPlusAnalyzer.data.totalTime = 0
        MythicPlusAnalyzer.isTracking = true
        print("Mythic Plus Analyzer: Dungeon tracking started!")

        -- Start all registered plugins
        for _, plugin in pairs(MythicPlusAnalyzer.plugins) do
            if plugin.StartTracking then
                plugin:StartTracking()
            end
        end
    end
end

-- Handle dungeon completion
function MythicPlusAnalyzer.events:CHALLENGE_MODE_COMPLETED()
    if MythicPlusAnalyzer.startTime then
        MythicPlusAnalyzer.data.totalTime = GetTime() - MythicPlusAnalyzer.startTime
        print("Mythic Plus Analyzer: Dungeon completed in " .. MythicPlusAnalyzer.data.totalTime .. " seconds.")
        MythicPlusAnalyzer.startTime = nil
        MythicPlusAnalyzer.isTracking = false

        -- Stop all registered plugins
        for _, plugin in pairs(MythicPlusAnalyzer.plugins) do
            if plugin.StopTracking then
                plugin:StopTracking()
            end
        end
    end
end

-- Handle player leaving the dungeon
function MythicPlusAnalyzer.events:PLAYER_LEAVING_WORLD()
    if MythicPlusAnalyzer.startTime then
        MythicPlusAnalyzer.data.totalTime = GetTime() - MythicPlusAnalyzer.startTime
        print("Mythic Plus Analyzer: Dungeon exited. Total time tracked: " .. MythicPlusAnalyzer.data.totalTime .. " seconds.")
        MythicPlusAnalyzer.startTime = nil
        MythicPlusAnalyzer.isTracking = false

        -- Stop all registered plugins
        for _, plugin in pairs(MythicPlusAnalyzer.plugins) do
            if plugin.StopTracking then
                plugin:StopTracking()
            end
        end
    end
end

-- Periodically update total time during dungeon
local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", function(self, elapsed)
    if MythicPlusAnalyzer.startTime then
        MythicPlusAnalyzer.data.totalTime = GetTime() - MythicPlusAnalyzer.startTime
    end
end)

-- Enable or disable test mode
SLASH_MYTHICPLUSTEST1 = "/mpatest"
SlashCmdList["MYTHICPLUSTEST"] = function()
    if MythicPlusAnalyzer.isTracking then
        print("Mythic Plus Analyzer: Already tracking a dungeon. Test mode cannot be toggled while tracking.")
        return
    end

    MythicPlusAnalyzer.testMode = not MythicPlusAnalyzer.testMode
    if MythicPlusAnalyzer.testMode then
        print("Mythic Plus Analyzer: Test mode ENABLED. Tracking in all dungeons.")

        -- Start tracking immediately when test mode is enabled
        if ShouldTrackDungeon() and not MythicPlusAnalyzer.isTracking then
            MythicPlusAnalyzer.startTime = GetTime()
            MythicPlusAnalyzer.data.totalTime = 0
            MythicPlusAnalyzer.isTracking = true
            print("Mythic Plus Analyzer: Test mode tracking started!")

            -- Start all registered plugins
            for _, plugin in pairs(MythicPlusAnalyzer.plugins) do
                if plugin.StartTracking then
                    plugin:StartTracking()
                end
            end
        end
    else
        print("Mythic Plus Analyzer: Test mode DISABLED. Tracking only in Mythic+.")

        -- Stop tracking and clear metrics when test mode is disabled
        if MythicPlusAnalyzer.isTracking then
            MythicPlusAnalyzer.startTime = nil
            MythicPlusAnalyzer.data.totalTime = 0
            MythicPlusAnalyzer.isTracking = false
            print("Mythic Plus Analyzer: Test mode tracking stopped.")

            -- Stop all registered plugins
            for _, plugin in pairs(MythicPlusAnalyzer.plugins) do
                if plugin.StopTracking then
                    plugin:StopTracking()
                end
            end
        end
    end
end

-- Register plugin function
function MythicPlusAnalyzer:RegisterPlugin(plugin)
    table.insert(self.plugins, plugin)
end

-- Command to print stored data
SLASH_MYTHICPLUSANALYZER1 = "/mpa"
SlashCmdList["MYTHICPLUSANALYZER"] = function()
    print("Mythic Plus Analyzer Data:")
    print("Total Time: " .. MythicPlusAnalyzer.data.totalTime .. " seconds")
end

print("Mythic Plus Analyzer Core loaded!")
