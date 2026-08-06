local _, ns = ...

local Entry    = ns:GetModule("Entry")
local Registry = ns:GetModule("Registry")
local L        = ns.L

local STATE, LINE, ICON = Entry.STATE, Entry.LINE, Entry.ICON

local Scenarios = {
    id       = "scenarios",
    groups   = { "scenarios" },
    -- Declares no idSpace, so it never claims and is never blocked by one. The scenario
    -- draws in its own container, outside Sections:Order(), so this only sets build order.
    priority = 1,
    tags     = {},
}

-- Only one scenario is ever active, so the entry keeps a constant id and the store reuses
-- its table across stages instead of churning a new one on every criteria update.
local ENTRY_ID = "scenario"

local DELVE_TYPE        = 8
local MYTHIC_PLUS_TYPE  = 1
local PROVING_TYPE      = 2
local DUNGEON_TYPE      = 5
local WARFRONT_TYPE     = 7
local FOLLOWER_DUNGEON  = 205

local store = Entry.NewStore({
    groupID   = "scenarios",
    icon      = { kind = ICON.NONE },
    isTracked = true,
})

-- Reused rather than rebuilt: GetEntries runs on every render, so a fresh table here
-- would allocate on every quest event for as long as a scenario is up.
local facts  = { active = false }
local banner = {}

local function categoryLabel(scenarioType, textureKit, scenarioName, instType, diffID)
    -- Ritual Sites reuse the Delve scenarioType, so only the texture kit separates them
    if scenarioType == DELVE_TYPE then
        if textureKit and textureKit ~= "" and not textureKit:lower():find("delve") then
            return L["Ritual Site"]
        end
        return L["Delves"]
    end
    if textureKit and textureKit:lower():find("delve") then return L["Delves"] end
    if scenarioType == MYTHIC_PLUS_TYPE then return L["Mythic+"] end
    if scenarioType == DUNGEON_TYPE     then return L["Dungeon"] end
    if scenarioType == WARFRONT_TYPE    then return L["Warfront"] end
    if scenarioType == PROVING_TYPE     then return L["Proving Grounds"] end

    -- Normal dungeons also report scenarioType 3, so only difficulty 205 means Follower Dungeon
    if diffID == FOLLOWER_DUNGEON then return L["Follower Dungeon"] end

    -- Matched against the English name, so this misses on a non-English client. EQ has the
    -- same gap. The fallbacks below still produce a sensible label.
    if scenarioName then
        local n = scenarioName:lower()
        if n:find("void incursion") or n:find("void assault") then return L["Void Incursion"] end
    end

    if instType == "party" then return L["Dungeon"]      end
    if instType == "raid"  then return L["Raid"]         end
    if instType == "pvp"   then return L["Battleground"] end
    if instType == "arena" then return L["Arena"]        end

    if scenarioName and scenarioName ~= "" then return scenarioName end
    return L["Scenario"]
end

local function resolveName(scenarioName, instName, instType)
    if instName and instName ~= "" and instType and instType ~= "none" then
        return instName
    end
    if scenarioName and scenarioName ~= "" then return scenarioName end
    return nil
end

-- Unreleased steps can return an internal build string where the criteria text belongs.
-- Real criteria never open with a version number or carry a "- Step NN" marker.
local function looksInternal(s)
    if not s or s == "" then return false end
    if s:find("^%s*%d+%.%d+%.%d+") then return true end
    if s:find("%-%s*Step%s+%d+")   then return true end
    if s:find("Scenario%s+%d%d")   then return true end
    return false
end

local function readScenario()
    local name, stage, numStages, _, _, _, _, _, _, sType, _, kit = C_Scenario.GetInfo()
    return name, stage, numStages, sType, kit
end

local function readStep()
    if not C_Scenario.GetStepInfo then return nil, 0, nil end
    local stageName, _, numCriteria, _, _, _, _, _, _, _, _, widgetSetID = C_Scenario.GetStepInfo()
    return stageName, numCriteria or 0, widgetSetID
end

local function fillCriteria(e, numCriteria)
    Entry.BeginLines(e)
    local done, total = 0, 0
    for i = 1, numCriteria do
        local info = C_ScenarioInfo.GetCriteriaInfo(i)
        if info then
            local desc = info.description or ""
            if looksInternal(desc) then desc = "" end

            -- Weighted progress reports quantity as a percentage rather than a count, so
            -- the denominator is fixed at 100 rather than read from totalQuantity.
            local isWeighted = info.isWeightedProgress and true or false
            -- isFormatted means the description already carries its own count
            local hasMeter = (not info.isFormatted) and info.totalQuantity
                             and info.totalQuantity > 0

            if desc ~= "" or isWeighted or hasMeter then
                local ln = Entry.PushLine(e)
                ln.text      = desc
                ln.completed = info.completed and true or false
                if isWeighted then
                    ln.kind    = LINE.WEIGHTED
                    ln.current, ln.required = info.quantity or 0, 100
                elseif hasMeter then
                    ln.kind    = LINE.PROGRESSBAR
                    ln.current, ln.required = info.quantity or 0, info.totalQuantity
                end
                total = total + 1
                if ln.completed then done = done + 1 end
            end
        end
    end
    Entry.EndLines(e)
    return done, total
