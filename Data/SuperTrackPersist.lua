local _, ns = ...

local SuperTrackPersist = ns:RegisterModule("SuperTrackPersist", {})

local CLEAR_DELAY = 0.5

local function shouldRestore()
    local gen = ns:GetModule("DB"):General()
    return (gen and gen.restoreSuperTrackOnLogin) == true
end

function SuperTrackPersist:OnEnable()
    if not ns.Has.SuperTrack then return end
    local Events = ns:GetModule("Events")

    Events:On("PLAYER_ENTERING_WORLD", function(_, isInitialLogin)
        -- Only a fresh login. A reload or a zone change must leave the current
        -- super-track alone, or every loading screen would drop the player's arrow.
        if not isInitialLogin then return end
        if shouldRestore() then return end
        C_Timer.After(CLEAR_DELAY, function()
            C_SuperTrack.SetSuperTrackedQuestID(0)
        end)
    end)
end
