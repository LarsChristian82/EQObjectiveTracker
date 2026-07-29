local _, ns = ...

-- The one module that reads quest APIs and builds a texture in the same file. It
-- decorates Blizzard's flight map rather than the tracker, so it has no Entry to split
-- across the Data and UI layers and forcing one on it would buy nothing.
local TaxiHighlight = ns:RegisterModule("TaxiHighlight", {})

local MAX_RETRIES   = 3
local RETRY_DELAY_S = 0.10
local GLOW_SIZE     = 36
local GLOW_ATLAS    = "loottoast-glow"

local _glow, _retryFn
local _retriesLeft = 0

local function ensureGlow()
    if _glow then return _glow end
    _glow = UIParent:CreateTexture(nil, "OVERLAY")
    _glow:SetSize(GLOW_SIZE, GLOW_SIZE)
    if ns.Util.AtlasExists(GLOW_ATLAS) then
        _glow:SetAtlas(GLOW_ATLAS)
    else
        _glow:SetTexture("Interface\\Buttons\\WHITE8X8")
        _glow:SetVertexColor(1, 0.85, 0, 0.45)
        _glow:SetBlendMode("ADD")
    end
    _glow:Hide()
    return _glow
end

local function detachGlow()
    if not _glow then return end
    _glow:Hide()
    _glow:ClearAllPoints()
    _glow:SetParent(UIParent)
end

local function attachGlow(pin)
    local g = ensureGlow()
    g:SetParent(pin)
    g:ClearAllPoints()
    g:SetPoint("CENTER", pin, "CENTER", 0, 0)
    g:Show()
end

local function questPosInContinent(continentMapID)
    if not (ns.Has.SuperTrack and C_QuestLog.GetNextWaypoint
            and C_Map.GetMapRectOnMap) then return nil end

    local qid = C_SuperTrack.GetSuperTrackedQuestID()
    if not qid or qid == 0 then return nil end

    local wm, wx, wy = C_QuestLog.GetNextWaypoint(qid)
    if not (wm and wx and wy) then return nil end

    -- GetMapRectOnMap returns four scalars, not a rect table
    local minX, maxX, minY, maxY = C_Map.GetMapRectOnMap(wm, continentMapID)
    if not (minX and maxX and minY and maxY) then return nil end
    return minX + wx * (maxX - minX), minY + wy * (maxY - minY)
end

local function findClosestNode(continentMapID, qcx, qcy)
    if not (C_TaxiMap and C_TaxiMap.GetAllTaxiNodes) then return nil end
    local nodes = C_TaxiMap.GetAllTaxiNodes(continentMapID)
    if not nodes or #nodes == 0 then return nil end

    local best, bestDist
    for i = 1, #nodes do
        local n   = nodes[i]
        local pos = n and n.position
        if pos and pos.x and pos.y then
            local dx, dy = pos.x - qcx, pos.y - qcy
            local d = dx * dx + dy * dy
            if not bestDist or d < bestDist then
                bestDist, best = d, n
            end
        end
    end
    return best
end

local function attemptHighlight()
    if not (FlightMapFrame and FlightMapFrame.IsShown and FlightMapFrame:IsShown()) then
        return
    end

    local mapID = FlightMapFrame.GetMapID and FlightMapFrame:GetMapID()
    if not mapID then return end

    local qcx, qcy = questPosInContinent(mapID)
    if not qcx then return end

    local target = findClosestNode(mapID, qcx, qcy)
    if not (target and target.nodeID) then return end

    if FlightMapFrame.EnumerateAllPins then
        for pin in FlightMapFrame:EnumerateAllPins() do
            local td = pin and pin.taxiNodeData
            if td and td.nodeID == target.nodeID then
                attachGlow(pin)
                return
            end
        end
    end

    -- The pin pool can still be empty on the first frame after the map opens
    if _retriesLeft > 0 then
        _retriesLeft = _retriesLeft - 1
        if not _retryFn then _retryFn = attemptHighlight end
        C_Timer.After(RETRY_DELAY_S, _retryFn)
    end
end

function TaxiHighlight:OnEnable()
    local Events = ns:GetModule("Events")
    Events:On("TAXIMAP_OPENED", function()
        detachGlow()
        _retriesLeft = MAX_RETRIES
        attemptHighlight()
    end)
    Events:On("TAXIMAP_CLOSED", function()
        detachGlow()
        _retriesLeft = 0
    end)
end
