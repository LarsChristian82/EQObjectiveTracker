local _, ns = ...

local Tracker = ns:RegisterModule("Tracker", {})

local CONTENT_PAD      = 4
local SCROLLBAR_GUTTER = 26
local DRAG_HANDLE_H    = 14
local GRIP_SIZE        = 14
local REFRESH_THROTTLE = 0.25
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

    local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", CONTENT_PAD, -DRAG_HANDLE_H)
    scroll:SetPoint("BOTTOMRIGHT", -SCROLLBAR_GUTTER, GRIP_SIZE + 2)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(math.max(1, cfg.width - SCROLLBAR_GUTTER), 1)
    scroll:SetScrollChild(content)

    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(sf, delta)
        local range = sf:GetVerticalScrollRange() or 0
        if range <= 0 then return end
        local new = (sf:GetVerticalScroll() or 0) - delta * 24
        sf:SetVerticalScroll(math.max(0, math.min(new, range)))
    end)

    f:SetScript("OnSizeChanged", function() Tracker:Refresh() end)

    f.drag, f.grip, f.scroll, f.content = drag, grip, scroll, content
    self:ApplyLockState()
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

    local width = math.max(1, math.floor((f:GetWidth() or 0) + 0.5) - SCROLLBAR_GUTTER)
    if math.floor((content:GetWidth() or 0) + 0.5) ~= width then
        content:SetWidth(width)
    end

    RowPool:Begin()
    Sections:HideAll()

    local byGroup  = Feed:Build()
    local Card     = ns:GetModule("Card")
    local gap      = Card:Gap(math.max(0, (cfg and cfg.blockSpacing) or 2), (Card:State(cfg)))
    local y        = 0
    local hasTimed = false

    for _, groupID in ipairs(Sections:Order()) do
        local group = byGroup[groupID]
        if group and group.visibleCount > 0 and not Sections:IsHidden(groupID) then
            local collapsed = Sections:IsCollapsed(groupID)
            local header    = Sections:Acquire(content, groupID)
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

    RowPool:Sweep(_resetRow)
    content:SetHeight(math.max(1, y))
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
