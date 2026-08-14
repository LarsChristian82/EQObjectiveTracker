local _, ns = ...

local Entry      = ns:GetModule("Entry")
local Registry   = ns:GetModule("Registry")
local QuestItems = ns:GetModule("QuestItems")
local Focus      = ns:GetModule("Focus")

local STATE, LINE, ICON = Entry.STATE, Entry.LINE, Entry.ICON

-- The Classic quest log is index driven where retail is questID driven, and it carries no
-- super-track and no campaign at all. Listed only in the Classic TOCs, so this file and
-- Data/Providers/Quests.lua are never both loaded and both may claim the id "quests".
local Quests = {
    id       = "quests",
    groups   = { "quests" },
    priority = 10,
    idSpace  = "quest",
    tags     = { "daily", "weekly", "dungeon", "raid" },
    filterCategories = true,
}

-- GetQuestLogTitle returns the full modern tuple on 1.15.9 and 2.5.6, measured on both:
-- 1 title, 2 level, 4 isHeader, 6 isComplete, 7 frequency, 8 questID.
local T_TITLE, T_LEVEL, T_HEADER, T_COMPLETE, T_FREQ, T_ID = 1, 2, 4, 6, 7, 8

-- Ceiling for the quest log walk. The real cap is far lower, so this only has to be safely
-- above it.
local MAX_LOG_INDEX = 75

-- Slot 7 of the flat GetQuestLogTitle carries the LEGACY numbering, 1 default / 2 daily /
-- 3 weekly, NOT Enum.QuestFrequency whose Daily is 1. Measured on 1.15.9: an ordinary
-- Elwynn quest reports 7 = 1, which means "default" only under the legacy scheme. Reading
-- the enum here, which is present on both Classic clients, tagged every quest as daily and
-- emptied the tracker whenever the Daily filter was unticked.
local DAILY_FREQ, WEEKLY_FREQ = 2, 3

local TAG_DUNGEON = (Enum and Enum.QuestTag and Enum.QuestTag.Dungeon) or 81
local TAG_RAID    = (Enum and Enum.QuestTag and Enum.QuestTag.Raid)    or 62
local TAG_RAID10  = (Enum and Enum.QuestTag and Enum.QuestTag.Raid10)  or 85
local TAG_RAID25  = (Enum and Enum.QuestTag and Enum.QuestTag.Raid25)  or 88

local store = Entry.NewStore({
    groupID = "quests",
    icon    = { kind = ICON.QUESTPOI },
    tags    = {},
})

local firstSeen = {}

local dirtyAll        = true
local dirtyObjectives = false
local primed          = false
local baselined       = false

-- Stamped so DebugLine can separate a stale cache from isWatched answering differently
-- inside the GetQuestLogTitle walk than outside it. Status read 0 cached against 9 live.
local lastFullAt, lastDynAt, lastFullWatched = 0, 0, 0

-- File scoped rather than an upvalue of Enable, because scheduleWatchRecheck is declared above
-- it and needs the same notifier.
local notifyDirty

local WATCH_RECHECK_DELAY = 1
local watchRecheckPending = false

-- Measured on TBC 2.5.6 at login: the rebuild walk saw 0 of 19 quests watched while a read
-- seconds later saw 17. Every quest is watched by default on 1.15.9 and 2.5.6, so zero across a
-- non-empty log is not a state the player can reach, which makes it a safe trigger. With Show
-- only tracked quests on, which is the default, that first pass rejected the whole log and
-- nothing asked again. One delayed re-read, and it does not matter which of the two candidate
-- causes it was.
local function scheduleWatchRecheck()
    if watchRecheckPending then return end
    watchRecheckPending = true
    C_Timer.After(WATCH_RECHECK_DELAY, function()
        watchRecheckPending = false
        dirtyAll = true
        if notifyDirty then notifyDirty() end
    end)
end

local tagIDCache = {}

local function logIndex(id)
    if type(GetQuestLogIndexByID) ~= "function" then return nil end
    local i = GetQuestLogIndexByID(id)
    if not i or i == 0 then return nil end
    return i
end

-- GetQuestTagInfo is a plain global here rather than a C_QuestLog method, and its return
-- can be a table or a bare id, so both shapes are accepted rather than assumed.
local function getTagID(id)
    local cached = tagIDCache[id]
    if cached then return cached end
    if type(GetQuestTagInfo) ~= "function" then return nil end
    local got = GetQuestTagInfo(id)
    local tagID = (type(got) == "table" and got.tagID) or (type(got) == "number" and got) or nil
    if tagID then tagIDCache[id] = tagID end
    return tagID
