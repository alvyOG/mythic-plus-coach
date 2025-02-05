-- MPA HealingPlugin
local HealingPlugin = CreateFrame("Frame")  -- Create a frame for the plugin
HealingPlugin.name = "HealingPlugin"
HealingPlugin.events = {}
HealingPlugin.healingSlices = {}  -- List to store combat slices with Healing data

-- Reset tracking metrics
function HealingPlugin:ResetTrackingMetrics()
    self.healingSlices = {}  -- Reset the healing slices
    print("MPA-Healing: Healing tracking reset!")
end

-- Track Healing events
function HealingPlugin:OnCombatLogEvent()
    local _, subevent, _, sourceGUID, _, _, _, _, _ = CombatLogGetCurrentEventInfo()
    local spellID, spellName, amount

    -- Check if the source is the player and if the event is SPELL_HEALING
    if sourceGUID == UnitGUID("player") and subevent == "SPELL_HEAL" then
        spellID, spellName, _, amount, _, _, _, _, _, _ = select(12, CombatLogGetCurrentEventInfo())

        print("MPA-Healing: SPELL_HEALING subevent: ", spellName, spellID, amount)

        -- Find the current combat slice
        local currentSlice = MythicPlusAnalyzer.combatTimes[#MythicPlusAnalyzer.combatTimes]
        if currentSlice then
            local sliceIndex = #self.healingSlices
            local healingData = self.healingSlices[sliceIndex]

            if not healingData then
                -- Initialize a new slice if it's the first event for this slice
                healingData = {}
                self.healingSlices[sliceIndex] = healingData
            end

            -- Track Healing per spell in the current slice
            if not healingData[spellID] then
                healingData[spellID] = amount  -- Initialize with the first Healing amount
            else
                healingData[spellID] = healingData[spellID] + amount
            end
        end
    end
end

-- Start a new Healing slice when combat starts
function HealingPlugin:OnCombatStart()
    table.insert(self.healingSlices, {})
    print("MPA-Healing: Combat started!")
end

-- Handle combat end, just print the associated message
function HealingPlugin:OnCombatEnd()
    print("MPA-Healing: Combat ended!")
end

-- Print Healing Metrics
function HealingPlugin:PrintHealingMetrics()
    print("MPA-Healing: Healing Metrics Summary")

    -- Calculate total Healing and the total duration of all combat slices
    local totalHealing = 0
    for _, slice in ipairs(self.healingSlices) do
        for _, healing in pairs(slice) do
            totalHealing = totalHealing + healing
        end
    end

    -- Calculate total combat time based on the combat time slices
    local totalCombatTime = 0
    for _, combatSlice in ipairs(MythicPlusAnalyzer.combatTimes) do
        totalCombatTime = totalCombatTime + (combatSlice.stop - combatSlice.start)
    end

    -- Calculate the total average HPS
    local avgHPS = totalHealing / totalCombatTime
    print("MPA-Healing: Total Healing: " .. totalHealing)
    print("MPA-Healing: Average HPS: " .. avgHPS)

    -- Print Healing per Spell for each slice and calculate slice-specific HPS
    for sliceIndex, slice in ipairs(self.healingSlices) do
        local sliceHealing = 0
        local sliceCombatTime = MythicPlusAnalyzer.combatTimes[sliceIndex].stop - MythicPlusAnalyzer.combatTimes[sliceIndex].start

        -- Calculate the total healing for the slice
        for spellID, healing in pairs(slice) do
            sliceHealing = sliceHealing + healing
        end

        -- Calculate the slice HPS
        local sliceHPS = sliceHealing / sliceCombatTime
        print("MPA-Healing: Combat Slice " .. sliceIndex .. ":")
        print("MPA-Healing:   Slice Total Healing: " .. sliceHealing)
        print("MPA-Healing:   Slice HPS: " .. sliceHPS)

        -- Print Healing per Spell for the slice
        for spellID, healing in pairs(slice) do
            local spellName = C_Spell.GetSpellName(spellID)
            local spellHPS = healing / sliceCombatTime
            print("MPA-Healing:   Spell: " .. spellName .. " (ID: " .. spellID .. ") - Total Healing: " .. healing .. " | HPS: " .. spellHPS)
        end
    end
end

-- Command to print Healing metrics
SLASH_HEALINGPLUGINPRINT1 = "/mpahprint"
SlashCmdList["HEALINGPLUGINPRINT"] = function()
    HealingPlugin:PrintHealingMetrics()
end

-- Command to reset Healing metrics
SLASH_HEALINGPLUGINRESET1 = "/mpahreset"
SlashCmdList["HEALINGPLUGINRESET"] = function()
    HealingPlugin:ResetTrackingMetrics()
end

-- Register the plugin with the Core module
MythicPlusAnalyzer:RegisterPlugin(HealingPlugin)

print("MPA-Healing: Healing Plugin loaded!")
