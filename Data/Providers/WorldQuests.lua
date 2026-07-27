local _, ns = ...

local Entry    = ns:GetModule("Entry")
local Registry = ns:GetModule("Registry")

local STATE, LINE, ICON = Entry.STATE, Entry.LINE, Entry.ICON

local WorldQuests = {
    id       = "worldquests",
    groups   = { "worldquests" },
    -- Ahead of the quests provider on purpose. A world quest you are standing inside is
    -- also in the quest log, so both providers emit it - and in EQ a world quest always
    -- belongs to its own section, never to Quests. Claiming first is what guarantees
    -- that, regardless of the quest section's filter settings.
    priority = 5,
    idSpace  = "quest",
    tags     = { "worldquest", "bonus" },
    filterCategories = true,
}

local FALLBACK_ATLAS = "Worldquest-icon"
local ICON_CROP      = { 0.08, 0.92, 0.08, 0.92 }
local MAP_DEPTH      = 5

local store = Entry.NewStore({
    groupID   = "worldquests",
    icon      = { kind = ICON.TEXTURE },
    tags      = {},
    isTracked = true,
})

local candidates, seen, watched = {}, {}, {}
local sourceStats = { watched = 0, inzone = 0, questlog = 0, wq = 0, bonus = 0, logOwned = 0 }
local currentSource

