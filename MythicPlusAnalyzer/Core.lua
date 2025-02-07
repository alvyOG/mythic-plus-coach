-- MPA Core
local AceAddon = LibStub("AceAddon-3.0")
local AceEvent = LibStub("AceEvent-3.0")

-- Initialize MPA as an AceAddon module
MythicPlusAnalyzer = AceAddon:NewAddon("MythicPlusAnalyzer", "AceEvent-3.0")

-- Event handlers
function MythicPlusAnalyzer:OnInitialize()
    self.plugins = {}
    self.testMode = false
    self.isTracking = false
    print("MPA-Core: Initialized")
end

function MythicPlusAnalyzer:OnEnable()
    -- Register events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("CHALLENGE_MODE_START")
    self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    self:RegisterEvent("PLAYER_LEAVING_WORLD")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

-- Event handlers
function MythicPlusAnalyzer:CHALLENGE_MODE_START()
    self:ResetTrackingMetrics()
    self.isTracking = true
    print("MPA-Core: Challenge Mode started! Tracking enabled.")
end

function MythicPlusAnalyzer:CHALLENGE_MODE_COMPLETED()
    self.isTracking = false
    print("MPA-Core: Challenge Mode completed! Tracking stopped.")
end

function MythicPlusAnalyzer:PLAYER_LEAVING_WORLD()
    self.isTracking = false
    print("MPA-Core: Player left the world. Tracking stopped.")
end

function MythicPlusAnalyzer:PLAYER_REGEN_DISABLED()
    if not self.isTracking then return end
    CoreSegments:SetCombatState(true)
    for _, plugin in pairs(self.plugins) do
        if plugin.OnCombatStart then 
            plugin:OnCombatStart() 
        end
    end
end

function MythicPlusAnalyzer:PLAYER_REGEN_ENABLED()
    if not CoreSegments:GetCombatState() then return end
    CoreSegments:SetCombatState(false)
    for _, plugin in pairs(self.plugins) do
        if plugin.OnCombatEnd then 
            plugin:OnCombatEnd() 
        end
    end
end

function MythicPlusAnalyzer:COMBAT_LOG_EVENT_UNFILTERED()
    if not self.isTracking then return end
    for _, plugin in pairs(self.plugins) do
        if plugin.OnCombatLogEvent then 
            plugin:OnCombatLogEvent() 
        end
    end
end

-- Plugin Management
function MythicPlusAnalyzer:RegisterPlugin(plugin)
    table.insert(self.plugins, plugin)
end

function MythicPlusAnalyzer:GetPlugin(pluginName)
    for _, plugin in pairs(self.plugins) do
        if plugin.name == pluginName then return plugin end
    end
    print("MPA-Core: Plugin", pluginName, "not found.")
    return nil
end

-- Utility Commands
function MythicPlusAnalyzer:ToggleTrackingState()
    self.isTracking = not self.isTracking
    if self.isTracking then
        self:ResetTrackingMetrics()
        print("MPA-Core: Tracking ENABLED.")
    else
        print("MPA-Core: Tracking DISABLED.")
    end
end

function MythicPlusAnalyzer:ResetTrackingMetrics()
    CoreSegments:ResetCombatSegments()
    for _, plugin in pairs(self.plugins) do
        if plugin.ResetTrackingMetrics then 
            plugin:ResetTrackingMetrics() 
        end
    end
end

-- Slash Commands
MythicPlusAnalyzer:RegisterChatCommand("mpa test", "ToggleTrackingState")
MythicPlusAnalyzer:RegisterChatCommand("mpa reset", "ResetTrackingMetrics")
