local DamagePlugin = CreateFrame("Frame")  -- Create a frame for the plugin
DamagePlugin.events = {}
DamagePlugin.totalDamage = 0
DamagePlugin.spellDamage = {}
DamagePlugin.damageStartTime = 0

-- Initialize DamagePlugin
function DamagePlugin:StartTracking()
    self:ResetDamageMetrics()
    print("Mythic Plus Analyzer: Damage tracking started!")
end

function DamagePlugin:StopTracking()
    self:PrintDamageMetrics()
    print("Mythic Plus Analyzer: Damage tracking stopped!")
end

-- Track damage events
function DamagePlugin:OnCombatLogEvent()
    local _, subevent, _, sourceGUID, _, _, _, _, _ = CombatLogGetCurrentEventInfo()
    local spellID, spellName, amount
    if sourceGUID == UnitGUID("player") and subevent == "SPELL_DAMAGE" and MythicPlusAnalyzer.inCombat then
        spellID, spellName, _, amount, _, _, _, _, _, _ = select(12, CombatLogGetCurrentEventInfo())
        print("Damage Event details: ", spellName, spellID, amount)
        self.totalDamage = self.totalDamage + amount
        -- Track damage per spell
        if not self.spellDamage[spellID] then
            self.spellDamage[spellID] = amount  -- Initialize with the first damage amount
        else
            self.spellDamage[spellID] = self.spellDamage[spellID] + amount
        end
    end
end

-- Track combat time (now managed by Core.lua)
function DamagePlugin:OnCombatStart()
    self.damageStartTime = GetTime()
    print("DamagePlugin: Combat started!")
end

function DamagePlugin:OnCombatEnd()
    local combatDuration = GetTime() - self.damageStartTime
    print("DamagePlugin: Combat ended! Duration: " .. combatDuration)
end

-- Print Damage Metrics
function DamagePlugin:PrintDamageMetrics()
    print("Mythic Plus Analyzer: Damage Metrics Summary")
    print("Total Damage: " .. self.totalDamage)
    print("Average Damage Per Second: " .. (self.totalDamage / MythicPlusAnalyzer.totalCombatTime))

    -- Print Damage per Spell
    for spellID, damage in pairs(self.spellDamage) do
        local spellName = GetSpellInfo(spellID) or "Unknown Spell"
        local avgDamagePerSec = damage / MythicPlusAnalyzer.totalCombatTime
        print("Spell: " .. spellName .. " (ID: " .. spellID .. ") - Total Damage: " .. damage .. " | Avg Damage Per Second: " .. avgDamagePerSec)
    end
end

-- Reset damage metrics
function DamagePlugin:ResetDamageMetrics()
    self.totalDamage = 0
    self.spellDamage = {}
    self.damageStartTime = 0
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

print("Mythic Plus Analyzer: Damage Plugin loaded!")