end

function Scenarios:IsAvailable()
    return ns.Has.Scenario and ns.Has.ScenarioCriteria
end

function Scenarios:GetEntries()
    store:Begin()

    local scenarioName, currentStage, numStages, scenarioType, textureKit = readScenario()
    local active = scenarioName and numStages and numStages > 0
                   and currentStage and currentStage > 0
    if not active then
        facts.active = false
        return store:Finish()
    end

    local stageName, numCriteria, widgetSetID = readStep()

    local instName, instType, diffID
    if GetInstanceInfo then instName, instType, diffID = GetInstanceInfo() end

    local category = categoryLabel(scenarioType, textureKit, scenarioName, instType, diffID)
    local name     = resolveName(scenarioName, instName, instType)

    -- The container draws the stage name on the banner and the category in its own
    -- sub-header, so the entry carries no subtitle and its title is never rendered.
    local e = store:Acquire(ENTRY_ID)
    e.title = (stageName and stageName ~= "" and stageName) or name or L["Scenario"]

    local done, total = fillCriteria(e, numCriteria)
    e.state = (total > 0 and done == total) and STATE.COMPLETE or STATE.ACTIVE

    facts.active       = true
    facts.category     = category
    facts.name         = name
    facts.stageName    = stageName
    facts.stage        = currentStage
    facts.numStages    = numStages
    facts.scenarioType = scenarioType
    facts.textureKit   = textureKit
    facts.widgetSetID  = widgetSetID
    facts.criteria     = total
    facts.instType     = instType
    facts.diffID       = diffID

    return store:Finish()
end

-- The banner is bespoke atlas art with no Entry equivalent, so the display layer reads
-- these facts through a provider method rather than through entry.payload. The theme
-- color resolves to plain numbers here - Data never hands UI a color escape.
function Scenarios:GetBanner()
    if not facts.active then return nil end

    banner.category     = facts.category
    banner.name         = facts.name
    banner.stageName    = facts.stageName
    banner.stage        = facts.stage
    banner.numStages    = facts.numStages
    banner.isFinalStage = facts.numStages > 1 and facts.stage == facts.numStages
    banner.textureKit   = facts.textureKit
    banner.widgetSetID  = facts.widgetSetID

    banner.themeR, banner.themeG, banner.themeB = nil, nil, nil
    if C_ScenarioInfo.GetDisplayInfo then
        local display = C_ScenarioInfo.GetDisplayInfo()
        if display and display.themeColor then
            banner.themeR, banner.themeG, banner.themeB = display.themeColor:GetRGB()
        end
    end
    return banner
end

function Scenarios:OnEntryTooltip(entry, tooltip)
    tooltip:AddLine(entry.title, 1, 0.82, 0)
    if not facts.active then return end
    if facts.name and facts.name ~= entry.title then
        tooltip:AddLine(facts.name, 1, 1, 1)
    end
    tooltip:AddLine(facts.category, 0.6, 0.6, 0.6)
    if facts.numStages > 1 then
        tooltip:AddLine((L["Stage %d of %d"]):format(facts.stage, facts.numStages), 0.6, 0.6, 0.6)
    end
end

function Scenarios:DebugLine()
    if not facts.active then return "no active scenario" end
    return ("%s | %s stage %d/%d | type %s kit %s diff %s inst %s | widgetSet %s | %d criteria"):format(
        facts.category, tostring(facts.stageName), facts.stage, facts.numStages,
        tostring(facts.scenarioType), tostring(facts.textureKit), tostring(facts.diffID),
        tostring(facts.instType), tostring(facts.widgetSetID), facts.criteria)
end

-- EQ debounces its own scenario events. Tracker:Refresh already coalesces, so a second
-- timer here would only add latency.
function Scenarios:Enable(notifyDirty)
    local Events = ns:GetModule("Events")
    Events:On("SCENARIO_UPDATE",                     notifyDirty)
    Events:On("SCENARIO_CRITERIA_UPDATE",            notifyDirty)
    Events:On("SCENARIO_SPELL_UPDATE",               notifyDirty)
    Events:On("SCENARIO_CRITERIA_SHOW_STATE_UPDATE", notifyDirty)
    Events:On("SCENARIO_COMPLETED",                  notifyDirty)
    Events:On("ACTIVE_DELVE_DATA_UPDATE",            notifyDirty)
    Events:On("PLAYER_ENTERING_WORLD",               notifyDirty)
end

Registry:Register(Scenarios)
