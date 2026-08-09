local _, ns = ...

local Coexist = ns:RegisterModule("QuestieCoexist", {})
local L       = ns.L

-- The other tracker's root frame is built lazily, after this addon's PLAYER_LOGIN, and is
-- nil outright while that tracker is switched off, so it is resolved on every check and
-- never cached.
local function trackerFrame()
    local f = Questie_BaseFrame
    if type(f) == "table" and type(f.Hide) == "function" then return f end
    return nil
end

local function cfg()
    local DB = ns:GetModule("DB")
    return DB and DB:General() or nil
end

-- Hide only. The other addon's own disable path is never called: it clears its saved
-- tracked quests and reloads, which is data loss in another addon's saved variables.
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

    -- Gated on SHOWN, not on the frame existing. That frame is built hidden and only shown
    -- once the player has a quest, so keying on existence asked "another tracker is on
    -- screen alongside this one" with nothing on screen - and the flag below is account
    -- wide and never cleared, so that wasted the one prompt the player ever gets.
    local f = trackerFrame()
    if not (f and f:IsShown()) then return end

    local Dialog = ns:GetModule("Dialog")
    if not Dialog then return end

    -- Marked asked before the dialog is shown, so dismissing it with Escape counts as an
    -- answer. A prompt that returns because the player closed it is a nag. After the Dialog
    -- lookup, or a missing module would burn the flag with no prompt ever shown.
    ns.db.global.questieTrackerPrompted = true

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

-- The one condition for the whole feature, so the login prompt and the Options checkbox can
-- never disagree about whether the other addon is here. C_AddOns was not among the values
-- measured on the Classic clients, so a missing API falls back to that addon's own global
-- rather than switching the feature off where it is really present.
function Coexist:QuestiePresent()
    if ns.Has.AddOns and C_AddOns.IsAddOnLoaded("Questie") then return true end
    return Questie ~= nil
end

-- The frame cannot be hidden before it exists, so some flash is unavoidable. The early polls
-- are dense because a flat 5 second interval left that tracker on screen for a visible beat
-- after every reload.
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
        -- What counts as done depends on the setting, and conflating the two broke this
        -- once: while hiding is ON the chain must run until the hook is actually installed,
        -- because "the player has already been asked" says nothing about whether that frame
        -- exists yet. Keying on the prompt flag alone stopped the chain on the first
        -- tick for anyone who had answered previously, and their tracker came back.
        -- Bounded either way, and cancelled by a newer generation.
        local c = cfg()
        local settled
        if c and c.hideQuestieTracker then
            settled = self._hookedFrame ~= nil
        else
            settled = ns.db and ns.db.global and ns.db.global.questieTrackerPrompted
        end
        if not settled then
            tries = tries + 1
            local delay = retryDelay(tries)
            if delay then
                C_Timer.After(delay, function() poll(gen) end)
            end
        end
    end

    -- Without this gate the full retry chain runs on every loading screen on retail, where
    -- that addon can never be present, for a feature that can never apply there.
    local function restart()
        if not self:QuestiePresent() then return end
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
