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
    if set[entry.id] then return true end
    -- Absent from this map is not the same as being somewhere else, and answering false for a
    -- quest with no location hid every category quest - GetQuestsOnMap measured 1 against a
    -- sixteen-quest log. All three returns are required: a mapID with no coordinates is an
    -- unresolved POI, guarded the same way in UI/TaxiHighlight.lua.
    if not ns.Has.NextWaypoint then return nil end
    local wm, wx, wy = C_QuestLog.GetNextWaypoint(entry.id)
    if wm and wx and wy then return false end
    return nil
end

-- Unlike 1.15.9, this bound is safe: on retail the count read 50 with every quest log header
-- collapsed and the walk still found all 15 quests.
local walkEntries, walkQuests = 0, 0

local function fullRebuild()
    local focused = superTrackedID()
    local currentHeader
    store:Begin()

    walkEntries, walkQuests = C_QuestLog.GetNumQuestLogEntries() or 0, 0

    for i = 1, walkEntries do
        local info = C_QuestLog.GetInfo(i)
        if info then
            if info.isHeader then
                currentHeader = info.title
            elseif not info.isHidden then
                walkQuests = walkQuests + 1
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

    -- Cached against live, separately, because one number cannot tell a stale cache from a
    -- watch list that really is empty. The cached answer is what the rows were filtered on;
    -- the live one re-reads outside the GetInfo walk that fullRebuild writes it from.
    local cached, live = 0, 0
    for id, e in store:Each() do
        if e.isTracked then cached = cached + 1 end
        if isWatched(id) then live = live + 1 end
    end

    local map  = ns.Has.Map and C_Map.GetBestMapForUnit("player") or nil
    local list = (map and ns.Has.QuestsOnMap) and C_QuestLog.GetQuestsOnMap(map) or nil

    -- Live rather than the walk's copy: the counters are written in fullRebuild only, so on a
    -- refreshDynamic pass the stored pair describes an older log state than this line.
    local apiNow = C_QuestLog.GetNumQuestLogEntries() or 0

    return ("quests: normal=%s questline=%s campaign=%s meta=%s important=%s | class %s\n      log api %d now %d walked %d | watched cached %d live %d | zone set map %s list %s"):format(
        tostring(QC.Normal), tostring(QC.Questline), tostring(QC.Campaign),
        tostring(QC.Meta), tostring(QC.Important), table.concat(parts, " "),
        walkEntries, apiNow, walkQuests, cached, live, tostring(map),
        list and tostring(#list) or "nil")
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

local function isFocused(id)
    return ns.Has.SuperTrack and C_SuperTrack.GetSuperTrackedQuestID
       and C_SuperTrack.GetSuperTrackedQuestID() == id
end

local function setWatched(id, watch)
    if not ns.Has.QuestWatchAPI then return end
    if watch then
        -- Typed Manual on purpose: an untyped watch is AUTOMATIC, which the engine silently
        -- evicts past a small cap, so the quest would drop off the tracker on its own.
        local manual = Enum and Enum.QuestWatchType and Enum.QuestWatchType.Manual
        C_QuestLog.AddQuestWatch(id, manual)
    else
        C_QuestLog.RemoveQuestWatch(id)
    end
end

local function openQuestDetailsPopup(id)
    if C_AddOns and C_AddOns.LoadAddOn then C_AddOns.LoadAddOn("Blizzard_QuestLog") end

    if QuestMapQuestOptions_OpenQuestDetails then
        QuestMapQuestOptions_OpenQuestDetails(id)
        return
    end
    if not QuestLogPopupDetailFrame then return end
    if not (C_QuestLog.GetLogIndexForQuestID and C_QuestLog.GetLogIndexForQuestID(id)) then return end

    QuestLogPopupDetailFrame.questID = id
    if C_QuestLog.SetSelectedQuest then C_QuestLog.SetSelectedQuest(id) end
    if StaticPopup_Hide then
        StaticPopup_Hide("ABANDON_QUEST")
        StaticPopup_Hide("ABANDON_QUEST_WITH_ITEMS")
    end
    if QuestMapFrame_UpdateQuestDetailsButtons then QuestMapFrame_UpdateQuestDetailsButtons() end
    if QuestLogPopupDetailFrame_Update then QuestLogPopupDetailFrame_Update(true) end
    QuestLogPopupDetailFrame:Show()
end

-- Routed through Blizzard's own confirmation popup rather than abandoning outright, so the
-- item-loss warning still appears. SetSelectedQuest is global state the quest log reads, so
-- the previous selection is put back or the log opens on a quest the player did not choose.
local function abandonQuest(id)
    if not (C_QuestLog.SetSelectedQuest and C_QuestLog.SetAbandonQuest
            and C_QuestLog.GetAbandonQuest) then
        return
    end
    if InCombatLockdown() then return end

    local oldSelected = C_QuestLog.GetSelectedQuest and C_QuestLog.GetSelectedQuest() or 0
    C_QuestLog.SetSelectedQuest(id)
    C_QuestLog.SetAbandonQuest()

    local abandonID = C_QuestLog.GetAbandonQuest()
    -- SetAbandonQuest latches a target. If the quest left the log between opening the menu and
    -- clicking, the latch can still hold the previous one, and abandoning that is unrecoverable.
    if abandonID and abandonID ~= id then
        C_QuestLog.SetSelectedQuest(oldSelected or 0)
        return
    end
    -- Total by construction: a nil here reaches StaticPopup's no-arg branch and the
    -- confirmation renders a literal %s instead of the quest name.
    local title = (QuestUtils_GetQuestName and QuestUtils_GetQuestName(abandonID))
                  or (C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(abandonID))
                  or ("Quest #" .. tostring(id))
    local items = C_QuestLog.GetAbandonQuestItems and C_QuestLog.GetAbandonQuestItems()
    if items and #items > 0 and StaticPopupDialogs and StaticPopupDialogs.ABANDON_QUEST_WITH_ITEMS then
        StaticPopup_Show("ABANDON_QUEST_WITH_ITEMS", title, table.concat(items, ", "))
    else
        StaticPopup_Show("ABANDON_QUEST", title)
    end

    C_QuestLog.SetSelectedQuest(oldSelected or 0)
end

local menuOut = {}
local pinShim = {}

function Quests:GetEntryMenu(entry)
    local Filter = ns:GetModule("Filter")
    local id = entry.id

    for i = #menuOut, 1, -1 do menuOut[i] = nil end

    -- Spaced by ten so an extension can land between any two, which is how EQ puts its Chain
    -- Guide "Get Directions" back between Focus and Open in Map.
    menuOut[#menuOut + 1] = { kind = "title", text = entry.title, order = 0 }
    menuOut[#menuOut + 1] = { id = Filter:IsPinned(entry) and "unpin" or "pin", order = 10 }
    menuOut[#menuOut + 1] = { id = isWatched(id) and "untrack" or "track",      order = 20 }
    menuOut[#menuOut + 1] = { id = isFocused(id) and "unfocus" or "focus",      order = 30 }
    menuOut[#menuOut + 1] = { id = "openlog", order = 40 }
    menuOut[#menuOut + 1] = { id = "popout",  order = 50 }
    menuOut[#menuOut + 1] = { id = "wowhead", order = 60 }
    menuOut[#menuOut + 1] = { kind = "divider", order = 70 }
    menuOut[#menuOut + 1] = { id = "abandon", order = 80, danger = true }
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
        if ns.Has.SuperTrack then C_SuperTrack.SetSuperTrackedQuestID(entryID) end
    elseif itemID == "unfocus" then
        if ns.Has.SuperTrack then C_SuperTrack.SetSuperTrackedQuestID(0) end
    elseif itemID == "openlog" then
        self:OnEntryOpenLog({ id = entryID })
    elseif itemID == "popout" then
        openQuestDetailsPopup(entryID)
    elseif itemID == "abandon" then
        abandonQuest(entryID)
    end
    if self._notifyDirty then self._notifyDirty() end
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
