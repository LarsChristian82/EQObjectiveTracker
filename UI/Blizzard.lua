local _, ns = ...

local Blizzard = ns:RegisterModule("Blizzard", {})

-- Deliberately does NOT reparent ObjectiveTrackerFrame. In retail it hosts secure
-- quest-item buttons, and reparenting a chain containing secure children taints it.
-- Unregister plus Hide plus an OnShow re-hide is the approach Everything Quests
-- ships against 12.0.x, so it is the known-good baseline.
local function silence(frame)
    if not frame then return end
    if frame.UnregisterAllEvents then frame:UnregisterAllEvents() end
    if frame.Hide then frame:Hide() end
end

-- Deliberately NOT latched behind a "done" flag. Another addon touching the tracker can
-- re-register its modules or re-show it, and a one-shot suppress could never recover -
-- that is exactly how a second tracker reappears mid-session.
function Blizzard:Suppress()
    local tracker = ObjectiveTrackerFrame
    if not tracker then return end

    silence(tracker)

    -- The sub-modules are deliberately NOT silenced, and must not be. Unregistering their
    -- events is an insecure write to eleven Blizzard frames that feed the quest POI system,
    -- and it is the ONE thing EQOT did here that EQ does not - EQ touches only the parent.
    -- EQ has never produced the SetPassThroughButtons taint that EQOT did on 2026-07-30.
    -- Leaving them registered costs a little idle work on an invisible frame, which is what
    -- EQ has always paid. Hiding the parent hides them, and the OnShow hook below catches
    -- any attempt to re-show it.

    -- Hooking is the one part that must happen once, or every Suppress stacks another
    if not self._hooked then
        self._hooked = true
        tracker:HookScript("OnShow", function(f)
            -- Hidden unconditionally, combat included, exactly as EQ does it. EQOT used to
            -- bail out in combat believing the Hide was protected, which left Blizzard's
            -- tracker on screen beside EQOT's for the rest of every fight. EQ has hidden it
            -- this way for years without a blocked action, so the belief was wrong.
            f:Hide()
            -- Belt and braces: if a future build ever does protect it, the queued re-suppress
            -- still catches the frame when combat ends.
            if InCombatLockdown() then
                local Events = ns:GetModule("Events")
                if Events and Events.RunWhenOutOfCombat then
                    self._reSuppress = self._reSuppress or function() self:Suppress() end
                    Events:RunWhenOutOfCombat("eqot.blizzardSuppress", self._reSuppress)
                end
            end
        end)
    end
end

function Blizzard:DebugLine()
    local t = ObjectiveTrackerFrame
    if not t then return "blizzard tracker: frame absent" end
    local n = (type(t.modules) == "table") and #t.modules or 0
    return ("blizzard tracker: %s, %d modules, hook %s"):format(
        t:IsShown() and "SHOWN - suppression lost" or "hidden",
        n, self._hooked and "installed" or "missing")
end

function Blizzard:OnEnable()
    self:Suppress()

    local Events = ns:GetModule("Events")
    Events:On("PLAYER_ENTERING_WORLD", function() self:Suppress() end)
    Events:On("PLAYER_REGEN_ENABLED",  function() self:Suppress() end)
    Events:On("ADDON_LOADED", function(_, name)
        if name == "Blizzard_ObjectiveTracker" then self:Suppress() end
    end)
end
