local _, ns = ...

local Bonus = ns:RegisterModule("ScenarioBonus", {})
local L     = ns.L

-- Midnight can hand back "secret values" that error when matched by tainted addon code,
-- even though they still report type "string"
local _issecret = _G.issecretvalue

local REFRESH_DEBOUNCE = 0.25
local DELVE_DIFFICULTY = 208

-- Delves expose no scenario bonus steps, so these vignette, spell and aura IDs stand in for
-- them. They churn every season, so they are the first thing to check when a delve tracks
-- nothing - read them back with /eqot bonushud.
local NEMESIS_PACK_VIGNETTE  = 7531
local RAGER_NAME_MATCH       = "voidfused"
local BANNER_INTERACT_SPELLS = { [1269411] = true, [1269412] = true, [1269416] = true }
local BANNER_BUFFS = {
    1271918, 1271945, 1272609, 1272666, 1272756, 1272769,
    1272809, 1272810, 1272813, 1272814, 1273058, 1273066,
}
local BANNER_RANK = { announced = 1, clicked = 2, buffed = 3, eliteUp = 4, grand = 5 }

local MSG_EVENTS = {
    "CHAT_MSG_RAID_BOSS_EMOTE", "CHAT_MSG_MONSTER_YELL",
    "CHAT_MSG_MONSTER_EMOTE",   "CHAT_MSG_MONSTER_SAY",
    "UI_INFO_MESSAGE",          "CHAT_MSG_SYSTEM",
}
local VIGNETTE_EVENTS = { "VIGNETTE_MINIMAP_UPDATED", "VIGNETTES_UPDATED" }

local bannerState, ragerGUID
local nemesisSeen, nemesisSeenCount, nemesisRemaining = {}, 0, nil
local trackedDelve, delveTier
local delveEventsOn = false

local model, stepPool, critPool = {}, {}, {}
local dirtyFns = {}

local function state()
    local DB = ns:GetModule("DB")
    local t  = DB and DB:Tracker()
    if not t then return nil end
    t.scenarioBonusHUD = t.scenarioBonusHUD or {}
    return t.scenarioBonusHUD
end

function Bonus:Enabled()
    local st = state()
    return (st and st.enabled == true) or false
end

local function playerInDelve()
    if not GetInstanceInfo then return false end
    local _, _, diffID = GetInstanceInfo()
    return diffID == DELVE_DIFFICULTY
end

function Bonus:InDelve() return playerInDelve() end

