local _, ns = ...

local Commands = ns:RegisterModule("Commands", {})

local function tracker() return ns:GetModule("Tracker") end

local handlers = {}

handlers.lock = function()
    ns:GetModule("DB"):General().lockTracker = true
    tracker():ApplyLockState()
    ns:Print("tracker locked.")
end

handlers.unlock = function()
    ns:GetModule("DB"):General().lockTracker = false
    tracker():ApplyLockState()
    ns:Print("tracker unlocked.")
end

handlers.reset = function()
    tracker():ResetPosition()
    ns:Print("position and size reset.")
end

handlers.toggle = function()
    tracker():Toggle()
end

handlers.debug = function()
    ns.DEBUG = not ns.DEBUG
    ns:Print("debug validation " .. (ns.DEBUG and "on" or "off") .. ".")
    tracker():Render()
end

handlers.status = function()
    local Registry = ns:GetModule("Registry")
    local Feed     = ns:GetModule("Feed")
    local RowPool  = ns:GetModule("RowPool")

    local Sections = ns:GetModule("Sections")

    ns:Print(("version %s"):format(ns.VERSION))

    -- Rebuild first so the counters describe the current state, not the last repaint
    ns:GetModule("Tracker"):Render()

    ns:Print("providers (emitted -> duplicate / filtered / shown):")
    for _, p in ipairs(Registry:Active()) do
        if not p._available then
            ns:Print(("  %-14s unavailable on this client"):format(p.id))
        else
            local st = Feed.stats[p.id] or {}
            ns:Print(("  %-14s %d -> dup %d, filtered %d, shown %d")
                :format(p.id, st.emitted or 0, st.duplicate or 0,
                        st.filtered or 0, st.shown or 0))
            if p.DebugLine then ns:Print("      " .. (p:DebugLine() or "")) end
        end
    end

    ns:Print("sections (in render order):")
    for _, id in ipairs(Sections:Order()) do
        local g = Feed.byGroup[id]
        ns:Print(("  %-14s %d/%d visible%s%s"):format(id,
            g and g.visibleCount or 0, g and g.totalCount or 0,
            Sections:IsHidden(id) and "  [hidden]" or "",
            Sections:IsCollapsed(id) and "  [collapsed]" or ""))
    end

    local active, free = RowPool:Count()
    ns:Print(("rows: %d active, %d pooled"):format(active, free))

    local T = tracker()
    if T and T.DebugScroll then ns:Print("scroll: " .. T:DebugScroll()) end

    local WP = ns:GetModule("WatchPersist")
    if WP and WP.DebugLine then ns:Print(WP:DebugLine()) end
end

function Commands:OnEnable()
    SLASH_EQOT1 = "/eqot"
    SLASH_EQOT2 = "/eqobjectivetracker"
    SlashCmdList["EQOT"] = function(msg)
        local cmd = strtrim((msg or ""):lower())
        local fn = handlers[cmd]
        if fn then
            fn()
        elseif cmd == "" then
            ns:GetModule("Options"):Toggle()
        else
            ns:Print("commands: lock, unlock, reset, toggle, status, debug")
        end
    end
end
