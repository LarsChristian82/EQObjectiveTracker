local _, ns = ...

local QuestSound = ns:RegisterModule("QuestSound", {})

-- Midnight can hand back "secret values" that error when indexed by tainted addon code,
-- even though they still report type "string"
local _issecret = _G.issecretvalue

local DEDUP_WINDOW_S = 2
local SCAN_DEBOUNCE  = 0.2

local lastComplete = {}
local recentTitles = {}
local scratch      = {}
local armed        = false

local function isRecent(title)
    if not title or title == "" then return false end
    local exp = recentTitles[title]
    if not exp then return false end
    if exp > GetTime() then return true end
    recentTitles[title] = nil
    return false
end

local function recordRecent(title)
    if not (title and title ~= "") then return end
    local now = GetTime()
    for k, exp in pairs(recentTitles) do
        if exp <= now then recentTitles[k] = nil end
    end
    recentTitles[title] = now + DEDUP_WINDOW_S
end

local function playSound()
    local cfg = ns:GetModule("DB"):Tracker()
    if not (cfg and cfg.questSoundEnabled ~= false and PlaySoundFile) then return end
    local file = ns:GetModule("Media"):GetSoundFile(cfg.questCompleteSound or "EQ: Work Complete")
    if file then PlaySoundFile(file, "Master") end
end

-- EQ diffs its own quest Cache here. EQOT has none, so the log is walked directly - the
-- transitions detected, and everything downstream of them, are identical.
local function detectTransitions()
    if not ns.Has.QuestLog then return end

    local n = 0
    local seen = scratch
    wipe(seen)

    for i = 1, C_QuestLog.GetNumQuestLogEntries() do
        local info = C_QuestLog.GetInfo(i)
        if info and not info.isHeader then
            local id = info.questID
            if id then
                local now = (ns.Has.QuestIsComplete and C_QuestLog.IsComplete(id)) and true or false
                seen[id] = now
                -- was == false, not "not was": a quest first seen already complete is nil
                -- here and must stay silent, or a cold login fires for the whole log
                if armed and now and lastComplete[id] == false then
                    local title = info.title or ""
                    -- The chat path may already have played this one
                    if not isRecent(title) then
                        n = n + 1
                        recordRecent(title)
                    end
                end
            end
        end
    end

    for id in pairs(lastComplete) do
        if seen[id] == nil then lastComplete[id] = nil end
    end
    for id, v in pairs(seen) do lastComplete[id] = v end

    -- The first pass only primes the table, or every already-complete quest sounds at once
    if not armed then
        armed = true
        return
    end
    if n > 0 then playSound() end
end

local _completePattern
local function completePattern()
    if _completePattern then return _completePattern end
    local fmt = ERR_QUEST_COMPLETE_S
    if type(fmt) ~= "string" or fmt == "" then return nil end
    local SENTINEL = "\1"
    _completePattern = "^" .. fmt
        :gsub("%%s", SENTINEL)
        :gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
        :gsub(SENTINEL, "(.+)")
        .. "$"
    return _completePattern
end

local function onSystemChat(_, msg)
    -- msg:match on a secret value throws, and the log scan still catches those quests
    if _issecret and _issecret(msg) then return end
    if type(msg) ~= "string" then return end
    local p = completePattern()
    if not p then return end
    local title = msg:match(p)
    if not title or title == "" then return end
    if isRecent(title) then return end
    recordRecent(title)
    playSound()
end

function QuestSound:OnEnable()
    local Events = ns:GetModule("Events")
    Events:On("QUEST_LOG_UPDATE", function()
        Events:Debounce("eqot.questsound", SCAN_DEBOUNCE, detectTransitions)
    end)
    Events:On("CHAT_MSG_SYSTEM", onSystemChat)
end
