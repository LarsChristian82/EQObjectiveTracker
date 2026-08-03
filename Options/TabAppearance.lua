local _, ns = ...

local Options = ns:GetModule("Options")
local L       = ns.L

-- Values go straight to SetFont, which takes a comma-joined combo and ignores unknown
-- tokens, so "" means no outline.
-- The space after each comma is EQ's, and it is copied rather than tidied: fontOutline is
-- one of the keys Core/Migrate.lua lifts from EQ by name, so an imported value has to be
-- one this list can represent or the dropdown reads blank.
local OUTLINES = {
    { value = "",                         label = L["None"] },
    { value = "OUTLINE",                  label = L["Outline"] },
    { value = "THICKOUTLINE",             label = L["Thick"] },
    { value = "MONOCHROME",               label = L["Mono"] },
    { value = "MONOCHROME, OUTLINE",      label = L["Mono Outline"] },
    { value = "MONOCHROME, THICKOUTLINE", label = L["Mono Thick"] },
}

local LAYOUTS = {
    { value = "classic", label = L["Plain"] },
    { value = "card",    label = L["Card"] },
}

local BAR_STYLES = {
    { value = 1, label = L["Header Bar 1"] },
    { value = 2, label = L["Header Bar 2"] },
}

local SCENARIO_ALIGN = {
    { value = "LEFT",   label = L["Left"] },
    { value = "CENTER", label = L["Center"] },
    { value = "RIGHT",  label = L["Right"] },
}

-- Anything unrecognized normalizes to CENTER. A profile written before the align value was
-- separated from its display label can hold a translated word like "GAUCHE".
local function alignValue(v)
    return (v == "LEFT" or v == "RIGHT") and v or "CENTER"
end

