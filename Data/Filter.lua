local _, ns = ...

local Filter = ns:RegisterModule("Filter", {})

-- First match wins, so this order is the precedence: a campaign daily filters as
-- campaign. Adding a category is one row here plus the tag on the provider - no
-- comparator, renderer, or branch anywhere else learns about it.
Filter.CATEGORIES = {
    { tag = "worldquest", key = "showWorld",    label = "World quests" },
    { tag = "bonus",      key = "showBonus",    label = "Bonus objectives" },
    { tag = "campaign",   key = "showCampaign", label = "Campaign"     },
    { tag = "daily",      key = "showDaily",    label = "Daily"        },
    { tag = "weekly",     key = "showWeekly",   label = "Weekly"       },
    { tag = nil,          key = "showNormal",   label = "Normal"       },
}

-- Hidden is keyed by provider then entry id so two providers can never collide on a
-- bare numeric id. The EQ import maps its flat hidden[questID] into hidden.quests.
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
function Filter:Visible(entry, cfg, provider)
    if self:IsHidden(entry) then return false end
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
