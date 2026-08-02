local _, ns = ...

local Dialog = ns:RegisterModule("Dialog", {})

-- Own frame rather than StaticPopup: that system recycles a small shared pool, so an
-- insecure handler here could taint the frame the logout or quit dialog later reuses.
local GOLD_R, GOLD_G, GOLD_B = 0.92, 0.72, 0.02

local function makeButton(parent)
    return CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
end

local function fitButton(b, label)
    b:SetText(label or "")
    local fs = b:GetFontString()
    local w = fs and math.ceil(fs:GetStringWidth()) or 0
    b:SetSize(math.max(90, w + 28), 22)
end

function Dialog:_finish(accepted)
    local opts = self.opts
    -- Guards a double fire - a button click and the escape key can both land.
    if not opts then return end
    self.opts = nil

    local f = self.frame
    local text = (f and f.editBox:IsShown()) and f.editBox:GetText() or nil
    if f then f:Hide() end

    if accepted then
        if opts.onAccept then opts.onAccept(text) end
    elseif opts.onCancel then
        opts.onCancel()
    end
end

function Dialog:Build()
    if self.frame then return self.frame end

    -- Deliberately unnamed. A named frame can be read out of _G, which is the whole
    -- mechanism behind the UISpecialFrames taint - see closeOnEscape in Options/Frame.lua.
    local f = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:SetSize(430, 160)
    f:SetPoint("CENTER")
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetClampedToScreen(true)
    f:Hide()

    if f.SetBackdrop then
        f:SetBackdrop({
            bgFile   = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        f:SetBackdropColor(0, 0, 0, 0.94)
        f:SetBackdropBorderColor(GOLD_R, GOLD_G, GOLD_B, 0.8)
    end

    -- SetPropagateKeyboardInput is protected, so the whole handler stands down in combat
    -- and Escape falls through to the default UI.
    f:EnableKeyboard(false)
    f:HookScript("OnShow", function(frame)
        if InCombatLockdown() then return end
        frame:EnableKeyboard(true)
        frame:SetPropagateKeyboardInput(true)
    end)
    f:HookScript("OnHide", function(frame) frame:EnableKeyboard(false) end)
    f:SetScript("OnKeyDown", function(frame, key)
        if InCombatLockdown() then return end
        if key == "ESCAPE" then
            frame:SetPropagateKeyboardInput(false)
            Dialog:_finish(false)
        else
            frame:SetPropagateKeyboardInput(true)
        end
    end)

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.title:SetPoint("TOP", 0, -12)
    f.title:SetTextColor(GOLD_R, GOLD_G, GOLD_B)

    f.text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.text:SetPoint("TOPLEFT", 18, -40)
    f.text:SetPoint("TOPRIGHT", -18, -40)
    f.text:SetJustifyH("LEFT")
    f.text:SetSpacing(3)

    f.editBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    f.editBox:SetAutoFocus(false)
    f.editBox:SetSize(340, 22)
    f.editBox:SetPoint("TOP", f.text, "BOTTOM", 0, -12)
    f.editBox:SetScript("OnEscapePressed", function() Dialog:_finish(false) end)
    f.editBox:SetScript("OnEnterPressed", function() Dialog:_finish(true) end)
    f.editBox:Hide()

    f.accept = makeButton(f)
    f.accept:SetScript("OnClick", function() Dialog:_finish(true) end)

    f.cancel = makeButton(f)
    f.cancel:SetPoint("BOTTOMRIGHT", -18, 14)
    f.cancel:SetScript("OnClick", function() Dialog:_finish(false) end)

    self.frame = f
    return f
end

function Dialog:Show(opts)
    local f = self:Build()
    -- Close a dialog still on screen so its callbacks are not silently dropped.
    if self.opts then self:_finish(false) end
    self.opts = opts

    f.title:SetText(opts.title or "EQ Objective Tracker")
    f.text:SetText(opts.text or "")

    fitButton(f.accept, opts.button1 or "OK")
    if opts.button2 then
        fitButton(f.cancel, opts.button2)
        f.cancel:Show()
    else
        f.cancel:Hide()
    end

    if opts.hasEditBox then
        f.editBox:Show()
        f.editBox:SetMaxLetters(opts.maxLetters or 0)
        f.editBox:SetText(opts.editBoxText or "")
        f.editBox:SetCursorPosition(0)
        f.editBox:SetFocus()
    else
        f.editBox:Hide()
        f.editBox:ClearFocus()
    end

    f.accept:ClearAllPoints()
    if opts.button2 then
        f.accept:SetPoint("BOTTOMLEFT", 18, 14)
    else
        f.accept:SetPoint("BOTTOM", 0, 14)
    end

    f:SetHeight(46 + math.max(18, f.text:GetStringHeight())
                + (opts.hasEditBox and 34 or 0) + 50)

    f:Show()
    f:Raise()
end
