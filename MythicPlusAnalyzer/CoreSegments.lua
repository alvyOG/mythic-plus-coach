--
CoreSegments = {}
CoreSegments.inCombat = false
CoreSegments.combatSegments = {}

function CoreSegments:ResetCombatSegments()
    self.combatSegments = {}
    print("MPA-Core Segments: Reset segments")
end

function CoreSegments:GetCombatState()
    return self.inCombat
end

function CoreSegments:SetCombatState(combat)
    if not self.inCombat == combat then
        self.inCombat = combat
        if self.inCombat then
            table.insert(self.combatSegments, {start = GetTime()})  -- Add a new combat entry with only start time
            print("MPA-Core Segments: Player entered combat")
        else
            self.combatSegments[#self.combatSegments].stop = GetTime()
            print("MPA-Core Segments: Player left combat")
        end
    end
end

-- Command to print stored total time
SLASH_CORESEGMENTSPRINT1 = "/mpaprint"
SlashCmdList["CORESEGMENTSPRINT"] = function()
    print("MPA-Core Segments Data:")
    print("Combat Time Entries:")
    for i, entry in ipairs(CoreSegments.combatSegments) do
        if entry.stop then
            print("Fight " .. i .. ": Start - " .. entry.start .. ", Stop - " .. entry.stop .. ", Duration - " .. (entry.stop - entry.start) .. " sec")
        else
            print("Fight " .. i .. ": Start - " .. entry.start .. " (still ongoing)")
        end
    end
end