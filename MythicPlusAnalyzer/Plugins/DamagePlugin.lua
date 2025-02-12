-- Mythic Plus Analyzer Addon
-- Author: alvy023
-- File: DamagePlugin.lua
-- Description: Damage tracking functionality for the Mythic Plus Analyzer addon.
-- License:
-- For more information, visit the project repository.

-- Load Libraries
local AceGUI = LibStub("AceGUI-3.0")

-- Create a frame for the plugin
local DamagePlugin = CreateFrame("Frame")
DamagePlugin.name = "DamagePlugin"
DamagePlugin.events = {}
DamagePlugin.damageSegments = {}  -- List to store combat slices with damage data

-- Register the plugin with the Core module
MythicPlusAnalyzer:RegisterPlugin(DamagePlugin)

--- Description: Reset tracking metrics.
--- @param:
--- @return:
function DamagePlugin:ResetTrackingMetrics()
    self.damageSegments = {}  -- Reset the damage slices
    print("MPA-Damage: Damage tracking reset!")
end

--- Description: Track damage events.
--- @param:
--- @return:
function DamagePlugin:OnCombatLogEvent()
    local _, subevent, _, sourceGUID, _, _, _, _, _ = CombatLogGetCurrentEventInfo()
    local spellID, spellName, amount

    -- Check if the source is the player and if the event is SPELL_DAMAGE
    if sourceGUID == UnitGUID("player") and subevent == "SPELL_DAMAGE" then
        spellID, spellName, _, amount, _, _, _, _, _, _ = select(12, CombatLogGetCurrentEventInfo())

        print("MPA-Damage: SPELL_DAMAGE subevent: ", spellName, spellID, amount)

        -- Find the current combat slice
        local currentSlice = CoreSegments.combatSegments[#CoreSegments.combatSegments]
        if currentSlice then
            local sliceIndex = #self.damageSegments
            local damageData = self.damageSegments[sliceIndex]

            if not damageData then
                -- Initialize a new slice if it's the first event for this slice
                damageData = {}
                self.damageSegments[sliceIndex] = damageData
            end

            -- Track damage per spell in the current slice
            if not damageData[spellID] then
                damageData[spellID] = amount  -- Initialize with the first damage amount
            else
                damageData[spellID] = damageData[spellID] + amount
            end
        end
    end
end

--- Description: Start a new damage slice when combat starts.
--- @param:
--- @return:
function DamagePlugin:OnCombatStart()
    table.insert(self.damageSegments, {})
    print("MPA-Damage: Combat started!")
end

--- Description: Handle combat end, just print the associated message.
--- @param:
--- @return:
function DamagePlugin:OnCombatEnd()
    print("MPA-Damage: Combat ended!")
end

--- Description: Print Damage Metrics.
--- @param:
--- @return:
function DamagePlugin:PrintDamageMetrics()
    print("MPA-Damage: Damage Metrics Summary")

    -- Calculate total damage and the total duration of all combat slices
    local totalDamage = 0
    for _, slice in ipairs(self.damageSegments) do
        for _, damage in pairs(slice) do
            totalDamage = totalDamage + damage
        end
    end

    -- Calculate total combat time based on the combat time slices
    local totalCombatTime = 0
    for _, combatSlice in ipairs(CoreSegments.combatSegments) do
        totalCombatTime = totalCombatTime + (combatSlice.stop - combatSlice.start)
    end

    -- Calculate the total average DPS
    local avgDPS = totalDamage / totalCombatTime
    print("MPA-Damage: Total Damage: " .. totalDamage)
    print("MPA-Damage: Average DPS: " .. avgDPS)

    -- Print Damage per Spell for each slice and calculate slice-specific DPS
    for sliceIndex, slice in ipairs(self.damageSegments) do
        local sliceDamage = 0
        local sliceCombatTime = CoreSegments.combatSegments[sliceIndex].stop - CoreSegments.combatSegments[sliceIndex].start

        -- Calculate the total damage for the slice
        for spellID, damage in pairs(slice) do
            sliceDamage = sliceDamage + damage
        end

        -- Calculate the slice DPS
        local sliceDPS = sliceDamage / sliceCombatTime
        print("MPA-Damage: Combat Slice " .. sliceIndex .. ":")
        print("MPA-Damage:   Slice Total Damage: " .. sliceDamage)
        print("MPA-Damage:   Slice DPS: " .. sliceDPS)

        -- Print Damage per Spell for the slice
        for spellID, damage in pairs(slice) do
            local spellName = C_Spell.GetSpellName(spellID)
            local spellDPS = damage / sliceCombatTime
            print("MPA-Damage:   Spell: " .. spellName .. " (ID: " .. spellID .. ") - Total Damage: " .. damage .. " | DPS: " .. spellDPS)
        end
    end
end

--- Description: Command to print damage metrics.
--- @param:
--- @return:
function DamagePlugin:PrintDamageMetricsCommand()
    DamagePlugin:PrintDamageMetrics()
end

--- Description: Command to reset damage metrics.
--- @param:
--- @return:
function DamagePlugin:ResetDamageMetricsCommand()
    DamagePlugin:ResetTrackingMetrics()
end

-- Register slash commands
MythicPlusAnalyzer:RegisterChatCommand("mpa-damage-print", function()
    DamagePlugin:PrintDamageMetricsCommand()
end)

MythicPlusAnalyzer:RegisterChatCommand("mpa-damage-reset", function()
    DamagePlugin:ResetDamageMetricsCommand()
end)
