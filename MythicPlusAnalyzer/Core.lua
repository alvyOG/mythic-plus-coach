-- Mythic Plus Analyzer Core Addon
MythicPlusAnalyzer = CreateFrame("Frame")
MythicPlusAnalyzer.events = {}
MythicPlusAnalyzer.plugins = {}
MythicPlusAnalyzer.testMode = false  -- Test mode flag
MythicPlusAnalyzer.startTime = nil  -- Track dungeon start time
MythicPlusAnalyzer.isTracking = false  -- Track if metrics are already being tracked

-- Combat tracking variables
MythicPlusAnalyzer.inCombat = false
MythicPlusAnalyzer.combatStartTime = 0
MythicPlusAnalyzer.totalCombatTime = 0

-- Register core events
MythicPlusAnalyzer:RegisterEvent("PLAYER_ENTERING_WORLD")
MythicPlusAnalyzer:RegisterEvent("CHALLENGE_MODE_START")
MythicPlusAnalyzer:RegisterEvent("CHALLENGE_MODE_COMPLETED")
MythicPlusAnalyzer:RegisterEvent("PLAYER_LEAVING_WORLD")
MythicPlusAnalyzer:RegisterEvent("PLAYER_REGEN_DISABLED")
MythicPlusAnalyzer:RegisterEvent("PLAYER_REGEN_ENABLED")
MythicPlusAnalyzer:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

-- Table to store run data
MythicPlusAnalyzer.data = {
    totalTime = 0,  -- Track total dungeon completion time
}

-- Event handler function
MythicPlusAnalyzer:SetScript("OnEvent", function(self, event, ...)
    if self.events[event] then
        self.events[event](self, ...)
    end
end)

-- Handle player entering combat
function MythicPlusAnalyzer.events:PLAYER_REGEN_DISABLED()
    MythicPlusAnalyzer.inCombat = true
    MythicPlusAnalyzer.combatStartTime = GetTime()
    print("Mythic Plus Analyzer: Player entered combat!")
    -- Notify plugins
    for _, plugin in pairs(MythicPlusAnalyzer.plugins) do
        if plugin.OnCombatStart then
            plugin:OnCombatStart()
        end
    end
end

-- Handle player leaving combat
function MythicPlusAnalyzer.events:PLAYER_REGEN_ENABLED()
    MythicPlusAnalyzer.inCombat = false
    MythicPlusAnalyzer.totalCombatTime = MythicPlusAnalyzer.totalCombatTime + (GetTime() - MythicPlusAnalyzer.combatStartTime)
    print("Mythic Plus Analyzer: Player left combat! Total combat time: " .. MythicPlusAnalyzer.totalCombatTime)
    -- Notify plugins
    for _, plugin in pairs(MythicPlusAnalyzer.plugins) do
        if plugin.OnCombatEnd then
            plugin:OnCombatEnd()
        end
    end
end

-- Handle combat log event (delegated to plugins)
-- timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags,
-- [spellID, spellName, spellSchool, amount]
function MythicPlusAnalyzer.events:COMBAT_LOG_EVENT_UNFILTERED()
    -- Dispatch the combat log event to all plugins
    for _, plugin in pairs(MythicPlusAnalyzer.plugins) do
        if plugin.OnCombatLogEvent then
            plugin:OnCombatLogEvent()
        end
    end
end

-- Track total time during dungeon
local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", function(self, elapsed)
    if MythicPlusAnalyzer.startTime then
        MythicPlusAnalyzer.data.totalTime = GetTime() - MythicPlusAnalyzer.startTime
    end
    if MythicPlusAnalyzer.inCombat then
        MythicPlusAnalyzer.totalCombatTime = MythicPlusAnalyzer.totalCombatTime + elapsed
    end
end)

-- Register plugin function
function MythicPlusAnalyzer:RegisterPlugin(plugin)
    table.insert(self.plugins, plugin)
end

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
    else
        print("Mythic Plus Analyzer: Test mode DISABLED. Tracking only in Mythic+.")
    end
end

-- Command to print stored data
SLASH_MYTHICPLUSANALYZER1 = "/mpa"
SlashCmdList["MYTHICPLUSANALYZER"] = function()
    print("Player GUID: " .. UnitGUID("player"))
    print("Mythic Plus Analyzer Data:")
    print("Total Time: " .. MythicPlusAnalyzer.data.totalTime .. " seconds")
end

print("Mythic Plus Analyzer Core loaded!")
