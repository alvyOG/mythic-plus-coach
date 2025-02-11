-- Mythic Plus Analyzer Addon
-- Author: alvy023
-- File: Core.lua
-- Description: Core functionality for the Mythic Plus Analyzer addon.
-- License:
-- For more information, visit the project repository.

-- Load Libraries
local AceAddon = LibStub("AceAddon-3.0")
local AceEvent = LibStub("AceEvent-3.0")
local AceConsole = LibStub("AceConsole-3.0")

-- Initialize MPA as an AceAddon module
MythicPlusAnalyzer = AceAddon:NewAddon("MythicPlusAnalyzer", "AceEvent-3.0", "AceConsole-3.0")

-- Event handlers
--- Description: Initializes the addon, setting up initial values and printing a message.
--- @param:
--- @return:
function MythicPlusAnalyzer:OnInitialize()
    self.plugins = self.plugins or {}
    self.testMode = false
    self.isTracking = false
end

--- Description: Registers events when the addon is enabled.
--- @param:
--- @return:
function MythicPlusAnalyzer:OnEnable()
    self:RegisterEvent("CHALLENGE_MODE_START")
    self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    self:RegisterEvent("PLAYER_LEAVING_WORLD")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

--- Description: Handles the start of a Challenge Mode, resetting tracking metrics and enabling tracking.
--- @param:
--- @return:
function MythicPlusAnalyzer:CHALLENGE_MODE_START()
    self:ResetTrackingMetrics()
    self.isTracking = true
    print("MPA-Core: Challenge Mode started! Tracking enabled.")
end

--- Description: Handles the completion of a Challenge Mode, disabling tracking.
--- @param:
--- @return:
function MythicPlusAnalyzer:CHALLENGE_MODE_COMPLETED()
    self.isTracking = false
    print("MPA-Core: Challenge Mode completed! Tracking stopped.")
end

--- Description: Handles the player leaving the world, disabling tracking.
--- @param:
--- @return:
function MythicPlusAnalyzer:PLAYER_LEAVING_WORLD()
    self.isTracking = false
    print("MPA-Core: Player left the world. Tracking stopped.")
end

--- Description: Handles the player entering combat, setting combat state and notifying plugins.
--- @param:
--- @return:
function MythicPlusAnalyzer:PLAYER_REGEN_DISABLED()
    if not self.isTracking then return end
    CoreSegments:SetCombatState(true)
    for _, plugin in pairs(self.plugins) do
        if plugin.OnCombatStart then
            plugin:OnCombatStart()
        end
    end
end

--- Description: Handles the player leaving combat, setting combat state and notifying plugins.
--- @param:
--- @return:
function MythicPlusAnalyzer:PLAYER_REGEN_ENABLED()
    if not CoreSegments:GetCombatState() then return end
    CoreSegments:SetCombatState(false)
    for _, plugin in pairs(self.plugins) do
        if plugin.OnCombatEnd then
            plugin:OnCombatEnd()
        end
    end
end

--- Description: Handles combat log events, notifying plugins.
--- @param:
--- @return:
function MythicPlusAnalyzer:COMBAT_LOG_EVENT_UNFILTERED()
    if not self.isTracking then return end
    for _, plugin in pairs(self.plugins) do
        if plugin.OnCombatLogEvent then
            plugin:OnCombatLogEvent()
        end
    end
end

-- Plugin Management
--- Description: Registers a plugin with the Mythic Plus Analyzer.
--- @param: plugin - The plugin to register.
--- @return:
function MythicPlusAnalyzer:RegisterPlugin(plugin)
    self.plugins = self.plugins or {}
    table.insert(self.plugins, plugin)
end

--- Description: Retrieves all registered plugins.
--- @param:
--- @return: A table of registered plugins.
function MythicPlusAnalyzer:GetPlugins()
    self.plugins = self.plugins or {}
    return self.plugins
end

--- Description: Retrieves a specific plugin by name.
--- @param: pluginName - The name of the plugin to retrieve.
--- @return: The plugin if found, or nil if not found.
function MythicPlusAnalyzer:GetPlugin(pluginName)
    for _, plugin in pairs(self.plugins) do
        if plugin.name == pluginName then return plugin end
    end
    print("MPA-Core: Plugin", pluginName, "not found.")
    return nil
end

-- Utility Commands
--- Description: Toggles the visibility of the Core Window.
--- @param:
--- @return:
function MythicPlusAnalyzer:ToggleCoreWindow()
    if CoreWindow:IsShown() then
        CoreWindow:Hide()
    else
        CoreWindow:Show()
    end
end

--- Description: Toggles the tracking state and resets tracking metrics if enabled.
--- @param:
--- @return:
function MythicPlusAnalyzer:ToggleTrackingState()
    self.isTracking = not self.isTracking
    if self.isTracking then
        self:ResetTrackingMetrics()
        print("MPA-Core: Tracking ENABLED.")
    else
        print("MPA-Core: Tracking DISABLED.")
    end
end

--- Description: Resets tracking metrics for all plugins and core segments.
--- @param:
--- @return:
function MythicPlusAnalyzer:ResetTrackingMetrics()
    CoreSegments:ResetCombatSegments()
    for _, plugin in pairs(self.plugins) do
        if plugin.ResetTrackingMetrics then
            plugin:ResetTrackingMetrics()
        end
    end
end

-- Slash Commands
MythicPlusAnalyzer:RegisterChatCommand("mpa-show", "ToggleCoreWindow")
MythicPlusAnalyzer:RegisterChatCommand("mpa-test", "ToggleTrackingState")
MythicPlusAnalyzer:RegisterChatCommand("mpa-reset", "ResetTrackingMetrics")