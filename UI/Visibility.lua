local _, ns = ...

local Visibility = ns:RegisterModule("Visibility", {})

local function cfg()
    return ns:GetModule("DB"):General()
end

local function inCombat()
    -- PLAYER_REGEN_DISABLED fires just before InCombatLockdown reports true, so the
    -- event-tracked flag has to count as well or the first hide lands a frame late.
    return InCombatLockdown() or Visibility._inCombat == true
end

local function inMythicPlus()
    if not ns.Has.MythicPlus then return false end
    return C_ChallengeMode.IsChallengeModeActive() and true or false
end

-- The manual hide is folded in here so one function owns every reason the tracker is not
-- on screen, and /eqot toggle never has to fight an event that repaints it.
local function shouldHide(f)
    if f._eqotUserHidden then return true end
    local g = cfg()
    if not g then return false end
    if g.hideInCombat     and inCombat()                                then return true end
    if g.hideInInstances  and IsInInstance and (IsInInstance())         then return true end
    if g.hideInMythicPlus and inMythicPlus()                            then return true end
    if g.hideOnMapOpen    and WorldMapFrame and WorldMapFrame:IsShown() then return true end
    return false
end

-- A real hide, unlike EQ's. EQ keeps the frame shown at alpha 0 during combat because its
-- tracker owns secure item buttons, which makes Show and Hide protected there - but that
-- leaves an invisible frame still taking clicks, tooltips and the wheel, which EQ patches
-- on only two of its own click paths. EQOT has no secure children yet, so this hides for
-- real. When the quest item buttons land, this has to go back to the alpha path AND guard
-- every mouse handler, or that click trap arrives with them.
local function setVisible(f, visible)
    f:SetAlpha(visible and 1 or 0)
    f._eqotHidden = (not visible) or nil
    if visible then f:Show() else f:Hide() end
end

function Visibility:Apply()
    local Tracker = ns:GetModule("Tracker")
    local f = Tracker and Tracker.frame
    if not f then return end

    local visible = not shouldHide(f)
    setVisible(f, visible)
    if visible and f._eqotPendingRender then
        f._eqotPendingRender = nil
        Tracker:Refresh()
    end
end

function Visibility:IsRuleHiding()
    local Tracker = ns:GetModule("Tracker")
    local f = Tracker and Tracker.frame
    if not f then return false end
    local was = f._eqotUserHidden
    f._eqotUserHidden = nil
    local hidden = shouldHide(f)
    f._eqotUserHidden = was
    return hidden
end

function Visibility:DebugLine()
    local g = cfg() or {}
    local Tracker = ns:GetModule("Tracker")
    local f = Tracker and Tracker.frame
    return ("visibility: ruleHide=%s | cfg combat=%s inst=%s m+=%s map=%s | now combat=%s inst=%s m+=%s map=%s | frame %s alpha=%.2f pending=%s")
        :format(tostring(self:IsRuleHiding()),
                tostring(g.hideInCombat), tostring(g.hideInInstances),
                tostring(g.hideInMythicPlus), tostring(g.hideOnMapOpen),
                tostring(inCombat()),
                tostring(IsInInstance and (IsInInstance()) or false),
                tostring(inMythicPlus()),
                tostring(WorldMapFrame and WorldMapFrame:IsShown() or false),
                f and (f:IsShown() and "shown" or "hidden") or "none",
                f and f:GetAlpha() or -1,
                tostring((f and f._eqotPendingRender) and true or false))
end

function Visibility:OnEnable()
    local Events = ns:GetModule("Events")
    local function apply() self:Apply() end

    Events:On("PLAYER_REGEN_DISABLED", function()
        Visibility._inCombat = true
        Visibility:Apply()
    end)
    Events:On("PLAYER_REGEN_ENABLED", function()
        Visibility._inCombat = false
        Visibility:Apply()
    end)
    Events:On("CHALLENGE_MODE_START",     apply)
    Events:On("CHALLENGE_MODE_COMPLETED", apply)

    -- The map frame is load-on-demand, so the hook is taken at the first login rather than
    -- here, and guarded so a second PLAYER_ENTERING_WORLD does not stack it.
    Events:On("PLAYER_ENTERING_WORLD", function()
        if WorldMapFrame and not Visibility._mapHooked then
            Visibility._mapHooked = true
            WorldMapFrame:HookScript("OnShow", apply)
            WorldMapFrame:HookScript("OnHide", apply)
        end
        apply()
    end)

    self:Apply()
end
