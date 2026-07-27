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

function Blizzard:Suppress()
    local tracker = ObjectiveTrackerFrame
    if not tracker or self._done then return end

    silence(tracker)

    -- The Midnight tracker is a container - each sub-module registers its own events,
    -- so silencing only the parent leaves them updating an invisible frame.
    if type(tracker.modules) == "table" then
        for _, m in ipairs(tracker.modules) do silence(m) end
    end

    tracker:HookScript("OnShow", function(f)
        if not InCombatLockdown() then f:Hide() end
    end)

    self._done = true
end

function Blizzard:OnEnable()
    self:Suppress()

    local Events = ns:GetModule("Events")
    Events:On("PLAYER_ENTERING_WORLD", function() self:Suppress() end)
    Events:On("ADDON_LOADED", function(_, name)
        if name == "Blizzard_ObjectiveTracker" then self:Suppress() end
    end)
end
