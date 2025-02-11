-- Mythic Plus Analyzer Addon
-- Author: alvy023
-- File: HealingPlugin.lua
-- Description: Healing tracking functionality for the Mythic Plus Analyzer addon.
-- License:
-- For more information, visit the project repository.

-- Load Libraries
local AceGUI = LibStub("AceGUI-3.0")

-- Create a frame for the plugin
local HealingPlugin = CreateFrame("Frame")
HealingPlugin.name = "HealingPlugin"
HealingPlugin.events = {}
HealingPlugin.healingSegments = {}  -- List to store combat slices with healing data

--- Description: Reset tracking metrics.
--- @param:
--- @return:
function HealingPlugin:ResetTrackingMetrics()
    self.healingSegments = {}  -- Reset the healing slices
    print("MPA-Healing: Healing tracking reset!")
end

--- Description: Track healing events.
--- @param:
--- @return:
function HealingPlugin:OnCombatLogEvent()
    local _, subevent, _, sourceGUID, _, _, _, _, _ = CombatLogGetCurrentEventInfo()
    local spellID, spellName, amount

    -- Check if the source is the player and if the event is SPELL_HEAL
    if sourceGUID == UnitGUID("player") and subevent == "SPELL_HEAL" then
        spellID, spellName, _, amount, _, _, _, _, _, _ = select(12, CombatLogGetCurrentEventInfo())

        print("MPA-Healing: SPELL_HEAL subevent: ", spellName, spellID, amount)

        -- Find the current combat slice
        local currentSlice = CoreSegments.combatSegments[#CoreSegments.combatSegments]
        if currentSlice then
            local sliceIndex = #self.healingSegments
            local healingData = self.healingSegments[sliceIndex]

            if not healingData then
                -- Initialize a new slice if it's the first event for this slice
                healingData = {}
                self.healingSegments[sliceIndex] = healingData
            end

            -- Track healing per spell in the current slice
            if not healingData[spellID] then
                healingData[spellID] = amount  -- Initialize with the first healing amount
            else
                healingData[spellID] = healingData[spellID] + amount
            end
        end
    end
end

--- Description: Start a new healing slice when combat starts.
--- @param:
--- @return:
function HealingPlugin:OnCombatStart()
    table.insert(self.healingSegments, {})
    print("MPA-Healing: Combat started!")
end

--- Description: Handle combat end, just print the associated message.
--- @param:
--- @return:
function HealingPlugin:OnCombatEnd()
    print("MPA-Healing: Combat ended!")
end

--- Description: Print healing metrics.
--- @param:
--- @return:
function HealingPlugin:PrintHealingMetrics()
    print("MPA-Healing: Healing Metrics Summary")

    -- Calculate total healing and the total duration of all combat slices
    local totalHealing = 0
    for _, slice in ipairs(self.healingSegments) do
        for _, healing in pairs(slice) do
            totalHealing = totalHealing + healing
        end
    end

    -- Calculate total combat time based on the combat time slices
    local totalCombatTime = 0
    for _, combatSlice in ipairs(CoreSegments.combatSegments) do
        totalCombatTime = totalCombatTime + (combatSlice.stop - combatSlice.start)
    end

    -- Calculate the total average HPS
    local avgHPS = totalHealing / totalCombatTime
    print("MPA-Healing: Total Healing: " .. totalHealing)
    print("MPA-Healing: Average HPS: " .. avgHPS)

    -- Print healing per spell for each slice and calculate slice-specific HPS
    for sliceIndex, slice in ipairs(self.healingSegments) do
        local sliceHealing = 0
        local sliceCombatTime = CoreSegments.combatSegments[sliceIndex].stop - CoreSegments.combatSegments[sliceIndex].start

        -- Calculate the total healing for the slice
        for spellID, healing in pairs(slice) do
            sliceHealing = sliceHealing + healing
        end

        -- Calculate the slice HPS
        local sliceHPS = sliceHealing / sliceCombatTime
        print("MPA-Healing: Combat Slice " .. sliceIndex .. ":")
        print("MPA-Healing:   Slice Total Healing: " .. sliceHealing)
        print("MPA-Healing:   Slice HPS: " .. sliceHPS)

        -- Print healing per spell for the slice
        for spellID, healing in pairs(slice) do
            local spellName = C_Spell.GetSpellName(spellID)
            local spellHPS = healing / sliceCombatTime
            print("MPA-Healing:   Spell: " .. spellName .. " (ID: " .. spellID .. ") - Total Healing: " .. healing .. " | HPS: " .. spellHPS)
        end
    end
end

--- Description: Command to print healing metrics.
--- @param:
--- @return:
function HealingPlugin:PrintHealingMetricsCommand()
    HealingPlugin:PrintHealingMetrics()
end

--- Description: Command to reset healing metrics.
--- @param:
--- @return:
function HealingPlugin:ResetHealingMetricsCommand()
    HealingPlugin:ResetTrackingMetrics()
end

-- Register the plugin with the Core module
MythicPlusAnalyzer:RegisterPlugin(HealingPlugin)

-- Register slash commands
MythicPlusAnalyzer:RegisterChatCommand("mpa-healing-print", function()
    HealingPlugin:PrintHealingMetricsCommand()
end)

MythicPlusAnalyzer:RegisterChatCommand("mpa-healing-reset", function()
    HealingPlugin:ResetHealingMetricsCommand()
end)

print("MPA-Healing: Healing Plugin loaded!")