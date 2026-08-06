local _, ns = ...

local Entry      = ns:GetModule("Entry")
local Registry   = ns:GetModule("Registry")
local QuestItems = ns:GetModule("QuestItems")

local STATE, LINE, ICON = Entry.STATE, Entry.LINE, Entry.ICON

local Quests = {
    id       = "quests",
    groups   = { "campaign", "quests" },
    priority = 10,
    idSpace  = "quest",
    tags     = { "campaign", "daily", "weekly", "dungeon", "raid", "legendary", "worldquest" },
    filterCategories = true,
}

local DAILY_FREQ  = (Enum and Enum.QuestFrequency and Enum.QuestFrequency.Daily)  or 2
local WEEKLY_FREQ = (Enum and Enum.QuestFrequency and Enum.QuestFrequency.Weekly) or 3

local TAG_DUNGEON = (Enum and Enum.QuestTag and Enum.QuestTag.Dungeon) or 81
local TAG_RAID    = (Enum and Enum.QuestTag and Enum.QuestTag.Raid)    or 62
local TAG_RAID10  = (Enum and Enum.QuestTag and Enum.QuestTag.Raid10)  or 85
local TAG_RAID25  = (Enum and Enum.QuestTag and Enum.QuestTag.Raid25)  or 88

local CLASS_LEGENDARY = Enum and Enum.QuestClassification and Enum.QuestClassification.Legendary

local store = Entry.NewStore({
    groupID = "quests",
    icon    = { kind = ICON.QUESTPOI },
    tags    = {},
})

local firstSeen = {}

local dirtyAll        = true
local dirtyObjectives = false

-- A cold login can present an empty quest log, so stay on full rebuild until one
-- succeeds. The cheap refresh only touches quests that are already cached.
local primed    = false
local baselined = false

local tagIDCache   = {}
local objTextCache = {}

local function getTagID(id)
    local cached = tagIDCache[id]
    if cached then return cached end
    if not ns.Has.QuestTagInfo then return nil end
    local info  = C_QuestLog.GetQuestTagInfo(id)
    local tagID = info and info.tagID
    -- Memoize hits only - a miss can mean static data has not streamed in yet
    if tagID then tagIDCache[id] = tagID end
    return tagID
end

local function getClassification(id)
    if C_QuestInfoSystem and C_QuestInfoSystem.GetQuestClassification then
        return C_QuestInfoSystem.GetQuestClassification(id)
    end
    if C_QuestLog.GetQuestClassification then
        return C_QuestLog.GetQuestClassification(id)
    end
    return nil
end

local function isCampaign(id, info)
    if ns.Has.CampaignInfo then
        local cid = C_CampaignInfo.GetCampaignID(id)
        if cid and cid > 0 then return true end
    end
    return (info and info.campaignID and info.campaignID > 0) and true or false
end

local function getFallbackText(id)
    local cached = objTextCache[id]
    if cached ~= nil then return cached end
    local text = ""
    if C_QuestLog.SetSelectedQuest and GetQuestLogQuestText then
        local saved = C_QuestLog.GetSelectedQuest and C_QuestLog.GetSelectedQuest()
        C_QuestLog.SetSelectedQuest(id)
        local _, objText = GetQuestLogQuestText()
        text = objText or ""
        -- Restored unconditionally: GetSelectedQuest answers 0 when nothing is selected, and
        -- skipping the restore there leaves Blizzard's quest log opening on whichever quest
        -- this happened to probe last. Gated on the getter existing, or a flavor that has
        -- only the setter would clear a selection it could never have read.
        if C_QuestLog.GetSelectedQuest then C_QuestLog.SetSelectedQuest(saved or 0) end
    end
    -- Never memoize "" - the text may simply not have streamed in yet
    if text ~= "" then objTextCache[id] = text end
    return text
end

local function questState(id)
    if ns.Has.QuestIsFailed and C_QuestLog.IsFailed(id) then return STATE.FAILED end
    if ns.Has.QuestIsComplete and C_QuestLog.IsComplete(id) then return STATE.COMPLETE end
    return STATE.ACTIVE
end

