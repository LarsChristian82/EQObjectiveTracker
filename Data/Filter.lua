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

local function countHidden(char)
    local hidden = char and char.hidden
    if not hidden then return 0, nil end
    local total, parts = 0, {}
    for providerID, byProvider in pairs(hidden) do
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
    local total = countHidden(char)
    char.hidden = {}
    return total
end

function Filter:DebugLine()
    local DB   = ns:GetModule("DB")
    local char = DB and DB:Char()
    local total, parts = countHidden(char)
    if total == 0 then return "hidden entries: none" end
    return ("hidden entries: %d (%s) - /eqot unhide restores them")
        :format(total, table.concat(parts, ", "))
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
    if cfg and cfg.showOnlyWatched and entry.isTracked == false then return false end

    -- A quest with a Complete popup is drawn as a popup box instead, so it must not also
    -- appear as a row. The suppression set is empty whenever the option is off, so this
    -- costs one lookup and needs no config branch of its own.
    if provider and provider.idSpace == "quest" then
        local Popups = ns:GetModule("AutoQuestPopups")
        if Popups and Popups:IsSuppressed(entry.id) then return false end
    end

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
