local _, ns = ...

local Coexist = ns:RegisterModule("QuestieCoexist", {})
local L       = ns.L

-- Questie names its tracker root Questie_BaseFrame (Questie 11.34.0,
-- Modules/Tracker/TrackerBaseFrame.lua). It is built lazily when Questie's tracker
-- initializes, after this addon's PLAYER_LOGIN, and it is nil outright while Questie's
-- tracker is switched off - so it is resolved on every check and never cached.
local function trackerFrame()
    local f = Questie_BaseFrame
    if type(f) == "table" and type(f.Hide) == "function" then return f end
    return nil
end

local function cfg()
    local DB = ns:GetModule("DB")
    return DB and DB:General() or nil
end

-- Hide only. QuestieTracker:Disable() is never called: it wipes Questie's own
-- TrackedQuests and AutoUntrackedQuests and reloads, which is data loss in another
-- addon's saved variables.
function Coexist:Apply()
    local f = trackerFrame()
    if not f then return end
    local c = cfg()
    if not (c and c.hideQuestieTracker) then return end

    f:Hide()
    if self._hookedFrame ~= f then
        self._hookedFrame = f
        f:HookScript("OnShow", function(frame)
            local live = cfg()
            if live and live.hideQuestieTracker then frame:Hide() end
        end)
    end
end

function Coexist:MaybePrompt()
    if not (ns.db and ns.db.global) then return end
    if ns.db.global.questieTrackerPrompted then return end
    if not trackerFrame() then return end

    -- Marked asked before the dialog is shown, so dismissing it with Escape counts as an
    -- answer. A prompt that returns because the player closed it is a nag.
    ns.db.global.questieTrackerPrompted = true

    local Dialog = ns:GetModule("Dialog")
    if not Dialog then return end
    Dialog:Show({
        title    = "EQ Objective Tracker",
        text     = L["Questie's own quest tracker is on screen alongside this one.\n\nHide Questie's tracker? You can change this later on the General tab. This only hides the frame, and leaves Questie's settings and tracked quests alone."],
        button1  = L["Hide it"],
        button2  = L["Keep both"],
        onAccept = function()
            local c = cfg()
            if c then c.hideQuestieTracker = true end
            Coexist:Apply()
        end,
    })
end

-- Questie builds its tracker lazily, a second or so after this addon's PLAYER_LOGIN, so the
-- frame genuinely cannot be hidden before it exists and some flash is unavoidable. The early
-- polls are dense to keep that to about a frame - a flat 5s interval let it sit on screen for
-- a visible beat. Once the frame is found, Apply installs the OnShow hook and polling stops
-- mattering, so the dense window costs nothing after the first few seconds.
local function retryDelay(tries)
    if tries <= 20 then return 0.15 end
    if tries <= 34 then return 0.5 end
    if tries <= 44 then return 2 end
    return nil
end

function Coexist:OnEnable()
    local generation, tries = 0, 0
    local poll
    poll = function(gen)
        if gen ~= generation then return end
        self:Apply()
        self:MaybePrompt()
        -- Bounded, and cancelled by a newer generation. An open-ended retry chain whose
        -- guard gets wiped is a defect shape this addon already carries elsewhere.
        if not trackerFrame() then
            tries = tries + 1
            local delay = retryDelay(tries)
            if delay then
                C_Timer.After(delay, function() poll(gen) end)
            end
        end
    end

    local function restart()
        generation = generation + 1
        tries = 0
        poll(generation)
    end

    ns:GetModule("Events"):On("PLAYER_ENTERING_WORLD", restart)
    restart()
end

function Coexist:DebugLine()
    local f = trackerFrame()
    local c = cfg()
    return ("questie: base frame %s | hide setting %s | hook %s"):format(
        f and (f:IsShown() and "shown" or "hidden") or "absent",
        tostring(c and c.hideQuestieTracker),
        self._hookedFrame and "installed" or "missing")
end
