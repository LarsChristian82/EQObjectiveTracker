local _, ns = ...

local Filter = ns:RegisterModule("Filter", {})
local L      = ns.L

-- First match wins, so this order is the precedence: a campaign daily filters as
-- campaign. Adding a category is one row here plus the tag on the provider - no
-- comparator, renderer, or branch anywhere else learns about it.
Filter.CATEGORIES = {
    { tag = "worldquest", key = "showWorld",    label = L["World Quests"]     },
    { tag = "bonus",      key = "showBonus",    label = L["Bonus Objectives"] },
    { tag = "campaign",   key = "showCampaign", label = L["Campaign quests"]  },
    { tag = "daily",      key = "showDaily",    label = L["Daily quests"]     },
    { tag = "weekly",     key = "showWeekly",   label = L["Weekly quests"]    },
    { tag = nil,          key = "showNormal",   label = L["Normal quests"]    },
}

-- Hidden is keyed by provider then entry id so two providers can never collide on a
-- bare numeric id.
function Filter:IsHidden(entry)
    local DB   = ns:GetModule("DB")
    local char = DB and DB:Char()
    local byProvider = char and char.hidden and char.hidden[entry.providerID]
    return (byProvider and byProvider[entry.id]) and true or false
end

function Filter:SetHidden(entry, hidden)
    local DB   = ns:GetModule("DB")
    local char = DB and DB:Char()
    if not char then return end
    char.hidden = char.hidden or {}
    local byProvider = char.hidden[entry.providerID]
    if not byProvider then byProvider = {}; char.hidden[entry.providerID] = byProvider end
    byProvider[entry.id] = hidden or nil
end

-- Keyed the same way as hidden, and for the same reason: two providers must never collide on
-- a bare numeric id.
function Filter:IsPinned(entry)
    local DB   = ns:GetModule("DB")
    local char = DB and DB:Char()
    local byProvider = char and char.pinned and char.pinned[entry.providerID]
    return (byProvider and byProvider[entry.id]) and true or false
end

function Filter:SetPinned(entry, pinned)
    local DB   = ns:GetModule("DB")
    local char = DB and DB:Char()
    if not char then return end
    char.pinned = char.pinned or {}
    local byProvider = char.pinned[entry.providerID]
    if not byProvider then byProvider = {}; char.pinned[entry.providerID] = byProvider end
    byProvider[entry.id] = pinned or nil
    -- Pinning something you had hidden would otherwise store a contradiction the UI resolves
    -- silently in hidden's favor, leaving a pin the player cannot see.
    if pinned then self:SetHidden(entry, false) end
end

local function countSet(char, key)
    local set = char and char[key]
    if not set then return 0, nil end
    local total, parts = 0, {}
    for providerID, byProvider in pairs(set) do
        local n = 0
        for _ in pairs(byProvider) do n = n + 1 end
        if n > 0 then
            total = total + n
            parts[#parts + 1] = ("%s %d"):format(providerID, n)
        end
    end
    -- pairs order is unspecified, so sort or the status line reshuffles between reads.
    table.sort(parts)
    return total, parts
end

-- A hidden entry keeps claiming its ID space, so it never resurfaces under another provider
-- for a second modified-click to undo. Without this the only way back is resetting the profile.
function Filter:ClearHidden()
    local DB   = ns:GetModule("DB")
    local char = DB and DB:Char()
    if not char then return 0 end
    local total = countSet(char, "hidden")
    char.hidden = {}
    return total
end

function Filter:DebugLine()
    local DB   = ns:GetModule("DB")
    local char = DB and DB:Char()
    local hidden, hParts = countSet(char, "hidden")
    local pinned, pParts = countSet(char, "pinned")

    local out = (hidden == 0) and "hidden entries: none"
        or ("hidden entries: %d (%s) - /eqot unhide restores them")
            :format(hidden, table.concat(hParts, ", "))

    if pinned > 0 then
        out = out .. ("  | pinned: %d (%s)"):format(pinned, table.concat(pParts, ", "))
    end
    return out
end

function Filter:PassesCategory(entry, f)
    if not f then return true end
    local tags = entry.tags
    if tags then
        for i = 1, #self.CATEGORIES do
            local c = self.CATEGORIES[i]
            if c.tag and tags[c.tag] then return f[c.key] ~= false end
        end
    end
    return f.showNormal ~= false
end

-- Category filters are opt-in per provider. Without that gate an untagged entry from
-- any other provider falls through to showNormal, and unchecking "Normal" would hide
-- every achievement too.
-- The second return says the rejection was the user hiding this entry rather than a display
-- setting. Feed needs the difference: a hidden quest must claim its ID space, a filtered one
-- must not.
function Filter:Visible(entry, cfg, provider)
    if self:IsHidden(entry) then return false, true end

    -- A quest with a Complete popup is drawn as a popup box instead, so it must not also
    -- appear as a row. The suppression set is empty whenever the option is off, so this
    -- costs one lookup and needs no config branch of its own.
    -- Above the pin check on purpose: a pin must not resurrect the row beside its own popup.
    if provider and provider.idSpace == "quest" then
        local Popups = ns:GetModule("AutoQuestPopups")
        if Popups and Popups:IsSuppressed(entry.id) then return false end
    end

    -- Below hidden and the popup, above everything else, matching EQ: a pin is the player
    -- saying "keep this on screen", so it outranks every display setting but not their own
    -- decision to hide the row.
    if self:IsPinned(entry) then return true end

    if cfg and cfg.showOnlyWatched and entry.isTracked == false then return false end

    if provider and provider.filterCategories then
        local f = cfg and cfg.filters
        if not self:PassesCategory(entry, f) then return false end
        -- nil from IsCurrentZone means the provider cannot tell, so fail open
        if f and f.onlyCurrentZone and provider.IsCurrentZone
           and provider:IsCurrentZone(entry) == false then
            return false
        end
    end

    return true
end
