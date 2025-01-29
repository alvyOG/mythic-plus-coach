local DamagePlugin = {}
DamagePlugin.totalDamage = 0
DamagePlugin.damagePerSpell = {}
DamagePlugin.damageStartTime = 0
DamagePlugin.totalDamageTime = 0
DamagePlugin.inCombat = false

-- Initialize DamagePlugin
function DamagePlugin:StartTracking()
    -- Reuse the reset function to clear previous data
    self:ResetDamageMetrics()
    print("Mythic Plus Analyzer: Damage tracking started!")
end

function DamagePlugin:StopTracking()
    self:PrintDamageMetrics()
    print("Mythic Plus Analyzer: Damage tracking stopped!")
end

-- Track damage events
function DamagePlugin.events:COMBAT_LOG_EVENT_UNFILTERED(_, _, event, _, sourceGUID, _, _, _, _, _, _, spellID, spellName, _, amount)
    -- Only track damage done by the player
    if sourceGUID == UnitGUID("player") then
        if event == "SPELL_DAMAGE" and DamagePlugin.inCombat then
            DamagePlugin.totalDamage = DamagePlugin.totalDamage + amount
            -- Track damage per spell
            if not DamagePlugin.damagePerSpell[spellID] then
                DamagePlugin.damagePerSpell[spellID] = amount  -- Initialize with the first damage amount
            else
                DamagePlugin.damagePerSpell[spellID] = DamagePlugin.damagePerSpell[spellID] + amount
            end
        end
    end
end

-- Track combat time
local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", function(self, elapsed)
    if DamagePlugin.damageStartTime > 0 and DamagePlugin.inCombat then
        DamagePlugin.totalDamageTime = DamagePlugin.totalDamageTime + elapsed
    end
end)

-- Handle player entering combat
function DamagePlugin.events:PLAYER_REGEN_DISABLED()
    DamagePlugin.inCombat = true
    DamagePlugin.damageStartTime = GetTime()
    print("Mythic Plus Analyzer: Player entered combat!")
end

-- Handle player leaving combat
function DamagePlugin.events:PLAYER_REGEN_ENABLED()
    DamagePlugin.inCombat = false
    print("Mythic Plus Analyzer: Player left combat!")
end

-- Print Damage Metrics
function DamagePlugin:PrintDamageMetrics()
    print("Mythic Plus Analyzer: Damage Metrics Summary")
    print("Total Damage: " .. DamagePlugin.totalDamage)
    print("Average Damage Per Second: " .. (DamagePlugin.totalDamage / DamagePlugin.totalDamageTime))

    -- Print Damage per Spell
    for spellID, damage in pairs(DamagePlugin.damagePerSpell) do
        local spellName = GetSpellInfo(spellID) or "Unknown Spell"
        local avgDamagePerSec = damage / DamagePlugin.totalDamageTime
        print("Spell: " .. spellName .. " (ID: " .. spellID .. ") - Total Damage: " .. damage .. " | Avg Damage Per Second: " .. avgDamagePerSec)
    end
end

-- Reset damage metrics
function DamagePlugin:ResetDamageMetrics()
    DamagePlugin.totalDamage = 0
    DamagePlugin.damagePerSpell = {}
    DamagePlugin.totalDamageTime = 0
end

-- Command to print damage metrics
SLASH_DAMAGEPLUGINPRINT1 = "/mpadprint"
SlashCmdList["DAMAGEPLUGINPRINT"] = function()
    DamagePlugin:PrintDamageMetrics()
end

-- Command to reset damage metrics
SLASH_DAMAGEPLUGINRESET1 = "/mpadreset"
SlashCmdList["DAMAGEPLUGINRESET"] = function()
    DamagePlugin:ResetDamageMetrics()
    print("Mythic Plus Analyzer: Damage metrics reset.")
end

-- Register the plugin with the Core module
MythicPlusAnalyzer:RegisterPlugin(DamagePlugin)

-- Register events for combat tracking
DamagePlugin:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
DamagePlugin:RegisterEvent("PLAYER_REGEN_DISABLED")  -- Player enters combat
DamagePlugin:RegisterEvent("PLAYER_REGEN_ENABLED")   -- Player exits combat

print("Mythic Plus Analyzer: Damage Plugin loaded!")
