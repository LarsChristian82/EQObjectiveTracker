local _, ns = ...

local Tracker = ns:RegisterModule("Tracker", {})

local CONTENT_PAD      = 4
local SCROLLBAR_GUTTER = 26
local DRAG_HANDLE_H    = 14
local GRIP_SIZE        = 14
local REFRESH_THROTTLE = 0.25

local WQ_PIN_FRACTION  = 0.40
local PINNED_GROUP     = "worldquests"
local CONTAINER_GROUP  = "scenarios"

-- Hiding the bar reclaims its gutter for text, so the inset is a function of the
-- setting rather than a constant.
local function scrollGutter(cfg)
    if cfg and cfg.hideScrollBar == true then return CONTENT_PAD * 2 end
    return SCROLLBAR_GUTTER
end

-- The pinned region reserves its header plus a 2px gap before its own scroll area.
-- Derived rather than a constant so it tracks the section header height.
local function headerBand()
    return ns:GetModule("Sections"):Height() + 2
end
local MIN_W, MIN_H     = 200, 100
local MAX_W, MAX_H     = 600, 2000

function Tracker:_ApplyPosition(anchor, relativePoint, x, y)
    local f = self.frame
    if not f then return end
    f:ClearAllPoints()
    f:SetPoint(anchor or "CENTER", UIParent, relativePoint or anchor or "CENTER", x or 0, y or 0)
end

function Tracker:PersistPositionAndSize()
    local f = self.frame
    if not f then return end
    local cfg = ns:GetModule("DB"):Tracker()
    if not cfg then return end

    cfg.width     = math.floor(f:GetWidth())
    cfg.maxHeight = math.floor(f:GetHeight())

    local point, _, relativePoint, x, y = f:GetPoint()
    if not point then return end

    cfg.anchor        = point
    cfg.relativePoint = relativePoint or point
    cfg.xOffset       = math.floor((x or 0) + 0.5)
    cfg.yOffset       = math.floor((y or 0) + 0.5)

    self:_ApplyPosition(cfg.anchor, cfg.relativePoint, cfg.xOffset, cfg.yOffset)
end

function Tracker:IsLocked()
    local gen = ns:GetModule("DB"):General()
    return (gen and gen.lockTracker) and true or false
end

function Tracker:ApplyLockState()
    local f = self.frame
    if not (f and f.grip) then return end
    local locked = self:IsLocked()
    if locked and f._dragging then
        f:StopMovingOrSizing()
        f._dragging = nil
    end
    f.grip:SetAlpha(locked and 0 or 1)
    f.grip:EnableMouse(not locked)
end

