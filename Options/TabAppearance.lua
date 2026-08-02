local _, ns = ...

local Options = ns:GetModule("Options")
local L       = ns.L

-- Each dropdown list is both what the user sees and what the setter compares against,
-- so every entry goes through L on both sides. Comparing a translated pick against an
-- English literal would silently always take the else branch.
local NONE_LABEL = L["None"]
-- OUTLINE and THICKOUTLINE are stored raw and handed to SetFont, so translating them
-- would write an unusable font flag into the profile.
local OUTLINES   = { NONE_LABEL, "OUTLINE", "THICKOUTLINE" }

local LAYOUT_PLAIN, LAYOUT_CARD = L["Plain"], L["Card"]
local LAYOUTS    = { LAYOUT_PLAIN, LAYOUT_CARD }

local BAR_H, BAR_V = L["Horizontal"], L["Vertical"]
local BAR_STYLES = { BAR_H, BAR_V }

local ALIGN_LEFT, ALIGN_CENTER, ALIGN_RIGHT = L["Left"], L["Center"], L["Right"]
local SCENARIO_ALIGN = { ALIGN_LEFT, ALIGN_CENTER, ALIGN_RIGHT }

local function alignLabel(v)
    if v == "LEFT"  then return ALIGN_LEFT  end
    if v == "RIGHT" then return ALIGN_RIGHT end
    return ALIGN_CENTER
end

-- The stored value stays the English enum. Deriving it with label:upper() would break
-- the moment a translation is loaded, and would write garbage into the profile.
local function alignValue(label)
    if label == ALIGN_LEFT  then return "LEFT"  end
    if label == ALIGN_RIGHT then return "RIGHT" end
    return "CENTER"
end

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

