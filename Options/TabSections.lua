local _, ns = ...

local Options = ns:GetModule("Options")

local ROW_H = 26
local WQ_POSITIONS = { "Top", "Bottom" }

local function pct(v) return ("%d%%"):format(math.floor(v + 0.5)) end
local function px(v)  return ("%dpx"):format(math.floor(v + 0.5)) end

local function buildSectionRow(parent)
    local r = CreateFrame("Frame", nil, parent)
    r:SetHeight(ROW_H)

    r.check = CreateFrame("CheckButton", nil, r, "UICheckButtonTemplate")
    r.check:SetSize(24, 24)
    r.check:SetPoint("LEFT", 0, 0)

    r.label = r:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    r.label:SetPoint("LEFT", r.check, "RIGHT", 4, 0)

    r.down = CreateFrame("Button", nil, r, "UIPanelButtonTemplate")
    r.down:SetSize(26, 20)
    r.down:SetText("\226\150\188")
    r.down:SetPoint("RIGHT", -4, 0)

    r.up = CreateFrame("Button", nil, r, "UIPanelButtonTemplate")
    r.up:SetSize(26, 20)
    r.up:SetText("\226\150\178")
    r.up:SetPoint("RIGHT", r.down, "LEFT", -2, 0)

    return r
end

Options:RegisterTab({
    id    = "sections",
    title = "Sections",
    order = 20,
    build = function(self, content)
        local DB       = ns:GetModule("DB")
        local Sections = ns:GetModule("Sections")
        local Filter   = ns:GetModule("Filter")
        local Registry = ns:GetModule("Registry")

        self:CreateHeading(content, "Sections")
        self:CreateLabel(content,
            "Reorder the tracker's sections. A section only shows while it has something in it.",
            0.6, 0.6, 0.6)

        local list = CreateFrame("Frame", nil, content)
        list:SetWidth(400)
        local rows = {}

        local function layout()
            local order = Sections:Order()
            for i = 1, #order do
                local id = order[i]
                local r  = rows[id]
                if r then
                    r:ClearAllPoints()
                    r:SetPoint("TOPLEFT", list, "TOPLEFT", 0, -(i - 1) * ROW_H)
                    r:SetPoint("TOPRIGHT", list, "TOPRIGHT", 0, -(i - 1) * ROW_H)
                    r.up:SetEnabled(i > 1)
                    r.down:SetEnabled(i < #order)
                end
            end
            list:SetHeight(math.max(1, #order * ROW_H))
        end

        for _, id in ipairs(Sections:Order()) do
            local r = buildSectionRow(list)
            rows[id] = r
            r.label:SetText(Sections:Title(id))
            -- A virtual section has no entries to hide, so its own settings own its
            -- visibility and a second control here would only contradict them. The label
            -- keeps the checkbox's anchor so the column stays flush.
            if Sections:IsVirtual(id) then
                r.check:Hide()
            else
                r.check:SetChecked(not Sections:IsHidden(id))
                self:AttachTooltip(r.check, Sections:Title(id),
                    "Hide this section entirely, even when it has entries.")
                r.check:SetScript("OnClick", function(btn)
                    Sections:SetHidden(id, not btn:GetChecked())
                    ns:GetModule("Tracker"):Render()
                end)
            end
            r.up:SetScript("OnClick", function()
                Sections:Move(id, -1); layout()
            end)
            r.down:SetScript("OnClick", function()
                Sections:Move(id, 1); layout()
            end)
        end

        layout()
        self:Place(content, list, list:GetHeight(), 4)

        local pinned = Sections:Pinned()
        if #pinned > 0 then
            self:CreateHeading(content, "World Quests")
            self:CreateLabel(content,
                "Pinned to its own capped area, so it is not in the list above.",
                0.6, 0.6, 0.6)

            for _, id in ipairs(pinned) do
                self:CreateCheckbox(content, ("Show %s"):format(Sections:Title(id)),
                    function() return not Sections:IsHidden(id) end,
                    function(v) Sections:SetHidden(id, not v) end,
                    "Hide this section entirely, even when it has entries.")
            end

            self:CreateCheckbox(content, "List every world quest in your zone",
                function() return DB:Tracker().autoListZoneWorldQuests end,
                function(v) DB:Tracker().autoListZoneWorldQuests = v end,
                "Shows every world quest on your current map without having to track each one. Only the map you are standing on, not the whole continent.")

            self:CreateDropdown(content, "Position",
                function() return WQ_POSITIONS end,
                function() return DB:Tracker().worldQuestsPosition == "top" and "Top" or "Bottom" end,
                function(v)
                    ns:GetModule("Tracker"):SetWorldQuestsPosition(v == "Top" and "top" or "bottom")
                end,
                "Whether the world quest area sits above or below the scrolling quest list.")

            self:CreateSlider(content, "Maximum height", 10, 80, 5,
                function() return (DB:Tracker().worldQuestsPinnedMaxFraction or 0.40) * 100 end,
                function(v)
                    DB:Tracker().worldQuestsPinnedMaxFraction = v / 100
                    ns:GetModule("Tracker"):Render()
                end,
                "The most of the tracker the world quest area may take. Quest sections are given their space first, so this is a ceiling rather than a reservation.",
                pct)

            self:CreateCheckbox(content, "Set a custom height",
                function() return DB:Tracker().worldQuestsHeightOverride end,
                function(v) DB:Tracker().worldQuestsHeightOverride = v end,
                "By default the world quest area shares space with the quest list and gets squeezed when you have a lot of quests. Turn this on to give it a fixed height instead.")

            self:CreateSlider(content, "Custom height", 40, 400, 10,
                function() return DB:Tracker().worldQuestsHeight or 120 end,
                function(v)
                    DB:Tracker().worldQuestsHeight = v
                    ns:GetModule("Tracker"):Render()
                end,
                "Fixed height for the world quest area. Only used while Set a custom height is on.",
                px)
        end

        self:CreateHeading(content, "Show quest types")

        for i = 1, #Filter.CATEGORIES do
            local c = Filter.CATEGORIES[i]
            -- No loaded provider can produce this category, so the toggle would be dead
            if (not c.tag) or Registry:HasTag(c.tag) then
                self:CreateCheckbox(content, c.label,
                    function() return DB:Tracker().filters[c.key] ~= false end,
                    function(v) DB:Tracker().filters[c.key] = v end,
                    ("Show or hide %s entries in the tracker."):format(c.label:lower()))
            end
        end

        self:CreateCheckbox(content, "This zone only",
            function() return DB:Tracker().filters.onlyCurrentZone end,
            function(v) DB:Tracker().filters.onlyCurrentZone = v end,
            "Only show entries with an objective on your current map. Entries whose provider cannot tell are always shown.")
    end,
})