function Tracker:BuildFrame()
    local cfg = ns:GetModule("DB"):Tracker()

    local f = CreateFrame("Frame", "EQOTTrackerFrame", UIParent)
    self.frame = f
    f:SetSize(cfg.width, cfg.maxHeight)
    f:SetScale(cfg.scale or 1)
    self:_ApplyPosition(cfg.anchor, cfg.relativePoint, cfg.xOffset, cfg.yOffset)
    f:SetMovable(true)
    f:SetResizable(true)
    if ns.Has.ResizeBounds then f:SetResizeBounds(MIN_W, MIN_H, MAX_W, MAX_H) end
    f:SetClampedToScreen(true)

    local drag = CreateFrame("Frame", nil, f)
    drag:SetPoint("TOPLEFT")
    drag:SetPoint("TOPRIGHT")
    drag:SetHeight(DRAG_HANDLE_H)
    drag:EnableMouse(true)
    drag:RegisterForDrag("LeftButton")

    local hint = drag:CreateTexture(nil, "OVERLAY")
    hint:SetAllPoints()
    hint:SetColorTexture(1, 1, 1, 0)

    drag:SetScript("OnEnter", function()
        hint:SetColorTexture(1, 1, 1, 0.15)
        GameTooltip:SetOwner(drag, "ANCHOR_BOTTOM")
        GameTooltip:SetText("EQ Objective Tracker", 0.92, 0.72, 0.02)
        if Tracker:IsLocked() then
            GameTooltip:AddLine("Tracker locked", 1, 0.3, 0.3)
            GameTooltip:AddLine("Use /eqot unlock to move it.", 0.8, 0.8, 0.8)
        else
            GameTooltip:AddLine("Drag to move, corner grip to resize.", 1, 1, 1)
            GameTooltip:AddLine("/eqot for options", 0.8, 0.8, 0.8)
        end
        GameTooltip:Show()
    end)
    drag:SetScript("OnLeave", function()
        hint:SetColorTexture(1, 1, 1, 0)
        GameTooltip:Hide()
    end)

    local function stopDrag()
        if not f._dragging then return end
        if InCombatLockdown() then
            ns:GetModule("Events"):RunWhenOutOfCombat("eqot.stopDrag", stopDrag)
            return
        end
        f._dragging = nil
        f:StopMovingOrSizing()
        Tracker:PersistPositionAndSize()
    end

    drag:SetScript("OnDragStart", function()
        if InCombatLockdown() or Tracker:IsLocked() then return end
        f:StartMoving()
        f._dragging = true
    end)
    drag:SetScript("OnDragStop", stopDrag)

    local grip = CreateFrame("Button", nil, f)
    grip:SetSize(GRIP_SIZE, GRIP_SIZE)
    grip:SetPoint("BOTTOMRIGHT", -2, 2)
    for i, len in ipairs({ 12, 8, 4 }) do
        local g = grip:CreateTexture(nil, "OVERLAY")
        g:SetColorTexture(1, 1, 1, 0.5)
        g:SetSize(len, 1)
        g:SetPoint("BOTTOMRIGHT", -2, 2 + (i - 1) * 3)
    end
    grip:SetScript("OnMouseDown", function()
        if InCombatLockdown() or Tracker:IsLocked() then return end
        f:StartSizing("BOTTOMRIGHT")
        f._dragging = true
    end)
    grip:SetScript("OnMouseUp", stopDrag)

    -- Its own frame one level below so the backdrop never draws over rows
    local bg = CreateFrame("Frame", nil, f, "BackdropTemplate")
    bg:SetAllPoints(f)
    bg:SetFrameLevel(math.max(0, f:GetFrameLevel() - 1))
    f.bgFrame = bg
    f.background = bg:CreateTexture(nil, "BACKGROUND")
    f.background:SetAllPoints()
    f.background:Hide()

    local scenarioContainer = CreateFrame("Frame", nil, f)
    scenarioContainer:SetPoint("TOPLEFT", CONTENT_PAD, -DRAG_HANDLE_H)
    -- Reserve the quest list's scroll bar gutter so the banner lines up with scrolled text
    scenarioContainer:SetPoint("TOPRIGHT", -(scrollGutter(cfg) - CONTENT_PAD), -DRAG_HANDLE_H)
    scenarioContainer:SetHeight(1)
    f.scenarioContainer = scenarioContainer
    scenarioContainer:SetScript("OnSizeChanged", function() Tracker:Refresh() end)

    local eventsRegion = CreateFrame("Frame", nil, f)
    eventsRegion:SetHeight(1)
    eventsRegion:Hide()
    f.eventsRegion = eventsRegion

    local eventsScroll = CreateFrame("ScrollFrame", nil, eventsRegion, "UIPanelScrollFrameTemplate")
    eventsScroll:SetPoint("TOPLEFT",     eventsRegion, "TOPLEFT",     0, -headerBand())
    eventsScroll:SetPoint("BOTTOMRIGHT", eventsRegion, "BOTTOMRIGHT", 0, 0)
    local eventsContent = CreateFrame("Frame", nil, eventsScroll)
    eventsContent:SetSize(math.max(1, cfg.width - scrollGutter(cfg)), 1)
    eventsScroll:SetScrollChild(eventsContent)
    f.eventsScroll, f.eventsContent = eventsScroll, eventsContent

    local eBg = f:CreateTexture(nil, "BORDER")
    local eBar = eventsScroll.ScrollBar or eventsScroll.scrollBar
    if eBar then
        eBg:SetPoint("TOPLEFT",     eBar, "TOPLEFT",    -1, 0)
        eBg:SetPoint("BOTTOMRIGHT", eBar, "BOTTOMRIGHT", 1, 0)
    else
        eBg:SetPoint("TOPLEFT",     eventsScroll, "TOPRIGHT",     0, 1)
        eBg:SetPoint("BOTTOMRIGHT", eventsRegion, "BOTTOMRIGHT", -2, 0)
    end
    eBg:Hide()
    f.eventsScrollBarBG = eBg

    -- scroll and eventsRegion are anchored by ApplyWorldQuestsPosition per the Top/Bottom
    -- setting, so they are deliberately not hard-anchored here.
    local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(math.max(1, cfg.width - scrollGutter(cfg)), 1)
    scroll:SetScrollChild(content)

    local function wheelScroll(sf, delta)
        local range = sf:GetVerticalScrollRange() or 0
        if range <= 0 then return end
        local new = (sf:GetVerticalScroll() or 0) - delta * 24
        sf:SetVerticalScroll(math.max(0, math.min(new, range)))
    end
    for _, sf in ipairs({ scroll, eventsScroll }) do
        sf:EnableMouseWheel(true)
        sf:SetScript("OnMouseWheel", wheelScroll)
    end

    -- Anchored to the bar itself when the template exposes one, so it tracks the bar's
    -- real width rather than assuming the gutter constant matches it.
    local sbBG = f:CreateTexture(nil, "BORDER")
    local sBar = scroll.ScrollBar or scroll.scrollBar
    if sBar then
        sbBG:SetPoint("TOPLEFT",     sBar, "TOPLEFT",    -1, 0)
        sbBG:SetPoint("BOTTOMRIGHT", sBar, "BOTTOMRIGHT", 1, 0)
    else
        sbBG:SetPoint("TOPLEFT",     scroll, "TOPRIGHT",     0, 1)
        sbBG:SetPoint("BOTTOMRIGHT", bg,     "BOTTOMRIGHT", -2, GRIP_SIZE + 2)
    end
    sbBG:Hide()
    f.scrollBarBG = sbBG

    f:SetScript("OnSizeChanged", function() Tracker:Refresh() end)

    f.drag, f.grip, f.scroll, f.content = drag, grip, scroll, content
    self:ApplyWorldQuestsPosition()
    self:ApplyLockState()
