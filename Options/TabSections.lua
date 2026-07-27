local _, ns = ...

local Options = ns:GetModule("Options")

local ROW_H = 26

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
            "Only sections a loaded content provider can fill are listed here.",
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
            r.check:SetChecked(not Sections:IsHidden(id))
            self:AttachTooltip(r.check, Sections:Title(id),
                "Hide this section entirely, even when it has entries.")
            r.check:SetScript("OnClick", function(btn)
                Sections:SetHidden(id, not btn:GetChecked())
                ns:GetModule("Tracker"):Render()
            end)
            r.up:SetScript("OnClick", function()
                Sections:Move(id, -1); layout()
            end)
            r.down:SetScript("OnClick", function()
                Sections:Move(id, 1); layout()
            end)
        end

        layout()
        self:Place(content, list, list:GetHeight(), 4)

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
