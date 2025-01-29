local HealingPlugin = {}
HealingPlugin.totalHealing = 0
HealingPlugin.healingPerSpell = {}
HealingPlugin.healingStartTime = 0
HealingPlugin.totalHealingTime = 0
HealingPlugin.inCombat = false

-- Initialize HealingPlugin
function HealingPlugin:StartTracking()
    -- Reuse the reset function to clear previous data
    self:ResetHealingMetrics()
    print("Mythic Plus Analyzer: Healing tracking started!")
end

function HealingPlugin:StopTracking()
    self:PrintHealingMetrics()
    print("Mythic Plus Analyzer: Healing tracking stopped!")
end

-- Track healing events
function HealingPlugin.events:COMBAT_LOG_EVENT_UNFILTERED(_, _, event, _, sourceGUID, _, _, _, _, _, _, spellID, spellName, _, amount)
    -- Only track healing done by the player
    if sourceGUID == UnitGUID("player") then
        if event == "SPELL_HEAL" and HealingPlugin.inCombat then
            HealingPlugin.totalHealing = HealingPlugin.totalHealing + amount
            -- Track healing per spell
            if not HealingPlugin.healingPerSpell[spellID] then
                HealingPlugin.healingPerSpell[spellID] = amount  -- Initialize with the first healing amount
            else
                HealingPlugin.healingPerSpell[spellID] = HealingPlugin.healingPerSpell[spellID] + amount
            end
        end
    end
end

-- Track combat time
local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", function(self, elapsed)
    if HealingPlugin.healingStartTime > 0 and HealingPlugin.inCombat then
        HealingPlugin.totalHealingTime = HealingPlugin.totalHealingTime + elapsed
    end
end)

-- Handle player entering combat
function HealingPlugin.events:PLAYER_REGEN_DISABLED()
    HealingPlugin.inCombat = true
    HealingPlugin.healingStartTime = GetTime()
    print("Mythic Plus Analyzer: Player entered combat!")
end

-- Handle player leaving combat
function HealingPlugin.events:PLAYER_REGEN_ENABLED()
    HealingPlugin.inCombat = false
    print("Mythic Plus Analyzer: Player left combat!")
end

-- Print Healing Metrics
function HealingPlugin:PrintHealingMetrics()
    print("Mythic Plus Analyzer: Healing Metrics Summary")
    print("Total Healing: " .. HealingPlugin.totalHealing)
    print("Average Healing Per Second: " .. (HealingPlugin.totalHealing / HealingPlugin.totalHealingTime))

    -- Print Healing per Spell
    for spellID, healing in pairs(HealingPlugin.healingPerSpell) do
        local spellName = GetSpellInfo(spellID) or "Unknown Spell"
        local avgHealingPerSec = healing / HealingPlugin.totalHealingTime
        print("Spell: " .. spellName .. " (ID: " .. spellID .. ") - Total Healing: " .. healing .. " | Avg Healing Per Second: " .. avgHealingPerSec)
    end
end

-- Reset healing metrics
function HealingPlugin:ResetHealingMetrics()
    HealingPlugin.totalHealing = 0
    HealingPlugin.healingPerSpell = {}
    HealingPlugin.totalHealingTime = 0
end

-- Command to print healing metrics
SLASH_HEALINGPLUGINPRINT1 = "/mpahprint"
SlashCmdList["HEALINGPLUGINPRINT"] = function()
    HealingPlugin:PrintHealingMetrics()
end

-- Command to reset healing metrics
SLASH_HEALINGPLUGINRESET1 = "/mpahreset"
SlashCmdList["HEALINGPLUGINRESET"] = function()
    HealingPlugin:ResetHealingMetrics()
    print("Mythic Plus Analyzer: Healing metrics reset.")
end

-- Register the plugin with the Core module
MythicPlusAnalyzer:RegisterPlugin(HealingPlugin)

-- Register events for combat tracking
HealingPlugin:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
HealingPlugin:RegisterEvent("PLAYER_REGEN_DISABLED")  -- Player enters combat
HealingPlugin:RegisterEvent("PLAYER_REGEN_ENABLED")   -- Player exits combat

print("Mythic Plus Analyzer: Healing Plugin loaded!")
