local HealingPlugin = {}
HealingPlugin.totalHealing = 0
HealingPlugin.healingPerSpell = {}
HealingPlugin.healingStartTime = 0
HealingPlugin.totalHealingTime = 0

-- Initialize HealingPlugin
function HealingPlugin:StartTracking()
    -- Reuse the reset function to clear previous data
    self:ResetHealingMetrics()
    self.healingStartTime = GetTime()
    self.totalHealingTime = 0
    print("Mythic Plus Analyzer: Healing tracking started!")
end

function HealingPlugin:StopTracking()
    self:PrintHealingMetrics()
    print("Mythic Plus Analyzer: Healing tracking stopped!")
end

-- Track healing events
function HealingPlugin:OnCombatLogEvent(_, _, event, _, sourceGUID, _, _, _, _, _, _, spellID, spellName, _, amount)
    -- Only track healing done by the player
    if sourceGUID == UnitGUID("player") then
        if event == "SPELL_HEAL" then
            self.totalHealing = self.totalHealing + amount
            -- Track healing per spell
            if not self.healingPerSpell[spellID] then
                self.healingPerSpell[spellID] = 0
            end
            self.healingPerSpell[spellID] = self.healingPerSpell[spellID] + amount
        end
    end
end

-- Update healing metrics over time
local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", function(self, elapsed)
    if HealingPlugin.healingStartTime > 0 then
        HealingPlugin.totalHealingTime = HealingPlugin.totalHealingTime + elapsed
    end
end)

-- Print Healing Metrics
function HealingPlugin:PrintHealingMetrics()
    print("Mythic Plus Analyzer: Healing Metrics Summary")
    print("Total Healing: " .. self.totalHealing)
    print("Average Healing Per Second: " .. (self.totalHealing / self.totalHealingTime))

    -- Print Healing per Spell
    for spellID, healing in pairs(self.healingPerSpell) do
        local spellName = GetSpellInfo(spellID) or "Unknown Spell"
        local avgHealingPerSec = healing / self.totalHealingTime
        print("Spell: " .. spellName .. " (ID: " .. spellID .. ") - Total Healing: " .. healing .. " | Avg Healing Per Second: " .. avgHealingPerSec)
    end
end

-- Reset healing metrics
function HealingPlugin:ResetHealingMetrics()
    self.totalHealing = 0
    self.healingPerSpell = {}
    self.totalHealingTime = 0
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
