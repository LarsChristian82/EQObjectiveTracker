local _, ns = ...

local Options = ns:GetModule("Options")

local OUTLINES = { "None", "OUTLINE", "THICKOUTLINE" }

local function pct(v) return ("%d%%"):format(math.floor(v * 100 + 0.5)) end
local function px(v)  return ("%dpx"):format(math.floor(v + 0.5)) end
local function signed(v)
    v = math.floor(v + 0.5)
    return v > 0 and ("+%d"):format(v) or tostring(v)
end

local function DB() return ns:GetModule("DB"):Tracker() end

-- Font, size, outline and shadow all feed the SetFont pass that pooled rows only redo
-- when the generation bumps, so every one of these setters must invalidate.
local function restyle(key, v)
    DB()[key] = v
    ns:GetModule("Row"):Invalidate()
    ns:GetModule("Tracker"):Render()
end

local function relayout(key, v)
    DB()[key] = v
    ns:GetModule("Tracker"):Render()
end

Options:RegisterTab({
    id    = "appearance",
    title = "Appearance",
    order = 30,
    build = function(self, content)
        self:CreateHeading(content, "Text")

        self:CreateDropdown(content, "Font",
            function() return ns:GetModule("Media"):GetFontList() end,
            function() return DB().font end,
            function(v) restyle("font", v) end,
            "Fonts registered through LibSharedMedia, so anything from ElvUI or SharedMedia appears here too.")

        self:CreateSlider(content, "Font size", 8, 24, 1,
            function() return DB().fontSize or 15 end,
            function(v) restyle("fontSize", v) end,
            "Base size for objective text. Titles and headers offset from this.", px)

        self:CreateDropdown(content, "Outline",
            function() return OUTLINES end,
            function() local o = DB().fontOutline; return (o == nil or o == "") and "None" or o end,
            function(v) restyle("fontOutline", v == "None" and "" or v) end,
            "Outlines keep small text legible over bright terrain.")

        self:CreateSlider(content, "Title size offset", -4, 10, 1,
            function() return DB().titleSizeDelta or 0 end,
            function(v) restyle("titleSizeDelta", v) end,
            "Size difference between quest titles and their objective lines.", signed)

        self:CreateCheckbox(content, "Text shadow",
            function() return DB().textShadow end,
            function(v) restyle("textShadow", v) end,
            "Drop shadow behind all tracker text. Helps a lot without an outline.")

        self:CreateColorPicker(content, "Shadow color",
            function() return DB().textShadowColor end,
            function(v) restyle("textShadowColor", v) end,
            "Shadow color and opacity.", true)

        self:CreateSlider(content, "Shadow distance", 1, 5, 1,
            function() return DB().textShadowStrength or 2 end,
            function(v) restyle("textShadowStrength", v) end,
            "How far the shadow is offset from the text.", px)

        self:CreateHeading(content, "Size and spacing")

        self:CreateSlider(content, "Tracker scale", 0.5, 2.0, 0.05,
            function() return DB().scale or 1 end,
            function(v)
                DB().scale = v
                local f = ns:GetModule("Tracker").frame
                -- SetScale on a frame with secure children is protected in combat
                if f and not InCombatLockdown() then f:SetScale(v) end
            end,
            "Scales the whole tracker. Takes effect immediately out of combat.", pct)

        self:CreateSlider(content, "Space between entries", 0, 20, 1,
            function() return DB().blockSpacing or 2 end,
            function(v) relayout("blockSpacing", v) end,
            "Vertical gap between each entry and between sections.", px)

        self:CreateSlider(content, "Space between objective lines", -8, 24, 1,
            function() return DB().lineSpacing or 0 end,
            function(v) restyle("lineSpacing", v) end,
            "Extra spacing between the objective lines within one entry.", signed)

        self:CreateSlider(content, "Space under titles", -8, 24, 1,
            function() return DB().headerSpacing or 0 end,
            function(v) restyle("headerSpacing", v) end,
            "Gap between an entry's title and its first objective line.", signed)

        self:CreateHeading(content, "Section headers")

        self:CreateColorPicker(content, "Header color",
            function() return DB().headerColor end,
            function(v) relayout("headerColor", v) end,
            "Color of the Quests, Campaign and World Quests headings.")

        self:CreateColorPicker(content, "Header divider color",
            function() return DB().headerDividerColor end,
            function(v) relayout("headerDividerColor", v) end,
            "The thin rule under each section heading.", true)

        self:CreateSlider(content, "Header size offset", -4, 12, 1,
            function() return DB().headerSizeDelta or 4 end,
            function(v) relayout("headerSizeDelta", v) end,
            "Size difference between section headings and objective text.", signed)

        self:CreateHeading(content, "Frame")

        self:CreateCheckbox(content, "Show background",
            function() return DB().showBackground end,
            function(v) relayout("showBackground", v) end,
            "Fills the tracker behind the text. Useful over bright terrain.")

        self:CreateColorPicker(content, "Background color",
            function() return DB().backgroundColor end,
            function(v) relayout("backgroundColor", v) end,
            "Background color and opacity.", true)

        self:CreateCheckbox(content, "Show border",
            function() return DB().showBorder end,
            function(v) relayout("showBorder", v) end,
            "Draws a border around the tracker.")

        self:CreateColorPicker(content, "Border color",
            function() return DB().borderColor end,
            function(v) relayout("borderColor", v) end,
            "Border color and opacity.", true)

        self:CreateSlider(content, "Border thickness", 1, 8, 1,
            function() return DB().borderSize or 1 end,
            function(v) relayout("borderSize", v) end,
            "Border thickness in pixels.", px)
    end,
})
