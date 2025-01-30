-- MPA DamagePlugin
local DamagePlugin = CreateFrame("Frame")  -- Create a frame for the plugin
DamagePlugin.events = {}
DamagePlugin.damageSlices = {}  -- List to store combat slices with damage data

-- Reset tracking metrics
function DamagePlugin:ResetTrackingMetrics()
    self.damageSlices = {}  -- Reset the damage slices
    print("MPA-Damage: Damage tracking started!")
end

-- Track damage events
function DamagePlugin:OnCombatLogEvent()
    local _, subevent, _, sourceGUID, _, _, _, _, _ = CombatLogGetCurrentEventInfo()
    local spellID, spellName, amount

    -- Check if the source is the player and if the event is SPELL_DAMAGE
    if sourceGUID == UnitGUID("player") and subevent == "SPELL_DAMAGE" then
        spellID, spellName, _, amount, _, _, _, _, _, _ = select(12, CombatLogGetCurrentEventInfo())

        print("MPA-Damage: SPELL_DAMAGE subevent: ", spellName, spellID, amount)

        -- Find the current combat slice
        local currentSlice = MythicPlusAnalyzer.combatTimes[#MythicPlusAnalyzer.combatTimes]
        if currentSlice then
            local sliceIndex = #self.damageSlices
            local damageData = self.damageSlices[sliceIndex]

            if not damageData then
                -- Initialize a new slice if it's the first event for this slice
                damageData = {}
                self.damageSlices[sliceIndex] = damageData
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

-- Start a new damage slice when combat starts
function DamagePlugin:OnCombatStart()
    table.insert(self.damageSlices, {})
    print("MPA-Damage: Combat started!")
end

-- Handle combat end, just print the associated message
function DamagePlugin:OnCombatEnd()
    print("MPA-Damage: Combat ended!")
end

-- Print Damage Metrics
function DamagePlugin:PrintDamageMetrics()
    print("MPA-Damage: Damage Metrics Summary")
    
    -- Calculate and print total damage and average DPS
    local totalDamage = 0
    for _, slice in ipairs(self.damageSlices) do
        for _, damage in pairs(slice) do
            totalDamage = totalDamage + damage
        end
    end

    print("MPA-Damage: Total Damage: " .. totalDamage)
    local avgDPS = totalDamage / MythicPlusAnalyzer.totalTime
    print("MPA-Damage: Average DPS: " .. avgDPS)

    -- Print Damage per Spell for each slice
    for sliceIndex, slice in ipairs(self.damageSlices) do
        print("MPA-Damage: Combat Slice " .. sliceIndex .. ":")
        for spellID, damage in pairs(slice) do
            local spellName = GetSpellInfo(spellID) or "Unknown Spell"
            local avgDamagePerSec = damage / MythicPlusAnalyzer.totalTime
            print("MPA-Damage:   Spell: " .. spellName .. " (ID: " .. spellID .. ") - Total Damage: " .. damage .. " | Avg Damage Per Second: " .. avgDamagePerSec)
        end
    end
end

-- Command to print damage metrics
SLASH_DAMAGEPLUGINPRINT1 = "/mpadprint"
SlashCmdList["DAMAGEPLUGINPRINT"] = function()
    DamagePlugin:PrintDamageMetrics()
end

-- Command to reset damage metrics
SLASH_DAMAGEPLUGINRESET1 = "/mpadreset"
SlashCmdList["DAMAGEPLUGINRESET"] = function()
    DamagePlugin:ResetTrackingMetrics()
end

-- Register the plugin with the Core module
MythicPlusAnalyzer:RegisterPlugin(DamagePlugin)

print("MPA-Damage: Damage Plugin loaded!")
