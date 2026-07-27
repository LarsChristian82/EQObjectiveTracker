local _, ns = ...

local Registry = ns:RegisterModule("Registry", {})

Registry.providers = {}
Registry.order     = {}

local dirtyListeners = {}

function Registry:Register(provider)
    if type(provider) ~= "table" or type(provider.id) ~= "string" then
        error("EQOT: provider must be a table with a string id")
    end
    if self.providers[provider.id] then
        error(("EQOT: provider %q already registered"):format(provider.id))
    end
    if type(provider.groups) ~= "table" or #provider.groups == 0 then
        error(("EQOT: provider %q declares no groups"):format(provider.id))
    end
    if type(provider.GetEntries) ~= "function" then
        error(("EQOT: provider %q has no GetEntries"):format(provider.id))
    end

    provider.priority = provider.priority or 100
    provider._groupSet = {}
    for _, g in ipairs(provider.groups) do provider._groupSet[g] = true end
    provider._tagSet = {}
    for _, t in ipairs(provider.tags or {}) do provider._tagSet[t] = true end

    self.providers[provider.id] = provider
    self.order[#self.order + 1]  = provider
    table.sort(self.order, function(a, b)
        if a.priority ~= b.priority then return a.priority < b.priority end
        return a.id < b.id
    end)
    return provider
end

function Registry:Get(id)
    return self.providers[id]
end

function Registry:Active()
    return self.order
end

-- A provider its TOC never loaded contributes no groups, so no section header and no
-- option for it can exist. This is what makes flavor gating free.
function Registry:Groups()
    local seen, out = {}, {}
    for _, p in ipairs(self.order) do
        if p._available then
            for _, g in ipairs(p.groups) do
                if not seen[g] then
                    seen[g] = true
                    out[#out + 1] = g
                end
            end
        end
    end
    return out
end

-- Lets the options panel show a control only when some loaded provider can produce the
-- thing it filters. On Vanilla nothing declares "worldquest", so no dead toggle exists.
function Registry:HasTag(tag)
    for _, p in ipairs(self.order) do
        if p._available and p._tagSet[tag] then return true end
    end
    return false
end

function Registry:OnDirty(fn)
    dirtyListeners[#dirtyListeners + 1] = fn
end

local function fireDirty(providerID)
    for i = 1, #dirtyListeners do
        local ok, err = pcall(dirtyListeners[i], providerID)
        if not ok then geterrorhandler()(err) end
    end
end

function Registry:OnInitialize()
    for _, p in ipairs(self.order) do
        p._available = (type(p.IsAvailable) ~= "function") or (p:IsAvailable() and true or false)
        if p._available and p.Init then
            xpcall(p.Init, geterrorhandler(), p)
        end
    end
end

function Registry:OnEnable()
    for _, p in ipairs(self.order) do
        if p._available and p.Enable then
            local notify = function() fireDirty(p.id) end
            p._notifyDirty = notify
            xpcall(p.Enable, geterrorhandler(), p, notify)
        end
    end
end
