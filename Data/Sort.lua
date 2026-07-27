local _, ns = ...

local Sort = ns:RegisterModule("Sort", {})

-- Every comparator reads only normalized Entry fields, so a new provider is sortable
-- the moment it exists - no comparator ever learns about a content type.
local function byTitle(a, b)
    local ta, tb = a.title or "", b.title or ""
    if ta ~= tb then return ta < tb end
    return tostring(a.id) < tostring(b.id)
end

local function byZone(a, b)
    local za, zb = a.zone or "~", b.zone or "~"
    if za ~= zb then return za < zb end
    return byTitle(a, b)
end

local function byStatus(a, b)
    local ca = (a.state == "complete")
    local cb = (b.state == "complete")
    if ca ~= cb then return ca end
    return byTitle(a, b)
end

local function byLevel(a, b)
    local la, lb = a.level or 0, b.level or 0
    if la ~= lb then return la < lb end
    return byTitle(a, b)
end

local function byRecent(a, b)
    local fa, fb = a.addedAt or 0, b.addedAt or 0
    if fa ~= fb then return fa > fb end
    return byTitle(a, b)
end

local MODES = {
    zone   = byZone,
    title  = byTitle,
    status = byStatus,
    level  = byLevel,
    recent = byRecent,
}

-- "distance" and "manual" are deliberately absent in v1: distance needs a position
-- ticker and a per-provider GetDistanceSq, manual needs the drag-drop reorder UI.
function Sort:For(mode)
    return MODES[mode or "zone"] or byZone
end

function Sort:Modes()
    return MODES
end
