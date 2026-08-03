local _, ns = ...

local Options = ns:RegisterModule("Options", {})
local L       = ns.L

local W, H        = 1020, 720
local TAB_H       = 28
local TAB_PAD_X   = 18
local FRAME_PAD   = 12
local TAB_TOP     = 44

local BRAND_RED    = { 0.635, 0.000, 0.039 }
local TAB_INACTIVE = { 0.10, 0.10, 0.10, 0.85 }
local GOLD         = { 0.92, 0.72, 0.02 }

Options.tabs = {}

-- Tab files load after this one and register themselves, so the tab bar is built from
-- whatever the TOC actually loaded.
function Options:RegisterTab(def)
    self.tabs[#self.tabs + 1] = def
    table.sort(self.tabs, function(a, b) return (a.order or 100) < (b.order or 100) end)
end

local function stripEscapes(s)
    if not s then return "" end
    return (s:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""))
end

function Options:AttachTooltip(frame, title, body)
    if not frame or (not title and not body) then return end
    title = (title and title ~= "") and stripEscapes(title) or nil

    if frame.GetObjectType and frame:GetObjectType() == "FontString" then
        local overlay = CreateFrame("Frame", nil, frame:GetParent())
        overlay:SetAllPoints(frame)
        frame = overlay
    elseif frame.label and frame.GetObjectType and frame:GetObjectType() == "CheckButton" then
        local w = frame.label:GetStringWidth() or 0
        if w > 0 then frame:SetHitRectInsets(0, -(w + 8), 0, 0) end
    end

    local targets = { frame }
    if frame.slider then targets[#targets + 1] = frame.slider end
    if frame.button then targets[#targets + 1] = frame.button end

    for _, t in ipairs(targets) do
        if t.EnableMouse then t:EnableMouse(true) end
        t:HookScript("OnEnter", function(s)
            GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
            -- SetText arg 5 is alpha, not wrap - wrap is 6th. Pass 1 or the title is invisible.
            if title then GameTooltip:SetText(title, GOLD[1], GOLD[2], GOLD[3], 1, true) end
            if body and body ~= "" then GameTooltip:AddLine(body, 0.82, 0.82, 0.82, true) end
            GameTooltip:Show()
        end)
        t:HookScript("OnLeave", function() GameTooltip:Hide() end)
    end
end

-- Every helper returns an UNANCHORED frame and the tab writes its own SetPoint chain, as
-- EQ does. There is no shared layout engine: two columns, same-row satellites, deferred
-- anchoring and the two runtime re-anchors cannot be expressed by a cursor, and the one tab
-- that does want stacking keeps a cursor of its own.
function Options:CreateHeading(content, text)
    local fs = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    fs:SetText(text)
    fs:SetTextColor(unpack(BRAND_RED))
    return fs
end

function Options:CreateCheckbox(content, label, getter, setter, tooltip)
    local cb = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    cb:SetSize(22, 22)
    cb.label = cb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cb.label:SetPoint("LEFT", cb, "RIGHT", 4, 1)
    cb.label:SetText(label)
    cb:SetChecked(getter() and true or false)
    cb:SetScript("OnClick", function(btn)
        setter(btn:GetChecked() and true or false)
        local Tracker = ns:GetModule("Tracker")
        if Tracker then Tracker:Render() end
    end)
    cb.Refresh = function(btn) btn:SetChecked(getter() and true or false) end
    if tooltip then self:AttachTooltip(cb, label, tooltip) end
    content._controls[#content._controls + 1] = cb
    return cb
end

local function flatButton(parent, label, onClick)
    local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
    b:SetSize(160, 28)
    local bg = b:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.10, 0.10, 0.10, 0.9)
    b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    b.text:SetPoint("CENTER")
    b.text:SetText(label)
    b.text:SetTextColor(unpack(GOLD))
    -- Keeps btn:SetText() working now the Blizzard template and its FontString are gone.
    -- Without it a caller relabelling a button would fail silently.
    b.SetText = function(_, s) b.text:SetText(s) end
    if onClick then b:SetScript("OnClick", onClick) end
    return b
end

function Options:CreateButton(content, label, width, onClick, tooltip)
    local b = flatButton(content, label, onClick)
    b:SetSize(width or 160, 28)
    if tooltip then self:AttachTooltip(b, label, tooltip) end
    return b
end

-- options is a list of { value =, label = } pairs. The value is what reaches the setter,
-- so a translated label can never end up in the profile.
function Options:CreateRadioGroup(content, label, options, getter, setter, maxWidth, pad,
                                  tipTitle, tipBody)
    local container = CreateFrame("Frame", nil, content)

    local labelFS
    if label then
        labelFS = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        labelFS:SetPoint("TOPLEFT")
        labelFS:SetText(label)
        labelFS:SetTextColor(1, 1, 1)
    end

    local buttons = {}
    local function paint(active)
        for _, b in ipairs(buttons) do
            if b.value == active then
                b.bg:SetColorTexture(BRAND_RED[1], BRAND_RED[2], BRAND_RED[3], 1)
                b.txt:SetTextColor(1, 1, 1, 1)
            else
                b.bg:SetColorTexture(unpack(TAB_INACTIVE))
                b.txt:SetTextColor(GOLD[1], GOLD[2], GOLD[3], 1)
            end
        end
    end

    local BTN_H, BTN_ROW_GAP, BTN_GAP = 24, 4, 4
    local btnPad     = pad or 18
    local rowAnchor  = labelFS or container
    local rowOffsetY = labelFS and -4 or 0
    local x, y, maxX = 0, 0, 0
    for _, opt in ipairs(options) do
        local btn = CreateFrame("Button", nil, container, "BackdropTemplate")
        btn:SetHeight(BTN_H)
        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        local txt = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        txt:SetPoint("CENTER")
        txt:SetText(opt.label)
        local w = math.max(40, txt:GetStringWidth() + btnPad)
        btn:SetWidth(w)
        if maxWidth and x > 0 and (x + w) > maxWidth then
            x, y = 0, y + BTN_H + BTN_ROW_GAP
        end
        btn:SetPoint("TOPLEFT", rowAnchor, labelFS and "BOTTOMLEFT" or "TOPLEFT",
                     x, rowOffsetY - y)
        btn.bg, btn.txt, btn.value = bg, txt, opt.value
        btn:SetScript("OnClick", function(b)
            if setter then setter(b.value) end
            paint(b.value)
        end)
        if tipTitle or tipBody then self:AttachTooltip(btn, tipTitle, tipBody) end
        x = x + w + BTN_GAP
        if x > maxX then maxX = x end
        buttons[#buttons + 1] = btn
    end

    paint(getter and getter())
    local h = 50 + y
    container:SetSize(maxWidth or maxX, h)
    container.Refresh = function() paint(getter and getter()) end
    content._controls[#content._controls + 1] = container
    return container
end

-- Built by hand rather than from OptionsSliderTemplate, whose name and children have
-- moved between flavors. This works everywhere and needs no template at all.
function Options:CreateSlider(content, label, minV, maxV, step, getter, setter, tooltip)
    local holder = CreateFrame("Frame", nil, content)
    holder:SetSize(280, 44)

    local text = holder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("TOPLEFT", 0, 0)
    text:SetText(label)
    text:SetTextColor(1, 1, 1)

    local value = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    value:SetPoint("TOPRIGHT", 0, 0)
    value:SetTextColor(unpack(GOLD))

    -- Decimals follow the step, so a 0.05 step reads 1.05 and a step of 1 reads 16.
    local function chooseFormat(s)
        if not s or s >= 1 then return "%d" end
        return "%." .. math.max(1, math.ceil(-math.log10(s))) .. "f"
    end
    local valueFmt = chooseFormat(step)
    local function formatValue(v) return valueFmt:format(v) end

    local slider = CreateFrame("Slider", nil, holder)
    slider:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 0, -8)
    slider:SetPoint("TOPRIGHT", holder, "TOPRIGHT", 0, -22)
    slider:SetHeight(16)
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

    -- Refresh runs on every tab view. Without this guard SetValue would clamp a saved
    -- value that sits outside the range and dispatch the clamped result straight back
    -- to setter, rewriting a profile the user never touched.
    local suppress = false

    slider:SetValue(getter() or minV)
    value:SetText(formatValue(slider:GetValue()))
    slider:SetScript("OnValueChanged", function(_, v)
        local stepped = step and (math.floor((v - minV) / step + 0.5) * step + minV) or v
        value:SetText(formatValue(stepped))
        if not suppress then setter(stepped) end
    end)

    holder.slider = slider
    holder.Refresh = function()
        suppress = true
        slider:SetValue(getter() or minV)
        suppress = false
        value:SetText(formatValue(slider:GetValue()))
    end

    if tooltip then self:AttachTooltip(holder, label, tooltip) end
    content._controls[#content._controls + 1] = holder
    return holder, slider
end

-- ⛔ Escape-to-close WITHOUT UISpecialFrames, and it must stay that way. Blizzard's panel
-- manager walks that list by NAME and does _G[name], so an addon frame in it taints
-- UIParentPanelManager on every single Escape press. That taint reaches the panel manager's
-- own state, and from there the world map and its data providers - which on 2026-07-30
-- blocked Button:SetPassThroughButtons() on map pins in combat and was blamed on EQOT. The
-- taint log named EQOTOptionsFrame at UIParentPanelManager.lua:1044 as the only source.
-- SetPropagateKeyboardInput is itself protected in combat, so the handler stands down there
-- and Escape just falls through to the default UI.
local function closeOnEscape(frame)
    frame:EnableKeyboard(false)
    frame:HookScript("OnShow", function(f)
        if InCombatLockdown() then return end
        f:EnableKeyboard(true)
        f:SetPropagateKeyboardInput(true)
    end)
    frame:HookScript("OnHide", function(f) f:EnableKeyboard(false) end)
    frame:SetScript("OnKeyDown", function(f, key)
        if InCombatLockdown() then return end
        if key == "ESCAPE" then
            f:SetPropagateKeyboardInput(false)
            f:Hide()
        else
            f:SetPropagateKeyboardInput(true)
        end
    end)
end

-- Hand-rolled rather than UIDropDownMenu: that was deprecated in favour of MenuUtil on
-- current retail but is still the only option on Classic, and this addon loads on both.
local DD_ROW      = 22
local DD_MAX_ROWS = 10

local function dropdownPopup()
    if Options._ddPopup then return Options._ddPopup end
    local p = CreateFrame("Frame", "EQOTDropdownPopup", UIParent, "BackdropTemplate")
    p:SetFrameStrata("FULLSCREEN_DIALOG")
    p:SetSize(240, 300)
    p:Hide()
    -- A backdrop, not a fill plus a larger rect over it. EQ draws the border texture at
    -- BORDER above a BACKGROUND fill, so the border covers the fill and the whole popup
    -- renders solid grey - the same layering mistake its drag ghost had.
    if p.SetBackdrop then
        p:SetBackdrop({
            bgFile   = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        p:SetBackdropColor(0.04, 0.04, 0.04, 0.98)
        p:SetBackdropBorderColor(0.30, 0.30, 0.30, 1)
    end
    local sf = CreateFrame("ScrollFrame", nil, p, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 4, -4)
    sf:SetPoint("BOTTOMRIGHT", -24, 4)
    local c = CreateFrame("Frame", nil, sf)
    c:SetSize(1, 1)
    sf:SetScrollChild(c)
    p.scroll, p.content, p.rows = sf, c, {}
    closeOnEscape(p)

    -- Hooked rather than set, so closeOnEscape's own OnShow hook above survives.
    p:HookScript("OnShow", function(self)
        if not self.closer then
            self.closer = CreateFrame("Button", nil, UIParent)
            self.closer:SetAllPoints(UIParent)
            self.closer:SetFrameStrata("FULLSCREEN")
            self.closer:RegisterForClicks("AnyDown")
            self.closer:SetScript("OnClick", function() p:Hide() end)
        end
        self.closer:Show()
    end)
    p:HookScript("OnHide", function(self)
        if self.closer then self.closer:Hide() end
    end)

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
            b.swatchBg:SetPoint("LEFT", 6, 0)
            b.swatchBg:SetSize(SWATCH_W, SWATCH_H)
            b.swatchBg:SetColorTexture(0, 0, 0, 0.6)
            b.swatch = b:CreateTexture(nil, "ARTWORK")
            b.swatch:SetPoint("LEFT", 6, 0)
            b.swatch:SetSize(SWATCH_W, SWATCH_H)
        end
        b.swatchBg:Show()
        b.swatch:Show()
        b.text:ClearAllPoints()
        b.text:SetPoint("LEFT", 74, 0)
        b.text:SetPoint("RIGHT", -6, 0)
        decorate(b, item)
    elseif b.swatch then
        b.swatchBg:Hide()
        b.swatch:Hide()
        b.text:ClearAllPoints()
        b.text:SetPoint("LEFT", 6, 0)
        b.text:SetPoint("RIGHT", -6, 0)
    end
end

local function showDropdown(anchor, opts, onPick, decorate)
    local p = dropdownPopup()
    p:ClearAllPoints()
    p:SetPoint("TOPLEFT",  anchor, "BOTTOMLEFT",  0, -2)
    p:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", 0, -2)
    p:SetHeight(math.min(#opts, DD_MAX_ROWS) * DD_ROW + 8)

    for i = 1, #opts do
        local b = p.rows[i]
        if not b then
            b = CreateFrame("Button", nil, p.content)
            b:SetHeight(DD_ROW)
            b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            b.text:SetPoint("LEFT", 6, 0)
            b.text:SetPoint("RIGHT", -6, 0)
            b.text:SetJustifyH("LEFT")
            b.text:SetWordWrap(false)
            b.text:SetTextColor(unpack(GOLD))
            local hl = b:CreateTexture(nil, "HIGHLIGHT")
            hl:SetAllPoints()
            hl:SetColorTexture(1, 1, 1, 0.10)
            p.rows[i] = b
        end
        local opt = opts[i]
        b:ClearAllPoints()
        b:SetPoint("TOPLEFT",  p.content, "TOPLEFT",  0, -(i - 1) * DD_ROW)
        b:SetPoint("TOPRIGHT", p.content, "TOPRIGHT", 0, -(i - 1) * DD_ROW)
        decorateRow(b, opt.value, decorate)
        b.text:SetText(opt.label)
        b:SetScript("OnClick", function() p:Hide(); onPick(opt.value) end)
        b:Show()
    end
    for i = #opts + 1, #p.rows do p.rows[i]:Hide() end

    -- Taken from the anchor rather than the popup: the popup's own width is only two
    -- SetPoints old here and has not resolved yet.
    p.content:SetSize(math.max(1, anchor:GetWidth() - 28), math.max(1, #opts * DD_ROW))
    p:Show()
end

-- options is a list of { value =, label = } pairs, or a function returning one that is
-- re-read on every open. The setter receives the VALUE, so a translated label can never
-- reach the profile and a setter never has to compare against a display string.
-- decorate(frame, value) draws a preview on the closed button and on every row. Passed by
-- pickers whose values are not self-describing, such as a status bar texture.
-- onTest(value) adds a speaker button left of the closed bar that replays the current pick.
function Options:CreateDropdown(content, label, options, getter, setter, tooltip, decorate, onTest)
    local holder = CreateFrame("Frame", nil, content)
    holder:SetSize(280, 44)

    local function resolveOptions()
        return (type(options) == "function") and (options() or {}) or options
    end

    local text = holder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("TOPLEFT", 0, 0)
    text:SetText(label)
    text:SetTextColor(1, 1, 1)

    local speaker
    if onTest then
        speaker = CreateFrame("Button", nil, holder)
        speaker:SetSize(20, 20)
        speaker:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 0, -4)
        local icon = speaker:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints()
        icon:SetTexture("Interface\\Common\\VoiceChat-Speaker")
        speaker:SetHighlightTexture("Interface\\Common\\VoiceChat-Speaker", "ADD")
        speaker:SetScript("OnClick", function() onTest(getter()) end)
    end

    local btn = CreateFrame("Button", nil, holder, "BackdropTemplate")
    btn:SetHeight(22)
    if speaker then
        btn:SetPoint("TOPLEFT", speaker, "TOPRIGHT", 4, 0)
    else
        btn:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 0, -4)
    end
    btn:SetPoint("TOPRIGHT", holder, "TOPRIGHT", 0, -22)
    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.10, 0.10, 0.10, 0.95)

    if decorate then
        btn.swatch = btn:CreateTexture(nil, "ARTWORK")
        btn.swatch:SetPoint("LEFT", 6, 0)
        btn.swatch:SetSize(SWATCH_W, SWATCH_H)
    end

    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    btn.text:SetPoint("LEFT", decorate and 74 or 6, 0)
    btn.text:SetPoint("RIGHT", -22, 0)
    btn.text:SetJustifyH("LEFT")
    btn.text:SetWordWrap(false)
    btn.text:SetTextColor(unpack(GOLD))

    -- A literal lowercase "v", as EQ has it. There is no chevron in the atlas set that
    -- matches, and an atlas arrow reads as a different widget.
    btn.arrow = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    btn.arrow:SetPoint("RIGHT", -6, 0)
    btn.arrow:SetText("v")
    btn.arrow:SetTextColor(unpack(GOLD))

    local function refresh()
        local current = getter()
        if decorate then decorate(btn, current) end
        for _, opt in ipairs(resolveOptions()) do
            if opt.value == current then btn.text:SetText(opt.label); return end
        end
        btn.text:SetText(tostring(current or ""))
    end
    refresh()

    btn:SetScript("OnClick", function()
        showDropdown(btn, resolveOptions(), function(v)
            setter(v)
            refresh()
        end, decorate)
    end)

    holder.button  = btn
    holder.Refresh = refresh
    if tooltip then self:AttachTooltip(holder, label, tooltip) end
    content._controls[#content._controls + 1] = holder
    return holder
end

-- Skipped when ElvUI is loaded, which puts its own class-colour button on the picker.
local function elvUILoaded()
    local f = (C_AddOns and C_AddOns.IsAddOnLoaded) or _G["IsAddOnLoaded"]
    return (f and f("ElvUI")) and true or false
end

local classColorButton, activeColorApply, activeReopen

local function ensureClassColorButton()
    if classColorButton ~= nil then return classColorButton or nil end
    if elvUILoaded() or not ColorPickerFrame then
        classColorButton = false
        return nil
    end
    local b = flatButton(ColorPickerFrame, _G.CLASS or "Class", function()
        local Util = ns:GetModule("Util")
        if not (Util and Util.GetPlayerClassColor and activeReopen) then return end
        local r, g, bl = Util.GetPlayerClassColor()
        if not r then return end
        -- SetColorRGB does not reliably move the 10.2.5+ picker, so re-open it seeded instead.
        local a = (ColorPickerFrame.GetColorAlpha and ColorPickerFrame:GetColorAlpha()) or 1
        activeReopen(r, g, bl, a)
        if activeColorApply then activeColorApply() end
    end)
    b:SetSize(90, 22)
    b:SetPoint("TOPLEFT", ColorPickerFrame, "TOPRIGHT", 6, -34)
    b:Hide()
    ColorPickerFrame:HookScript("OnHide", function()
        if classColorButton then classColorButton:Hide() end
        activeColorApply, activeReopen = nil, nil
    end)
    classColorButton = b
    return b
end

-- SetupColorPickerAndShow is the current retail entry point. The field-assignment form
-- is the only one Classic has. Feature-detect, never version-detect.
function Options:ShowColorPicker(r, g, b, a, hasAlpha, onChange)
    local cp = ColorPickerFrame
    if not cp then return end
    -- Snapshotted before the first open, so Cancel after a Class click still restores the
    -- colour the picker was opened on rather than the seeded class colour.
    local origR, origG, origB, origA = r, g, b, a

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
    local function cancel() onChange(origR, origG, origB, origA) end

    local function openWith(nr, ng, nb, na)
        if cp.SetupColorPickerAndShow then
            cp:SetupColorPickerAndShow({
                r = nr, g = ng, b = nb,
                opacity = na, hasOpacity = hasAlpha and true or false,
                swatchFunc = apply, opacityFunc = apply, cancelFunc = cancel,
            })
        else
            cp.func, cp.opacityFunc, cp.cancelFunc = apply, apply, cancel
            cp.hasOpacity = hasAlpha and true or false
            cp.opacity = na
            cp:SetColorRGB(nr, ng, nb)
            cp:Hide()
            cp:Show()
        end
        -- Set after the open: the legacy branch's Hide fires the OnHide hook that clears these.
        activeColorApply, activeReopen = apply, openWith
        local classBtn = ensureClassColorButton()
        if classBtn then classBtn:Show() end
    end

    openWith(r, g, b, a)
end

function Options:CreateColorPicker(content, label, getter, setter, tooltip, hasAlpha, onClear)
    local holder = CreateFrame("Frame", nil, content)
    holder:SetSize(220, 22)

    local text = holder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT")
    text:SetText(label)
    text:SetTextColor(1, 1, 1)

    local swatch = CreateFrame("Button", nil, holder)
    swatch:SetSize(44, 20)
    swatch:SetPoint("LEFT", text, "RIGHT", 8, 0)
    local rim = swatch:CreateTexture(nil, "BACKGROUND")
    rim:SetAllPoints()
    rim:SetColorTexture(GOLD[1], GOLD[2], GOLD[3], 1)
    -- The colour is drawn with its own alpha, so it needs something opaque behind it or a
    -- translucent swatch composites against the gold rim and reads as washed-out gold.
    local underlay = swatch:CreateTexture(nil, "BORDER")
    underlay:SetPoint("TOPLEFT", 2, -2)
    underlay:SetPoint("BOTTOMRIGHT", -2, 2)
    underlay:SetColorTexture(0, 0, 0, 1)
    local tex = swatch:CreateTexture(nil, "ARTWORK")
    tex:SetPoint("TOPLEFT", 2, -2)
    tex:SetPoint("BOTTOMRIGHT", -2, 2)

    local clear
    local function paint()
        local c = getter()
        local isSet = (c and c.r ~= nil) and true or false
        if isSet then
            tex:SetColorTexture(c.r, c.g or 0, c.b or 0, c.a or 1)
        else
            tex:SetColorTexture(0.22, 0.22, 0.22, 1)
        end
        if clear then clear:SetShown(isSet) end
    end

    -- Only clearable pickers get the button, so an unset swatch stays distinguishable
    -- from a deliberately black one.
    if onClear then
        clear = flatButton(holder, L["Clear"], function()
            onClear()
            paint()
            local T = ns:GetModule("Tracker")
            if T then T:Render() end
        end)
        clear:SetSize(60, 18)
        clear:SetPoint("LEFT", holder, "RIGHT", 8, 0)
    end
    paint()

    swatch:SetScript("OnClick", function()
        local c = getter() or {}
        Options:ShowColorPicker(c.r or 1, c.g or 1, c.b or 1, c.a or 1, hasAlpha,
            function(nr, ng, nb, na)
                setter({ r = nr, g = ng, b = nb, a = na })
                paint()
                local T = ns:GetModule("Tracker")
                if T then T:Render() end
            end)
    end)

    holder.button  = swatch
    holder.label   = text
    holder.paint   = paint
    holder.Refresh = paint
    if tooltip then self:AttachTooltip(holder, label, tooltip) end
    content._controls[#content._controls + 1] = holder
    return holder
end

-- Straightens the swatch column in a run of pickers whose labels are different lengths:
-- the button takes the reference picker's x and the label hangs right-aligned off its left
-- edge. Used by the two-column Appearance tab.
function Options:AlignSwatchTo(picker, ref)
    picker.button:ClearAllPoints()
    picker.button:SetPoint("TOP",  picker, "TOP", 0, -1)
    picker.button:SetPoint("LEFT", ref.button, "LEFT", 0, 0)
    picker.label:ClearAllPoints()
    picker.label:SetPoint("RIGHT", picker.button, "LEFT", -8, 0)
end

-- A hand-anchored column resolves nothing until the next frame, so its height is unknowable
-- at build time. Run per view rather than once per build as EQ does, because Build() runs
-- at login with the whole window hidden - GetTop() is nil there and a one-shot measure
-- would leave the tab unscrollable until a reload.
local function measureContentHeight(content)
    C_Timer.After(0, function()
        local top = content:GetTop()
        if not top then return end
        local lowest = top

        -- Regions as well as children. A FontString is not a child, so a children-only
        -- walk measures a tab whose lowest element is a heading or a label as empty -
        -- which is the whole of the About tab.
        local function consider(o)
            if not (o and o.IsShown and o:IsShown() and o.GetBottom) then return end
            local bottom = o:GetBottom()
            if bottom and bottom < lowest then lowest = bottom end
        end
        for _, child  in ipairs({ content:GetChildren() }) do consider(child) end
        for _, region in ipairs({ content:GetRegions()  }) do consider(region) end

        content:SetHeight((top - lowest) + 28)
    end)
end

local function styleTab(btn, selected)
    if selected then
        btn.bg:SetColorTexture(BRAND_RED[1], BRAND_RED[2], BRAND_RED[3], 1)
    else
        btn.bg:SetColorTexture(unpack(TAB_INACTIVE))
    end
    btn.text:SetTextColor(1, 1, 1, 1)
end

function Options:SelectTab(id)
    if not self.frame then return end
    for _, t in ipairs(self.tabs) do
        local isSel = (t.id == id)
        styleTab(t._button, isSel)
        if isSel then
            if not t._built then
                t._content._controls = {}
                t.build(self, t._content)
                t._built = true
            end
            if t.refresh then t.refresh(self, t._content) end
            for _, c in ipairs(t._content._controls or {}) do
                if c.Refresh then c:Refresh() end
            end
            t._scroll:Show()
            measureContentHeight(t._content)
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
    closeOnEscape(f)

    if f.SetBackdrop then
        f:SetBackdrop({
            bgFile   = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        f:SetBackdropColor(0, 0, 0, 0.95)
        f:SetBackdropBorderColor(BRAND_RED[1], BRAND_RED[2], BRAND_RED[3], 1.0)
    end

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -14)
    title:SetText("EQ Objective Tracker")
    title:SetTextColor(unpack(BRAND_RED))
    title:SetFont(title:GetFont(), 25, "OUTLINE")

    local version = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    version:SetPoint("TOPRIGHT", -34, -14)
    version:SetText("v" .. ns.VERSION)
    version:SetTextColor(unpack(GOLD))

    -- Untemplated to match EQ - UIPanelCloseButton draws Blizzard's own red panel art.
    local close = CreateFrame("Button", nil, f)
    close:SetSize(20, 20)
    close:SetPoint("TOPRIGHT", -8, -10)
    local closeBg = close:CreateTexture(nil, "BACKGROUND")
    closeBg:SetAllPoints()
    closeBg:SetColorTexture(0, 0, 0, 0.9)
    local closeText = close:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    closeText:SetPoint("CENTER")
    closeText:SetText("X")
    closeText:SetTextColor(1, 1, 1, 1)
    close:SetScript("OnClick", function() f:Hide() end)

    f.tabStrip = CreateFrame("Frame", nil, f)
    f.tabStrip:SetPoint("TOPLEFT", FRAME_PAD, -TAB_TOP)
    f.tabStrip:SetPoint("TOPRIGHT", -FRAME_PAD, -TAB_TOP)
    f.tabStrip:SetHeight(TAB_H)

    f.tabContent = CreateFrame("Frame", nil, f)
    f.tabContent:SetPoint("TOPLEFT", FRAME_PAD, -(TAB_TOP + TAB_H + 6))
    f.tabContent:SetPoint("BOTTOMRIGHT", -FRAME_PAD, FRAME_PAD)

    local x = 0
    for _, t in ipairs(self.tabs) do
        local b = CreateFrame("Button", nil, f.tabStrip)
        b:SetHeight(TAB_H)
        b.bg = b:CreateTexture(nil, "BACKGROUND")
        b.bg:SetAllPoints()
        b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        b.text:SetPoint("CENTER")
        b.text:SetText(t.title)
        b:SetWidth(b.text:GetStringWidth() + TAB_PAD_X * 2)
        b:SetPoint("LEFT", f.tabStrip, "LEFT", x, 0)
        b:SetScript("OnClick", function() Options:SelectTab(t.id) end)
        x = x + b:GetWidth() + 4
        t._button = b

        local scroll = CreateFrame("ScrollFrame", nil, f.tabContent,
                                   "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", 0, 0)
        scroll:SetPoint("BOTTOMRIGHT", -24, 0)
        scroll:Hide()
        local content = CreateFrame("Frame", nil, scroll)
        content:SetSize(W - FRAME_PAD * 2 - 24, 1)
        content._controls = {}
        scroll:SetScrollChild(content)
        t._scroll, t._content = scroll, content
    end

    local char = ns:GetModule("DB"):Char()
    local want = (char and char.lastOptionsTab) or (self.tabs[1] and self.tabs[1].id)
    local found = false
    for _, t in ipairs(self.tabs) do
        if t.id == want then found = true break end
    end
    self:SelectTab(found and want or (self.tabs[1] and self.tabs[1].id))
end

-- EQ's version, ported as it stands. The UIParent-units idiom the tracker and zone bar use
-- does not apply here: this frame persists no position, so there is nothing stored to be in
-- the wrong units.
function Options:ApplyWindowScale()
    local f = self.frame
    if not f then return end
    local g = ns:GetModule("DB"):Global()
    local s = g and g.optionsWindowScale
    if type(s) ~= "number" or s <= 0 then s = 1 end

    -- SetScale re-reads the anchor offsets in the new scale, so a dragged window jumps
    -- unless its centre is restored.
    local cx, cy = f:GetCenter()
    local oldEff = f:GetEffectiveScale()
    f:SetScale(s)
    if cx and cy and oldEff then
        local newEff = f:GetEffectiveScale()
        f:ClearAllPoints()
        f:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cx * oldEff / newEff, cy * oldEff / newEff)
    end
end

function Options:Toggle()
    self:Build()
    if self.frame:IsShown() then
        self.frame:Hide()
    else
        self:ApplyWindowScale()
        self:SelectTab(self._current)
        self.frame:Show()
    end
end

function Options:OnEnable()
    self:Build()
end
