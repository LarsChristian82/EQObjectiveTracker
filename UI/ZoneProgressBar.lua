local _, ns = ...

local ZoneBar = ns:RegisterModule("ZoneProgressBar", {})

local FRAME_W     = 220
local FRAME_H     = 38
local BAR_H       = 12
local DEFAULT_BAR = [[Interface\TargetingFrame\UI-StatusBar]]

local TITLE_COLOR = { 0.93, 0.32, 0.10 }
local COUNT_COLOR = { 0.92, 0.72, 0.02 }
local BORDER_RED  = { 0.635, 0.000, 0.039, 1 }

local function cfg()
    return ns:GetModule("DB"):Tracker()
end

local function barState()
    local t = cfg()
    if not t then return nil end
    t.zoneProgressBar = t.zoneProgressBar or {}
    return t.zoneProgressBar
end

local function enabled()
    local t = cfg()
    return (t and t.showZoneProgressBar) == true
end

local function isFloating()
    local t = cfg()
    return ((t and t.zoneProgressLocation) or "floating") == "floating"
end

local function applyBarFill(bar)
    if not bar then return end
    local st = barState() or {}
    local Media = ns:GetModule("Media")
    bar:SetStatusBarTexture(Media:GetStatusBarFile(st.barTexture) or DEFAULT_BAR)
    local c = st.barColor
    if c then bar:SetStatusBarColor(c.r, c.g, c.b, c.a or 1)
    else       bar:SetStatusBarColor(0.26, 0.42, 1.0) end
end

function ZoneBar:ApplySettings()
    local f = self.frame
    if not f then return end
    local st = barState() or {}

    f:ClearAllPoints()
    f:SetPoint(st.point or "CENTER", UIParent, st.relPoint or st.point or "CENTER",
               st.x or 0, st.y or 220)
    f:SetScale(st.scale or 1.0)

    if st.showBackground == false then
        f:SetBackdropColor(0, 0, 0, 0)
    else
        -- Fades slightly once locked, so an unlocked bar reads as draggable
        f:SetBackdropColor(0, 0, 0, st.locked and 0.40 or 0.55)
    end

    if st.showBorder == false then
        f:SetBackdropBorderColor(0, 0, 0, 0)
    else
        local bc = st.borderColor
        if bc then f:SetBackdropBorderColor(bc.r, bc.g, bc.b, bc.a or 1)
        else       f:SetBackdropBorderColor(BORDER_RED[1], BORDER_RED[2], BORDER_RED[3], BORDER_RED[4]) end
    end
end

function ZoneBar:_SavePosition()
    local f, st = self.frame, barState()
    if not (f and st) then return end
    local point, _, relPoint, x, y = f:GetPoint()
    st.point, st.relPoint, st.x, st.y = point, relPoint, x, y
end

function ZoneBar:_ContextMenu()
    if not (MenuUtil and MenuUtil.CreateContextMenu and self.frame) then return end
    MenuUtil.CreateContextMenu(self.frame, function(_, root)
        root:CreateTitle("Zone Progress Bar")
        local st = barState() or {}
        root:CreateButton(st.locked and "Unlock (allow moving)" or "Lock position", function()
            local s = barState()
            if s then s.locked = not s.locked end
            ZoneBar:ApplySettings()
        end)
        root:CreateButton("Reset position", function()
            local s = barState()
            if s then s.point, s.relPoint, s.x, s.y = "CENTER", "CENTER", 0, 220 end
            ZoneBar:ApplySettings()
        end)
        root:CreateDivider()
        root:CreateButton("Cancel", function() end)
    end)
end

function ZoneBar:_Acquire()
    if self.frame then return self.frame end

    local f = CreateFrame("Frame", "EQOTZoneProgressBar", UIParent, "BackdropTemplate")
    f:SetSize(FRAME_W, FRAME_H)
    f:SetFrameStrata("MEDIUM")
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(s)
        local st = barState()
        if st and st.locked then return end
        s:StartMoving()
    end)
    f:SetScript("OnDragStop", function(s)
        s:StopMovingOrSizing()
        ZoneBar:_SavePosition()
    end)
    f:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" then ZoneBar:_ContextMenu() end
    end)

    f:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.title:SetPoint("TOPLEFT", 6, -4)
    f.title:SetJustifyH("LEFT")
    f.title:SetTextColor(TITLE_COLOR[1], TITLE_COLOR[2], TITLE_COLOR[3])

    f.count = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.count:SetPoint("TOPRIGHT", -6, -5)
    f.count:SetTextColor(COUNT_COLOR[1], COUNT_COLOR[2], COUNT_COLOR[3])

    local bar = CreateFrame("StatusBar", nil, f)
    bar:SetPoint("BOTTOMLEFT", 6, 5)
    bar:SetPoint("BOTTOMRIGHT", -6, 5)
    bar:SetHeight(BAR_H)
    bar:SetMinMaxValues(0, 100)
    applyBarFill(bar)
    bar.bg = bar:CreateTexture(nil, "BACKGROUND")
    bar.bg:SetAllPoints()
    bar.bg:SetColorTexture(0.04, 0.07, 0.18, 0.9)
    bar.label = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bar.label:SetPoint("CENTER")
    f.bar = bar

    self.frame = f
    self:ApplySettings()
    return f
end

function ZoneBar:Update()
    if not (enabled() and isFloating()) then
        if self.frame then self.frame:Hide() end
        return
    end

    local done, total, zoneName = ns:GetModule("ZoneProgress"):Current()
    if not total or total <= 0 then
        if self.frame then self.frame:Hide() end
        return
    end

    local f   = self:_Acquire()
    local pct = (done / total) * 100

    f.title:SetText(zoneName or "")
    f.count:SetText(done .. "/" .. total)
    f.bar:SetValue(pct)
    f.bar.label:SetText(("%d%%"):format(math.floor(pct + 0.5)))

    local st = barState() or {}
    local hc = st.headerColor
    if hc then f.title:SetTextColor(hc.r, hc.g, hc.b, hc.a or 1)
    else       f.title:SetTextColor(TITLE_COLOR[1], TITLE_COLOR[2], TITLE_COLOR[3]) end
    local cc = st.countColor
    if cc then f.count:SetTextColor(cc.r, cc.g, cc.b, cc.a or 1)
    else       f.count:SetTextColor(COUNT_COLOR[1], COUNT_COLOR[2], COUNT_COLOR[3]) end

    local Media = ns:GetModule("Media")
    Media:ApplyTitleFont(f.title)
    Media:ApplyFont(f.count, -2)
    Media:ApplyFont(f.bar.label, -2)
    applyBarFill(f.bar)

    f:Show()
end

function ZoneBar:SetEnabled(on)
    local t = cfg()
    if t then t.showZoneProgressBar = on and true or false end
    self:Update()
end

function ZoneBar:SetLocation(loc)
    local t = cfg()
    if t then t.zoneProgressLocation = loc end
    self:Update()
end

function ZoneBar:RefreshAppearance()
    self:ApplySettings()
    self:Update()
end

function ZoneBar:OnEnable()
    local Events = ns:GetModule("Events")
    local function refresh() self:Update() end
    Events:On("ZONE_CHANGED_NEW_AREA", refresh)
    Events:On("PLAYER_ENTERING_WORLD", refresh)
    Events:On("QUEST_TURNED_IN",       refresh)
    Events:On("QUEST_REMOVED",         refresh)
    -- Questline contents arrive async, so recount when the data lands
    Events:On("QUESTLINE_UPDATE",      refresh)
    self:Update()
end
