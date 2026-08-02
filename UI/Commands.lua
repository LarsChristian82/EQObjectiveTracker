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

    -- Rebuild first so the counters describe the current state, not the last repaint.
    -- Render skips entirely while the tracker is hidden, so the feed is built directly too
    -- or a rule-hidden tracker would report whatever the last paint happened to leave.
    ns:GetModule("Tracker"):Render()
    -- Render owns this refresh normally, but it returns early while hidden, and Filter reads
    -- the suppression set - so refresh here too or the direct build below reports stale rows.
    ns:GetModule("AutoQuestPopups"):Refresh()
    Feed:Build()

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
        ns:Print(("  %-14s %d/%d visible%s%s%s"):format(id,
            g and g.visibleCount or 0, g and g.totalCount or 0,
            Sections:IsVirtual(id) and "  [virtual]" or "",
            Sections:IsHidden(id) and "  [hidden]" or "",
            Sections:IsCollapsed(id) and "  [collapsed]" or ""))
    end

    local active, free = RowPool:Count()
    ns:Print(("rows: %d active, %d pooled"):format(active, free))

    local T = tracker()
    if T and T.DebugScroll then ns:Print("scroll: " .. T:DebugScroll()) end

    local IB = ns:GetModule("ItemButtons")
    if IB and IB.DebugLine then ns:Print(IB:DebugLine()) end

    local MO = ns:GetModule("ManualOrder")
    if MO and MO.DebugLine then ns:Print(MO:DebugLine()) end

    local DIST = ns:GetModule("Distance")
    if DIST and DIST.DebugLine then ns:Print(DIST:DebugLine()) end

    local MIG = ns:GetModule("Migrate")
    if MIG and MIG.DebugLine then ns:Print(MIG:DebugLine()) end

    local AQP = ns:GetModule("AutoQuestPopups")
    if AQP and AQP.DebugLine then ns:Print(AQP:DebugLine()) end

    local WP = ns:GetModule("WatchPersist")
    if WP and WP.DebugLine then ns:Print(WP:DebugLine()) end

    local BZ = ns:GetModule("Blizzard")
    if BZ and BZ.DebugLine then ns:Print(BZ:DebugLine()) end

    local VIS = ns:GetModule("Visibility")
    if VIS and VIS.DebugLine then ns:Print(VIS:DebugLine()) end

    local ZP = ns:GetModule("ZoneProgress")
    if ZP and ZP.DebugLines then
        for _, line in ipairs(ZP:DebugLines()) do ns:Print(line) end
    end

    local ZB = ns:GetModule("ZoneProgressBar")
    if ZB and ZB.DebugLine then ns:Print(ZB:DebugLine()) end

    local BH = ns:GetModule("ScenarioBonusHUD")
    if BH and BH.DebugLine then ns:Print(BH:DebugLine()) end
end

