local _, ns = ...

-- The public surface another addon reaches through _G.EQObjectiveTracker. EQOT declares no
-- dependency on anything, so every list here is empty in the standalone case and each reader
-- below costs one length check.
--
-- Registrations carry an entry ID and a provider ID, never the entry table itself - entries are
-- rebuilt on every quest event and handing one to a foreign addon would leak a table that is
-- invalid by the time it is read.
local API = ns:RegisterModule("API", {})

API.headerIcons = {}
API.menuItems   = {}

local function slotFor(list, id)
    for i = 1, #list do
        if list[i].id == id then return i end
    end
    return #list + 1
end

function API:AddHeaderIcon(spec)
    if type(spec) ~= "table" or type(spec.id) ~= "string" then return false end
    if type(spec.onClick) ~= "function" or type(spec.texture) ~= "string" then return false end
    self.headerIcons[slotFor(self.headerIcons, spec.id)] = {
        id      = spec.id,
        texture = spec.texture,
        tooltip = spec.tooltip,
        onClick = spec.onClick,
        dbKey   = spec.dbKey,
    }
    local Tracker = ns:GetModule("Tracker")
    if Tracker and Tracker.RebuildHeaderIcons then Tracker:RebuildHeaderIcons() end
    return true
end

function API:RemoveHeaderIcon(id)
    for i = #self.headerIcons, 1, -1 do
        if self.headerIcons[i].id == id then table.remove(self.headerIcons, i) end
    end
    local Tracker = ns:GetModule("Tracker")
    if Tracker and Tracker.RebuildHeaderIcons then Tracker:RebuildHeaderIcons() end
end

function API:HeaderIcons()
    return self.headerIcons
end

-- order interleaves with the provider's own items, which are spaced by ten so a caller can
-- land between any two of them.
function API:AddMenuItem(spec)
    if type(spec) ~= "table" or type(spec.id) ~= "string" then return false end
    if type(spec.onClick) ~= "function" then return false end
    self.menuItems[slotFor(self.menuItems, spec.id)] = {
        id         = spec.id,
        providerID = spec.providerID,
        label      = spec.label,
        order      = tonumber(spec.order) or 999,
        shouldShow = spec.shouldShow,
        onClick    = spec.onClick,
    }
    return true
end

function API:RemoveMenuItem(id)
    for i = #self.menuItems, 1, -1 do
        if self.menuItems[i].id == id then table.remove(self.menuItems, i) end
    end
end

function API:MenuItemsFor(providerID, entryID, out)
    out = out or {}
    for i = 1, #self.menuItems do
        local it = self.menuItems[i]
        if not it.providerID or it.providerID == providerID then
            local show = true
            if it.shouldShow then
                local ok, res = pcall(it.shouldShow, providerID, entryID)
                show = ok and res and true or false
            end
            if show and it.label then
                out[#out + 1] = {
                    id = it.id, kind = "button", label = it.label,
                    order = it.order, external = it,
                }
            end
        end
    end
    return out
end

function API:DebugLine()
    return ("api: %d header icon(s), %d menu item(s)")
        :format(#self.headerIcons, #self.menuItems)
end
