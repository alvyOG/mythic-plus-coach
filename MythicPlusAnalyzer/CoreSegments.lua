-- Mythic Plus Analyzer Addon
-- Author: alvy023
-- File: CoreSegments.lua
-- Description: Core segments functionality for the Mythic Plus Analyzer addon.
-- License:
-- For more information, visit the project repository.

CoreSegments = {}
CoreSegments.inCombat = false
CoreSegments.combatSegments = {}

--- Description: Reset combat segments.
--- @param:
--- @return:
function CoreSegments:ResetCombatSegments()
    self.combatSegments = {}
    print("MPA-Core Segments: Reset segments")
end

--- Description: Get the current combat state.
--- @param:
--- @return: The current combat state.
function CoreSegments:GetCombatState()
    return self.inCombat
end

--- Description: Set the combat state.
--- @param: combat - The new combat state.
--- @return:
function CoreSegments:SetCombatState(combat)
    if not self.inCombat == combat then
        self.inCombat = combat
        if self.inCombat then
            table.insert(self.combatSegments, {start = GetTime()})
            print("MPA-Core Segments: Player entered combat")
        else
            self.combatSegments[#self.combatSegments].stop = GetTime()
            print("MPA-Core Segments: Player left combat")
        end
    end
end

--- Description: Print core segments data.
--- @param:
--- @return:
function CoreSegments:PrintCoreSegments()
    print("MPA-Core Segments Data:")
    print("Combat Time Entries:")
    for i, entry in ipairs(self.combatSegments) do
        if entry.stop then
            print("Fight " .. i .. ": Start - " .. entry.start .. ", Stop - " ..
                    entry.stop .. ", Duration - " .. (entry.stop - entry.start) .. " sec")
        else
            print("Fight " .. i .. ": Start - " .. entry.start .. " (still ongoing)")
        end
    end
end

-- Register the PrintCoreSegments method as a chat command
MythicPlusAnalyzer:RegisterChatCommand("mpa-print", function()
    CoreSegments:PrintCoreSegments()
end)