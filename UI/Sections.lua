local _, ns = ...

local Sections = ns:RegisterModule("Sections", {})

local HEADER_H     = 26
local HEADER_COLOR = { 0.93, 0.32, 0.10 }
local HAIRLINE     = { 0.92, 0.72, 0.02, 0.85 }

-- Titles are display-side because a group is a display concept. A provider that
-- declares a group nobody has titled still renders, under its raw id.
Sections.TITLES = {
    quests       = "Quests",
    campaign     = "Campaign",
    worldquests  = "World Quests",
    achievements = "Achievements",
    scenarios    = "Scenario",
    endeavors    = "Endeavors",
}

Sections.frames = {}

function Sections:Title(groupID)
    return self.TITLES[groupID] or groupID
end

-- Saved order first, then any group the saved order has not seen. Appending the
-- unseen ones keeps a newly added provider from being invisible on an old profile.
function Sections:Order()
    local Registry = ns:GetModule("Registry")
    local DB       = ns:GetModule("DB")
    local cfg      = DB and DB:Tracker()

    local live = {}
    for _, id in ipairs(Registry:Groups()) do live[id] = true end

    local seen, out = {}, {}
    for _, id in ipairs((cfg and cfg.sectionOrder) or {}) do
        if live[id] and not seen[id] then
            seen[id] = true
            out[#out + 1] = id
        end
    end
    for _, id in ipairs(Registry:Groups()) do
        if not seen[id] then
            seen[id] = true
            out[#out + 1] = id
        end
    end
    return out
end

function Sections:IsHidden(groupID)
    local DB  = ns:GetModule("DB")
    local cfg = DB and DB:Tracker()
    return (cfg and cfg.sectionsHidden and cfg.sectionsHidden[groupID]) and true or false
end

function Sections:SetHidden(groupID, hidden)
    local DB  = ns:GetModule("DB")
    local cfg = DB and DB:Tracker()
    if not cfg then return end
    cfg.sectionsHidden = cfg.sectionsHidden or {}
    cfg.sectionsHidden[groupID] = hidden or nil
end

-- Writes the full reconciled order back, not just the swap, so a profile whose saved
-- order predates a newly loaded provider gets that provider persisted too.
function Sections:Move(groupID, delta)
    local order = self:Order()
    local idx
    for i = 1, #order do
        if order[i] == groupID then idx = i break end
    end
    if not idx then return end
    local j = idx + delta
    if j < 1 or j > #order then return end
    order[idx], order[j] = order[j], order[idx]

    local DB  = ns:GetModule("DB")
    local cfg = DB and DB:Tracker()
    if cfg then cfg.sectionOrder = order end

    local Tracker = ns:GetModule("Tracker")
    if Tracker then Tracker:Render() end
end

function Sections:IsCollapsed(groupID)
    local DB   = ns:GetModule("DB")
    local char = DB and DB:Char()
    if not char then return false end
    char.sectionsCollapsed = char.sectionsCollapsed or {}
    return char.sectionsCollapsed[groupID] == true
end

function Sections:ToggleCollapsed(groupID)
    local DB   = ns:GetModule("DB")
    local char = DB and DB:Char()
    if not char then return end
    char.sectionsCollapsed = char.sectionsCollapsed or {}
    char.sectionsCollapsed[groupID] = not self:IsCollapsed(groupID)
    local Tracker = ns:GetModule("Tracker")
    if Tracker then Tracker:Render() end
end

local function build(parent, groupID, title)
    local h = CreateFrame("Button", nil, parent)
    h:SetHeight(HEADER_H)
    h:RegisterForClicks("LeftButtonUp")

    h.hairline = h:CreateTexture(nil, "ARTWORK")
    h.hairline:SetColorTexture(HAIRLINE[1], HAIRLINE[2], HAIRLINE[3], HAIRLINE[4])
    h.hairline:SetHeight(2)
    h.hairline:SetPoint("BOTTOMLEFT", 0, 0)
    h.hairline:SetPoint("BOTTOMRIGHT", 0, 0)

    h.text = h:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    h.text:SetPoint("LEFT", 4, 0)
    h.text:SetText(title)
    h.text:SetTextColor(HEADER_COLOR[1], HEADER_COLOR[2], HEADER_COLOR[3])

    h.collapse = h:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    h.collapse:SetPoint("RIGHT", -4, 0)
    h.collapse:SetTextColor(HEADER_COLOR[1], HEADER_COLOR[2], HEADER_COLOR[3])

    h.count = h:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    h.count:SetPoint("RIGHT", h.collapse, "LEFT", -6, 0)
    h.count:SetTextColor(HEADER_COLOR[1], HEADER_COLOR[2], HEADER_COLOR[3])

    h.groupID = groupID
    h:SetScript("OnClick", function(self)
        Sections:ToggleCollapsed(self.groupID)
    end)
    return h
end

function Sections:Acquire(parent, groupID)
    local h = self.frames[groupID]
    if not h then
        h = build(parent, groupID, self:Title(groupID))
        self.frames[groupID] = h
    end
    if h:GetParent() ~= parent then h:SetParent(parent) end
    return h
end

-- Applied per section per render rather than cached: there are only a handful of
-- headers, and it means every appearance option lands without a separate invalidate.
function Sections:ApplyStyle(header)
    local cfg   = ns:GetModule("DB"):Tracker()
    local Media = ns:GetModule("Media")
    if not cfg then return end

    local delta = cfg.headerSizeDelta or 4
    Media:ApplyFont(header.text, delta)
    Media:ApplyFont(header.count, delta - 4 - 2)
    Media:ApplyFont(header.collapse, delta)

    local c = cfg.headerColor or {}
    local r, g, b = c.r or HEADER_COLOR[1], c.g or HEADER_COLOR[2], c.b or HEADER_COLOR[3]
    header.text:SetTextColor(r, g, b)
    header.count:SetTextColor(r, g, b)
    header.collapse:SetTextColor(r, g, b)

    local d = cfg.headerDividerColor or {}
    header.hairline:SetColorTexture(d.r or HAIRLINE[1], d.g or HAIRLINE[2],
                                    d.b or HAIRLINE[3], d.a or HAIRLINE[4])
end

function Sections:Place(header, content, y, group, collapsed, showTotal)
    self:ApplyStyle(header)
    header:Show()
    header:ClearAllPoints()
    header:SetPoint("TOPLEFT",  content, "TOPLEFT",  0, -y)
    header:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -y)

    if showTotal and group.totalCount ~= group.visibleCount then
        header.count:SetText(group.visibleCount .. "/" .. group.totalCount)
    else
        header.count:SetText(tostring(group.visibleCount))
    end
    header.collapse:SetText(collapsed and "+" or "\226\128\147")
    return HEADER_H
end

function Sections:HideAll()
    for _, h in pairs(self.frames) do h:Hide() end
end

function Sections:Height()
    return HEADER_H
end