end

-- isComplete arrives nil while in progress, 1 when complete and -1 when failed.
local function questState(isComplete)
    if isComplete == -1 then return STATE.FAILED end
    if isComplete and isComplete ~= 0 then return STATE.COMPLETE end
    return STATE.ACTIVE
end

-- nil, never false, when there is no index to read. Filter tests isTracked == false explicitly,
-- so "cannot tell" fails open there the way IsCurrentZone's nil already does.
local function isWatched(id)
    if type(IsQuestWatched) ~= "function" then return nil end
    local i = logIndex(id)
    if not i then return nil end
    return IsQuestWatched(i) and true or false
end

local function setWatched(id, watch)
    local i = logIndex(id)
    if not i then return end
    if watch then
        if type(AddQuestWatch) == "function" then AddQuestWatch(i) end
    elseif type(RemoveQuestWatch) == "function" then
        RemoveQuestWatch(i)
    end
end

local function fillLines(e, id, index)
    Entry.BeginLines(e)

    local objs = ns.Has.QuestObjectives and C_QuestLog.GetQuestObjectives(id) or nil
    local n    = objs and #objs or 0

    if n > 0 then
        for i = 1, n do
            local o  = objs[i]
            local ln = Entry.PushLine(e)
            ln.text      = o.text or ""
            ln.completed = o.finished and true or false
            ln.current   = o.numFulfilled
            ln.required  = o.numRequired
            if o.type == "progressbar" then ln.kind = LINE.PROGRESSBAR end
        end
    elseif index and type(GetNumQuestLeaderBoards) == "function"
           and type(GetQuestLogLeaderBoard) == "function" then
        -- Fallback for a quest whose structured objectives have not streamed in. The text
        -- already carries its own "0/1" here, so no current/required is set.
        for i = 1, (GetNumQuestLeaderBoards(index) or 0) do
            local text, _, finished = GetQuestLogLeaderBoard(i, index)
            if text and text ~= "" then
                local ln = Entry.PushLine(e)
                ln.text      = text
                ln.completed = finished and true or false
            end
        end
    end

    Entry.EndLines(e)
end

local function fillTags(e, id, frequency)
    local tags = e.tags
    wipe(tags)
    e.frequency = frequency or 0
    if frequency == DAILY_FREQ  then tags.daily  = true end
    if frequency == WEEKLY_FREQ then tags.weekly = true end
    local tagID = getTagID(id)
    if tagID == TAG_DUNGEON then
        tags.dungeon = true
    elseif tagID == TAG_RAID or tagID == TAG_RAID10 or tagID == TAG_RAID25 then
        tags.raid = true
    end
end

-- Quest-log headers ARE zone names on Classic, unlike retail where they are campaign
-- groupings, so comparing the header to the player's zone is correct here.
function Quests:IsCurrentZone(entry)
    if type(GetZoneText) ~= "function" then return nil end
    local zone = GetZoneText()
    if not zone or zone == "" then return nil end
    return entry.zone == zone
end

local function fullRebuild()
    local currentHeader
    local watchedDuringWalk = 0
    store:Begin()

    -- Bounded by a ceiling and stopped at the first nil title, NOT by GetNumQuestLogEntries.
    -- That count returns only the VISIBLE rows, so it drops to the header count when the
    -- player collapses their quest log - while the quests stay perfectly addressable, just
    -- reordered after the headers. Measured on 1.15.9 with all three headers collapsed:
    -- entries=3, yet indices 4 through 13 still returned all ten quests. Walking to that
    -- count saw three headers and no quests, and Store:Finish then pruned every entry, so
    -- one collapsed header plus any quest event emptied the tracker and re-flagged the lot
    -- as NEW on expand.
    for i = 1, MAX_LOG_INDEX do
        local t = { GetQuestLogTitle(i) }
        local title = t[T_TITLE]
        if not title then break end
        if t[T_HEADER] then
            currentHeader = title
        else
            local id = t[T_ID]
            if id and id ~= 0 then
                local fs = firstSeen[id]
                if not fs then
                    fs = baselined and time() or 0
                    firstSeen[id] = fs
                end

                local e = store:Acquire(id)
                e.title     = title
                e.subtitle  = currentHeader
                e.zone      = currentHeader
                e.level     = t[T_LEVEL]
                e.addedAt   = fs
                e.state     = questState(t[T_COMPLETE])
                e.isTracked = isWatched(id)
                if e.isTracked then watchedDuringWalk = watchedDuringWalk + 1 end
                e.icon.classification = nil
                e.hasItem   = QuestItems:Has(id)
                fillTags(e, id, t[T_FREQ])
                e.groupID = "quests"
                fillLines(e, id, i)
            end
        end
    end

    store:Finish()

    for id in pairs(firstSeen) do
        if not store:Get(id) then
            firstSeen[id], tagIDCache[id] = nil, nil
        end
    end

    if next(store:Out()) ~= nil then
        primed    = true
        baselined = true
    end
    lastFullAt, lastFullWatched = time(), watchedDuringWalk
    dirtyAll        = false
    dirtyObjectives = false

    if watchedDuringWalk == 0 and next(store:Out()) ~= nil then
        scheduleWatchRecheck()
    end