end

-- Blizzard re-shows the bar whenever the scroll range changes, so this needs a
-- persistent hook rather than a one-shot Hide.
local function setScrollBarHidden(sf, hidden)
    if not sf then return end
    local bar = sf.ScrollBar or sf.scrollBar
    if not bar then return end
    bar._eqotHidden = hidden
    if not bar._eqotShowHook then
        bar._eqotShowHook = true
        bar:HookScript("OnShow", function(b) if b._eqotHidden then b:Hide() end end)
    end
    if hidden then
        if bar:IsShown() then bar:Hide() end
    else
        bar:SetShown((sf:GetVerticalScrollRange() or 0) > 0.5)
    end
end

local function scrollArrowButtons(bar)
    local name = bar.GetName and bar:GetName()
    local up = bar.ScrollUpButton or bar.Back
        or (name and _G[name .. "ScrollUpButton"])
    local down = bar.ScrollDownButton or bar.Forward
        or (name and _G[name .. "ScrollDownButton"])
    return up, down
end

-- Blizzard re-shows the arrows whenever the scroll range changes, so hiding needs a
-- persistent hook rather than a one-shot Hide.
local function setArrowHidden(btn, hidden)
    if not btn then return end
    btn._eqotArrowHidden = hidden
    if not btn._eqotArrowHook then
        btn._eqotArrowHook = true
        btn:HookScript("OnShow", function(b) if b._eqotArrowHidden then b:Hide() end end)
    end
    if hidden then
        if btn:IsShown() then btn:Hide() end
    elseif not btn:IsShown() then
        btn:Show()
    end