local function push(qid)
    if qid and not seen[qid] then
        seen[qid] = true
        candidates[#candidates + 1] = qid
        if currentSource then sourceStats[currentSource] = sourceStats[currentSource] + 1 end
    end
end

function WorldQuests:DebugLine()
    local m = ns.Has.Map and C_Map.GetBestMapForUnit("player")
    return ("sources: watched %d, in-zone %d, quest log %d   map %s\n      kinds: %d real world quests, %d task/bonus, %d normal log quests (left to Quests)")
        :format(sourceStats.watched, sourceStats.inzone, sourceStats.questlog, tostring(m),
                sourceStats.wq, sourceStats.bonus, sourceStats.logOwned)
end

local function addWatched()
    wipe(watched)
    if not ns.Has.WorldQuests then return end
    for i = 1, (C_QuestLog.GetNumWorldQuestWatches() or 0) do
        local qid = C_QuestLog.GetQuestIDForWorldQuestWatchIndex(i)
        if qid then
            watched[qid] = true
            push(qid)
        end
    end
end

-- C_TaskQuest.GetQuestsForPlayerByMapID was renamed to GetQuestsOnMap - try the new
-- name first, since the old one is gone on current retail.
local function taskQuestsForMap(mapID)
    if not (C_TaskQuest and mapID) then return nil end
    if C_TaskQuest.GetQuestsOnMap then return C_TaskQuest.GetQuestsOnMap(mapID) end
    if C_TaskQuest.GetQuestsForPlayerByMapID then
        return C_TaskQuest.GetQuestsForPlayerByMapID(mapID)
    end
    return nil
end

-- Walks the current map and its parents: a world quest you are standing inside is
-- often registered on a parent map rather than the one you are on.
local function addInZoneTaskQuests()
    if not ns.Has.Map then return end
    local m = C_Map.GetBestMapForUnit("player")
    for _ = 1, MAP_DEPTH do
        if not m then break end
        local list = taskQuestsForMap(m)
        for i = 1, (list and #list or 0) do
            local q = list[i]
            local qid = q and (q.questId or q.questID)
            if qid and q.inProgress then push(qid) end
        end
        local info = C_Map.GetMapInfo and C_Map.GetMapInfo(m)
        m = info and info.parentMapID
    end
end

local function addQuestLogTaskQuests()
    if not ns.Has.QuestLog then return end
    for i = 1, (C_QuestLog.GetNumQuestLogEntries() or 0) do
        local info = C_QuestLog.GetInfo(i)
        if info and info.questID and not info.isHeader and not info.isHidden then
            if info.isTask or info.isBounty
               or (QuestUtils_IsQuestWorldQuest and QuestUtils_IsQuestWorldQuest(info.questID)) then
                push(info.questID)
            end
        end
    end
end

local function isWorldQuest(qid)
    if C_QuestLog.IsWorldQuest and C_QuestLog.IsWorldQuest(qid) then return true end
    if QuestUtils_IsQuestWorldQuest and QuestUtils_IsQuestWorldQuest(qid) then return true end
    return false
end

-- A normal, visible quest log entry belongs to the Quests section. Task and bonus
-- entries do not, even though they are in the log, and neither do world quests.
local function ownedByQuestLog(qid)
    if not C_QuestLog.GetLogIndexForQuestID then return false end
    local idx = C_QuestLog.GetLogIndexForQuestID(qid)
    if not idx then return false end
    local info = C_QuestLog.GetInfo(idx)
    if not info or info.isHidden then return false end
    return not (info.isTask or info.isBounty)
end

local function minutesLeft(questID)
    if not ns.Has.WorldQuestTime then return nil end
    return C_TaskQuest.GetQuestTimeLeftMinutes(questID)
end

local function title(questID)
    if ns.Has.TaskQuestInfo then
        local t = C_TaskQuest.GetQuestInfoByQuestID(questID)
        if t and t ~= "" then return t end
    end
    if C_QuestLog.GetTitleForQuestID then
        local t = C_QuestLog.GetTitleForQuestID(questID)
        if t and t ~= "" then return t end
    end
    return nil
end

local rewardCache = {}

local function classifyReward(questID)
    local money = GetQuestLogRewardMoney and GetQuestLogRewardMoney(questID) or 0
    if money > 0 then
        return { texture = "Interface\\MoneyFrame\\UI-MoneyIcons", texCoord = { 0, 0.25, 0, 1 } }
    end

    local numItems = GetNumQuestLogRewards and GetNumQuestLogRewards(questID) or 0
    if numItems > 0 then
        local _, texture = GetQuestLogRewardInfo(1, questID)
        if texture then return { texture = texture, texCoord = ICON_CROP } end
    end

    local currencies = C_QuestLog.GetQuestRewardCurrencies
                       and C_QuestLog.GetQuestRewardCurrencies(questID)
    if currencies and currencies[1] and currencies[1].texture then
        return { texture = currencies[1].texture, texCoord = ICON_CROP }
    end

    return nil
end

-- Never memoize a miss - reward data streams in late, and a cached fallback would
-- freeze the row on the generic marker forever.
local function reward(questID)
    local cached = rewardCache[questID]
    if cached then return cached end
    local r = classifyReward(questID)
    if r and (not HaveQuestRewardData or HaveQuestRewardData(questID)) then
        rewardCache[questID] = r
    end
    return r
end

local function fillLines(e, questID, complete)
    Entry.BeginLines(e)
    local objs = ns.Has.QuestObjectives and C_QuestLog.GetQuestObjectives(questID) or nil
    for i = 1, (objs and #objs or 0) do
        local o  = objs[i]
        local ln = Entry.PushLine(e)
        ln.text      = o.text or ""
        ln.completed = o.finished and true or false
        ln.current   = o.numFulfilled
        ln.required  = o.numRequired
        if o.type == "progressbar" then ln.kind = LINE.PROGRESSBAR end
    end
    if (objs and #objs or 0) == 0 and complete then
        local ln = Entry.PushLine(e)
        ln.text, ln.completed = "Ready to turn in", true
    end
    Entry.EndLines(e)
end

function WorldQuests:IsAvailable()
    return (ns.Has.WorldQuests or ns.Has.TaskQuests) and ns.Has.QuestObjectives
end

function WorldQuests:GetEntries()
    wipe(candidates)
    wipe(seen)
    sourceStats.watched, sourceStats.inzone, sourceStats.questlog = 0, 0, 0
    sourceStats.wq, sourceStats.bonus, sourceStats.logOwned = 0, 0, 0
    currentSource = "watched";  addWatched()
    currentSource = "inzone";   addInZoneTaskQuests()
    currentSource = "questlog"; addQuestLogTaskQuests()
    currentSource = nil

    store:Begin()
    for i = 1, #candidates do
        local qid  = candidates[i]
        local name = title(qid)
        local mins = minutesLeft(qid)
        local wq       = isWorldQuest(qid)
        -- The map API returns in-progress task-flavored content, which on some maps
        -- includes ordinary quests. Those belong to the quest section, so leave them
        -- there rather than dragging them under a World Quests header.
        local logOwned = (not wq) and ownedByQuestLog(qid) or false

        if wq then
            sourceStats.wq = sourceStats.wq + 1
        elseif logOwned then
            sourceStats.logOwned = sourceStats.logOwned + 1
        else
            sourceStats.bonus = sourceStats.bonus + 1
        end

        -- A watched entry with no time left is an expired ghost. Liveness cannot come
        -- from IsWorldQuest: that stays true forever once a quest has been one.
        local expired = watched[qid] and not (mins and mins > 0)

        if name and not expired and not logOwned then
            local complete = ns.Has.QuestIsComplete and C_QuestLog.IsComplete(qid) or false
            local e = store:Acquire(qid)
            e.title     = name
            e.state     = complete and STATE.COMPLETE or STATE.ACTIVE
            e.expiresAt = (mins and mins > 0) and (time() + mins * 60) or nil

            wipe(e.tags)
            if wq then e.tags.worldquest = true else e.tags.bonus = true end

            local r = reward(qid)
            e.icon.texture  = r and r.texture or nil
            e.icon.texCoord = r and r.texCoord or nil
            e.icon.atlas    = (not r) and FALLBACK_ATLAS or nil

            fillLines(e, qid, complete)
        end
    end
    return store:Finish()
end

function WorldQuests:OnEntryClick(entry, button)
    if button == "RightButton" then
        if ns.Has.WorldQuestWatchAPI then C_QuestLog.RemoveWorldQuestWatch(entry.id) end
        return
    end
    if ns.Has.SuperTrack then
        C_SuperTrack.SetSuperTrackedQuestID(entry.id)
        if self._notifyDirty then self._notifyDirty() end
    end
end

function WorldQuests:OnEntryTooltip(entry, tooltip)
    tooltip:AddLine(entry.title, 1, 0.82, 0)
    local mins = minutesLeft(entry.id)
    if mins and mins > 0 then
        tooltip:AddLine(ns.Util.FmtDuration(mins * 60) .. " remaining", 0.6, 0.6, 0.6)
    end
    tooltip:AddLine(" ")
    tooltip:AddLine("Left-click to super-track, right-click to untrack.", 0.5, 0.5, 0.5)
end

function WorldQuests:Enable(notifyDirty)
    local Events = ns:GetModule("Events")

    -- Quest IDs get recycled, so drop the reward or the next quest under that ID
    -- inherits this one's icon
    local function drop(_, questID)
        if questID then rewardCache[questID] = nil end
        notifyDirty()
    end

    Events:On("QUEST_TURNED_IN",           drop)
    Events:On("QUEST_REMOVED",             drop)
    Events:On("QUEST_WATCH_LIST_CHANGED",  notifyDirty)
    Events:On("QUEST_LOG_UPDATE",          notifyDirty)
    Events:On("SUPER_TRACKING_CHANGED",    notifyDirty)
    Events:On("TASK_PROGRESS_UPDATE",      notifyDirty)
    Events:On("QUEST_ACCEPTED",            notifyDirty)
    Events:On("ZONE_CHANGED_NEW_AREA",     notifyDirty)
    Events:On("PLAYER_ENTERING_WORLD",     notifyDirty)
end

Registry:Register(WorldQuests)