-- Bisection aid: skip a subsystem's OnEnable for a session so a fault can be narrowed to one
-- module. Persisted per account so it survives the reload it needs to take effect.
local function moduleCmd(cmd, rest)
    local db = ns.db
    if not db then ns:Print("database not ready."); return end
    db.global.disabledModules = db.global.disabledModules or {}
    local off = db.global.disabledModules
    local list = ns:SkippableModules()

    db.global.disabledProviders = db.global.disabledProviders or {}
    local offP = db.global.disabledProviders
    local Registry = ns:GetModule("Registry")

    if cmd == "modules" then
        ns:Print(("skippable modules (safe mode %s, /reload to apply):")
            :format(db.global.safeMode and "|cffff5555ON|r" or "off"))
        for _, name in ipairs(list) do
            ns:Print(("  %-18s %s"):format(name, off[name] and "|cffff5555disabled|r" or "enabled"))
        end
        ns:Print("providers:")
        for _, p in ipairs(Registry:Active()) do
            ns:Print(("  %-18s %s"):format(p.id, offP[p.id] and "|cffff5555disabled|r" or "enabled"))
        end
        return
    end

    local want = strtrim(rest or "")
    if want == "" then ns:Print("usage: /eqot " .. cmd .. " <module>  (see /eqot modules)"); return end

    -- "all" is the first step of a bisection: everything optional off, including the two
    -- subsystems that have no OnEnable and are driven from the render pass instead.
    if want:lower() == "all" then
        if cmd == "disable" then
            db.global.safeMode = true
            ns:Print("|cffff5555safe mode ON|r - every optional module, every provider, quest item buttons and quest popups are off. /reload to apply.")
        else
            db.global.safeMode = nil
            wipe(off)
            wipe(offP)
            ns:Print("safe mode off, all modules and providers re-enabled. /reload to apply.")
        end
        return
    end

    for _, name in ipairs(list) do
        if name:lower() == want:lower() then
            off[name] = (cmd == "disable") or nil
            ns:Print(("%s is now %s. /reload to apply."):format(name,
                off[name] and "|cffff5555disabled|r" or "enabled"))
            return
        end
    end

    for _, p in ipairs(Registry:Active()) do
        if p.id:lower() == want:lower() then
            offP[p.id] = (cmd == "disable") or nil
            ns:Print(("provider %s is now %s. /reload to apply."):format(p.id,
                offP[p.id] and "|cffff5555disabled|r" or "enabled"))
            return
        end
    end

    ns:Print(("no module or provider %q. see /eqot modules"):format(want))
end

-- The automatic import only ever fires on a first run, so this is the only way to exercise
-- it without deleting the saved variables, and the only way back for someone who moved to
-- EQOT before installing it alongside EQ.
local function importEQ()
    local Migrate = ns:GetModule("Migrate")
    if not (Migrate and Migrate.HasEQConfig and Migrate:HasEQConfig()) then
        ns:Print("no Everything Quests configuration found to import.")
        return
    end

    local Dialog = ns:GetModule("Dialog")
    if not Dialog then return end
    Dialog:Show({
        title   = "Import from Everything Quests",
        text    = "Reset this profile to defaults and replace it with your Everything Quests tracker settings?\n\nThis cannot be undone. Make a new profile first if you want to keep the current one.",
        button1 = "Import",
        button2 = "Cancel",
        onAccept = function()
            -- Reset first, because the import copies only the keys EQ actually saved. AceDB
            -- strips defaults at logout, so what survives there is the user's deviation, and
            -- laying that over a tuned profile would leave a hybrid of the two. Resetting
            -- also drops positionInScreenUnits, so the reload converts EQ's frame-space
            -- offsets exactly as it does on a first run.
            if ns.db and ns.db.ResetProfile then ns.db:ResetProfile() end
            local n = Migrate:ImportFromEQ(ns.db)
            ns:Print(("imported %d settings from Everything Quests."):format(n or 0))
            ReloadUI()
        end,
    })
end

function Commands:OnEnable()
    SLASH_EQOT1 = "/eqot"
    SLASH_EQOT2 = "/eqobjectivetracker"
    SlashCmdList["EQOT"] = function(msg)
        local raw = strtrim(msg or "")
        local cmd, rest = raw:match("^(%S*)%s*(.-)$")
        cmd = (cmd or ""):lower()
        local fn = handlers[cmd]
        if cmd == "disable" or cmd == "enable" or cmd == "modules" then
            moduleCmd(cmd, rest)
        elseif cmd == "bonushud" then
            local BH = ns:GetModule("ScenarioBonusHUD")
            if strtrim(rest or ""):lower() == "test" then BH:ToggleTest() else BH:Dump() end
        elseif cmd == "importeq" then
            importEQ()
        elseif fn then
            fn()
        elseif cmd == "" then
            ns:GetModule("Options"):Toggle()
        else
            ns:Print("commands: lock, unlock, reset, toggle, status, debug, bonushud [test], importeq, modules, disable <m>, enable <m>")
        end
    end
end