end

-- The thumb is a texture on the old slider-based bar and a frame on the newer one, so
-- both shapes are handled. The stock look is captured before the first skin so turning
-- it back off restores rather than guesses.
local function applyScrollBarSkin(sf, cfg)
    if not (sf and cfg) then return end
    local bar = sf.ScrollBar or sf.scrollBar
    if not bar then return end
    local on = cfg.skinScrollBar == true
    local c  = cfg.scrollBarThumbColor or {}
    local r, g, b, a = c.r or 0.60, c.g or 0.60, c.b or 0.65, c.a or 0.90
    local w  = cfg.scrollBarThumbWidth

    local thumbTex = bar.GetThumbTexture and bar:GetThumbTexture()
    if thumbTex then
        -- Capture the plain texture as well as the atlas. A stock thumb that is not
        -- atlas-based leaves the atlas nil, and restoring on that alone strands the
        -- solid colour permanently, since the skinned flag is cleared either way.
        if not bar._eqotThumbCaptured then
            bar._eqotThumbCaptured = true
            bar._eqotThumbAtlas   = thumbTex.GetAtlas and thumbTex:GetAtlas() or nil
            bar._eqotThumbTexture = thumbTex.GetTexture and thumbTex:GetTexture() or nil
            bar._eqotThumbW       = thumbTex:GetWidth()
        end
        if on then
            thumbTex:SetTexture(nil)
            thumbTex:SetColorTexture(r, g, b, a)
            if w and w > 0 then thumbTex:SetWidth(w) end
        elseif bar._eqotThumbSkinned then
            if bar._eqotThumbAtlas then
                thumbTex:SetAtlas(bar._eqotThumbAtlas, true)
            else
                thumbTex:SetTexture(bar._eqotThumbTexture)
            end
            if bar._eqotThumbW and bar._eqotThumbW > 0 then thumbTex:SetWidth(bar._eqotThumbW) end
        end
        bar._eqotThumbSkinned = on
    else
        local tf = bar.Thumb or (bar.Track and bar.Track.Thumb)
        if tf then
            local skin = tf._eqotSkinTex
            if not tf._eqotW then tf._eqotW = tf:GetWidth() end
            if on then
                if not skin then
                    skin = tf:CreateTexture(nil, "OVERLAY")
                    skin:SetAllPoints(tf)
                    tf._eqotSkinTex = skin
                end
                skin:SetColorTexture(r, g, b, a)
                skin:Show()
                if w and w > 0 then tf:SetWidth(w) end
            elseif skin then
                skin:Hide()
                if tf._eqotW > 0 then tf:SetWidth(tf._eqotW) end
            end
        end
    end

    local up, down = scrollArrowButtons(bar)
    setArrowHidden(up,   cfg.hideScrollArrows == true)
    setArrowHidden(down, cfg.hideScrollArrows == true)
end