end

local function refreshDynamic()
    for id, e in store:Each() do
        local i = logIndex(id)
        e.isTracked = isWatched(id)
        e.hasItem   = QuestItems:Has(id)
        if i then
            local t = { GetQuestLogTitle(i) }
            e.state = questState(t[T_COMPLETE])
        end
        fillLines(e, id, i)
    end
    lastDynAt = time()
    dirtyObjectives = false
end

function Quests:IsAvailable()
    return type(GetNumQuestLogEntries) == "function"
       and type(GetQuestLogTitle) == "function"
end

-- Watch state is re-read here, outside any GetQuestLogTitle walk and on every call, because
-- the copy written during fullRebuild's walk came back false for every quest on 1.15.9 while
-- a direct read moments later returned true for nine of ten. Two causes fit that - the walk
-- context, or a cache nothing re-dirtied after login - and they were never separated. This
-- is correct under both. `saw N watched` in DebugLine still reports the walk-time answer, so
-- the next rebuild that happens with quests watched will say which it was.
local function syncWatched()
    for id, e in store:Each() do
        e.isTracked = isWatched(id)
    end
end

-- Total rather than written during the walk, so a focus change needs no rebuild and a pooled
-- entry can never keep a previous quest's focus. This client has no super-track, so the answer
-- comes from Data/Focus.lua rather than from the game.
local function syncFocus()
    local providerID, focusedID = Focus:Get()
    local mine = providerID == Quests.id
    for id, e in store:Each() do
        e.isFocused = mine and focusedID == id
    end
end

function Quests:GetEntries()
    if dirtyAll then
        fullRebuild()
    elseif dirtyObjectives then
        refreshDynamic()
    end
    syncWatched()
    syncFocus()
    return store:Out()
end

