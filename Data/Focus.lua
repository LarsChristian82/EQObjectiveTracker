local _, ns = ...

-- Which row the player is working on, for a client with no super-track. Retail marks a focused
-- row with the -SuperTracked atlas and drives C_SuperTrack instead, so only the Classic TOCs
-- list this file and nothing on retail reads it.
--
-- Session state on purpose. Nothing is persisted, so a login never republishes a focus the
-- player did not just ask for, and no listener has to guard against one.
local Focus = ns:RegisterModule("Focus", {})

local focusedProvider, focusedID
local dirtyHandlers = {}

function Focus:OnDirty(fn)
    dirtyHandlers[#dirtyHandlers + 1] = fn
end

function Focus:Get()
    return focusedProvider, focusedID
end

function Focus:Is(providerID, entryID)
    return focusedProvider ~= nil and focusedProvider == providerID and focusedID == entryID
end

function Focus:Set(providerID, entryID)
    -- Normalized first so a clear cannot be stored as a provider with no entry, which would
    -- make the no-op check below miss and announce a clear over an already empty focus.
    if not entryID then providerID = nil end
    if focusedProvider == providerID and focusedID == entryID then return false end

    -- A clear is announced against the provider that LOST focus, so a listener scoped to one
    -- provider can tell whether the clear concerns it.
    local announceProvider = providerID or focusedProvider
    focusedProvider, focusedID = providerID, entryID

    local API = ns:GetModule("API")
    if API then API:NotifyFocus(announceProvider, entryID) end
    for i = 1, #dirtyHandlers do dirtyHandlers[i]() end
    return true
end

function Focus:Toggle(providerID, entryID)
    if self:Is(providerID, entryID) then return self:Set(nil, nil) end
    return self:Set(providerID, entryID)
end