function Tracker:ApplyFrameSkin(cfg)
    local f = self.frame
    if not (f and f.bgFrame and cfg) then return end

    if cfg.showBackground then
        local c = cfg.backgroundColor or {}
        f.background:SetColorTexture(c.r or 0, c.g or 0, c.b or 0, c.a or 0.6)
        f.background:Show()
    else
        f.background:Hide()
    end

    -- SetBackdrop rebuilds the edge textures, so only call it when the size changes
    local size = math.max(1, cfg.borderSize or 1)
    if f._borderSize ~= size then
        f._borderSize = size
        f.bgFrame:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = size })
        f.bgFrame:SetBackdropColor(0, 0, 0, 0)
    end

    if cfg.showBorder then
        local c = cfg.borderColor or {}
        f.bgFrame:SetBackdropBorderColor(c.r or 0, c.g or 0, c.b or 0, c.a or 1)
    else
        f.bgFrame:SetBackdropBorderColor(0, 0, 0, 0)
    end

    -- The scroll frame is sized explicitly per render, so the gutter feeds the anchoring
    -- pass rather than a BOTTOMRIGHT point that would fight SetSize.
    self:ApplyContentInset()

    local hideBar = cfg.hideScrollBar == true
    if f.scrollBarBG then
        if cfg.scrollBarBg ~= false and not hideBar then
            local s = cfg.scrollBarBgColor or {}
            f.scrollBarBG:SetColorTexture(s.r or 0.60, s.g or 0.60, s.b or 0.65, s.a or 0.25)
            f.scrollBarBG:Show()
        else
            f.scrollBarBG:Hide()
        end
    end

    setScrollBarHidden(f.scroll, hideBar)
    setScrollBarHidden(f.eventsScroll, hideBar)
    applyScrollBarSkin(f.scroll, cfg)
    applyScrollBarSkin(f.eventsScroll, cfg)
end

-- Guarded on the last gutter: SetPoint fires scenarioContainer's OnSizeChanged, which
-- calls Refresh, so an unguarded re-inset re-enters on every pass.
function Tracker:ApplyContentInset()
    local f = self.frame
    if not (f and f.scenarioContainer) then return end
    local gutter = scrollGutter(ns:GetModule("DB"):Tracker())
    if f._scrollGutter == gutter then return end
    f._scrollGutter = gutter
    f.scenarioContainer:SetPoint("TOPLEFT",  CONTENT_PAD, -DRAG_HANDLE_H)
    f.scenarioContainer:SetPoint("TOPRIGHT", -(gutter - CONTENT_PAD), -DRAG_HANDLE_H)
end

-- Everything hangs off the scenario container's bottom rather than off the frame top, so
-- the whole stack moves down together when a scenario appears.
function Tracker:ApplyWorldQuestsPosition()
    local f = self.frame
    if not f then return end
    local scroll, region, scen = f.scroll, f.eventsRegion, f.scenarioContainer
    if not (scroll and region and scen) then return end

    local cfg = ns:GetModule("DB"):Tracker()
    local pos = (cfg and cfg.worldQuestsPosition) or "bottom"

    scroll:ClearAllPoints()
    region:ClearAllPoints()
    if pos == "top" then
        region:SetPoint("TOPLEFT",  scen,   "BOTTOMLEFT",  0, -2)
        region:SetPoint("TOPRIGHT", scen,   "BOTTOMRIGHT", 0, -2)
        scroll:SetPoint("TOPLEFT",  region, "BOTTOMLEFT",  0, -2)
    else
        scroll:SetPoint("TOPLEFT",  scen,   "BOTTOMLEFT",  0, -2)
        region:SetPoint("TOPLEFT",  scroll, "BOTTOMLEFT",  0, -2)
        region:SetPoint("TOPRIGHT", scroll, "BOTTOMRIGHT", 0, -2)
    end
end

function Tracker:SetWorldQuestsPosition(pos)
    local cfg = ns:GetModule("DB"):Tracker()
    if cfg then cfg.worldQuestsPosition = pos end
    self:ApplyWorldQuestsPosition()
    self:Render()
end

