local HealingPlugin = CreateFrame("Frame")  -- Create a frame for the plugin
HealingPlugin.events = {}
HealingPlugin.totalHealing = 0
HealingPlugin.spellHealing = {}
HealingPlugin.healingStartTime = 0

-- Initialize HealingPlugin
function HealingPlugin:StartTracking()
    self:ResetHealingMetrics()
    print("Mythic Plus Analyzer: Healing tracking started!")
end

function HealingPlugin:StopTracking()
    self:PrintHealingMetrics()
    print("Mythic Plus Analyzer: Healing tracking stopped!")
end

-- Track healing events
function HealingPlugin:OnCombatLogEvent()
    local _, subevent, _, sourceGUID, _, _, _, _, _ = CombatLogGetCurrentEventInfo()
    local spellID, spellName, amount
    if sourceGUID == UnitGUID("player") and subevent == "SPELL_HEAL" and MythicPlusAnalyzer.inCombat then
        spellID, spellName, _, amount, _, _, _, _, _, _ = select(12, CombatLogGetCurrentEventInfo())
        print("Healing Event details: ", spellName, spellID, amount)
        self.totalHealing = self.totalHealing + amount
        -- Track healing per spell
        if not self.spellHealing[spellID] then
            self.spellHealing[spellID] = amount  -- Initialize with the first healing amount
        else
            self.spellHealing[spellID] = self.spellHealing[spellID] + amount
        end
    end
end

-- Track combat time (now managed by Core.lua)
function HealingPlugin:OnCombatStart()
    self.healingStartTime = GetTime()
    print("HealingPlugin: Combat started!")
end

function HealingPlugin:OnCombatEnd()
    local healingDuration = GetTime() - self.healingStartTime
    print("HealingPlugin: Combat ended! Healing Duration: " .. healingDuration)
end

-- Print Healing Metrics
function HealingPlugin:PrintHealingMetrics()
    print("Mythic Plus Analyzer: Healing Metrics Summary")
    print("Total Healing: " .. self.totalHealing)
    print("Average Healing Per Second: " .. (self.totalHealing / MythicPlusAnalyzer.totalCombatTime))

    -- Print Healing per Spell
    for spellID, healing in pairs(self.spellHealing) do
        local spellName = GetSpellInfo(spellID) or "Unknown Spell"
        local avgHealingPerSec = healing / MythicPlusAnalyzer.totalCombatTime
        print("Spell: " .. spellName .. " (ID: " .. spellID .. ") - Total Healing: " .. healing .. " | Avg Healing Per Second: " .. avgHealingPerSec)
    end
end

-- Reset healing metrics
function HealingPlugin:ResetHealingMetrics()
    self.totalHealing = 0
    self.spellHealing = {}
    self.healingStartTime = 0
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

print("Mythic Plus Analyzer: Healing Plugin loaded!")
