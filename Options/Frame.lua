local _, ns = ...

local Options = ns:RegisterModule("Options", {})

local W, H        = 580, 460
local TAB_H       = 24
local PAD         = 16
local CONTENT_TOP = 76
local ROW_GAP     = 6

Options.tabs = {}

-- Tab files load after this one and register themselves, so the tab bar is built from
-- whatever the TOC actually loaded.
function Options:RegisterTab(def)
    self.tabs[#self.tabs + 1] = def
    table.sort(self.tabs, function(a, b) return (a.order or 100) < (b.order or 100) end)
end

function Options:AttachTooltip(frame, title, body)
    if not (frame and body) then return end
    frame:HookScript("OnEnter", function(f)
        GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
        if title then GameTooltip:AddLine(title, 1, 0.82, 0) end
        GameTooltip:AddLine(body, 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    frame:HookScript("OnLeave", function() GameTooltip:Hide() end)
end

-- Controls stack down the content frame automatically. Tab files never do arithmetic.
function Options:Place(content, frame, height, gapBefore)
    content._y = (content._y or -4) - (gapBefore or ROW_GAP)
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", content, "TOPLEFT", content._indent or 0, content._y)
    content._y = content._y - height
    content:SetHeight(math.abs(content._y) + 12)
end

function Options:ResetCursor(content)
    content._y = -4
    content._indent = 0
end

function Options:CreateHeading(content, text)
    local fs = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetText(text)
    fs:SetTextColor(0.93, 0.32, 0.10)
    self:Place(content, fs, 16, 12)
    return fs
end

function Options:CreateLabel(content, text, r, g, b)
    local fs = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetJustifyH("LEFT")
    fs:SetText(text)
    fs:SetTextColor(r or 0.8, g or 0.8, b or 0.8)
    self:Place(content, fs, math.max(12, fs:GetStringHeight()), 2)
    return fs
end

function Options:CreateCheckbox(content, label, getter, setter, tooltip)
    local cb = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    cb:SetSize(24, 24)
    cb.label = cb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cb.label:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    cb.label:SetText(label)
    cb:SetChecked(getter() and true or false)
    cb:SetScript("OnClick", function(btn)
        setter(btn:GetChecked() and true or false)
        local Tracker = ns:GetModule("Tracker")
        if Tracker then Tracker:Render() end
    end)
    cb.Refresh = function(btn) btn:SetChecked(getter() and true or false) end
    self:AttachTooltip(cb, label, tooltip)
    self:Place(content, cb, 24, 2)
    content._controls[#content._controls + 1] = cb
    return cb
end

function Options:CreateButton(content, label, width, onClick, tooltip)
    local b = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    b:SetSize(width or 150, 22)
    b:SetText(label)
    b:SetScript("OnClick", onClick)
    self:AttachTooltip(b, label, tooltip)
    self:Place(content, b, 22, ROW_GAP)
    return b
end

-- Built by hand rather than from OptionsSliderTemplate, whose name and children have
-- moved between flavors. This works everywhere and needs no template at all.
function Options:CreateSlider(content, label, minV, maxV, step, getter, setter, tooltip, fmt)
    local holder = CreateFrame("Frame", nil, content)
    holder:SetSize(320, 40)

    local text = holder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("TOPLEFT", 0, 0)
    text:SetText(label)

    local value = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    value:SetPoint("TOPRIGHT", 0, -2)
    value:SetTextColor(0.92, 0.72, 0.02)

    local slider = CreateFrame("Slider", nil, holder)
    slider:SetPoint("TOPLEFT", 0, -20)
    slider:SetSize(320, 16)
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(minV, maxV)
    slider:SetValueStep(step)
    if slider.SetObeyStepOnDrag then slider:SetObeyStepOnDrag(true) end
    slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")

    local track = slider:CreateTexture(nil, "BACKGROUND")
    track:SetPoint("LEFT", 0, 0)
    track:SetPoint("RIGHT", 0, 0)
    track:SetHeight(4)
    track:SetColorTexture(0.25, 0.25, 0.25, 0.9)

    local function label_(v)
        return fmt and fmt(v) or tostring(math.floor(v * 100 + 0.5) / 100)
    end

    slider:SetValue(getter() or minV)
    value:SetText(label_(slider:GetValue()))
    slider:SetScript("OnValueChanged", function(_, v)
        value:SetText(label_(v))
        setter(v)
    end)

    holder.Refresh = function()
        local v = getter() or minV
        slider:SetValue(v)
        value:SetText(label_(v))
    end

    self:AttachTooltip(slider, label, tooltip)
    self:Place(content, holder, 40, ROW_GAP)
    content._controls[#content._controls + 1] = holder
    return holder, slider
end

-- Hand-rolled rather than UIDropDownMenu: that was deprecated in favour of MenuUtil on
-- current retail but is still the only option on Classic, and this addon loads on both.
local DD_ROW = 18
local function dropdownPopup()
    if Options._ddPopup then return Options._ddPopup end
    local p = CreateFrame("Frame", "EQOTDropdownPopup", UIParent, "BackdropTemplate")
    p:SetFrameStrata("FULLSCREEN_DIALOG")
    p:SetSize(240, 300)
    p:Hide()
    if p.SetBackdrop then
        p:SetBackdrop({
            bgFile   = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        p:SetBackdropColor(0, 0, 0, 0.95)
        p:SetBackdropBorderColor(0.92, 0.72, 0.02, 0.8)
    end
    local sf = CreateFrame("ScrollFrame", nil, p, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 6, -6)
    sf:SetPoint("BOTTOMRIGHT", -26, 6)
    local c = CreateFrame("Frame", nil, sf)
    c:SetSize(1, 1)
    sf:SetScrollChild(c)
    p.scroll, p.content, p.rows = sf, c, {}
    tinsert(UISpecialFrames, "EQOTDropdownPopup")
    Options._ddPopup = p
    return p
end

local SWATCH_W, SWATCH_H = 60, 12

-- One popup is shared by every dropdown, so a row that grew a swatch has to give it back
-- when a plain list reuses it.
local function decorateRow(b, item, decorate)
    if decorate then
        if not b.swatch then
            b.swatchBg = b:CreateTexture(nil, "BACKGROUND")
            b.swatchBg:SetPoint("LEFT", 4, 0)
            b.swatchBg:SetSize(SWATCH_W, SWATCH_H)
            b.swatchBg:SetColorTexture(0, 0, 0, 0.6)
            b.swatch = b:CreateTexture(nil, "ARTWORK")
            b.swatch:SetPoint("LEFT", 4, 0)
            b.swatch:SetSize(SWATCH_W, SWATCH_H)
        end
        b.swatchBg:Show()
        b.swatch:Show()
        b.text:ClearAllPoints()
        b.text:SetPoint("LEFT", SWATCH_W + 12, 0)
        decorate(b, item)
    elseif b.swatch then
        b.swatchBg:Hide()
        b.swatch:Hide()
        b.text:ClearAllPoints()
        b.text:SetPoint("LEFT", 4, 0)
    end
end

local function showDropdown(anchor, list, current, onPick, decorate)
    local p = dropdownPopup()
    p:ClearAllPoints()
    p:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -2)
    p:SetWidth(math.max(240, anchor:GetWidth()))

    for i = 1, #list do
        local b = p.rows[i]
        if not b then
            b = CreateFrame("Button", nil, p.content)
            b:SetHeight(DD_ROW)
            b.text = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            b.text:SetPoint("LEFT", 4, 0)
            b.text:SetJustifyH("LEFT")
            local hl = b:CreateTexture(nil, "HIGHLIGHT")
            hl:SetAllPoints()
            hl:SetColorTexture(1, 1, 1, 0.15)
            p.rows[i] = b
        end
        local item = list[i]
        b:ClearAllPoints()
        b:SetPoint("TOPLEFT",  p.content, "TOPLEFT",  0, -(i - 1) * DD_ROW)
        b:SetPoint("TOPRIGHT", p.content, "TOPRIGHT", 0, -(i - 1) * DD_ROW)
        decorateRow(b, item, decorate)
        b.text:SetText(item)
        if item == current then
            b.text:SetTextColor(0.92, 0.72, 0.02)
        else
            b.text:SetTextColor(1, 1, 1)
        end
        b:SetScript("OnClick", function() p:Hide(); onPick(item) end)
        b:Show()
    end
    for i = #list + 1, #p.rows do p.rows[i]:Hide() end

    p.content:SetSize(math.max(1, p:GetWidth() - 32), math.max(1, #list * DD_ROW))
    p:SetHeight(math.min(300, #list * DD_ROW + 12))
    p:Show()
end

-- decorate(frame, value) draws a preview on the closed button and on every row. Passed by
-- pickers whose values are not self-describing, such as a status bar texture.
function Options:CreateDropdown(content, label, getList, getter, setter, tooltip, decorate)
    local holder = CreateFrame("Frame", nil, content)
    holder:SetSize(320, 40)

    local text = holder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("TOPLEFT", 0, 0)
    text:SetText(label)

    local btn = CreateFrame("Button", nil, holder, "UIPanelButtonTemplate")
    btn:SetPoint("TOPLEFT", 0, -18)
    btn:SetSize(320, 20)

    if decorate then
        btn.swatchBg = btn:CreateTexture(nil, "BACKGROUND")
        btn.swatchBg:SetPoint("LEFT", 8, 0)
        btn.swatchBg:SetSize(SWATCH_W, SWATCH_H)
        btn.swatchBg:SetColorTexture(0, 0, 0, 0.6)
        btn.swatch = btn:CreateTexture(nil, "ARTWORK")
        btn.swatch:SetPoint("LEFT", 8, 0)
        btn.swatch:SetSize(SWATCH_W, SWATCH_H)
        local fs = btn:GetFontString()
        if fs then
            fs:ClearAllPoints()
            fs:SetPoint("LEFT", btn.swatch, "RIGHT", 8, 0)
            fs:SetJustifyH("LEFT")
        end
    end

    local function refresh()
        btn:SetText(getter() or "")
        if decorate then decorate(btn, getter()) end
    end
    refresh()

    btn:SetScript("OnClick", function()
        showDropdown(btn, getList(), getter(), function(v)
            setter(v)
            refresh()
        end, decorate)
    end)

    holder.Refresh = refresh
    self:AttachTooltip(btn, label, tooltip)
    self:Place(content, holder, 40, ROW_GAP)
    content._controls[#content._controls + 1] = holder
    return holder
end

-- SetupColorPickerAndShow is the current retail entry point; the field-assignment form
-- is the only one Classic has. Feature-detect, never version-detect.
function Options:ShowColorPicker(r, g, b, a, hasAlpha, onChange)
    local cp = ColorPickerFrame
    if not cp then return end
    local function apply()
        local nr, ng, nb = cp:GetColorRGB()
        local na = 1
        if hasAlpha then
            if cp.GetColorAlpha then
                na = cp:GetColorAlpha()
            elseif OpacitySliderFrame then
                na = OpacitySliderFrame:GetValue()
            end
        end
        onChange(nr, ng, nb, na)
    end
    local function cancel() onChange(r, g, b, a) end

    if cp.SetupColorPickerAndShow then
        cp:SetupColorPickerAndShow({
            r = r, g = g, b = b,
            opacity = a, hasOpacity = hasAlpha and true or false,
            swatchFunc = apply, opacityFunc = apply, cancelFunc = cancel,
        })
    else
        cp.func, cp.opacityFunc, cp.cancelFunc = apply, apply, cancel
        cp.hasOpacity = hasAlpha and true or false
        cp.opacity = a
        cp:SetColorRGB(r, g, b)
        cp:Hide()
        cp:Show()
    end
end

function Options:CreateColorPicker(content, label, getter, setter, tooltip, hasAlpha, onClear)
    local holder = CreateFrame("Frame", nil, content)
    holder:SetSize(320, 22)

    local swatch = CreateFrame("Button", nil, holder, "BackdropTemplate")
    swatch:SetSize(20, 20)
    swatch:SetPoint("TOPLEFT", 0, 0)
    if swatch.SetBackdrop then
        swatch:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
        swatch:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    end
    local tex = swatch:CreateTexture(nil, "ARTWORK")
    tex:SetPoint("TOPLEFT", 1, -1)
    tex:SetPoint("BOTTOMRIGHT", -1, 1)

    local text = holder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT", swatch, "RIGHT", 6, 0)
    text:SetText(label)

    local clear
    local function refresh()
        local c = getter()
        local isSet = (c and c.r ~= nil) and true or false
        if isSet then
            tex:SetColorTexture(c.r, c.g or 0, c.b or 0, 1)
        else
            tex:SetColorTexture(0.22, 0.22, 0.22, 1)
        end
        if clear then clear:SetShown(isSet) end
    end

    -- Only clearable pickers get the button, so an unset swatch stays distinguishable
    -- from a deliberately black one.
    if onClear then
        clear = CreateFrame("Button", nil, holder, "UIPanelButtonTemplate")
        clear:SetSize(54, 18)
        clear:SetPoint("LEFT", text, "RIGHT", 8, 0)
        clear:SetText("Clear")
        clear:SetScript("OnClick", function()
            onClear()
            refresh()
            local T = ns:GetModule("Tracker")
            if T then T:Render() end
        end)
    end
    refresh()

    swatch:SetScript("OnClick", function()
        local c = getter() or {}
        Options:ShowColorPicker(c.r or 1, c.g or 1, c.b or 1, c.a or 1, hasAlpha,
            function(nr, ng, nb, na)
                setter({ r = nr, g = ng, b = nb, a = na })
                refresh()
                local T = ns:GetModule("Tracker")
                if T then T:Render() end
            end)
    end)

    holder.Refresh = refresh
    self:AttachTooltip(swatch, label, tooltip)
    self:Place(content, holder, 22, ROW_GAP)
    content._controls[#content._controls + 1] = holder
    return holder
end

local function styleTab(btn, selected)
    btn.bg:SetColorTexture(0, 0, 0, selected and 0 or 0.55)
    btn.text:SetTextColor(selected and 0.92 or 0.65, selected and 0.72 or 0.65,
                          selected and 0.02 or 0.65)
    btn.underline:SetShown(selected)
end

function Options:SelectTab(id)
    if not self.frame then return end
    for _, t in ipairs(self.tabs) do
        local isSel = (t.id == id)
        styleTab(t._button, isSel)
        if isSel then
            if not t._built then
                self:ResetCursor(t._content)
                t._content._controls = {}
                t.build(self, t._content)
                t._built = true
            end
            if t.refresh then t.refresh(self, t._content) end
            for _, c in ipairs(t._content._controls or {}) do
                if c.Refresh then c:Refresh() end
            end
            t._scroll:Show()
        else
            t._scroll:Hide()
        end
    end
    local char = ns:GetModule("DB"):Char()
    if char then char.lastOptionsTab = id end
    self._current = id
end

function Options:Build()
    if self.frame then return end

    local f = CreateFrame("Frame", "EQOTOptionsFrame", UIParent, "BackdropTemplate")
    self.frame = f
    f:SetSize(W, H)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:Hide()
    tinsert(UISpecialFrames, "EQOTOptionsFrame")

    if f.SetBackdrop then
        f:SetBackdrop({
            bgFile   = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        f:SetBackdropColor(0, 0, 0, 0.94)
        f:SetBackdropBorderColor(0.92, 0.72, 0.02, 0.8)
    end

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", PAD, -14)
    title:SetText("EQ Objective Tracker")
    title:SetTextColor(0.92, 0.72, 0.02)

    local version = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    version:SetPoint("LEFT", title, "RIGHT", 8, -1)
    version:SetText("v" .. ns.VERSION)
    version:SetTextColor(0.5, 0.5, 0.5)

    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)

    local x = PAD
    for _, t in ipairs(self.tabs) do
        local b = CreateFrame("Button", nil, f)
        b:SetHeight(TAB_H)
        b.bg = b:CreateTexture(nil, "BACKGROUND")
        b.bg:SetAllPoints()
        b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        b.text:SetPoint("CENTER")
        b.text:SetText(t.title)
        b.underline = b:CreateTexture(nil, "ARTWORK")
        b.underline:SetHeight(2)
        b.underline:SetPoint("BOTTOMLEFT", 2, 0)
        b.underline:SetPoint("BOTTOMRIGHT", -2, 0)
        b.underline:SetColorTexture(0.92, 0.72, 0.02, 1)
        b:SetWidth(b.text:GetStringWidth() + 28)
        b:SetPoint("TOPLEFT", x, -46)
        b:SetScript("OnClick", function() Options:SelectTab(t.id) end)
        x = x + b:GetWidth() + 4
        t._button = b

        local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", PAD, -CONTENT_TOP)
        scroll:SetPoint("BOTTOMRIGHT", -(PAD + 22), PAD)
        scroll:Hide()
        local content = CreateFrame("Frame", nil, scroll)
        content:SetSize(W - PAD * 2 - 24, 1)
        content._controls = {}
        scroll:SetScrollChild(content)
        t._scroll, t._content = scroll, content
    end

    local divider = f:CreateTexture(nil, "ARTWORK")
    divider:SetHeight(1)
    divider:SetPoint("TOPLEFT", PAD, -(CONTENT_TOP - 8))
    divider:SetPoint("TOPRIGHT", -PAD, -(CONTENT_TOP - 8))
    divider:SetColorTexture(0.3, 0.3, 0.3, 0.8)

    local char = ns:GetModule("DB"):Char()
    local want = (char and char.lastOptionsTab) or (self.tabs[1] and self.tabs[1].id)
    local found = false
    for _, t in ipairs(self.tabs) do
        if t.id == want then found = true break end
    end
    self:SelectTab(found and want or (self.tabs[1] and self.tabs[1].id))
end

function Options:Toggle()
    self:Build()
    if self.frame:IsShown() then
        self.frame:Hide()
    else
        self:SelectTab(self._current)
        self.frame:Show()
    end
end

function Options:OnEnable()
    self:Build()
end
