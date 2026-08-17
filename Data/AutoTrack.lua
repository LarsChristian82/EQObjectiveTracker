local _, ns = ...

local AutoTrack = ns:RegisterModule("AutoTrack", {})

-- EQ keeps this in its Visibility.lua, but that file is pure frame work in EQOT and calls
-- no quest API. Storage keys and labels still match EQ, only the file differs.
-- Classic fires (questLogIndex, questID) where retail fires (questID) on its own, so the id is
-- read off the LAST argument rather than a fixed slot - correct under either signature without
-- having to know which client sends which. Reading slot one auto-tracked the LOG INDEX on
-- Classic, which is itself a valid quest id belonging to some unrelated quest.
local function onQuestAccepted(_, a, b)
    local cfg = ns:GetModule("DB"):General()
    local questID = b or a
    AutoTrack._lastPayload = ("%s,%s"):format(tostring(a), tostring(b))
    AutoTrack._lastID      = questID
    if not (cfg and questID) then return end

    -- World quest watches are their own system with their own cap and persistence
    if C_QuestLog.IsWorldQuest and C_QuestLog.IsWorldQuest(questID) then return end

    -- Classic owns its tracked set rather than Blizzard's watch list, so this works there now.
    -- It could not before: the flat AddQuestWatch is capped at five and throws a red error on the
    -- sixth, which made auto-tracking every accepted quest a dead end rather than a missing wire.
    -- The module is absent on retail, where the C_QuestLog path below is correct.
    local TrackedSet = ns:GetModule("TrackedSet")
    if TrackedSet then
        TrackedSet:Set(questID, cfg.autoTrackAccepted ~= false)
        return
    end

    if cfg.autoTrackAccepted == false then
        local watched = ns.Has.QuestWatchType and C_QuestLog.GetQuestWatchType(questID) ~= nil
        if watched and ns.Has.QuestWatchAPI then
            C_QuestLog.RemoveQuestWatch(questID)
        end
        return
    end

    if not ns.Has.QuestWatchAPI then return end
    -- Forced to MANUAL. AddQuestWatch with no type adds an AUTOMATIC watch, which is what
    -- Blizzard's autoQuestWatch CVar creates, and the engine silently evicts those past a
    -- small cap - so the quest would vanish from the tracker again on its own.
    local manual = Enum and Enum.QuestWatchType and Enum.QuestWatchType.Manual
    C_QuestLog.AddQuestWatch(questID, manual)
end

function AutoTrack:OnEnable()
    ns:GetModule("Events"):On("QUEST_ACCEPTED", onQuestAccepted)
end

-- The payload is printed raw. Which slot carries the quest id differs by flavor and is the
-- kind of thing that gets re-derived wrongly from memory, so one accept settles it on screen.
function AutoTrack:DebugLine()
    local cfg = ns:GetModule("DB"):General()
    return ("auto track: %s, set owned %s | last accept payload (%s) -> id %s"):format(
        (cfg and cfg.autoTrackAccepted ~= false) and "on" or "off",
        tostring(ns:GetModule("TrackedSet") ~= nil),
        self._lastPayload or "none this session",
        tostring(self._lastID))
end