function Bonus:OnDirty(fn)
    if fn then dirtyFns[#dirtyFns + 1] = fn end
end

local function notifyDirty()
    for i = 1, #dirtyFns do
        local ok, err = pcall(dirtyFns[i])
        if not ok then geterrorhandler()(err) end
    end
end

function Bonus:QueueRefresh()
    if not self:Enabled() then return end
    ns:GetModule("Events"):Debounce("eqot.scenariobonus", REFRESH_DEBOUNCE, notifyDirty)
end

local function resetModel()
    for i = #model, 1, -1 do
        local step = model[i]
        local crit = step.criteria
        for c = #crit, 1, -1 do
            critPool[#critPool + 1] = crit[c]
            crit[c] = nil
        end
        stepPool[#stepPool + 1] = step
        model[i] = nil
    end
end

local function pushStep(name, rewardQuestID, rewardIcon)
    local step = tremove(stepPool) or { criteria = {} }
    step.name          = name
    step.rewardQuestID = rewardQuestID
    step.rewardIcon    = rewardIcon
    model[#model + 1]  = step
    return step
end

local function pushCriterion(step, text, completed)
    local c = tremove(critPool) or {}
    c.text, c.completed = text, completed
    step.criteria[#step.criteria + 1] = c
end

-- Reward data streams in, so a nil icon here is a not-yet rather than a never. The renderer
-- falls back to a generic chest and the next refresh picks up the real one.
local function rewardIconFor(questID)
    if not (questID and questID ~= 0) then return nil end
    if HaveQuestRewardData and not HaveQuestRewardData(questID)
       and C_TaskQuest and C_TaskQuest.RequestPreloadRewardData then
        C_TaskQuest.RequestPreloadRewardData(questID)
    end
    if not GetQuestLogRewardInfo then return nil end
    local _, texture = GetQuestLogRewardInfo(1, questID)
    return texture
end

local function gatherScenarioSteps()
    if not (C_Scenario and C_Scenario.GetBonusSteps and C_ScenarioInfo
            and C_ScenarioInfo.GetCriteriaInfoByStep) then return false end
    local steps = C_Scenario.GetBonusSteps()
    if not (steps and #steps > 0) then return false end

    for i = 1, #steps do
        local idx = steps[i]
        local name, description, numCriteria, _, _, _, shouldShow = C_Scenario.GetStepInfo(idx)
        if shouldShow then
            local rewardQuestID = C_Scenario.GetBonusStepRewardQuestID
                                  and C_Scenario.GetBonusStepRewardQuestID(idx)
            local step = pushStep((name and name ~= "" and name) or description or "",
                                  rewardQuestID, rewardIconFor(rewardQuestID))
            for c = 1, (numCriteria or 0) do
                local info = C_ScenarioInfo.GetCriteriaInfoByStep(idx, c)
                if info then
                    local desc  = info.description or ""
                    local label = desc
                    if not info.isFormatted and not info.completed
                       and info.totalQuantity and info.totalQuantity > 0 then
                        label = ("%d/%d %s"):format(info.quantity or 0, info.totalQuantity, desc)
                    end
                    pushCriterion(step, label, info.completed and true or false)
                end
            end
        end
    end
    return #model > 0
end

local function readTier()
    if not (C_ScenarioInfo and C_ScenarioInfo.GetScenarioStepInfo
            and C_UIWidgetManager and C_UIWidgetManager.GetAllWidgetsBySetID) then return nil end
    local ok, stepInfo = pcall(C_ScenarioInfo.GetScenarioStepInfo)
    if not (ok and stepInfo and stepInfo.widgetSetID) then return nil end
    local VT     = Enum and Enum.UIWidgetVisualizationType
    local getter = C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo
    if not (VT and VT.ScenarioHeaderDelves and getter) then return nil end
    local ok2, widgets = pcall(C_UIWidgetManager.GetAllWidgetsBySetID, stepInfo.widgetSetID)
    if not (ok2 and type(widgets) == "table") then return nil end
    for _, w in ipairs(widgets) do
        if w.widgetType == VT.ScenarioHeaderDelves then
            local ok3, hv = pcall(getter, w.widgetID)
            local tt = ok3 and hv and tonumber(hv.tierText)
            if tt then return tt end
        end
    end
    return nil
end

local function setBannerState(s)
    if not BANNER_RANK[s] then return end
    if bannerState and BANNER_RANK[s] <= BANNER_RANK[bannerState] then return end
    bannerState = s
    Bonus:QueueRefresh()
end

local function scanVignettes()
    if not playerInDelve() then return end
    if not (C_VignetteInfo and C_VignetteInfo.GetVignettes) then return end
    local ok, vigs = pcall(C_VignetteInfo.GetVignettes)
    if not (ok and type(vigs) == "table") then return end

    local ragerSeen, packCount = false, 0
    for _, vguid in ipairs(vigs) do
        local ok2, v = pcall(C_VignetteInfo.GetVignetteInfo, vguid)
        if ok2 and v then
            if v.vignetteID == NEMESIS_PACK_VIGNETTE then
                packCount = packCount + 1
                local key = v.objectGUID
                if key and not nemesisSeen[key] then
                    nemesisSeen[key]  = true
                    nemesisSeenCount = nemesisSeenCount + 1
                end
            end
            local nm = v.name
            if type(nm) == "string" then
                local ln = nm:lower()
                if ln:find(RAGER_NAME_MATCH, 1, true) then
                    ragerSeen, ragerGUID = true, vguid
                    setBannerState("eliteUp")
                elseif ln:find("grand sanctified", 1, true) then
                    setBannerState("grand")
                elseif ln:find("sanctified spoils", 1, true) then
                    setBannerState("clicked")
                elseif ln:find("sanctified banner", 1, true) then
                    setBannerState("announced")
                end
            end
        end
    end
    if ragerGUID and not ragerSeen and bannerState == "eliteUp" then
        setBannerState("grand")
    end
    nemesisRemaining = packCount
end

local function onUnitAura(_, unit)
    if unit ~= "player" then return end
    if not playerInDelve() then return end
    if bannerState and BANNER_RANK[bannerState] >= BANNER_RANK.buffed then return end
    if not (C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID) then return end
    for _, sid in ipairs(BANNER_BUFFS) do
        local ok, aura = pcall(C_UnitAuras.GetPlayerAuraBySpellID, sid)
        if ok and aura then setBannerState("buffed"); return end
    end
    for sid in pairs(BANNER_INTERACT_SPELLS) do
        local ok, aura = pcall(C_UnitAuras.GetPlayerAuraBySpellID, sid)
        if ok and aura then setBannerState("clicked"); return end
    end
end

local function onUnitCast(_, unit, _, spellID)
    if unit ~= "player" then return end
    if not (spellID and playerInDelve()) then return end
    if BANNER_INTERACT_SPELLS[spellID] then setBannerState("clicked") end
end

local function onMessage(event, a1, a2)
    if not playerInDelve() then return end
    local text = (event == "UI_INFO_MESSAGE") and a2 or a1
    -- find on a secret value throws, and the vignette scan still catches the banner
    if _issecret and _issecret(text) then return end
    if type(text) ~= "string" or text == "" then return end
    if text:lower():find("sanctified banner", 1, true) then setBannerState("announced") end
end

local function onVignette()
    if not playerInDelve() then return end
    pcall(scanVignettes)
    Bonus:QueueRefresh()
end

local function resetRun()
    delveTier    = nil
    bannerState, ragerGUID = nil, nil
    nemesisRemaining, nemesisSeenCount = nil, 0
    wipe(nemesisSeen)
end

-- Reset per-run state on delve change or exit so a new run never inherits the old packs or
-- banner. The exit half has to be driven from a world transition: gatherDelveModel is only
-- ever reached from inside a delve, so it can never observe the player leaving one, and
-- re-entering the same delve would otherwise match trackedDelve and skip the reset.
local function checkRun()
    if not playerInDelve() then
        if trackedDelve then
            trackedDelve = nil
            resetRun()
        end
        return
    end
    local name = (GetInstanceInfo and GetInstanceInfo()) or "delve"
    if name ~= trackedDelve then
        trackedDelve = name
        resetRun()
    end
end

local function gatherDelveModel()
    checkRun()
    if not playerInDelve() then return false end
    pcall(scanVignettes)

    local step = pushStep(L["Delve Bonus Loot"], nil, nil)

    if nemesisSeenCount > 0 then
        if not delveTier then delveTier = readTier() end
        local tier, expected = delveTier or 0, 0
        if     tier >= 10 then expected = 4
        elseif tier >= 8  then expected = 3
        elseif tier >= 6  then expected = 2
        elseif tier >= 4  then expected = 1 end
        local total  = math.max(expected, nemesisSeenCount)
        local killed = math.max(0, nemesisSeenCount - (nemesisRemaining or 0))
        pushCriterion(step, (L["Nemesis Strongbox: %d/%d packs"]):format(killed, total),
                      killed >= total)
    end

    if bannerState == "grand" then
        pushCriterion(step, L["Sanctified Banner: Grand Spoils earned"], true)
    elseif bannerState == "buffed" or bannerState == "clicked" then
        pushCriterion(step, L["Sanctified Banner: bonus Spoils secured"], true)
    elseif bannerState == "eliteUp" then
        pushCriterion(step, L["Sanctified Banner: kill the Voidfused Rager"], false)
    elseif bannerState == "announced" then
        pushCriterion(step, L["Sanctified Banner: find it for bonus loot"], false)
    end

    if #step.criteria == 0 then resetModel(); return false end
    return true
end

-- The unit events are the expensive half, so they are held only while a delve is actually
-- being tracked. UNIT_AURA is filtered to the player in the handler rather than through
-- RegisterUnitEvent, since the shared event frame registers by name.
local function setDelveEvents(on)
    if on == delveEventsOn then return end
    delveEventsOn = on
    local Events = ns:GetModule("Events")
    local bind = on and Events.On or Events.Off
    bind(Events, "UNIT_AURA", onUnitAura)
    bind(Events, "UNIT_SPELLCAST_SUCCEEDED", onUnitCast)
    for i = 1, #MSG_EVENTS      do bind(Events, MSG_EVENTS[i], onMessage) end
    for i = 1, #VIGNETTE_EVENTS do bind(Events, VIGNETTE_EVENTS[i], onVignette) end
end

function Bonus:Reconcile()
    setDelveEvents(self:Enabled() and playerInDelve())
end

-- Entries are valid only until the next call, exactly as a provider's are.
function Bonus:GetModel()
    resetModel()
    if not self:Enabled() then return nil end
    local any
    if playerInDelve() then
        any = gatherDelveModel()
    else
        any = gatherScenarioSteps()
    end
    return any and model or nil
end

function Bonus:DebugLine()
    return ("source=%s banner=%s packs seen %d remaining %s tier=%s"):format(
        playerInDelve() and "delve" or "scenario",
        tostring(bannerState), nemesisSeenCount,
        tostring(nemesisRemaining), tostring(delveTier))
end

function Bonus:DumpLines(out)
    out[#out + 1] = ("enabled=%s inDelve=%s tier=%s banner=%s nemesisSeen=%d remaining=%s")
        :format(tostring(self:Enabled()), tostring(playerInDelve()), tostring(readTier()),
                tostring(bannerState), nemesisSeenCount, tostring(nemesisRemaining))

    if GetInstanceInfo then
        local _, itype, diffID = GetInstanceInfo()
        out[#out + 1] = ("instance: type=%s difficultyID=%s (208=Delve)")
            :format(tostring(itype), tostring(diffID))
    end

    if C_Scenario and C_Scenario.GetStepInfo then
        local sname, _, ncrit = C_Scenario.GetStepInfo()
        out[#out + 1] = ("current step: name=%s numCriteria=%s")
            :format(tostring(sname), tostring(ncrit))
        if C_ScenarioInfo and C_ScenarioInfo.GetCriteriaInfo then
            for i = 1, math.min(ncrit or 0, 10) do
                local info = C_ScenarioInfo.GetCriteriaInfo(i)
                if info then
                    out[#out + 1] = ("  mainCrit[%d] %s done=%s %s/%s"):format(i,
                        tostring(info.description), tostring(info.completed),
                        tostring(info.quantity), tostring(info.totalQuantity))
                end
            end
        end
    end

    local steps = C_Scenario and C_Scenario.GetBonusSteps and C_Scenario.GetBonusSteps()
    out[#out + 1] = "GetBonusSteps count=" .. tostring(steps and #steps or "nil")

    if C_VignetteInfo and C_VignetteInfo.GetVignettes then
        local ok, vigs = pcall(C_VignetteInfo.GetVignettes)
        out[#out + 1] = "vignettes=" .. tostring(ok and type(vigs) == "table" and #vigs or "nil")
        if ok and type(vigs) == "table" then
            for _, g in ipairs(vigs) do
                local ok2, v = pcall(C_VignetteInfo.GetVignetteInfo, g)
                if ok2 and v then
                    out[#out + 1] = ("  vig id=%s name=%s")
                        :format(tostring(v.vignetteID), tostring(v.name))
                end
            end
        end
    end
    return out
end

function Bonus:OnEnable()
    -- RegisterEvent throws on an event the client does not know, so a flavor without bonus
    -- steps must never reach the delve and scenario registrations below.
    if not ns.Has.ScenarioBonus then return end
    local Events = ns:GetModule("Events")
    local function refresh()
        Bonus:Reconcile()
        Bonus:QueueRefresh()
    end
    -- Only the world transitions test for an exit. A criteria update fires throughout a run,
    -- so letting one observe a momentarily stale "not in a delve" would wipe the live run.
    local function worldChanged()
        checkRun()
        refresh()
    end
    Events:On("SCENARIO_UPDATE",                     refresh)
    Events:On("SCENARIO_CRITERIA_UPDATE",            refresh)
    Events:On("SCENARIO_CRITERIA_SHOW_STATE_UPDATE", refresh)
    Events:On("SCENARIO_COMPLETED",                  refresh)
    Events:On("ACTIVE_DELVE_DATA_UPDATE",            refresh)
    Events:On("PLAYER_ENTERING_WORLD",               worldChanged)
    Events:On("ZONE_CHANGED_NEW_AREA",               worldChanged)
    self:Reconcile()
end
