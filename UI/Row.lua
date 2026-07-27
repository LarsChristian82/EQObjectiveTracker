local _, ns = ...

local Row   = ns:RegisterModule("Row", {})
local Entry = ns:GetModule("Entry")
local Util  = ns.Util

local STATE, LINE, ICON = Entry.STATE, Entry.LINE, Entry.ICON

local PAD_X, PAD_Y     = 6, 2
local ICON_SIZE        = 26
local ICON_GAP         = 4
local TITLE_TO_SUB     = 1
local SUB_TO_LINES     = 2
local SUBTITLE_COLOR   = { 0.42, 0.69, 1.00 }
local DEFAULT_DONE_HEX = "44ff44"

-- Reserved for the secure quest-item buttons that land as the first post-launch
-- feature. Every horizontal anchor already offsets by it, so turning it on is a
-- constant change plus the button itself - no layout rework.
Row.GUTTER_W = 0

function Row:Gutter()
    return self.GUTTER_W
end

-- Shared by quests, campaign quests and world quests, so these live here once rather
-- than being copied into each provider.
local OUTER_GLOW, CENTER_FACE, CENTER_TURNIN = {}, {}, {}
do
    local QC = (Enum and Enum.QuestClassification) or {}
    local NORMAL = QC.Normal or -1

    OUTER_GLOW[NORMAL]              = "UI-QuestPoi-OuterGlow"
    OUTER_GLOW[QC.Questline or -2]  = "UI-QuestPoi-OuterGlow"
    OUTER_GLOW[QC.Campaign  or -3]  = "UI-QuestPoiCampaign-OuterGlow"
    OUTER_GLOW[QC.Calling   or -4]  = "UI-QuestPoiCampaign-OuterGlow"
    OUTER_GLOW[QC.Important or -5]  = "UI-QuestPoiImportant-OuterGlow"
    OUTER_GLOW[QC.Legendary or -6]  = "UI-QuestPoiLegendary-OuterGlow"
    OUTER_GLOW[QC.Recurring or -7]  = "UI-QuestPoiRecurring-OuterGlow"
    OUTER_GLOW[QC.Meta      or -8]  = "UI-QuestPoiWrapper-OuterGlow"

    CENTER_FACE[NORMAL]             = "UI-QuestPoi-QuestNumber"
    CENTER_FACE[QC.Questline or -2] = "UI-QuestPoi-QuestNumber"
    CENTER_FACE[QC.Campaign  or -3] = "UI-QuestPoiCampaign-QuestNumber"
    CENTER_FACE[QC.Calling   or -4] = "UI-QuestPoiCampaign-QuestNumber"
    CENTER_FACE[QC.Important or -5] = "UI-QuestPoiImportant-QuestNumber"
    CENTER_FACE[QC.Legendary or -6] = "UI-QuestPoiLegendary-QuestNumber"
    CENTER_FACE[QC.Recurring or -7] = "UI-QuestPoiRecurring-QuestNumber"
    CENTER_FACE[QC.Meta      or -8] = "UI-QuestPoiWrapper-QuestNumber"

    CENTER_TURNIN[NORMAL]             = "UI-QuestIcon-TurnIn-Normal"
    CENTER_TURNIN[QC.Questline or -2] = "UI-QuestIcon-TurnIn-Normal"
    CENTER_TURNIN[QC.Campaign  or -3] = "UI-QuestPoiCampaign-QuestBangTurnIn"
    CENTER_TURNIN[QC.Calling   or -4] = "UI-DailyQuestPoiCampaign-QuestBangTurnIn"
    CENTER_TURNIN[QC.Important or -5] = "UI-QuestPoiImportant-QuestBangTurnIn"
    CENTER_TURNIN[QC.Legendary or -6] = "UI-QuestPoiLegendary-QuestBangTurnIn"
    CENTER_TURNIN[QC.Recurring or -7] = "UI-QuestPoiRecurring-QuestBangTurnIn"
    CENTER_TURNIN[QC.Meta      or -8] = "UI-QuestPoiWrapper-QuestBangTurnIn"
end

local function lookup(tbl, classification)
    local QC = (Enum and Enum.QuestClassification) or {}
    return tbl[classification] or tbl[QC.Normal or -1]
end

