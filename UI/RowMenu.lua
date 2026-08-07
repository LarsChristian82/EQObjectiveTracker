local _, ns = ...

local RowMenu = ns:RegisterModule("RowMenu", {})
local L       = ns.L

-- Providers return item IDs, never translatable wording, so Data/ stays free of display text
-- and the manifest has one place to harvest. The title row carries the quest name as data, and
-- an API-registered item supplies its own already-translated label.
local LABELS = {
    pin        = L["Pin to tracker"],
    unpin      = L["Unpin from tracker"],
    track      = L["Track Quest"],
    untrack    = L["Untrack Quest"],
    focus      = L["Focus"],
    unfocus    = L["Unfocus"],
    supertrack = L["Super-track (follow arrow)"],
    openlog    = L["Open in Map & Quest Log"],
    popout     = L["Pop Out Quest Details"],
    wowhead    = L["Search on Wowhead"],
    abandon    = L["Abandon Quest"],
}

local DANGER = "|cffff5050%s|r"

local scratch = {}

local function byOrder(a, b)
    if a.order == b.order then return (a.id or "") < (b.id or "") end
    return a.order < b.order
end

-- Handled here rather than dispatched: opening a link needs the ID and nothing else, so
-- routing it through a provider would be Data/ reaching into UI/ for no gain.
local function wowhead(entryID)
    ns:ShowURL("https://www.wowhead.com/quest=" .. tostring(entryID))
end

-- Dispatched against the entry ID rather than the entry table: the menu outlives the render
-- that opened it, and entries are rebuilt on every quest event.
local function run(providerID, entryID, item)
    if item.external then
        item.external.onClick(providerID, entryID)
    elseif item.id == "wowhead" then
        wowhead(entryID)
    else
        local provider = ns:GetModule("Registry"):Get(providerID)
        if provider and provider.OnEntryMenuSelect then
            provider:OnEntryMenuSelect(entryID, item.id)
        end
    end
    local Tracker = ns:GetModule("Tracker")
    if Tracker then Tracker:Refresh() end
end

function RowMenu:Show(row)
    -- No OnEnable, so ns:IsModuleDisabled never covers this. Honored directly, as DragDrop and
    -- ItemButtons do, or /eqot disable all leaves the menu live - and MenuUtil, StaticPopup and
    -- the quest log popout are the newest taint vectors a bisection would be trying to rule out.
    if ns:SafeMode() then return false end
    if not (MenuUtil and MenuUtil.CreateContextMenu) then return false end

    local entry, providerID = row._entry, row._providerID
    if not (entry and providerID) then return false end

    local provider = ns:GetModule("Registry"):Get(providerID)
    if not (provider and provider.GetEntryMenu) then return false end

    local items = provider:GetEntryMenu(entry)
    if not items then return false end

    local entryID = entry.id

    for i = #scratch, 1, -1 do scratch[i] = nil end
    for i = 1, #items do scratch[#scratch + 1] = items[i] end
    ns:GetModule("API"):MenuItemsFor(providerID, entryID, scratch)
    table.sort(scratch, byOrder)

    -- Copied out because the callback runs long after this returns and the provider's list is
    -- a reused table that the next GetEntryMenu overwrites.
    local list = {}
    for i = 1, #scratch do list[i] = scratch[i] end
    if #list == 0 then return false end

    MenuUtil.CreateContextMenu(row, function(_, root)
        for i = 1, #list do
            local it = list[i]
            if it.kind == "title" then
                root:CreateTitle(it.text or "")
            elseif it.kind == "divider" then
                root:CreateDivider()
            else
                local label = it.label or LABELS[it.id]
                if label then
                    root:CreateButton(it.danger and DANGER:format(label) or label,
                        function() run(providerID, entryID, it) end)
                end
            end
        end
        root:CreateDivider()
        root:CreateButton(L["Cancel"], function() end)
    end)
    return true
end
