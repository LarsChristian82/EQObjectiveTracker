local _, ns = ...

local ZoneProgress = ns:RegisterModule("ZoneProgress", {})

local MAX_HOPS = 5

-- EQ resolves the zone by walking up from the player's map until it hits a Zone, so a
-- micro-dungeon or a sub-area still counts against the zone that contains it.
local _rootID, _rootName, _rootDirty = nil, nil, true

local function zoneRoot()
    if not _rootDirty then return _rootID, _rootName end
    if not ns.Has.Map then return nil end
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID or mapID <= 0 then return nil end

    _rootDirty = false
    _rootID, _rootName = nil, nil

    local id = mapID
    for _ = 1, MAX_HOPS do
        local info = C_Map.GetMapInfo(id)
        if not info then break end
        if info.mapType == Enum.UIMapType.Zone then
            _rootID, _rootName = id, info.name
            break
        end
        if not info.parentMapID or info.parentMapID == 0 then break end
        id = info.parentMapID
    end
    return _rootID, _rootName
end

local RETRY_DELAY = 0.3
local RETRY_MAX   = 5

-- Blizzard exposes no per-zone quest total. Zone story achievements, campaign chapters
-- and GetAvailableQuestLines were each measured against a live client and none of them
-- answers, which is why the routing index in Data/ZoneRouting.lua has to exist.
local function categoryByMapID(rootID)
    if not rootID then return nil end
    for id, cat in pairs(ns.ZONE_CATEGORIES or {}) do
        if cat.mapID == rootID then return id end
        local mids = cat.mapIDs
        if type(mids) == "table" then
            for i = 1, #mids do
                if mids[i] == rootID then return id end
            end
        end
    end
    return nil
end

-- Substring both ways after the exact pass, so "Eversong Woods" still matches when the
-- client hands back a decorated zone name.
local function categoryByName(name)
    if not name or name == "" then return nil end
    local lower = name:lower()
    for id, cat in pairs(ns.ZONE_CATEGORIES or {}) do
        if (cat.name or ""):lower() == lower then return id end
    end
    for id, cat in pairs(ns.ZONE_CATEGORIES or {}) do
        local cn = (cat.name or ""):lower()
        if cn ~= "" and (lower:find(cn, 1, true) or cn:find(lower, 1, true)) then
            return id
        end
    end
    return nil
end

local _catIndex
local function categoryQuestLines(catID)
    local routing = ns.QUESTLINE_ROUTING
    if not (routing and catID) then return nil end
    if not _catIndex then
        _catIndex = {}
        for qlID, entry in pairs(routing) do
            local c = (type(entry) == "table") and entry.cat or entry
            if c then
                local list = _catIndex[c]
                if not list then list = {}; _catIndex[c] = list end
                list[#list + 1] = qlID
            end
        end
    end
    return _catIndex[catID]
end

-- Questline contents stream in late, so a miss is retried rather than cached as empty,
-- and the store only ever grows for a given questline.
local qlQuests      = {}
local retryCount    = {}
local retryPending  = {}

function ZoneProgress:EnsureQuests(qlID)
    if not (qlID and C_QuestLine and C_QuestLine.GetQuestLineQuests) then return end
    local quests = C_QuestLine.GetQuestLineQuests(qlID)
    if not quests or #quests == 0 then
        local n = retryCount[qlID] or 0
        if n < RETRY_MAX and not retryPending[qlID] then
            retryPending[qlID] = true
            retryCount[qlID]   = n + 1
            C_Timer.After(RETRY_DELAY * (n + 1), function()
                retryPending[qlID] = nil
                self:EnsureQuests(qlID)
            end)
        end
        return
    end
    retryCount[qlID] = nil
    local existing = qlQuests[qlID]
    if not existing or #quests >= #existing then
        qlQuests[qlID] = quests
    end
end

local _seen = {}

-- Deduplicated by quest id: a quest can appear in more than one routed questline, and
-- counting it twice would inflate both halves of the bar.
function ZoneProgress:Count(rootID, rootName)
    local catID = categoryByMapID(rootID) or categoryByName(rootName)
    local lines = catID and categoryQuestLines(catID)
    if not lines then return nil, nil, catID end

    wipe(_seen)
    local total, done = 0, 0
    local flagged = C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted

    for i = 1, #lines do
        local qlID = lines[i]
        local quests = qlQuests[qlID]
        if not quests then
            self:EnsureQuests(qlID)
            quests = qlQuests[qlID]
        end
        for j = 1, (quests and #quests or 0) do
            local qid = quests[j]
            if qid and not _seen[qid] then
                _seen[qid] = true
                total = total + 1
                if flagged and flagged(qid) then done = done + 1 end
            end
        end
    end
    return done, total, catID
end

function ZoneProgress:Current()
    local rootID, rootName = zoneRoot()
    if not rootID then return nil end
    local done, total, catID = self:Count(rootID, rootName)
    if not total or total == 0 then return nil end
    return done, total, rootName, catID
end

function ZoneProgress:DebugLines()
    local lines = {}
    local rootID, rootName = zoneRoot()
    if not rootID then
        lines[1] = "zone progress: no zone map (instanced or no map)"
        return lines
    end

    local done, total, catID = self:Count(rootID, rootName)
    local cat = catID and ns.ZONE_CATEGORIES and ns.ZONE_CATEGORIES[catID]
    if not total then
        lines[1] = ("zone progress: %s (%d) -> NO ROUTING, no bar here")
            :format(rootName or "?", rootID)
        return lines
    end

    local qls = categoryQuestLines(catID) or {}
    local loaded = 0
    for i = 1, #qls do
        if qlQuests[qls[i]] then loaded = loaded + 1 end
    end

    lines[1] = ("zone progress: %s (%d) -> %s, %d/%d complete")
        :format(rootName or "?", rootID, (cat and cat.name) or tostring(catID), done, total)
    lines[2] = ("  %d/%d routed questlines loaded"):format(loaded, #qls)
    return lines
end

function ZoneProgress:OnEnable()
    local Events = ns:GetModule("Events")
    local function dirty() _rootDirty = true end
    Events:On("ZONE_CHANGED_NEW_AREA", dirty)
    Events:On("PLAYER_ENTERING_WORLD", dirty)
end