local function fillLines(e, id)
    Entry.BeginLines(e)
    local objs = ns.Has.QuestObjectives and C_QuestLog.GetQuestObjectives(id) or nil
    local n    = objs and #objs or 0

    if n == 0 then
        local fb = getFallbackText(id)
        if fb ~= "" then
            local ln = Entry.PushLine(e)
            ln.text      = fb
            ln.completed = (e.state == STATE.COMPLETE)
        end
    else
        for i = 1, n do
            local o  = objs[i]
            local ln = Entry.PushLine(e)
            ln.text      = o.text or ""
            ln.completed = o.finished and true or false
            ln.current   = o.numFulfilled
            ln.required  = o.numRequired
            if o.type == "progressbar" then ln.kind = LINE.PROGRESSBAR end
        end
    end

    Entry.EndLines(e)
end

-- A world quest can sit in the quest log and therefore render in a quest section.
-- EQ's Filters.lua checks this before every other category, so tag it the same way or
-- the World quests toggle would silently miss them.
local function isWorldQuest(id)
    if C_QuestLog.IsWorldQuest and C_QuestLog.IsWorldQuest(id) then return true end
    if QuestUtils_IsQuestWorldQuest and QuestUtils_IsQuestWorldQuest(id) then return true end
    return false
end

local function fillTags(e, id, info)
    local tags = e.tags
    wipe(tags)
    if isWorldQuest(id) then tags.worldquest = true end
    if isCampaign(id, info) then tags.campaign = true end
    -- Kept as the raw enum as well as a tag, because the type sort orders by it
    -- directly - weekly above daily above normal - rather than by tag presence.
    e.frequency = (info and info.frequency) or 0
    if info then
        if info.frequency == DAILY_FREQ  then tags.daily  = true end
        if info.frequency == WEEKLY_FREQ then tags.weekly = true end
    end
    local tagID = getTagID(id)
    if tagID == TAG_DUNGEON then
        tags.dungeon = true
    elseif tagID == TAG_RAID or tagID == TAG_RAID10 or tagID == TAG_RAID25 then
        tags.raid = true
    end
    if CLASS_LEGENDARY and e.icon.classification == CLASS_LEGENDARY then tags.legendary = true end
end

local function superTrackedID()
    if not (ns.Has.SuperTrack and C_SuperTrack.GetSuperTrackedQuestID) then return nil end
    return C_SuperTrack.GetSuperTrackedQuestID()
end

local function isWatched(id)
    return (ns.Has.QuestWatchType and C_QuestLog.GetQuestWatchType(id) ~= nil) and true or false
end

local zoneSet   = {}
local zoneMapID = nil
local zoneDirty = true

local function currentZoneSet()
    if not (ns.Has.QuestsOnMap and ns.Has.Map) then return nil end
    local map = C_Map.GetBestMapForUnit("player")
    if not map then return nil end
    if not zoneDirty and map == zoneMapID then return zoneSet end
    local list = C_QuestLog.GetQuestsOnMap(map)
    if not list then return nil end
    wipe(zoneSet)
    for i = 1, #list do
        local q = list[i]
        if q and q.questID then zoneSet[q.questID] = true end
    end
    zoneMapID, zoneDirty = map, false
    return zoneSet
end

-- Zone membership comes from map POIs. Quest-log headers are campaign groupings that
-- rarely equal GetZoneText(), so comparing those would hide almost everything.
-- Returning nil means "cannot tell", and the filter must then fail open.
function Quests:IsCurrentZone(entry)
    local set = currentZoneSet()
    if not set then return nil end
    return set[entry.id] == true
end

local function fullRebuild()
    local focused = superTrackedID()
    local currentHeader
    store:Begin()

    for i = 1, C_QuestLog.GetNumQuestLogEntries() do
        local info = C_QuestLog.GetInfo(i)
        if info then
            if info.isHeader then
                currentHeader = info.title
            elseif not info.isHidden then
                local id = info.questID
                local fs = firstSeen[id]
                if not fs then
                    fs = baselined and time() or 0
                    firstSeen[id] = fs
                end

                local e = store:Acquire(id)
                e.title     = info.title or ("Quest #" .. tostring(id))
                e.subtitle  = currentHeader
                e.zone      = currentHeader
                e.level     = info.level
                e.addedAt   = fs
                e.state     = questState(id)
                e.isFocused = (focused == id)
                e.isTracked = isWatched(id)
                e.icon.classification = getClassification(id)
                e.hasItem   = QuestItems:Has(id)
                fillTags(e, id, info)
                e.groupID = e.tags.campaign and "campaign" or "quests"
                fillLines(e, id)
            end
        end
    end

    store:Finish()

    for id in pairs(firstSeen) do
        if not store:Get(id) then
            firstSeen[id], tagIDCache[id], objTextCache[id] = nil, nil, nil
        end
    end

    if next(store:Out()) ~= nil then
        primed    = true
        baselined = true
    end
    dirtyAll        = false
    dirtyObjectives = false