-- Scroll widgets differ between flavors and between the old slider bar and the newer
-- one, so report what is actually on screen rather than what the template should give.
function Tracker:DebugScroll()
    local f = self.frame
    if not (f and f.scroll) then return "no frame" end
    local cfg = ns:GetModule("DB"):Tracker() or {}
    local sf  = f.scroll
    local bar = sf.ScrollBar or sf.scrollBar
    local out = {}

    local function shown(o) return o and (o:IsShown() and "shown" or "hidden") or "none" end

    out[#out + 1] = ("gutter %s range %.0f bgTex %s"):format(
        tostring(f._scrollGutter), sf:GetVerticalScrollRange() or 0, shown(f.scrollBarBG))

    if not bar then
        out[#out + 1] = "bar none"
    else
        out[#out + 1] = ("bar %s %.0fx%.0f"):format(shown(bar), bar:GetWidth() or 0, bar:GetHeight() or 0)
        local t = bar.GetThumbTexture and bar:GetThumbTexture()
        if t then
            -- Assign before tostring: a getter that returns NO values, rather than nil,
            -- leaves tostring() with zero arguments and that is an error, not a "nil"
            local tex   = t:GetTexture()
            local atlas = t.GetAtlas and t:GetAtlas()
            out[#out + 1] = ("thumbTex %s tex=%s atlas=%s w=%.0f"):format(shown(t),
                tostring(tex), tostring(atlas), t:GetWidth() or 0)
        else
            local tf = bar.Thumb or (bar.Track and bar.Track.Thumb)
            out[#out + 1] = tf and ("thumbFrame %s w=%.0f"):format(shown(tf), tf:GetWidth() or 0)
                or "thumb none"
        end
        local up, down = scrollArrowButtons(bar)
        out[#out + 1] = ("arrows %s/%s"):format(shown(up), shown(down))
    end

    out[#out + 1] = ("cfg hide=%s bg=%s skin=%s noArrows=%s"):format(
        tostring(cfg.hideScrollBar), tostring(cfg.scrollBarBg),
        tostring(cfg.skinScrollBar), tostring(cfg.hideScrollArrows))

    out[#out + 1] = ("wq %s pos=%s scrollH=%.0f regionH=%.0f contentH=%.0f"):format(
        shown(f.eventsRegion), tostring(cfg.worldQuestsPosition),
        sf:GetHeight() or 0,
        f.eventsRegion and f.eventsRegion:GetHeight() or 0,
        f.eventsContent and f.eventsContent:GetHeight() or 0)

    out[#out + 1] = ("scenario container %s h=%.0f"):format(
        shown(f.scenarioContainer),
        f.scenarioContainer and f.scenarioContainer:GetHeight() or 0)

    return table.concat(out, " | ")
end

function Tracker:Refresh()
    if not self.frame then return end
    local Events = ns:GetModule("Events")
    if not (Events and Events.Debounce) then return end
    self._renderThunk = self._renderThunk or function() self:Render() end
    Events:Debounce("eqot.render", REFRESH_THROTTLE, self._renderThunk)
end

-- Hoisted: Render runs on every quest event, so a per-row closure here would
-- allocate garbage proportional to the tracker's length on every repaint.
local _buildRow, _resetRow

-- World quests live outside the main scroll area in a region capped to a fraction of the
-- tracker, so a long world quest list can never push the quest sections off screen.
function Tracker:_RenderPinnedWorldQuests(group, cap, width, cfg)
    local f = self.frame
    local region, escroll, econtent = f.eventsRegion, f.eventsScroll, f.eventsContent
    if not (region and escroll and econtent) then return 0, false end

    local Sections = ns:GetModule("Sections")
    local band     = headerBand()

    local function collapseRegion()
        escroll:Hide()
        if f.eventsScrollBarBG then f.eventsScrollBarBG:Hide() end
        region:SetHeight(1)
        region:Hide()
    end

    if not group or group.visibleCount == 0 or Sections:IsHidden(PINNED_GROUP) then
        collapseRegion()
        return 0, false
    end

    region:Show()

    local collapsed = Sections:IsCollapsed(PINNED_GROUP)
    local header    = Sections:Acquire(region, PINNED_GROUP)
    Sections:Place(header, region, 0, group, collapsed, cfg and cfg.showQuestTotal ~= false)

    if collapsed then
        escroll:Hide()
        if f.eventsScrollBarBG then f.eventsScrollBarBG:Hide() end
        region:SetHeight(band)
        return band, false
    end

    escroll:Show()
    econtent:SetWidth(math.max(1, width))

    local Row     = ns:GetModule("Row")
    local RowPool = ns:GetModule("RowPool")
    local Card    = ns:GetModule("Card")
    local gap     = Card:Gap(math.max(0, (cfg and cfg.blockSpacing) or 2), (Card:State(cfg)))

    local y, hasTimed = 0, false
    for i = 1, group.visibleCount do
        local entry = group.entries[i]
        if entry.expiresAt then hasTimed = true end
        local row = RowPool:Acquire(econtent, entry.providerID, entry.id, _buildRow)
        row:SetWidth(width)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", econtent, "TOPLEFT", 0, -y)
        y = y + Row:Render(row, entry, width, cfg) + gap
    end
    econtent:SetHeight(math.max(1, y))

    local capViewport = math.max(30, (cap or 0) - band)
    local viewport    = math.max(1, math.min(y, capViewport))
    region:SetHeight(band + viewport)

    if escroll.UpdateScrollChildRect then escroll:UpdateScrollChildRect() end

    if f.eventsScrollBarBG then
        local needsBar = y > viewport + 0.5
        if needsBar and cfg and cfg.scrollBarBg ~= false and cfg.hideScrollBar ~= true then
            local s = cfg.scrollBarBgColor or {}
            f.eventsScrollBarBG:SetColorTexture(s.r or 0.60, s.g or 0.60, s.b or 0.65, s.a or 0.25)
            f.eventsScrollBarBG:Show()
        else
            f.eventsScrollBarBG:Hide()
        end
    end

    return band + viewport, hasTimed
end

function Tracker:_RenderScenario(group, cfg)
    local f    = self.frame
    local scen = f.scenarioContainer
    if not scen then return 1 end

    local entry = (group and group.visibleCount > 0) and group.entries[1] or nil
    local info
    if entry then
        local provider = ns:GetModule("Registry"):Get(CONTAINER_GROUP)
        if provider and provider.GetBanner then info = provider:GetBanner() end
    end

    local h = math.max(1, ns:GetModule("Scenario"):Render(scen, cfg, info, entry))

    -- SetHeight fires OnSizeChanged, which calls Refresh, so only touch it on a real move
    if math.abs((scen:GetHeight() or 0) - h) > 0.5 then scen:SetHeight(h) end
    return h
end

function Tracker:Render()
    local f = self.frame
    if not f then return end
    local content = f.content
    if not content then return end

    if not _buildRow then
        local Row = ns:GetModule("Row")
        _buildRow = function() return Row:Build() end
        _resetRow = function(row) Row:Reset(row) end
    end

    local DB       = ns:GetModule("DB")
    local Feed     = ns:GetModule("Feed")
    local Row      = ns:GetModule("Row")
    local RowPool  = ns:GetModule("RowPool")
    local Sections = ns:GetModule("Sections")
    local cfg      = DB:Tracker()

    self:ApplyFrameSkin(cfg)

    local width = math.max(1, math.floor((f:GetWidth() or 0) + 0.5) - scrollGutter(cfg))
    if math.floor((content:GetWidth() or 0) + 0.5) ~= width then
        content:SetWidth(width)
    end

    RowPool:Begin()
    Sections:HideAll()

    local byGroup  = Feed:Build()
    local Card     = ns:GetModule("Card")
    local gap      = Card:Gap(math.max(0, (cfg and cfg.blockSpacing) or 2), (Card:State(cfg)))

    local scenarioH = self:_RenderScenario(byGroup[CONTAINER_GROUP], cfg)

    local y        = 0
    local hasTimed = false
    local sectionTops = {}

    for _, groupID in ipairs(Sections:Order()) do
        local group = byGroup[groupID]
        if group and group.visibleCount > 0 and not Sections:IsHidden(groupID) then
            local collapsed = Sections:IsCollapsed(groupID)
            local header    = Sections:Acquire(content, groupID)
            sectionTops[#sectionTops + 1] = y
            y = y + Sections:Place(header, content, y, group, collapsed,
                                   cfg and cfg.showQuestTotal ~= false) + gap

            if not collapsed then
                for i = 1, group.visibleCount do
                    local entry = group.entries[i]
                    if entry.expiresAt then hasTimed = true end
                    local row = RowPool:Acquire(content, entry.providerID, entry.id, _buildRow)
                    row:SetWidth(width)
                    row:ClearAllPoints()
                    row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
                    y = y + Row:Render(row, entry, width, cfg) + gap
                end
            end
        end
    end

    local questContentH = y
    content:SetHeight(math.max(1, questContentH))

    local available = math.max(1, (f:GetHeight() or 0) - DRAG_HANDLE_H - scenarioH - 2
                                  - (GRIP_SIZE + 2))
    local fraction  = (cfg and cfg.worldQuestsPinnedMaxFraction) or WQ_PIN_FRACTION
    local band      = headerBand()

    -- Quests get vertical-space priority so a trailing section is never left as a header
    -- with no body, and the floor keeps the world quest region from vanishing entirely.
    local eventsCap
    if cfg and cfg.worldQuestsHeightOverride then
        local wqWant   = band + math.max(0, cfg.worldQuestsHeight or 0)
        local questMin = band + 40
        eventsCap = math.max(0, math.min(wqWant, available - questMin))
    else
        local wqFloor    = band + 40
        local questWants = math.min(questContentH, math.max(1, available - wqFloor))
        eventsCap = math.max(0, math.min(math.floor(available * fraction), available - questWants))
    end

    local wqH, wqTimed = self:_RenderPinnedWorldQuests(byGroup[PINNED_GROUP], eventsCap, width, cfg)
    if wqTimed then hasTimed = true end

    -- Only snap the clip up when the cut lands inside a header's own row. Snapping when a
    -- body merely overflows would collapse the viewport to the sections above it.
    local scrollH = math.min(questContentH, available - (wqH or 0))
    if scrollH < questContentH then
        local headerGap = Sections:Height() + gap
        for i = #sectionTops, 1, -1 do
            local top = sectionTops[i]
            if top > 0 and top < scrollH then
                if scrollH - top < headerGap then scrollH = top end
                break
            end
        end
    end
    if scrollH < 1 then scrollH = 1 end

    f.scroll:SetSize(math.max(1, width), scrollH)
    if f.scroll.UpdateScrollChildRect then f.scroll:UpdateScrollChildRect() end

    RowPool:Sweep(_resetRow)
    self:_EnsureTimerTicker(hasTimed)
end

-- Row's change gate keys on the formatted time string, so a plain Render only repaints
-- the rows whose countdown actually rolled over. No Invalidate needed here.
function Tracker:_EnsureTimerTicker(wanted)
    if wanted and not self._timerTicker then
        self._timerTicker = C_Timer.NewTicker(30, function()
            local f = self.frame
            if f and f:IsShown() then self:Render() end
        end)
    elseif not wanted and self._timerTicker then
        self._timerTicker:Cancel()
        self._timerTicker = nil
    end
end

function Tracker:Toggle()
    local f = self.frame
    if not f then return end
    if f:IsShown() then f:Hide() else f:Show(); self:Render() end
end

function Tracker:ResetPosition()
    local DB  = ns:GetModule("DB")
    local cfg = DB:Tracker()
    local d   = DB.defaults.profile.tracker
    cfg.anchor, cfg.relativePoint = d.anchor, d.relativePoint
    cfg.xOffset, cfg.yOffset      = d.xOffset, d.yOffset
    cfg.width, cfg.maxHeight      = d.width, d.maxHeight
    if self.frame then self.frame:SetSize(cfg.width, cfg.maxHeight) end
    self:_ApplyPosition(cfg.anchor, cfg.relativePoint, cfg.xOffset, cfg.yOffset)
    self:Render()
end

function Tracker:OnEnable()
    self:BuildFrame()

    local Registry = ns:GetModule("Registry")
    Registry:OnDirty(function() self:Refresh() end)

    self:Render()
end