local function applyIcon(row, entry)
    local icon = entry.icon
    local kind = icon and icon.kind or ICON.NONE

    if kind == ICON.NONE or not icon then
        row.iconGlow:SetTexture(nil)
        row.icon:SetTexture(nil)
        row.iconBang:SetTexture(nil)
        return
    end

    row.iconGlow:SetVertexColor(1, 1, 1)
    row.icon:SetVertexColor(1, 1, 1)
    row.iconBang:SetVertexColor(1, 1, 1)

    if kind == ICON.QUESTPOI then
        local face = lookup(CENTER_FACE, icon.classification)
        if entry.isFocused and face then face = face .. "-SuperTracked" end
        Util.SafeSetAtlas(row.iconGlow, lookup(OUTER_GLOW, icon.classification))
        Util.SafeSetAtlas(row.icon, face)
        if entry.state == STATE.COMPLETE then
            Util.SafeSetAtlas(row.iconBang, lookup(CENTER_TURNIN, icon.classification))
        else
            Util.SafeSetAtlas(row.iconBang, "Quest-In-Progress-Icon-yellow")
        end
        return
    end

    row.iconGlow:SetTexture(nil)
    row.iconBang:SetTexture(nil)
    if icon.atlas then
        Util.SafeSetAtlas(row.icon, icon.atlas)
    elseif icon.texture then
        row.icon:SetTexture(icon.texture)
        local c = icon.texCoord
        if c then row.icon:SetTexCoord(c[1], c[2], c[3], c[4]) else row.icon:SetTexCoord(0, 1, 0, 1) end
    else
        row.icon:SetTexture(nil)
    end
end

local function doneHex(cfg)
    if not cfg or cfg.overrideCompleteGreen == false then return DEFAULT_DONE_HEX end
    local r, g, b = Util.EffectiveTitleColor(cfg)
    if r then return Util.Hex(r, g, b) end
    return DEFAULT_DONE_HEX
end

