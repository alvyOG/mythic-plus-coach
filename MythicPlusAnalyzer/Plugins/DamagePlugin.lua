local DamagePlugin = {}
DamagePlugin.events = {}

-- Metrics storage
DamagePlugin.data = {
    totalDamage = 0,  -- Total cumulative damage
    totalCombatTime = 0,  -- Total time in combat
    spellDamage = {},  -- Damage per spell
    spellDPS = {},  -- Average DPS per spell
    interruptCounts = {},  -- Interrupt count per spellID
}

-- Function to print the damage and interrupt stats
local function PrintDamageMetrics()
    -- Print damage data for each spell
    print("Damage Plugin: Spell Damage Data:")
    for spellID, totalDamage in pairs(DamagePlugin.data.spellDamage) do
        local spellName = GetSpellInfo(spellID)
        if spellName then
            local dps = (DamagePlugin.data.totalCombatTime > 0) and (totalDamage / DamagePlugin.data.totalCombatTime) or 0
            print(string.format("Spell: %s (ID: %d) - Total Damage: %d, DPS: %.2f", spellName, spellID, totalDamage, dps))
        end
    end

    -- Print interrupt counts per spell
    print("Interrupts Per Spell:")
    for spellID, count in pairs(DamagePlugin.data.interruptCounts) do
        local spellName = GetSpellInfo(spellID)
        if spellName then
            print(string.format("Spell: %s (ID: %d) - Interrupt Count: %d", spellName, spellID, count))
        end
    end
end

-- Function to reset all metrics to their default values
local function ResetDamageMetrics()
    DamagePlugin.data.totalDamage = 0
    DamagePlugin.data.totalCombatTime = 0
    DamagePlugin.data.spellDamage = {}
    DamagePlugin.data.spellDPS = {}
    DamagePlugin.data.interruptCounts = {}

    print("Damage Plugin: Metrics reset to default values.")
end

-- Start tracking function
function DamagePlugin:StartTracking()
    -- Reuse the reset function to clear previous data when starting tracking
    ResetDamageMetrics()
end

-- Stop tracking function
function DamagePlugin:StopTracking()
    -- Print stats when tracking stops (using the reusable function)
    print("Damage Plugin: Tracking stopped.")
    PrintDamageMetrics()
end

-- Track total damage and damage per spell
function DamagePlugin.events:COMBAT_LOG_EVENT_UNFILTERED(_, _, event, _, sourceGUID, _, _, _, _, _, _, spellID, _, amount)
    -- Only track damage for the player
    if sourceGUID == UnitGUID("player") then
        if event == "SPELL_DAMAGE" or event == "SWING_DAMAGE" then
            -- Track total damage
            DamagePlugin.data.totalDamage = DamagePlugin.data.totalDamage + amount

            -- Track damage per spell
            if not DamagePlugin.data.spellDamage[spellID] then
                DamagePlugin.data.spellDamage[spellID] = 0
            end
            DamagePlugin.data.spellDamage[spellID] = DamagePlugin.data.spellDamage[spellID] + amount
        end

        -- Track interrupt usage per spellID
        if event == "SPELL_INTERRUPT" then
            if not DamagePlugin.data.interruptCounts[spellID] then
                DamagePlugin.data.interruptCounts[spellID] = 0
            end
            DamagePlugin.data.interruptCounts[spellID] = DamagePlugin.data.interruptCounts[spellID] + 1
        end
    end
end

-- Track combat time
local combatStartTime = nil
local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", function(self, elapsed)
    if UnitAffectingCombat("player") then
        if not combatStartTime then
            combatStartTime = GetTime()
        end
    elseif combatStartTime then
        DamagePlugin.data.totalCombatTime = DamagePlugin.data.totalCombatTime + (GetTime() - combatStartTime)
        combatStartTime = nil
    end
end)

-- Calculate average DPS per spell (after combat)
function DamagePlugin:CalculateSpellDPS()
    for spellID, totalDamage in pairs(self.data.spellDamage) do
        if self.data.totalCombatTime > 0 then
            self.data.spellDPS[spellID] = totalDamage / self.data.totalCombatTime
        else
            self.data.spellDPS[spellID] = 0
        end
    end
end

-- Command to print the damage for each spellID
SLASH_DAMAGEPRINT1 = "/mpadprint"
SlashCmdList["DAMAGEPRINT"] = function()
    -- Use the reusable print function
    PrintDamageMetrics()
end

-- Command to reset all metrics to their default values
SLASH_MPARESET1 = "/mpdareset"
SlashCmdList["MPARESET"] = function()
    -- Call the local reset function
    ResetDamageMetrics()
end

-- Register the plugin
MythicPlusAnalyzer:RegisterPlugin(DamagePlugin)

-- Event registration
DamagePlugin:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
