local _, ns = ...

local Options = ns:GetModule("Options")

local OUTLINES   = { "None", "OUTLINE", "THICKOUTLINE" }
local LAYOUTS    = { "Plain", "Card" }
local BAR_STYLES = { "Horizontal", "Vertical" }

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

        self:CreateHeading(content, "Title colors")

        self:CreateCheckbox(content, "Color titles by difficulty",
            function() return DB().colorByDifficulty ~= false end,
            function(v) restyle("colorByDifficulty", v) end,
            "Tints each title by how hard the quest is for your level, the same way the quest log does. Turn it off for plain gold titles.")

        self:CreateColorPicker(content, "Title color override",
            function() return DB().titleColorOverride end,
            function(v) restyle("titleColorOverride", v) end,
            "Forces every title to one color. Clear it to go back to difficulty coloring, or to plain gold when that is off.",
            false,
            function() restyle("titleColorOverride", nil) end)

        self:CreateCheckbox(content, "Use class color for titles",
            function() return DB().titleColorUseClass end,
            function(v) restyle("titleColorUseClass", v) end,
            "Colors titles with the class color of the character you are logged in on. Wins over the override above while it is on.")

        self:CreateCheckbox(content, "Use title color when complete",
            function() return DB().overrideCompleteGreen ~= false end,
            function(v) restyle("overrideCompleteGreen", v) end,
            "Completed entries and finished objectives use your title color instead of green. Does nothing until a color override or class color is set, since it needs a color to use.")

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

        self:CreateHeading(content, "Entry rows")

        self:CreateDropdown(content, "Row layout",
            function() return LAYOUTS end,
            function() return DB().blockLayout == "card" and "Card" or "Plain" end,
            function(v) restyle("blockLayout", v == "Card" and "card" or "classic") end,
            "Plain draws text straight on the tracker background. Card gives every entry its own panel, which makes long lists easier to tell apart.")

        self:CreateColorPicker(content, "Card background color",
            function() return DB().cardColor end,
            function(v) restyle("cardColor", v) end,
            "Fill behind each card. Only used while Row layout is Card.", true)

        self:CreateColorPicker(content, "Card border color",
            function() return DB().cardBorderColor end,
            function(v) restyle("cardBorderColor", v) end,
            "Outline around each card. Only used while Row layout is Card.", true)

        self:CreateSlider(content, "Card border thickness", 0, 4, 1,
            function() return DB().cardBorderSize or 1 end,
            function(v) restyle("cardBorderSize", v) end,
            "0 hides the outline and leaves just the fill.", px)

        self:CreateSlider(content, "Card padding", 2, 14, 1,
            function() return DB().cardPadding or 6 end,
            function(v) restyle("cardPadding", v) end,
            "Breathing room between a card's edge and the text inside it. Larger values make taller cards.", px)

        self:CreateCheckbox(content, "Tint cards by type",
            function() return DB().cardTintByType end,
            function(v) restyle("cardTintByType", v) end,
            "Gives campaign, legendary, dungeon and raid entries their own card color. Anything else uses the plain background color above.")

        self:CreateColorPicker(content, "Campaign tint",
            function() return DB().cardTintCampaign end,
            function(v) restyle("cardTintCampaign", v) end,
            "Card color for campaign entries. Needs Tint cards by type switched on.", true)

        self:CreateColorPicker(content, "Legendary tint",
            function() return DB().cardTintLegendary end,
            function(v) restyle("cardTintLegendary", v) end,
            "Card color for legendary entries. Needs Tint cards by type switched on.", true)

        self:CreateColorPicker(content, "Dungeon tint",
            function() return DB().cardTintDungeon end,
            function(v) restyle("cardTintDungeon", v) end,
            "Card color for dungeon entries. Needs Tint cards by type switched on.", true)

        self:CreateColorPicker(content, "Raid tint",
            function() return DB().cardTintRaid end,
            function(v) restyle("cardTintRaid", v) end,
            "Card color for raid entries. Needs Tint cards by type switched on.", true)

        self:CreateHeading(content, "Section headers")

        self:CreateColorPicker(content, "Header color",
            function() return DB().headerColor end,
            function(v) relayout("headerColor", v) end,
            "Color of the Quests, Campaign and World Quests headings.")

        self:CreateCheckbox(content, "Use class color for headers",
            function() return DB().headerColorUseClass end,
            function(v) relayout("headerColorUseClass", v) end,
            "Colors the section headings with your character's class color. Wins over the header color above while it is on.")

        self:CreateColorPicker(content, "Header divider color",
            function() return DB().headerDividerColor end,
            function(v) relayout("headerDividerColor", v) end,
            "The thin rule under each section heading.", true)

        self:CreateSlider(content, "Header size offset", -4, 12, 1,
            function() return DB().headerSizeDelta or 4 end,
            function(v) relayout("headerSizeDelta", v) end,
            "Size difference between section headings and objective text.", signed)

        self:CreateCheckbox(content, "Header bar",
            function() return DB().headerBar end,
            function(v) relayout("headerBar", v) end,
            "Draws a colored gradient bar behind each section heading, for a look closer to the default Blizzard tracker.")

        self:CreateColorPicker(content, "Bar color",
            function() return DB().headerBarColor end,
            function(v) relayout("headerBarColor", v) end,
            "Brightest end of the bar gradient. The other end is the same color darkened.", true)

        self:CreateDropdown(content, "Bar style",
            function() return BAR_STYLES end,
            function() return (DB().headerBarStyle or 1) == 2 and "Vertical" or "Horizontal" end,
            function(v) relayout("headerBarStyle", v == "Vertical" and 2 or 1) end,
            "Horizontal runs bright on the left to dark on the right. Vertical runs bright at the top to dark at the bottom.")

        self:CreateSlider(content, "Bar height", 6, 26, 1,
            function() return DB().headerBarHeight or 22 end,
            function(v) relayout("headerBarHeight", v) end,
            "The bar is centered on the heading row, so larger values fill more of it.", px)

        self:CreateCheckbox(content, "Soft bar edges",
            function() return DB().headerBarSoftEdges end,
            function(v) relayout("headerBarSoftEdges", v) end,
            "Feathers the top, left and right edges so the bar blends into the UI instead of sitting in a hard box. The bottom stays flush with the divider line.")

        self:CreateSlider(content, "Edge softness", 1, 10, 1,
            function() return DB().headerBarSoftEdgeStrength or 10 end,
            function(v) relayout("headerBarSoftEdgeStrength", v) end,
            "Higher is softer. Only applies while Soft bar edges is on.")

        self:CreateHeading(content, "Scroll bar")

        self:CreateCheckbox(content, "Hide scroll bar",
            function() return DB().hideScrollBar end,
            function(v) relayout("hideScrollBar", v) end,
            "Removes the scroll bar entirely and gives its gutter back to the text. The tracker still scrolls with the mouse wheel.")

        self:CreateCheckbox(content, "Scroll bar background",
            function() return DB().scrollBarBg ~= false end,
            function(v) relayout("scrollBarBg", v) end,
            "Draws a track behind the scroll bar so it stays visible over bright terrain.")

        self:CreateColorPicker(content, "Scroll bar color",
            function() return DB().scrollBarBgColor end,
            function(v) relayout("scrollBarBgColor", v) end,
            "Color and opacity of the scroll bar track.", true)

        self:CreateCheckbox(content, "Solid color thumb",
            function() return DB().skinScrollBar end,
            function(v) relayout("skinScrollBar", v) end,
            "Replaces the textured draggable block with a flat single color one. Turning this off restores the stock Blizzard look.")

        self:CreateColorPicker(content, "Thumb color",
            function() return DB().scrollBarThumbColor end,
            function(v) relayout("scrollBarThumbColor", v) end,
            "Color and opacity of the draggable block. Only used while Solid color thumb is on.", true)

        self:CreateSlider(content, "Thumb width", 4, 16, 1,
            function() return DB().scrollBarThumbWidth or 8 end,
            function(v) relayout("scrollBarThumbWidth", v) end,
            "How wide the draggable block is. Only used while Solid color thumb is on.", px)

        self:CreateCheckbox(content, "Hide scroll bar arrows",
            function() return DB().hideScrollArrows end,
            function(v) relayout("hideScrollArrows", v) end,
            "Hides the up and down buttons at the ends of the bar. It still scrolls by dragging the thumb or using the mouse wheel.")

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
