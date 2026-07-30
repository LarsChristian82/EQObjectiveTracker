local _, ns = ...

local AutoTrack = ns:RegisterModule("AutoTrack", {})

-- EQ keeps this in its Visibility.lua, but that file is pure frame work in EQOT and calls
-- no quest API. Storage keys and labels still match EQ, only the file differs.
local function onQuestAccepted(_, questID)
    local cfg = ns:GetModule("DB"):General()
    if not (cfg and questID) then return end

    -- World quest watches are their own system with their own cap and persistence
    if C_QuestLog.IsWorldQuest and C_QuestLog.IsWorldQuest(questID) then return end

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
