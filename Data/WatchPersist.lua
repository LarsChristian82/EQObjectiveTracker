local _, ns = ...

local WatchPersist = ns:RegisterModule("WatchPersist", {})

local MANUAL        = (Enum and Enum.QuestWatchType and Enum.QuestWatchType.Manual) or 1
local RESTORE_DELAY = 2

-- Everything Quests drives this from its own world map pins, which call Track and
-- Untrack directly. EQOT is tracker-only and has no map UI to hook, so it mirrors
-- Blizzard's watch list instead of intercepting it.
--
-- Only MANUAL watches are stored. Walking near a world quest auto-watches it, and
-- persisting that would permanently pin every quest the player ever ran past.
local restored = false

local function getList()
    local DB   = ns:GetModule("DB")
    local char = DB and DB:Char()
    if not char then return nil end
    char.trackedWorldQuests = char.trackedWorldQuests or {}
    return char.trackedWorldQuests
end

-- Not C_QuestLog.IsWorldQuest: that stays true for an expired world quest forever, so
-- ghost entries could never be pruned.
local function stillActive(questID)
    if ns.Has.WorldQuestTime then
        local t = C_TaskQuest.GetQuestTimeLeftMinutes(questID)
        if t and t > 0 then return true end
    end
    if C_TaskQuest and C_TaskQuest.IsActive and C_TaskQuest.IsActive(questID) then
        return true
    end
    return false
end

local function watchType(questID)
    if not ns.Has.QuestWatchType then return nil end
    return C_QuestLog.GetQuestWatchType(questID)
end

local function restore()
    local list = getList()
    if not list then return end
    for questID in pairs(list) do
        if not stillActive(questID) then
            list[questID] = nil
        elseif watchType(questID) == nil and ns.Has.WorldQuestWatchAdd then
            C_QuestLog.AddWorldQuestWatch(questID, MANUAL)
        end
    end
    restored = true
    -- Through the provider's own dirty hook rather than the tracker, so this stays
    -- inside the data layer.
    local provider = ns:GetModule("Registry"):Get("worldquests")
    if provider and provider._notifyDirty then provider._notifyDirty() end
end

-- Blizzard's watch list is empty until the restore runs, so mirroring any earlier would
-- wipe the saved set on every login.
local function mirror()
    if not restored then return end
    local list = getList()
    if not (list and ns.Has.WorldQuests) then return end
    wipe(list)
    for i = 1, (C_QuestLog.GetNumWorldQuestWatches() or 0) do
        local qid = C_QuestLog.GetQuestIDForWorldQuestWatchIndex(i)
        if qid and watchType(qid) == MANUAL then list[qid] = true end
    end
end

function WatchPersist:DebugLine()
    local list = getList()
    local n = 0
    if list then for _ in pairs(list) do n = n + 1 end end
    return ("world quest watches: %d saved, restore %s"):format(
        n, restored and "done" or "pending")
end

function WatchPersist:OnEnable()
    if not ns.Has.WorldQuests then return end
    local Events = ns:GetModule("Events")

    -- World quest data is not populated at login, so the restore has to wait for it
    Events:On("PLAYER_ENTERING_WORLD", function()
        C_Timer.After(RESTORE_DELAY, restore)
    end)
    Events:On("QUEST_WATCH_LIST_CHANGED", mirror)
    Events:On("QUEST_TURNED_IN", function(_, questID)
        local list = getList()
        if list and questID then list[questID] = nil end
    end)
end