-- The cached count is what the rows were drawn from. The live count re-reads the API now.
-- They are reported separately because status once said 0 watched a minute after a direct
-- IsQuestWatched read on the same quests returned true, and a single number cannot tell a
-- stale cache from a watch list that really did empty.
function Quests:DebugLine()
    local n, cached, live = 0, 0, 0
    local sample = {}
    for id, e in store:Each() do
        n = n + 1
        local now = isWatched(id)
        if e.isTracked then cached = cached + 1 end
        if now then live = live + 1 end
        if #sample < 6 then
            sample[#sample + 1] = ("%s:%d/%d"):format(id, e.isTracked and 1 or 0, now and 1 or 0)
        end
    end
    -- Assigned to locals first: select(2, ...) on a one-value return yields ZERO values and
    -- tostring() with no argument raises, which would truncate the rest of /eqot status.
    local numEntries, numQuests
    if type(GetNumQuestLogEntries) == "function" then
        numEntries, numQuests = GetNumQuestLogEntries()
    end

    local now = time()
    return ("quests: classic quest log, %d entries (%d cached watched, %d live) | log %s/%s | zone %s | rebuild %ds ago saw %d watched, refresh %ds ago | id:cached/live %s"):format(
        n, cached, live,
        tostring(numQuests),
        tostring(numEntries),
        tostring(GetZoneText and GetZoneText()),
        lastFullAt > 0 and (now - lastFullAt) or -1, lastFullWatched,
        lastDynAt > 0 and (now - lastDynAt) or -1,
        table.concat(sample, " "))
end

-- The icon half of a left-click lands here and the title half goes to OnEntryOpenLog, which is
-- retail's layout with focus standing in for super-track. With Split quest click OFF the whole
-- row lands here, so focus is then the only left-click and the quest log is reached from the
-- row menu, exactly as it is on retail.
function Quests:OnEntryClick(entry, button)
    if button == "RightButton" then
        setWatched(entry.id, false)
        return
    end
    Focus:Toggle(self.id, entry.id)
end

function Quests:OnEntryOpenLog(entry)
    local i = logIndex(entry.id)
    if i and type(SelectQuestLogEntry) == "function" then SelectQuestLogEntry(i) end
    if type(ToggleQuestLog) == "function" then ToggleQuestLog() end
end

local menuOut = {}
local pinShim = {}

-- Still shorter than the retail menu. Pop out and Abandon both need a Blizzard popup or detail
-- frame, and Data/ may not drive one - the two calls that already do in Quests.lua are recorded
-- debt, not a precedent to copy. Named indirectly so the layering grep's output stays a known
-- set. Focus is here at retail's own order 30 now that this client has a focus concept.
function Quests:GetEntryMenu(entry)
    local Filter = ns:GetModule("Filter")
    local id = entry.id

    for i = #menuOut, 1, -1 do menuOut[i] = nil end

    menuOut[#menuOut + 1] = { kind = "title", text = entry.title, order = 0 }
    menuOut[#menuOut + 1] = { id = Filter:IsPinned(entry) and "unpin" or "pin", order = 10 }
    menuOut[#menuOut + 1] = { id = isWatched(id) and "untrack" or "track",      order = 20 }
    menuOut[#menuOut + 1] = { id = Focus:Is(self.id, id) and "unfocus" or "focus", order = 30 }
    menuOut[#menuOut + 1] = { id = "openlog", order = 40 }
    menuOut[#menuOut + 1] = { id = "wowhead", order = 60 }
    return menuOut
end

function Quests:OnEntryMenuSelect(entryID, itemID)
    if itemID == "pin" or itemID == "unpin" then
        pinShim.id, pinShim.providerID = entryID, self.id
        ns:GetModule("Filter"):SetPinned(pinShim, itemID == "pin")
    elseif itemID == "track" then
        setWatched(entryID, true)
    elseif itemID == "untrack" then
        setWatched(entryID, false)
    elseif itemID == "focus" then
        Focus:Set(self.id, entryID)
    elseif itemID == "unfocus" then
        Focus:Set(nil, nil)
    elseif itemID == "openlog" then
        self:OnEntryOpenLog({ id = entryID })
    end
    if self._notifyDirty then self._notifyDirty() end
end

function Quests:Enable(notify)
    local Events = ns:GetModule("Events")

    notifyDirty = notify

    -- Focus answers to no game event, so the repaint has to come from the store itself.
    Focus:OnDirty(notifyDirty)

    local function markAll()
        dirtyAll = true
        notifyDirty()
    end

    -- A focused quest can leave the log by being turned in or abandoned, and nothing else would
    -- ever announce the clear, so a listener's arrow would keep pointing at a quest the player
    -- no longer has. Checked against the log rather than the store because this runs before the
    -- rebuild. Focus:Set notifies through OnDirty, so the plain notify is the other branch only.
    local function markRemoved()
        dirtyAll = true
        local providerID, focusedID = Focus:Get()
        if providerID == Quests.id and focusedID and not logIndex(focusedID) then
            Focus:Set(nil, nil)
        else
            notifyDirty()
        end
    end
    local function markDynamic()
        if not primed then dirtyAll = true else dirtyObjectives = true end
        notifyDirty()
    end

    Events:On("QUEST_ACCEPTED",          markAll)
    Events:On("QUEST_REMOVED",           markRemoved)
    Events:On("QUEST_TURNED_IN",         markRemoved)
    Events:On("PLAYER_ENTERING_WORLD",   markAll)
    Events:On("QUEST_LOG_UPDATE",        markDynamic)
    Events:On("UNIT_QUEST_LOG_CHANGED",  markDynamic)
    Events:On("QUEST_WATCH_UPDATE",      markDynamic)
    Events:On("ZONE_CHANGED_NEW_AREA",   markAll)
end

Registry:Register(Quests)