Options:RegisterTab({
    id    = "appearance",
    title = L["Appearance"],
    order = 30,
    build = function(self, content)
        self:CreateHeading(content, L["Text"])

        self:CreateDropdown(content, L["Font"],
            function() return ns:GetModule("Media"):GetFontList() end,
            function() return DB().font end,
            function(v) restyle("font", v) end,
            L["Fonts registered through LibSharedMedia, so anything from ElvUI or SharedMedia appears here too."])

        self:CreateSlider(content, L["Font Size"], 8, 24, 1,
            function() return DB().fontSize or 15 end,
            function(v) restyle("fontSize", v) end,
            L["Base size for objective text. Titles and headers offset from this."], px)

        self:CreateDropdown(content, L["Outline"],
            function() return OUTLINES end,
            function() local o = DB().fontOutline; return (o == nil or o == "") and NONE_LABEL or o end,
            function(v) restyle("fontOutline", v == NONE_LABEL and "" or v) end,
            L["Outlines keep small text legible over bright terrain."])

        self:CreateSlider(content, L["Title Size Offset"], -4, 10, 1,
            function() return DB().titleSizeDelta or 0 end,
            function(v) restyle("titleSizeDelta", v) end,
            L["Size difference between quest titles and their objective lines."], signed)

        self:CreateCheckbox(content, L["Text Shadow"],
            function() return DB().textShadow end,
            function(v) restyle("textShadow", v) end,
            L["Drop shadow behind all tracker text. Helps a lot without an outline."])

        self:CreateColorPicker(content, L["Shadow Color"],
            function() return DB().textShadowColor end,
            function(v) restyle("textShadowColor", v) end,
            L["Shadow color and opacity."], true)

        self:CreateSlider(content, L["Shadow distance"], 1, 5, 1,
            function() return DB().textShadowStrength or 2 end,
            function(v) restyle("textShadowStrength", v) end,
            L["How far the shadow is offset from the text."], px)

        self:CreateHeading(content, L["Scenario"])

        self:CreateCheckbox(content, L["Text Shadow"],
            function() return DB().scenarioTextShadow ~= false end,
            function(v)
                DB().scenarioTextShadow = v
                ns:GetModule("Scenario"):ApplyBannerShadow()
                ns:GetModule("Tracker"):Render()
            end,
            L["Draws a drop shadow behind the scenario and delve banner text, the Stage and name lines. This is SEPARATE from the Text Shadow above, which affects only the quest and objective text - the banner is styled on its own."])

        self:CreateColorPicker(content, L["Shadow Color"],
            function() return DB().scenarioTextShadowColor end,
            function(v)
                DB().scenarioTextShadowColor = v
                ns:GetModule("Scenario"):ApplyBannerShadow()
            end,
            L["Color and opacity of the banner's drop shadow."], true)

        self:CreateSlider(content, L["Shadow distance"], 1, 6, 0.5,
            function() return DB().scenarioTextShadowStrength or 1 end,
            function(v)
                DB().scenarioTextShadowStrength = v
                ns:GetModule("Scenario"):ApplyBannerShadow()
                ns:GetModule("Tracker"):Render()
            end,
            L["How far the banner's drop shadow is cast. Only used while the Scenario Text Shadow above is on."], px)

        self:CreateDropdown(content, L["Banner Alignment"],
            function() return SCENARIO_ALIGN end,
            function() return alignLabel(DB().scenarioTextAlign) end,
            function(v) relayout("scenarioTextAlign", alignValue(v)) end,
            L["Positions the scenario / delve banner within the tracker. Left lines it up with the quest text, Center keeps it centered (the default), and Right pushes it to the tracker's right edge."])

        self:CreateSlider(content, L["Banner Text Size"], -4, 6, 0.5,
            function() return DB().scenarioTextSizeDelta or 0 end,
            function(v) relayout("scenarioTextSizeDelta", v) end,
            L["Grows or shrinks the scenario / delve banner's Stage and name text. 0 is the default size. The banner artwork is a fixed size, so large values may overflow it."], signed)

        self:CreateSlider(content, L["Criteria Text Size"], 8, 24, 0.5,
            function() return DB().scenarioFontSize or 13 end,
            function(v) relayout("scenarioFontSize", v) end,
            L["Sizes the scenario and delve objective lines under the banner, separately from the Banner Text Size above."], px)

        self:CreateHeading(content, L["Title colors"])

        self:CreateCheckbox(content, L["Color titles by difficulty"],
            function() return DB().colorByDifficulty ~= false end,
            function(v) restyle("colorByDifficulty", v) end,
            L["Tints each title by how hard the quest is for your level, the same way the quest log does. Turn it off for plain gold titles."])

        self:CreateColorPicker(content, L["Title color override"],
            function() return DB().titleColorOverride end,
            function(v) restyle("titleColorOverride", v) end,
            L["Forces every title to one color. Clear it to go back to difficulty coloring, or to plain gold when that is off."],
            false,
            function() restyle("titleColorOverride", nil) end)

        self:CreateCheckbox(content, L["Use class color for titles"],
            function() return DB().titleColorUseClass end,
            function(v) restyle("titleColorUseClass", v) end,
            L["Colors titles with the class color of the character you are logged in on. Wins over the override above while it is on."])

        self:CreateCheckbox(content, L["Use title color when complete"],
            function() return DB().overrideCompleteGreen ~= false end,
            function(v) restyle("overrideCompleteGreen", v) end,
            L["Completed entries and finished objectives use your title color instead of green. Does nothing until a color override or class color is set, since it needs a color to use."])

        self:CreateHeading(content, L["Size and spacing"])

        self:CreateSlider(content, L["Tracker Scale"], 0.5, 2.0, 0.05,
            function() return DB().scale or 1 end,
            function(v)
                DB().scale = v
                ns:GetModule("Tracker"):ApplyScale()
            end,
            L["Scales the whole tracker. Takes effect immediately out of combat."], pct)

        self:CreateSlider(content, L["Space between entries"], 0, 20, 1,
            function() return DB().blockSpacing or 2 end,
            function(v) relayout("blockSpacing", v) end,
            L["Vertical gap between each entry and between sections."], px)

        self:CreateSlider(content, L["Space between objective lines"], -8, 24, 1,
            function() return DB().lineSpacing or 0 end,
            function(v) restyle("lineSpacing", v) end,
            L["Extra spacing between the objective lines within one entry."], signed)

        self:CreateSlider(content, L["Space under titles"], -8, 24, 1,
            function() return DB().headerSpacing or 0 end,
            function(v) restyle("headerSpacing", v) end,
            L["Gap between an entry's title and its first objective line."], signed)

        self:CreateHeading(content, L["Entry rows"])

        self:CreateDropdown(content, L["Row Layout"],
            function() return LAYOUTS end,
            function() return DB().blockLayout == "card" and LAYOUT_CARD or LAYOUT_PLAIN end,
            function(v) restyle("blockLayout", v == LAYOUT_CARD and "card" or "classic") end,
            L["Plain draws text straight on the tracker background. Card gives every entry its own panel, which makes long lists easier to tell apart."])

        self:CreateColorPicker(content, L["Card background color"],
            function() return DB().cardColor end,
            function(v) restyle("cardColor", v) end,
            L["Fill behind each card. Only used while Row Layout is Card."], true)

        self:CreateColorPicker(content, L["Card border color"],
            function() return DB().cardBorderColor end,
            function(v) restyle("cardBorderColor", v) end,
            L["Outline around each card. Only used while Row Layout is Card."], true)

        self:CreateSlider(content, L["Card border thickness"], 0, 4, 1,
            function() return DB().cardBorderSize or 1 end,
            function(v) restyle("cardBorderSize", v) end,
            L["0 hides the outline and leaves just the fill."], px)

        self:CreateSlider(content, L["Card Padding"], 2, 14, 1,
            function() return DB().cardPadding or 6 end,
            function(v) restyle("cardPadding", v) end,
            L["Breathing room between a card's edge and the text inside it. Larger values make taller cards."], px)

        self:CreateCheckbox(content, L["Tint cards by type"],
            function() return DB().cardTintByType end,
            function(v) restyle("cardTintByType", v) end,
            L["Gives campaign, legendary, dungeon and raid entries their own card color. Anything else uses the plain background color above."])

        self:CreateColorPicker(content, L["Campaign tint"],
            function() return DB().cardTintCampaign end,
            function(v) restyle("cardTintCampaign", v) end,
            L["Card color for campaign entries. Needs Tint cards by type switched on."], true)

        self:CreateColorPicker(content, L["Legendary tint"],
            function() return DB().cardTintLegendary end,
            function(v) restyle("cardTintLegendary", v) end,
            L["Card color for legendary entries. Needs Tint cards by type switched on."], true)

        self:CreateColorPicker(content, L["Dungeon tint"],
            function() return DB().cardTintDungeon end,
            function(v) restyle("cardTintDungeon", v) end,
            L["Card color for dungeon entries. Needs Tint cards by type switched on."], true)

        self:CreateColorPicker(content, L["Raid tint"],
            function() return DB().cardTintRaid end,
            function(v) restyle("cardTintRaid", v) end,
            L["Card color for raid entries. Needs Tint cards by type switched on."], true)

        self:CreateHeading(content, L["Section headers"])

        self:CreateColorPicker(content, L["Header Color"],
            function() return DB().headerColor end,
            function(v) relayout("headerColor", v) end,
            L["Color of the Quests, Campaign and World Quests headings."])

        self:CreateCheckbox(content, L["Use class color for headers"],
            function() return DB().headerColorUseClass end,
            function(v) relayout("headerColorUseClass", v) end,
            L["Colors the section headings with your character's class color. Wins over the Header Color above while it is on."])

        self:CreateColorPicker(content, L["Header divider color"],
            function() return DB().headerDividerColor end,
            function(v) relayout("headerDividerColor", v) end,
            L["The thin rule under each section heading."], true)

        self:CreateSlider(content, L["Header Size Offset"], -4, 12, 1,
            function() return DB().headerSizeDelta or 4 end,
            function(v) relayout("headerSizeDelta", v) end,
            L["Size difference between section headings and objective text."], signed)

        self:CreateCheckbox(content, L["Header bar"],
            function() return DB().headerBar end,
            function(v) relayout("headerBar", v) end,
            L["Draws a colored gradient bar behind each section heading, for a look closer to the default Blizzard tracker."])

        self:CreateColorPicker(content, L["Bar Color"],
            function() return DB().headerBarColor end,
            function(v) relayout("headerBarColor", v) end,
            L["Brightest end of the bar gradient. The other end is the same color darkened."], true)

        self:CreateDropdown(content, L["Bar Style"],
            function() return BAR_STYLES end,
            function() return (DB().headerBarStyle or 1) == 2 and BAR_V or BAR_H end,
            function(v) relayout("headerBarStyle", v == BAR_V and 2 or 1) end,
            L["Horizontal runs bright on the left to dark on the right. Vertical runs bright at the top to dark at the bottom."])

        self:CreateSlider(content, L["Bar Height"], 6, 26, 1,
            function() return DB().headerBarHeight or 22 end,
            function(v) relayout("headerBarHeight", v) end,
            L["The bar is centered on the heading row, so larger values fill more of it."], px)

        self:CreateCheckbox(content, L["Soft bar edges"],
            function() return DB().headerBarSoftEdges end,
            function(v) relayout("headerBarSoftEdges", v) end,
            L["Feathers the top, left and right edges so the bar blends into the UI instead of sitting in a hard box. The bottom stays flush with the divider line."])

        self:CreateSlider(content, L["Edge Softness"], 1, 10, 1,
            function() return DB().headerBarSoftEdgeStrength or 10 end,
            function(v) relayout("headerBarSoftEdgeStrength", v) end,
            L["Higher is softer. Only applies while Soft bar edges is on."])

        self:CreateHeading(content, L["Scroll bar"])

        self:CreateCheckbox(content, L["Hide scroll bar"],
            function() return DB().hideScrollBar end,
            function(v) relayout("hideScrollBar", v) end,
            L["Removes the scroll bar entirely and gives its gutter back to the text. The tracker still scrolls with the mouse wheel."])

        self:CreateCheckbox(content, L["Scroll Bar Background"],
            function() return DB().scrollBarBg ~= false end,
            function(v) relayout("scrollBarBg", v) end,
            L["Draws a track behind the scroll bar so it stays visible over bright terrain."])

        self:CreateColorPicker(content, L["Scroll Bar Color"],
            function() return DB().scrollBarBgColor end,
            function(v) relayout("scrollBarBgColor", v) end,
            L["Color and opacity of the scroll bar track."], true)

        self:CreateCheckbox(content, L["Solid color thumb"],
            function() return DB().skinScrollBar end,
            function(v) relayout("skinScrollBar", v) end,
            L["Replaces the textured draggable block with a flat single color one. Turning this off restores the stock Blizzard look."])

        self:CreateColorPicker(content, L["Thumb Color"],
            function() return DB().scrollBarThumbColor end,
            function(v) relayout("scrollBarThumbColor", v) end,
            L["Color and opacity of the draggable block. Only used while Solid color thumb is on."], true)

        self:CreateSlider(content, L["Thumb Width"], 4, 16, 1,
            function() return DB().scrollBarThumbWidth or 8 end,
            function(v) relayout("scrollBarThumbWidth", v) end,
            L["How wide the draggable block is. Only used while Solid color thumb is on."], px)

        self:CreateCheckbox(content, L["Hide scroll bar arrows"],
            function() return DB().hideScrollArrows end,
            function(v) relayout("hideScrollArrows", v) end,
            L["Hides the up and down buttons at the ends of the bar. It still scrolls by dragging the thumb or using the mouse wheel."])

        self:CreateHeading(content, L["Frame"])

        self:CreateCheckbox(content, L["Show background"],
            function() return DB().showBackground end,
            function(v) relayout("showBackground", v) end,
            L["Fills the tracker behind the text. Useful over bright terrain."])

        self:CreateColorPicker(content, L["Background Color"],
            function() return DB().backgroundColor end,
            function(v) relayout("backgroundColor", v) end,
            L["Background color and opacity."], true)

        self:CreateCheckbox(content, L["Show border"],
            function() return DB().showBorder end,
            function(v) relayout("showBorder", v) end,
            L["Draws a border around the tracker."])

        self:CreateColorPicker(content, L["Border Color"],
            function() return DB().borderColor end,
            function(v) relayout("borderColor", v) end,
            L["Border color and opacity."], true)

        self:CreateSlider(content, L["Border Thickness"], 1, 8, 1,
            function() return DB().borderSize or 1 end,
            function(v) relayout("borderSize", v) end,
            L["Border thickness in pixels."], px)

        self:CreateHeading(content, L["Zone Bar Appearance"])

        self:CreateDropdown(content, L["Bar Texture"],
            function() return ns:GetModule("Media"):GetStatusBarList() end,
            function() local st = zbState(); return (st and st.barTexture) or "Blizzard" end,
            function(v) zbSet("barTexture", v, true) end,
            L["Fill texture for the zone progress bar. Textures registered through LibSharedMedia, so anything from ElvUI, SharedMedia or Details appears here too."],
            barTextureSwatch)

        self:CreateColorPicker(content, L["Bar Color"],
            function()
                local st = zbState()
                return (st and st.barColor) or { r = 0.26, g = 0.42, b = 1.0, a = 1 }
            end,
            function(v) zbSet("barColor", v, true) end,
            L["Fill color and opacity of the bar itself."], true)

        self:CreateSlider(content, L["Scale"], 0.5, 2.0, 0.05,
            function() local st = zbState(); return (st and st.scale) or 1.0 end,
            function(v) zbSet("scale", v) end,
            L["Size of the floating bar. The docked section follows the tracker's own scale instead."],
            pct)

        self:CreateDropdown(content, L["Font"],
            function()
                local list = { SAME_FONT }
                for _, n in ipairs(ns:GetModule("Media"):GetFontList()) do
                    list[#list + 1] = n
                end
                return list
            end,
            function() local st = zbState(); return (st and st.font) or SAME_FONT end,
            function(v) zbSet("font", v ~= SAME_FONT and v or nil) end,
            L["Font for the floating bar's zone name, count and percentage. The docked section uses the tracker font."])

        self:CreateColorPicker(content, L["Zone name color"],
            function()
                local st = zbState()
                return (st and st.headerColor) or { r = 0.93, g = 0.32, b = 0.10, a = 1 }
            end,
            function(v) zbSet("headerColor", v) end,
            L["Color of the zone name on the floating bar. The docked section uses the section header color."], true)

        self:CreateColorPicker(content, L["Count Color"],
            function()
                local st = zbState()
                return (st and st.countColor) or { r = 0.92, g = 0.72, b = 0.02, a = 1 }
            end,
            function(v) zbSet("countColor", v) end,
            L["Color of the completed-of-total count on the floating bar."], true)

        self:CreateCheckbox(content, L["Show background"],
            function() local st = zbState(); return not (st and st.showBackground == false) end,
            function(v) zbSet("showBackground", v) end,
            L["Fills the floating bar behind its text. It fades slightly once the bar is locked."])

        self:CreateCheckbox(content, L["Show border"],
            function() local st = zbState(); return not (st and st.showBorder == false) end,
            function(v) zbSet("showBorder", v) end,
            L["Draws a border around the floating bar."])

        self:CreateColorPicker(content, L["Border Color"],
            function()
                local st = zbState()
                return (st and st.borderColor) or { r = 0.635, g = 0.000, b = 0.039, a = 1 }
            end,
            function(v) zbSet("borderColor", v) end,
            L["Border color and opacity for the floating bar."], true)
    end,
})