end

local function refreshDynamic()
    local focused = superTrackedID()
    for id, e in store:Each() do
        e.isTracked = isWatched(id)
        e.isFocused = (focused == id)
        e.state     = questState(id)
        -- Refreshed on the cheap path too. A quest's special item arrives after the
        -- quest does, so caching it only on full rebuild leaves the gutter missing.
        e.hasItem   = QuestItems:Has(id)
        -- Same reason, and deliberately not memoized: a classification read while static
        -- data is still streaming can come back wrong, and caching the hit would pin the
        -- wrong POI shape until the next full rebuild.
        e.icon.classification = getClassification(id)
        -- fillTags needs GetInfo and so only runs on a full rebuild. The one tag derived from
        -- classification is re-derived here, or a late-arriving Legendary repaints the POI
        -- icon while the card stays tinted as an ordinary quest.
        e.tags.legendary = (CLASS_LEGENDARY and e.icon.classification == CLASS_LEGENDARY)
                           or nil
        fillLines(e, id)
    end
    dirtyObjectives = false
end

function Quests:IsAvailable()
    return ns.Has.QuestLog
end

function Quests:GetEntries()
    if dirtyAll then
        fullRebuild()
    elseif dirtyObjectives then
        refreshDynamic()
    end
    return store:Out()
end

function Quests:DebugLine()
    local QC    = (Enum and Enum.QuestClassification) or {}
    local parts = {}
    for id, e in store:Each() do
        parts[#parts + 1] = ("%d=%s%s"):format(
            id, tostring(e.icon.classification), e.isFocused and "*" or "")
    end
    table.sort(parts)
    -- The enum values are printed because they decide the POI shape, and a wrong one is
    -- otherwise only visible as an odd icon nobody can map back to a number.
    return ("quests: normal=%s questline=%s campaign=%s meta=%s important=%s | class %s"):format(
        tostring(QC.Normal), tostring(QC.Questline), tostring(QC.Campaign),
        tostring(QC.Meta), tostring(QC.Important), table.concat(parts, " "))
end

function Quests:OnEntryClick(entry, button)
    if button == "RightButton" then
        if ns.Has.QuestWatchAPI then C_QuestLog.RemoveQuestWatch(entry.id) end
        return
    end
    if ns.Has.SuperTrack then
        C_SuperTrack.SetSuperTrackedQuestID(entry.id)
        if self._notifyDirty then self._notifyDirty() end
    end
end

-- Only implemented here, which is also what gates the split-click option: Row offers it
-- solely to a provider that answers this, matching EQ having it on quest blocks alone.
function Quests:OnEntryOpenLog(entry)
    if C_AddOns and C_AddOns.LoadAddOn then C_AddOns.LoadAddOn("Blizzard_QuestLog") end
    if QuestMapFrame_OpenToQuestDetails then
        QuestMapFrame_OpenToQuestDetails(entry.id)
    elseif ToggleQuestLog then
        ToggleQuestLog()
    end
end

function Quests:Enable(notifyDirty)
    local Events = ns:GetModule("Events")

    local function markAll()
        dirtyAll, zoneDirty = true, true
        notifyDirty()
    end
    local function markDynamic()
        if not primed then dirtyAll = true else dirtyObjectives = true end
        zoneDirty = true
        notifyDirty()
    end
    local function markZone()
        zoneDirty = true
        notifyDirty()
    end

    Events:On("QUEST_ACCEPTED",           markAll)
    Events:On("QUEST_REMOVED",            markAll)
    Events:On("QUEST_TURNED_IN",          markAll)
    Events:On("PLAYER_ENTERING_WORLD",    markAll)
    Events:On("QUEST_LOG_UPDATE",         markDynamic)
    Events:On("QUEST_WATCH_LIST_CHANGED", markDynamic)
    Events:On("SUPER_TRACKING_CHANGED",   markDynamic)
    Events:On("ZONE_CHANGED_NEW_AREA",    markZone)
end

Registry:Register(Quests)
