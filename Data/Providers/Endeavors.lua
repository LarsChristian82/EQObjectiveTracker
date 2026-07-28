local _, ns = ...

local Entry    = ns:GetModule("Entry")
local Registry = ns:GetModule("Registry")

local STATE, ICON = Entry.STATE, Entry.ICON

local Endeavors = {
    id       = "endeavors",
    groups   = { "endeavors" },
    -- Perks activity IDs are their own space, so no idSpace and no claim contention
    -- with the quest providers.
    priority = 40,
    tags     = {},
}

local store = Entry.NewStore({
    groupID   = "endeavors",
    icon      = { kind = ICON.NONE },
    isTracked = true,
})

local trackedIDs = {}

local function collectTracked()
    wipe(trackedIDs)
    if not ns.Has.PerksActivities then return trackedIDs end
    local data = C_PerksActivities.GetTrackedPerksActivities()
    local list = data and data.trackedIDs
    for i = 1, (list and #list or 0) do
        trackedIDs[#trackedIDs + 1] = list[i]
    end
    return trackedIDs
end

-- requirementText arrives pre-bulleted and with padded fractions, like
-- "- 1 / 15 Quests completed". Both are presentation the renderer owns, so they are
-- stripped here. EQ leaves the bullet in and prepends its own, giving a double dash.
local function cleanRequirement(text)
    text = (text or ""):gsub("^%s*%-%s*", "")
    return (text:gsub("(%d+)%s*/%s*(%d+)", "%1/%2"))
end

-- Requirements are emitted as ordinary objective lines with a completion flag, never as
-- pre-coloured strings. EQ bakes a checkmark texture and a hardcoded green escape into
-- this text, which is why its endeavors ignore the complete-colour setting.
local function fillLines(e, info)
    Entry.BeginLines(e)
    local reqs = info.requirementsList
    local done, total = 0, 0
    for i = 1, (reqs and #reqs or 0) do
        local rq = reqs[i]
        local ln = Entry.PushLine(e)
        ln.text      = cleanRequirement(rq.requirementText)
        ln.completed = rq.completed and true or false
        total = total + 1
        if ln.completed then done = done + 1 end
    end
    Entry.EndLines(e)
    return done, total
end

function Endeavors:IsAvailable()
    return ns.Has.PerksActivities and ns.Has.PerksActivityInfo
end

function Endeavors:GetEntries()
    local ids = collectTracked()

    store:Begin()
    for i = 1, #ids do
        local id   = ids[i]
        local info = C_PerksActivities.GetPerksActivityInfo(id)
        if info then
            local e = store:Acquire(id)
            e.title = info.activityName or ("Activity " .. tostring(id))
            local done, total = fillLines(e, info)
            local complete = info.completed
            if complete == nil then complete = (total > 0 and done == total) end
            e.state = complete and STATE.COMPLETE or STATE.ACTIVE
        end
    end
    return store:Finish()
end

function Endeavors:Enable(notifyDirty)
    local Events = ns:GetModule("Events")
    Events:On("PERKS_ACTIVITY_COMPLETED",              notifyDirty)
    Events:On("PERKS_ACTIVITIES_TRACKED_UPDATED",      notifyDirty)
    Events:On("PERKS_ACTIVITIES_TRACKED_LIST_CHANGED", notifyDirty)
    Events:On("PLAYER_ENTERING_WORLD",                 notifyDirty)
end

Registry:Register(Endeavors)
