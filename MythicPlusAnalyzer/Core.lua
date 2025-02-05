-- Mythic Plus Analyzer Core Addon
MythicPlusAnalyzer = CreateFrame("Frame")
MythicPlusAnalyzer.events = {}
MythicPlusAnalyzer.plugins = {}
MythicPlusAnalyzer.testMode = false  -- Test mode flag
MythicPlusAnalyzer.isTracking = false  -- Track if metrics are already being tracked

-- Combat tracking variables
MythicPlusAnalyzer.inCombat = false
MythicPlusAnalyzer.combatTimes = {}  -- List of combat start/stop pairs

-- Register core events
MythicPlusAnalyzer:RegisterEvent("PLAYER_ENTERING_WORLD")
MythicPlusAnalyzer:RegisterEvent("CHALLENGE_MODE_START")
MythicPlusAnalyzer:RegisterEvent("CHALLENGE_MODE_COMPLETED")
MythicPlusAnalyzer:RegisterEvent("PLAYER_LEAVING_WORLD")
MythicPlusAnalyzer:RegisterEvent("PLAYER_REGEN_DISABLED")
MythicPlusAnalyzer:RegisterEvent("PLAYER_REGEN_ENABLED")
MythicPlusAnalyzer:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

-- Event handler function
MythicPlusAnalyzer:SetScript("OnEvent", function(self, event, ...)
    if self.events[event] then
        self.events[event](self, ...)
    end
end)

print("MPA-Core Core loaded!")

-- Register plugin function
function MythicPlusAnalyzer:RegisterPlugin(plugin)
    table.insert(self.plugins, plugin)
end

-- Getter plugin function
function MythicPlusAnalyzer:GetPlugin(pluginName)
    for _, plugin in pairs(self.plugins) do
        if plugin.name == pluginName then
            return plugin
        end
    end
    print("MPA-Core: Plugin", pluginName, "not found.")
    return nil
end


-- Function to toggle tracking
function MythicPlusAnalyzer:ToggleTrackingState()
    self.isTracking = not self.isTracking
    
    if self.isTracking then
        self:ResetTrackingMetrics()
        print("MPA-Core: Tracking ENABLED.")
    else
        print("MPA-Core: Tracking DISABLED.")
    end
end

-- Reset tracking-specific variables (but not global state like testMode)
function MythicPlusAnalyzer:ResetTrackingMetrics()
    self.combatTimes = {}
    
    print("MPA-Core: Tracking data has been reset.")

    -- Notify plugins
    for _, plugin in pairs(MythicPlusAnalyzer.plugins) do
        if plugin.ResetTrackingMetrics then
            plugin:ResetTrackingMetrics()
        end
    end
end

-- Start tracking when entering a Challenge Mode dungeon
function MythicPlusAnalyzer.events:CHALLENGE_MODE_START()
    MythicPlusAnalyzer:ResetTrackingMetrics()  -- Reset only relevant tracking variables
    MythicPlusAnalyzer.isTracking = true
    print("MPA-Core: Challenge Mode started! Tracking enabled.")
end

-- Stop tracking when the dungeon is completed
function MythicPlusAnalyzer.events:CHALLENGE_MODE_COMPLETED()
    MythicPlusAnalyzer.isTracking = false
    print("MPA-Core: Challenge Mode completed! Tracking stopped.")
end

-- Stop tracking when leaving the world (e.g., logging out, leaving instance)
function MythicPlusAnalyzer.events:PLAYER_LEAVING_WORLD()
    MythicPlusAnalyzer.isTracking = false
    print("MPA-Core: Player left the world. Tracking stopped.")
end

-- Handle player entering combat
function MythicPlusAnalyzer.events:PLAYER_REGEN_DISABLED()
    if not MythicPlusAnalyzer.isTracking then return end  -- Don't track if not in a dungeon/test mode

    MythicPlusAnalyzer.inCombat = true
    table.insert(MythicPlusAnalyzer.combatTimes, {start = GetTime()})  -- Add a new combat entry with only start time
    print("MPA-Core: Player entered combat!")

    -- Notify plugins
    for _, plugin in pairs(MythicPlusAnalyzer.plugins) do
        if plugin.OnCombatStart then
            plugin:OnCombatStart()
        end
    end
end

-- Handle player leaving combat
function MythicPlusAnalyzer.events:PLAYER_REGEN_ENABLED()
    if not MythicPlusAnalyzer.inCombat then return end  -- Ignore if combat wasn't started

    -- Add stop time to the last combat entry
    MythicPlusAnalyzer.combatTimes[#MythicPlusAnalyzer.combatTimes].stop = GetTime()
    
    print("MPA-Core: Player left combat!")

    -- Reset combat state
    MythicPlusAnalyzer.inCombat = false

    -- Notify plugins
    for _, plugin in pairs(MythicPlusAnalyzer.plugins) do
        if plugin.OnCombatEnd then
            plugin:OnCombatEnd()
        end
    end
end

-- Handle combat log event (delegated to plugins)
function MythicPlusAnalyzer.events:COMBAT_LOG_EVENT_UNFILTERED()
    if not MythicPlusAnalyzer.isTracking then return end  -- Ignore events if tracking is disabled

    -- Dispatch the combat log event to all plugins
    for _, plugin in pairs(MythicPlusAnalyzer.plugins) do
        if plugin.OnCombatLogEvent then
            plugin:OnCombatLogEvent()
        end
    end
end

-- Command to print stored total time
SLASH_MYTHICPLUSANALYZER1 = "/mpaprint"
SlashCmdList["MYTHICPLUSANALYZER"] = function()
    print("MPA-Core Data:")
    print("Combat Time Entries:")
    for i, entry in ipairs(MythicPlusAnalyzer.combatTimes) do
        if entry.stop then
            print("Fight " .. i .. ": Start - " .. entry.start .. ", Stop - " .. entry.stop .. ", Duration - " .. (entry.stop - entry.start) .. " sec")
        else
            print("Fight " .. i .. ": Start - " .. entry.start .. " (still ongoing)")
        end
    end
end

-- Enable or disable test mode
SLASH_MYTHICPLUSTEST1 = "/mpatest"
SlashCmdList["MYTHICPLUSTEST"] = function()
    local _, _, isInMythicPlus = C_ChallengeMode.GetActiveKeystoneInfo()

    if isInMythicPlus then
        print("MPA-Core: You are in an active Mythic+ dungeon. Test mode cannot be toggled.")
        return
    end

    MythicPlusAnalyzer:ToggleTrackingState()

    if MythicPlusAnalyzer.testMode then
        print("MPA-Core: Test mode ENABLED. Tracking in all dungeons.")
    else
        print("MPA-Core: Test mode DISABLED. Tracking only in Mythic+.")
    end
end

-- Command to reset tracking metrics
SLASH_MYTHICPLUSRESET1 = "/mpareset"
SlashCmdList["MYTHICPLUSRESET"] = function()
    MythicPlusAnalyzer:ResetTrackingMetrics()
end