-- Every user styling option is applied here, once, so it reaches every content type.
local _scratch = {}
local function buildLineText(entry, cfg)
    local lines  = entry.lines
    local hex    = doneHex(cfg)
    local hideN  = cfg and cfg.showObjectiveNumbers == false
    local simple = cfg and cfg.simplifyMode

    local n = 0
    for i = 1, #lines do
        local ln = lines[i]
        if not (simple and ln.completed) then
            local text = ln.text or ""
            if not ln.richText then
                if ln.kind == LINE.PROGRESSBAR and ln.required and ln.required > 0 then
                    local meter = tostring(ln.current or 0) .. "/" .. tostring(ln.required)
                    text = (text ~= "") and (meter .. " " .. text) or meter
                end
                if hideN then text = Util.StripLeadingCount(text) end
                if ln.completed then
                    text = "|A:common-icon-checkmark:12:12|a |cff" .. hex .. text .. "|r"
                elseif ln.kind == LINE.NOTE then
                    text = "|cff999999" .. text .. "|r"
                else
                    text = "- " .. Util.ColorizeProgress(text)
                end
            end
            n = n + 1
            _scratch[n] = text
            if simple then break end
        end
    end

    -- Simplify mode with everything finished still needs to show the last line
    if n == 0 and simple and #lines > 0 then
        local last = lines[#lines]
        n = 1
        _scratch[1] = "|A:common-icon-checkmark:12:12|a |cff" .. hex .. (last.text or "") .. "|r"
    end

    if n == 0 then return "" end
    return table.concat(_scratch, "\n", 1, n)
end

local function dispatch(row, fnName, ...)
    local Registry = ns:GetModule("Registry")
    local provider = row._providerID and Registry:Get(row._providerID)
    if not (provider and provider[fnName] and row._entry) then return end
    provider[fnName](provider, row._entry, ...)
end

local function onMouseUp(row, button)
    if not row._entry then return end
    if IsModifiedClick and IsModifiedClick("QUESTWATCHTOGGLE") then
        local Filter = ns:GetModule("Filter")
        Filter:SetHidden(row._entry, not Filter:IsHidden(row._entry))
        local Tracker = ns:GetModule("Tracker")
        if Tracker then Tracker:Refresh() end
        return
    end
    dispatch(row, "OnEntryClick", button)
end

local function onEnter(row)
    if not row._entry then return end
    local Registry = ns:GetModule("Registry")
    local provider = row._providerID and Registry:Get(row._providerID)
    if not (provider and provider.OnEntryTooltip) then return end
    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    provider:OnEntryTooltip(row._entry, GameTooltip)
    GameTooltip:Show()
end

local function onLeave()
    GameTooltip:Hide()
end

function Row:Build()
    local r = CreateFrame("Frame")

    r.iconHolder = CreateFrame("Frame", nil, r)
    r.iconHolder:SetSize(ICON_SIZE, ICON_SIZE)

    r.iconGlow = r.iconHolder:CreateTexture(nil, "BACKGROUND")
    r.iconGlow:SetSize(50, 50)
    r.iconGlow:SetPoint("CENTER")
    r.iconGlow:SetBlendMode("ADD")
    r.iconGlow:SetAlpha(0.5)

    r.icon = r.iconHolder:CreateTexture(nil, "ARTWORK", nil, 0)
    r.icon:SetSize(ICON_SIZE, ICON_SIZE)
    r.icon:SetPoint("CENTER")

    r.iconBang = r.iconHolder:CreateTexture(nil, "ARTWORK", nil, 1)
    r.iconBang:SetSize(ICON_SIZE, ICON_SIZE)
    r.iconBang:SetPoint("CENTER")

    r.title = r:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    r.title:SetJustifyH("LEFT")
    r.title:SetWordWrap(true)

    r.subtitle = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    r.subtitle:SetJustifyH("LEFT")
    r.subtitle:SetWordWrap(false)
    r.subtitle:SetTextColor(SUBTITLE_COLOR[1], SUBTITLE_COLOR[2], SUBTITLE_COLOR[3])

    r.lines = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    r.lines:SetJustifyH("LEFT")
    r.lines:SetWordWrap(true)
    r.lines:SetTextColor(0.85, 0.85, 0.85)

    r.timer = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    r.timer:SetJustifyH("RIGHT")
    r.timer:SetWordWrap(false)
    r.timer:Hide()

    r:EnableMouse(true)
    r:SetScript("OnMouseUp", onMouseUp)
    r:SetScript("OnEnter", onEnter)
    r:SetScript("OnLeave", onLeave)

    return r
end

function Row:Reset(row)
    row._entry, row._providerID = nil, nil
    row._sTitle, row._sSub, row._sState  = nil, nil, nil
    row._sFocus, row._sWidth, row._sText = nil, nil, nil
    row._sTime, row._sGen, row._sCardBg  = nil, nil, nil
    ns:GetModule("Card"):Clear(row)
end

Row.generation = 0

function Row:Invalidate()
    self.generation = self.generation + 1
end

function Row:Render(row, entry, width, cfg)
    row._entry      = entry
    row._providerID = entry.providerID

    local subtitle = (cfg and cfg.showZoneTag ~= false) and entry.subtitle or nil
    local lineText = buildLineText(entry, cfg)

    local timeText, timeMins
    if entry.expiresAt then
        timeMins = math.floor((entry.expiresAt - time()) / 60)
        if timeMins > 0 then timeText = Util.TimeShort(timeMins) end
    end

    local Card = ns:GetModule("Card")
    local cardOn, cardPad, cardBorderSize = Card:State(cfg)
    local cardBg, cardBorder
    if cardOn then
        cardBg, cardBorder = Card:Colors(cfg)
        if cfg and cfg.cardTintByType then cardBg = Card:TintFor(cfg, entry) or cardBg end
    end

    -- The resolved colour is compared by table identity, which is stable per option and
    -- changes whenever a setter assigns a new one, so tint swaps repaint without a bump.
    local unchanged =
           row._sTitle == entry.title
       and row._sSub   == subtitle
       and row._sState == entry.state
       and row._sFocus == entry.isFocused
       and row._sWidth == width
       and row._sText  == lineText
       and row._sTime  == timeText
       and row._sCardBg == cardBg
       and row._sGen   == self.generation
    if unchanged then return row:GetHeight() end

    applyIcon(row, entry)

    local padX = cardOn and cardPad or PAD_X
    local padY = cardOn and cardPad or PAD_Y

    -- Zero inset: the row frame already carries the card's padding, so the card tracks it
    if cardOn then
        Card:Draw(row, nil, 0, cardBorderSize, cardBg, cardBorder)
    else
        Card:Clear(row)
    end

    local Media = ns:GetModule("Media")
    Media:ApplyTitleFont(row.title)
    Media:ApplyFont(row.subtitle, -3)
    Media:ApplyFont(row.lines, -2)
    Media:ApplyFont(row.timer, -2)
    row.lines:SetSpacing(Media:LineSpacing())

    local gutter = self:Gutter()
    row.iconHolder:ClearAllPoints()
    row.iconHolder:SetPoint("TOPLEFT", row, "TOPLEFT", padX + gutter, -padY)

    row.timer:ClearAllPoints()
    row.timer:SetPoint("TOPRIGHT", row, "TOPRIGHT", -padX, -padY)
    local timerW = 0
    if timeText then
        row.timer:SetText(timeText)
        row.timer:SetTextColor(Util.TimeColor(timeMins))
        row.timer:Show()
        timerW = row.timer:GetStringWidth() + 6
    else
        row.timer:SetText("")
        row.timer:Hide()
    end

    -- Widths are explicit rather than left to a TOPRIGHT anchor, so the timer only ever
    -- narrows the title. Objectives keep the full column.
    row.title:ClearAllPoints()
    row.title:SetPoint("TOPLEFT", row.iconHolder, "TOPRIGHT", ICON_GAP, 1)

    -- Anchor the subtitle even when hidden - the lines below hang off it, so leaving it
    -- unpositioned drops the objectives off the frame the moment it is shown
    row.subtitle:ClearAllPoints()
    row.subtitle:SetPoint("TOPLEFT", row.title, "BOTTOMLEFT", 0, -TITLE_TO_SUB)

    row.title:SetText(entry.title or "")
    local ovR, ovG, ovB = Util.EffectiveTitleColor(cfg)
    -- Recolouring completed entries needs a colour to recolour them TO, so the toggle is
    -- inert until an override or class colour is set.
    local recolorComplete = ovR and (not cfg or cfg.overrideCompleteGreen ~= false)
    if entry.state == STATE.FAILED then
        row.title:SetTextColor(0.85, 0.27, 0.27)
    elseif entry.state == STATE.COMPLETE and not recolorComplete then
        row.title:SetTextColor(0.27, 0.85, 0.27)
    elseif ovR then
        row.title:SetTextColor(ovR, ovG, ovB)
    elseif (not cfg or cfg.colorByDifficulty ~= false) and entry.level and GetQuestDifficultyColor then
        local c = GetQuestDifficultyColor(entry.level)
        row.title:SetTextColor(c.r, c.g, c.b)
    else
        row.title:SetTextColor(0.92, 0.72, 0.02)
    end

    local subGap = math.max(0, SUB_TO_LINES + Media:HeaderSpacing())
    row.lines:ClearAllPoints()
    if subtitle and subtitle ~= "" then
        row.subtitle:SetText(subtitle)
        row.subtitle:Show()
        row.lines:SetPoint("TOPLEFT", row.subtitle, "BOTTOMLEFT", 0, -subGap)
    else
        row.subtitle:SetText("")
        row.subtitle:Hide()
        row.lines:SetPoint("TOPLEFT", row.title, "BOTTOMLEFT", 0, -subGap)
    end
    row.lines:SetText(lineText)

    -- Without an explicit SetWidth, GetStringHeight returns stale values after a
    -- width change and rows overlap
    local textW = width - (ICON_SIZE + ICON_GAP + padX * 2 + gutter)
    if textW > 0 then
        row.title:SetWidth(math.max(1, textW - timerW))
        row.lines:SetWidth(textW)
        if row.subtitle:IsShown() then row.subtitle:SetWidth(textW) end
    end

    local titleH = math.max(row.title:GetStringHeight(), ICON_SIZE)
    local subH   = row.subtitle:IsShown() and (TITLE_TO_SUB + row.subtitle:GetStringHeight()) or 0
    local linesH = (lineText ~= "") and (subGap + row.lines:GetStringHeight()) or 0
    local h      = titleH + subH + linesH + padY * 2

    row:SetHeight(math.max(1, h))

    row._sTitle, row._sSub, row._sState = entry.title, subtitle, entry.state
    row._sFocus, row._sWidth, row._sText = entry.isFocused, width, lineText
    row._sTime = timeText
    row._sCardBg = cardBg
    row._sGen = self.generation

    return row:GetHeight()
end