-- Media names are a migration contract - a profile stores the font or bar by name - so
-- value and label are deliberately the same string.
local function mediaOptions(names, first)
    local out = {}
    if first then out[1] = first end
    for _, n in ipairs(names) do out[#out + 1] = { value = n, label = n } end
    return out
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

local function bannerRestyle(key, v)
    DB()[key] = v
    ns:GetModule("Scenario"):ApplyBannerShadow()
    ns:GetModule("Tracker"):Render()
end

local SAME_FONT = L["Same as tracker font"]

local function zbState()
    local t = DB()
    if not t then return nil end
    t.zoneProgressBar = t.zoneProgressBar or {}
    return t.zoneProgressBar
end

-- Only the fill texture and colour reach the docked bar, so only those repaint the tracker.
-- The rest land on the floating frame alone, and a full Render there would re-run every
-- provider once per slider step for a frame the tracker does not contain.
local function zbSet(key, v, shared)
    local st = zbState()
    if st then st[key] = v end
    ns:GetModule("ZoneProgressBar"):RefreshAppearance()
    if shared then ns:GetModule("Tracker"):Render() end
end

local function barTextureSwatch(frame, name)
    if not frame.swatch then return end
    frame.swatch:SetTexture(ns:GetModule("Media"):GetStatusBarFile(name))
    frame.swatch:SetVertexColor(0.26, 0.42, 1.0)
end

-- EQ's two columns are nothing but a second anchor chain rooted this far right of the
-- first header, sharing its y. There is no column API on either side.
local COLUMN_X = 460

Options:RegisterTab({
    id    = "appearance",
    title = L["Appearance"],
    order = 30,
    build = function(self, content)
        local h = self:CreateHeading(content, L["Appearance"])
        h:SetPoint("TOPLEFT", 8, -8)

        local fontDD = self:CreateDropdown(content, L["Font"],
            function() return mediaOptions(ns:GetModule("Media"):GetFontList()) end,
            function() return DB().font end,
            function(v) restyle("font", v) end,
            L["Fonts registered through LibSharedMedia, so anything from ElvUI or SharedMedia appears here too."])
        fontDD:SetPoint("TOPLEFT", h, "BOTTOMLEFT", 0, -16)

        local sizeSlider = self:CreateSlider(content, L["Font Size"], 8, 24, 0.5,
            function() return DB().fontSize or 15 end,
            function(v) restyle("fontSize", v) end,
            L["Base size for objective text. Titles and headers offset from this."])
        sizeSlider:SetPoint("TOPLEFT", fontDD, "BOTTOMLEFT", 0, -16)

        local titleSizeSlider = self:CreateSlider(content, L["Title Size Offset"], -6, 12, 0.5,
            function() return DB().titleSizeDelta or 0 end,
            function(v) restyle("titleSizeDelta", v) end,
            L["Sizes quest and achievement titles separately from the objective text. This value is added to the Font Size above: 0 keeps titles the same size as the base font, positive makes them larger, negative smaller."])
        titleSizeSlider:SetPoint("TOPLEFT", sizeSlider, "BOTTOMLEFT", 0, -16)

        local headerSizeSlider = self:CreateSlider(content, L["Header Size Offset"], -8, 12, 0.5,
            function() return DB().headerSizeDelta or 4 end,
            function(v) relayout("headerSizeDelta", v) end,
            L["Sizes the section headers (Quests, Campaign, and so on) independently of the quest text. Added on top of the Font Size above: the default 4 keeps headers at their current size, lower shrinks them (handy on a low UI scale), higher enlarges them."])
        headerSizeSlider:SetPoint("TOPLEFT", titleSizeSlider, "BOTTOMLEFT", 0, -16)

        local outlineDD = self:CreateDropdown(content, L["Font Outline"],
            OUTLINES,
            function() return DB().fontOutline or "" end,
            function(v) restyle("fontOutline", v) end,
            L["Outlines keep small text legible over bright terrain."])
        outlineDD:SetPoint("TOPLEFT", headerSizeSlider, "BOTTOMLEFT", 0, -16)

        local shadowCheck = self:CreateCheckbox(content, L["Text Shadow"],
            function() return DB().textShadow end,
            function(v) restyle("textShadow", v) end,
            L["Draws a soft drop-shadow behind all tracker text so it stays readable over bright or busy backgrounds. Use Shadow Color to tint it and Shadow Size to set how far it's cast."])
        shadowCheck:SetPoint("TOPLEFT", outlineDD, "BOTTOMLEFT", 0, -16)

        local shadowPicker = self:CreateColorPicker(content, L["Shadow Color"],
            function() return DB().textShadowColor end,
            function(v) restyle("textShadowColor", v) end,
            L["Shadow color and opacity."], true)
        shadowPicker:SetPoint("LEFT", shadowCheck, "RIGHT", 120, 0)

        local shadowSizeSlider = self:CreateSlider(content, L["Shadow Size"], 1, 6, 0.5,
            function() return DB().textShadowStrength or 2 end,
            function(v) restyle("textShadowStrength", v) end,
            L["How far the text drop-shadow is cast behind the letters. Higher values give a larger, more pronounced shadow; lower values keep it tight. Only applies while Text Shadow is on."])
        shadowSizeSlider:SetPoint("TOPLEFT", shadowCheck, "BOTTOMLEFT", 0, -14)

        local scenarioHeader = self:CreateHeading(content, L["Scenario"])
        scenarioHeader:SetPoint("TOPLEFT", shadowSizeSlider, "BOTTOMLEFT", 0, -16)

        local scShadowCheck = self:CreateCheckbox(content, L["Text Shadow"],
            function() return DB().scenarioTextShadow ~= false end,
            function(v) bannerRestyle("scenarioTextShadow", v) end,
            L["Draws a drop-shadow behind the scenario / delve banner text (the Stage and name lines). This is SEPARATE from the Text Shadow above, which affects only the quest and objective text \226\128\148 the banner is styled on its own."])
        scShadowCheck:SetPoint("TOPLEFT", scenarioHeader, "BOTTOMLEFT", 0, -10)

        local scShadowPicker = self:CreateColorPicker(content, L["Shadow Color"],
            function() return DB().scenarioTextShadowColor end,
            function(v)
                DB().scenarioTextShadowColor = v
                ns:GetModule("Scenario"):ApplyBannerShadow()
            end,
            L["Color and opacity of the banner's drop shadow."], true)
        scShadowPicker:SetPoint("LEFT", scShadowCheck, "RIGHT", 120, 0)

        local scShadowSizeSlider = self:CreateSlider(content, L["Shadow Size"], 1, 6, 0.5,
            function() return DB().scenarioTextShadowStrength or 1 end,
            function(v) bannerRestyle("scenarioTextShadowStrength", v) end,
            L["How far the scenario banner's drop-shadow is cast. Higher values give a larger, more pronounced shadow; lower values keep it tight. Only applies while the Scenario Text Shadow above is on."])
        scShadowSizeSlider:SetPoint("TOPLEFT", scShadowCheck, "BOTTOMLEFT", 0, -14)

        local scAlignDD = self:CreateDropdown(content, L["Banner Alignment"],
            SCENARIO_ALIGN,
            function() return alignValue(DB().scenarioTextAlign) end,
            function(v) relayout("scenarioTextAlign", v) end,
            L["Positions the scenario / delve banner within the tracker. Left lines it up with the quest text, Center keeps it centered (the default), and Right pushes it to the tracker's right edge."])
        scAlignDD:SetPoint("TOPLEFT", scShadowSizeSlider, "BOTTOMLEFT", 0, -16)

        local scSizeSlider = self:CreateSlider(content, L["Banner Text Size"], -4, 6, 0.5,
            function() return DB().scenarioTextSizeDelta or 0 end,
            function(v) relayout("scenarioTextSizeDelta", v) end,
            L["Grows or shrinks the scenario / delve banner's Stage and name text. 0 is the default size. The banner artwork is a fixed size, so large values may overflow it."])
        scSizeSlider:SetPoint("TOPLEFT", scAlignDD, "BOTTOMLEFT", 0, -16)

        local scCritSizeSlider = self:CreateSlider(content, L["Criteria Text Size"], 8, 24, 0.5,
            function() return DB().scenarioFontSize or 13 end,
            function(v) relayout("scenarioFontSize", v) end,
            L["Sizes the scenario / delve objective (criteria) lines shown under the banner, separately from the Banner Text Size above. Raise it if the criteria text looks small next to your quest and World Quest text."])
        scCritSizeSlider:SetPoint("TOPLEFT", scSizeSlider, "BOTTOMLEFT", 0, -16)

        -- Built here but anchored at the very bottom of this builder, because it re-homes
        -- the Tracker group under a section written further down. Screen order is not file
        -- order in EQ either, and the mirror is of the screen.
        local trackerHeader = self:CreateHeading(content, L["Tracker"])

        local skinsHeader = self:CreateHeading(content, L["Tracker Skins"])
        skinsHeader:SetPoint("TOPLEFT", scCritSizeSlider, "BOTTOMLEFT", 0, -16)

        local sbCheck = self:CreateCheckbox(content, L["Scroll Bar Background"],
            function() return DB().scrollBarBg ~= false end,
            function(v) relayout("scrollBarBg", v) end,
            L["Draws a track behind the scroll bar so it stays visible over bright terrain."])
        sbCheck:SetPoint("TOPLEFT", skinsHeader, "BOTTOMLEFT", 0, -10)

        local sbPicker = self:CreateColorPicker(content, L["Scroll Bar Color"],
            function() return DB().scrollBarBgColor end,
            function(v) relayout("scrollBarBgColor", v) end,
            L["Color and opacity of the scroll bar track."], true)
        sbPicker:SetPoint("LEFT", sbCheck, "RIGHT", 170, 0)

        local thumbSkinCheck = self:CreateCheckbox(content, L["Solid color thumb"],
            function() return DB().skinScrollBar end,
            function(v) relayout("skinScrollBar", v) end,
            L["Replaces the tracker scroll bar's textured thumb (the draggable block) with a flat single-colour block. Use the Thumb Color and Thumb Width controls to style it. Off restores the stock Blizzard bar."])
        thumbSkinCheck:SetPoint("TOPLEFT", sbCheck, "BOTTOMLEFT", 0, -12)

        local thumbColorPicker = self:CreateColorPicker(content, L["Thumb Color"],
            function() return DB().scrollBarThumbColor end,
            function(v) relayout("scrollBarThumbColor", v) end,
            L["Color and opacity of the draggable block. Only used while Solid color thumb is on."], true)
        thumbColorPicker:SetPoint("LEFT", thumbSkinCheck, "RIGHT", 170, 0)
        self:AlignSwatchTo(thumbColorPicker, sbPicker)

        local thumbWidthSlider = self:CreateSlider(content, L["Thumb Width"], 4, 16, 0.5,
            function() return DB().scrollBarThumbWidth or 8 end,
            function(v) relayout("scrollBarThumbWidth", v) end,
            L["How wide the draggable block is. Only used while Solid color thumb is on."])
        thumbWidthSlider:SetPoint("TOPLEFT", thumbSkinCheck, "BOTTOMLEFT", 0, -14)

        local hideArrowsCheck = self:CreateCheckbox(content, L["Hide scroll bar arrows"],
            function() return DB().hideScrollArrows end,
            function(v) relayout("hideScrollArrows", v) end,
            L["Hides the up and down arrow buttons at the ends of the tracker scroll bar. The bar still scrolls by dragging the thumb or using the mouse wheel."])
        hideArrowsCheck:SetPoint("TOPLEFT", thumbWidthSlider, "BOTTOMLEFT", 0, -14)

        local bgCheck = self:CreateCheckbox(content, L["Background"],
            function() return DB().showBackground end,
            function(v) relayout("showBackground", v) end,
            L["Fills the tracker behind the text. Useful over bright terrain."])
        bgCheck:SetPoint("TOPLEFT", trackerHeader, "BOTTOMLEFT", 0, -10)

        local bgPicker = self:CreateColorPicker(content, L["Background Color"],
            function() return DB().backgroundColor end,
            function(v) relayout("backgroundColor", v) end,
            L["Background color and opacity."], true)
        bgPicker:SetPoint("LEFT", bgCheck, "RIGHT", 120, 0)

        local borderCheck = self:CreateCheckbox(content, L["Border"],
            function() return DB().showBorder end,
            function(v) relayout("showBorder", v) end,
            L["Draws a border around the tracker."])
        borderCheck:SetPoint("TOPLEFT", bgCheck, "BOTTOMLEFT", 0, -10)

        local borderPicker = self:CreateColorPicker(content, L["Border Color"],
            function() return DB().borderColor end,
            function(v) relayout("borderColor", v) end,
            L["Border color and opacity."], true)
        borderPicker:SetPoint("TOPLEFT", bgPicker, "BOTTOMLEFT", 0, -8)
        self:AlignSwatchTo(borderPicker, bgPicker)

        local borderThickSlider = self:CreateSlider(content, L["Border Thickness"], 1, 5, 0.5,
            function() return DB().borderSize or 1 end,
            function(v) relayout("borderSize", v) end,
            L["Border thickness in pixels."])
        borderThickSlider:SetPoint("TOPLEFT", borderCheck, "BOTTOMLEFT", 0, -20)

        local hbBarHeader = self:CreateHeading(content, L["Header Bar"])
        hbBarHeader:SetPoint("TOPLEFT", borderThickSlider, "BOTTOMLEFT", 0, -20)

        local hbCheck = self:CreateCheckbox(content, L["Header bar"],
            function() return DB().headerBar end,
            function(v) relayout("headerBar", v) end,
            L["Draws a coloured gradient bar behind each section header (Quests, Campaign, World Quests, and so on), for a look closer to the default Blizzard tracker. Off by default."])
        hbCheck:SetPoint("TOPLEFT", hbBarHeader, "BOTTOMLEFT", 0, -10)

        local hbPicker = self:CreateColorPicker(content, L["Bar Color"],
            function() return DB().headerBarColor end,
            function(v) relayout("headerBarColor", v) end,
            L["Brightest end of the bar gradient. The other end is the same color darkened."], true)
        hbPicker:SetPoint("LEFT", hbCheck, "RIGHT", 120, 0)
        self:AlignSwatchTo(hbPicker, bgPicker)

        local hbStyleDD = self:CreateDropdown(content, L["Bar Style"],
            BAR_STYLES,
            function() return (DB().headerBarStyle or 1) == 2 and 2 or 1 end,
            function(v) relayout("headerBarStyle", v) end,
            L["Header Bar 1 is a horizontal gradient (bright on the left, dark on the right). Header Bar 2 is a vertical gradient (bright at the top, dark at the bottom). Bar Color, Bar Height, and Soft edges all apply to whichever style you pick."])
        hbStyleDD:SetWidth(150)
        hbStyleDD:SetPoint("TOPLEFT", hbCheck, "BOTTOMLEFT", 0, -14)

        local hbSoftCheck = self:CreateCheckbox(content, L["Soft edges"],
            function() return DB().headerBarSoftEdges end,
            function(v) relayout("headerBarSoftEdges", v) end,
            L["Feathers the top, left, and right edges of the header bar so it blends into the UI instead of sitting in a hard box. The gradient colour is unchanged. Only applies while Header bar is on; off by default."])
        hbSoftCheck.label:ClearAllPoints()
        hbSoftCheck.label:SetPoint("RIGHT", hbSoftCheck, "LEFT", -4, 1)
        hbSoftCheck:SetPoint("LEFT", hbStyleDD.button, "RIGHT",
                             24 + (hbSoftCheck.label:GetStringWidth() or 70), 1)
        -- The label sits LEFT here, so flip the hit rect AttachTooltip widened to the right.
        hbSoftCheck:SetHitRectInsets(-((hbSoftCheck.label:GetStringWidth() or 70) + 8), 0, 0, 0)

        local hbHeightSlider = self:CreateSlider(content, L["Bar Height"], 6, 26, 0.5,
            function() return DB().headerBarHeight or 22 end,
            function(v) relayout("headerBarHeight", v) end,
            L["How tall the section-header bar is. The bar is centred on the header row, so larger values fill more of it."])
        hbHeightSlider:SetPoint("TOPLEFT", hbStyleDD, "BOTTOMLEFT", 0, -14)

        local hbSoftSlider = self:CreateSlider(content, L["Edge Softness"], 1, 10, 0.5,
            function() return DB().headerBarSoftEdgeStrength or 10 end,
            function(v) relayout("headerBarSoftEdgeStrength", v) end,
            L["How soft the header bar's feathered edges are when Soft edges is on. Higher is softer; lower tightens toward a hard edge."])
        hbSoftSlider:SetPoint("TOPLEFT", hbHeightSlider, "BOTTOMLEFT", 0, -14)

        local colorsHeader = self:CreateHeading(content, L["Colors & Dimensions"])
        colorsHeader:SetPoint("TOPLEFT", h, "TOPLEFT", COLUMN_X, 0)

        local resetBtn = self:CreateButton(content, L["Reset to Defaults"], 160, function()
            local Dialog = ns:GetModule("Dialog")
            if not Dialog then return end
            Dialog:Show({
                title    = "EQ Objective Tracker",
                text     = L["Reset all Appearance settings to defaults?"],
                button1  = L["Reset"],
                button2  = L["Cancel"],
                onAccept = function()
                    ns:GetModule("DB"):ResetTrackerAppearance()
                    ReloadUI()
                end,
            })
        end)
        resetBtn:SetSize(160, 24)
        resetBtn:SetPoint("LEFT", colorsHeader, "LEFT", 320, 0)

        local titlePicker = self:CreateColorPicker(content, L["Quest Title Color Override"],
            function() return DB().titleColorOverride end,
            function(v) restyle("titleColorOverride", v) end,
            L["When cleared, falls back to difficulty coloring or default yellow."])
        titlePicker:SetPoint("TOPLEFT", colorsHeader, "BOTTOMLEFT", 0, -16)

        local clearBtn = self:CreateButton(content, L["Clear"], 60, function()
            restyle("titleColorOverride", nil)
            titlePicker.paint()
        end)
        clearBtn:SetSize(60, 18)
        clearBtn:SetPoint("LEFT", titlePicker, "RIGHT", 8, 0)

        local titleClassCheck = self:CreateCheckbox(content, L["Use class color"],
            function() return DB().titleColorUseClass end,
            function(v) restyle("titleColorUseClass", v) end,
            L["Colors quest, achievement, and endeavor titles with the class color of the character you are currently logged in on. Overrides the color above while it is on. Off by default."])
        titleClassCheck:SetPoint("TOPLEFT", titlePicker, "BOTTOMLEFT", 0, -10)

        local recolorCheck = self:CreateCheckbox(content, L["Use title color for completed quests"],
            function() return DB().overrideCompleteGreen ~= false end,
            function(v) restyle("overrideCompleteGreen", v) end,
            L["Instead of green."])
        recolorCheck:SetPoint("TOPLEFT", titleClassCheck, "BOTTOMLEFT", 0, -8)

        local headerPicker = self:CreateColorPicker(content, L["Section Header Color"],
            function() return DB().headerColor end,
            function(v) relayout("headerColor", v) end,
            L["Color of the Quests, Campaign and World Quests headings."])
        headerPicker:SetPoint("TOPLEFT", recolorCheck, "BOTTOMLEFT", 0, -16)
        self:AlignSwatchTo(headerPicker, titlePicker)

        local headerClassCheck = self:CreateCheckbox(content, L["Use class color"],
            function() return DB().headerColorUseClass end,
            function(v) relayout("headerColorUseClass", v) end,
            L["Colors the section headers (Quests, Campaign, and so on) with the class color of the character you are currently logged in on. Overrides the color above while it is on. Off by default."])
        headerClassCheck:SetPoint("TOPLEFT", headerPicker, "BOTTOMLEFT", 0, -10)

        local dividerPicker = self:CreateColorPicker(content, L["Divider Line Color"],
            function() return DB().headerDividerColor end,
            function(v) relayout("headerDividerColor", v) end,
            L["Sets the color of the thin line under each section header. Defaults to the original gold."], true)
        dividerPicker:SetPoint("TOPLEFT", headerClassCheck, "BOTTOMLEFT", 0, -14)
        self:AlignSwatchTo(dividerPicker, titlePicker)

        local scaleSlider = self:CreateSlider(content, L["Tracker Scale"], 0.7, 1.5, 0.05,
            function() return DB().scale or 1 end,
            function(v)
                DB().scale = v
                ns:GetModule("Tracker"):ApplyScale()
            end,
            L["Scales the whole tracker. Takes effect immediately out of combat."])
        scaleSlider:SetPoint("TOPLEFT", dividerPicker, "BOTTOMLEFT", 0, -32)

        local spacingSlider = self:CreateSlider(content, L["Block Spacing"], 0, 12, 0.5,
            function() return DB().blockSpacing or 2 end,
            function(v) relayout("blockSpacing", v) end,
            L["Vertical gap between each entry and between sections."])
        spacingSlider:SetPoint("TOPLEFT", scaleSlider, "BOTTOMLEFT", 0, -16)

        local lineSpacingSlider = self:CreateSlider(content, L["Line Spacing"], 0, 12, 1,
            function() return DB().lineSpacing or 0 end,
            function(v) restyle("lineSpacing", v) end,
            L["Adds vertical space between a quest's objective lines, across the whole tracker. 0 keeps the default spacing."])
        lineSpacingSlider:SetPoint("TOPLEFT", spacingSlider, "BOTTOMLEFT", 0, -16)

        local headerSpacingSlider = self:CreateSlider(content, L["Header Spacing"], -2, 12, 1,
            function() return DB().headerSpacing or 0 end,
            function(v) restyle("headerSpacing", v) end,
            L["Adds or removes space around section headers and beneath each quest's title. 0 keeps the default spacing."])
        headerSpacingSlider:SetPoint("TOPLEFT", lineSpacingSlider, "BOTTOMLEFT", 0, -16)

        local cardHeader = self:CreateHeading(content, L["Quest Rows"])
        cardHeader:SetPoint("TOPLEFT", headerSpacingSlider, "BOTTOMLEFT", 0, -20)

        local layout = self:CreateRadioGroup(content, L["Row Layout"],
            LAYOUTS,
            function() return DB().blockLayout or "classic" end,
            function(v) restyle("blockLayout", v) end,
            300, 14,
            L["Row Layout"],
            L["How each quest is drawn in the tracker. |cffffffffPlain|r is the default look - text straight on the tracker background. |cffffffffCard|r gives every quest its own panel with a background and border, which makes long lists easier to read apart."])
        layout:SetPoint("TOPLEFT", cardHeader, "BOTTOMLEFT", 0, -8)

        local cardColorPicker = self:CreateColorPicker(content, L["Background Color"],
            function() return DB().cardColor end,
            function(v) restyle("cardColor", v) end,
            L["Fill color behind each quest card. Only used while Row Layout is set to Card."], true)
        cardColorPicker:SetPoint("TOPLEFT", layout, "BOTTOMLEFT", 0, -8)

        local cardBorderPicker = self:CreateColorPicker(content, L["Border Color"],
            function() return DB().cardBorderColor end,
            function(v) restyle("cardBorderColor", v) end,
            L["Outline color around each quest card. Only used while Row Layout is set to Card."], true)
        cardBorderPicker:SetPoint("TOPLEFT", cardColorPicker, "BOTTOMLEFT", 0, -10)
        self:AlignSwatchTo(cardBorderPicker, cardColorPicker)

        local cardBorderSlider = self:CreateSlider(content, L["Border Thickness"], 0, 4, 1,
            function() return DB().cardBorderSize or 1 end,
            function(v) restyle("cardBorderSize", v) end,
            L["How thick the card outline is, in pixels. 0 hides the outline and leaves just the fill."])
        cardBorderSlider:SetPoint("TOPLEFT", cardBorderPicker, "BOTTOMLEFT", 0, -20)

        local cardPaddingSlider = self:CreateSlider(content, L["Card Padding"], 2, 14, 1,
            function() return DB().cardPadding or 6 end,
            function(v) restyle("cardPadding", v) end,
            L["Breathing room between a card's edge and the text inside it. Larger values make taller cards."])
        cardPaddingSlider:SetPoint("TOPLEFT", cardBorderSlider, "BOTTOMLEFT", 0, -16)

        local tintCheck = self:CreateCheckbox(content, L["Tint cards by quest type"],
            function() return DB().cardTintByType end,
            function(v) restyle("cardTintByType", v) end,
            L["Gives campaign, legendary, dungeon and raid entries their own card color. Anything else uses the plain background color above."])
        tintCheck:SetPoint("TOPLEFT", cardPaddingSlider, "BOTTOMLEFT", 0, -16)

        local campaignTint = self:CreateColorPicker(content, L["Campaign"],
            function() return DB().cardTintCampaign end,
            function(v) restyle("cardTintCampaign", v) end,
            L["Card color for campaign entries. Needs Tint cards by quest type switched on."], true)
        campaignTint:SetPoint("TOPLEFT", tintCheck, "BOTTOMLEFT", 0, -10)

        local legendaryTint = self:CreateColorPicker(content, L["Legendary"],
            function() return DB().cardTintLegendary end,
            function(v) restyle("cardTintLegendary", v) end,
            L["Card color for legendary entries. Needs Tint cards by quest type switched on."], true)
        legendaryTint:SetPoint("TOPLEFT", campaignTint, "BOTTOMLEFT", 0, -10)
        self:AlignSwatchTo(legendaryTint, campaignTint)

        local dungeonTint = self:CreateColorPicker(content, L["Dungeon"],
            function() return DB().cardTintDungeon end,
            function(v) restyle("cardTintDungeon", v) end,
            L["Card color for dungeon entries. Needs Tint cards by quest type switched on."], true)
        dungeonTint:SetPoint("TOPLEFT", legendaryTint, "BOTTOMLEFT", 0, -10)
        self:AlignSwatchTo(dungeonTint, campaignTint)

        local raidTint = self:CreateColorPicker(content, L["Raid"],
            function() return DB().cardTintRaid end,
            function(v) restyle("cardTintRaid", v) end,
            L["Card color for raid entries. Needs Tint cards by quest type switched on."], true)
        raidTint:SetPoint("TOPLEFT", dungeonTint, "BOTTOMLEFT", 0, -10)
        self:AlignSwatchTo(raidTint, campaignTint)

        -- Renders under Quest Rows, above the Zone Bar Appearance header that owns it.
        -- That is where EQ puts it, so it is where the mirror puts it.
        local zbScaleSlider = self:CreateSlider(content, L["Zone Bar Scale"], 0.5, 2.0, 0.05,
            function() local st = zbState(); return (st and st.scale) or 1.0 end,
            function(v) zbSet("scale", v) end,
            L["Size of the floating bar. The docked section follows the tracker's own scale instead."])
        zbScaleSlider:SetPoint("TOPLEFT", raidTint, "BOTTOMLEFT", 0, -20)

        local zbHeader = self:CreateHeading(content, L["Zone Bar Appearance"])
        zbHeader:SetPoint("TOPLEFT", zbScaleSlider, "BOTTOMLEFT", 0, -20)

        local zbBgCheck = self:CreateCheckbox(content, L["Background"],
            function() local st = zbState(); return not (st and st.showBackground == false) end,
            function(v) zbSet("showBackground", v) end,
            L["Fills the floating bar behind its text. It fades slightly once the bar is locked."])
        zbBgCheck:SetPoint("TOPLEFT", zbHeader, "BOTTOMLEFT", 0, -12)

        local zbBorderCheck = self:CreateCheckbox(content, L["Border"],
            function() local st = zbState(); return not (st and st.showBorder == false) end,
            function(v) zbSet("showBorder", v) end,
            L["Draws a border around the floating bar."])
        zbBorderCheck:SetPoint("TOPLEFT", zbBgCheck, "BOTTOMLEFT", 0, -12)

        local zbBorderPicker = self:CreateColorPicker(content, L["Border Color"],
            function()
                local st = zbState()
                return (st and st.borderColor) or { r = 0.635, g = 0.000, b = 0.039, a = 1 }
            end,
            function(v) zbSet("borderColor", v) end,
            L["Border color and opacity for the floating bar."], true)
        zbBorderPicker:SetPoint("LEFT", zbBorderCheck, "LEFT", 90, 0)

        local zbFontDD = self:CreateDropdown(content, L["Font"],
            function()
                return mediaOptions(ns:GetModule("Media"):GetFontList(),
                                    { value = "", label = SAME_FONT })
            end,
            function() local st = zbState(); return (st and st.font) or "" end,
            function(v) zbSet("font", v ~= "" and v or nil) end,
            L["Font for the floating bar's zone name, count and percentage. The docked section uses the tracker font."])
        zbFontDD:SetPoint("TOPLEFT", zbBorderCheck, "BOTTOMLEFT", 0, -14)

        local zbTexDD = self:CreateDropdown(content, L["Bar Texture"],
            function() return mediaOptions(ns:GetModule("Media"):GetStatusBarList()) end,
            function() local st = zbState(); return (st and st.barTexture) or "Blizzard" end,
            function(v) zbSet("barTexture", v, true) end,
            L["Sets the fill texture of the zone progress bar. Textures added by other media addons (such as SharedMedia, ElvUI, or Details) appear here too."],
            barTextureSwatch)
        zbTexDD:SetPoint("TOPLEFT", zbFontDD, "BOTTOMLEFT", 0, -14)

        local zbBarColorPicker = self:CreateColorPicker(content, L["Bar Color"],
            function()
                local st = zbState()
                return (st and st.barColor) or { r = 0.26, g = 0.42, b = 1.0, a = 1 }
            end,
            function(v) zbSet("barColor", v, true) end,
            L["Fill color and opacity of the bar itself."], true)
        zbBarColorPicker:SetPoint("TOPLEFT", zbTexDD, "BOTTOMLEFT", 0, -16)

        local zbHeaderPicker = self:CreateColorPicker(content, L["Header Color"],
            function()
                local st = zbState()
                return (st and st.headerColor) or { r = 0.93, g = 0.32, b = 0.10, a = 1 }
            end,
            function(v) zbSet("headerColor", v) end,
            L["Color of the zone name on the floating bar. The docked section uses the section header color."], true)
        zbHeaderPicker:SetPoint("TOPLEFT", zbBarColorPicker, "BOTTOMLEFT", 0, -16)

        local zbCountPicker = self:CreateColorPicker(content, L["Count Color"],
            function()
                local st = zbState()
                return (st and st.countColor) or { r = 0.92, g = 0.72, b = 0.02, a = 1 }
            end,
            function(v) zbSet("countColor", v) end,
            L["Color of the completed-of-total count on the floating bar."], true)
        zbCountPicker:SetPoint("TOPLEFT", zbHeaderPicker, "BOTTOMLEFT", 0, -12)
        self:AlignSwatchTo(zbCountPicker, zbHeaderPicker)

        trackerHeader:SetPoint("TOPLEFT", hideArrowsCheck, "BOTTOMLEFT", 0, -20)
    end,
})
