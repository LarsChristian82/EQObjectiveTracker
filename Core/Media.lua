local _, ns = ...

local Media = ns:RegisterModule("Media", {})

local FONT_PATH = [[Interface\AddOns\EQObjectiveTracker\Media\Fonts\]]

-- These names must stay character-for-character identical to Everything Quests. A
-- profile imported from EQ stores the font by NAME, so a renamed entry silently falls
-- back to Friz Quadrata and the user's tracker changes appearance with nothing to
-- explain why. When EQ drops its own font registration it will fetch these through
-- LibSharedMedia, so the names are a shared contract, not a private list.
local FONTS = {
    { name = "GothamXNarrow Black",       file = FONT_PATH .. "GothamXNarrow-Black.ttf" },
    { name = "Avquest",                   file = FONT_PATH .. "Avquest.ttf" },
    { name = "Barlow Condensed",          file = FONT_PATH .. "BarlowCondensed-Regular.ttf" },
    { name = "Barlow Condensed Medium",   file = FONT_PATH .. "BarlowCondensed-Medium.ttf" },
    { name = "Barlow Condensed SemiBold", file = FONT_PATH .. "BarlowCondensed-SemiBold.ttf" },
    { name = "Barlow Condensed Bold",     file = FONT_PATH .. "BarlowCondensed-Bold.ttf" },
    { name = "Beep",                      file = FONT_PATH .. "Beep-Regular.otf" },
    { name = "Beep Medium",               file = FONT_PATH .. "Beep-Medium.otf" },
    { name = "Beep Bold",                 file = FONT_PATH .. "Beep-Bold.otf" },
    { name = "Exo 2 ExtraBold",           file = FONT_PATH .. "Exo2-ExtraBold.ttf" },
    { name = "GoodBrush",                 file = FONT_PATH .. "GoodBrush.ttf" },
    { name = "Gotham Narrow Black",       file = FONT_PATH .. "GothamNarrowBlack.ttf" },
    { name = "Inter",                     file = FONT_PATH .. "Inter-Regular.ttf" },
    { name = "Inter SemiBold",            file = FONT_PATH .. "Inter-SemiBold.ttf" },
    { name = "Inter Bold",                file = FONT_PATH .. "Inter-Bold.ttf" },
    { name = "Josefin Sans Bold",         file = FONT_PATH .. "JosefinSans-Bold.ttf" },
    { name = "Kimberley",                 file = FONT_PATH .. "Kimberley.ttf" },
    { name = "Lemon",                     file = FONT_PATH .. "Lemon-Regular.ttf" },
    { name = "Metal Lord",                file = FONT_PATH .. "Metal-Lord.ttf" },
    { name = "Montserrat",                file = FONT_PATH .. "Montserrat-Regular.ttf" },
    { name = "Montserrat Medium",         file = FONT_PATH .. "Montserrat-Medium.ttf" },
    { name = "Montserrat SemiBold",       file = FONT_PATH .. "Montserrat-SemiBold.ttf" },
    { name = "Montserrat Bold",           file = FONT_PATH .. "Montserrat-Bold.ttf" },
    { name = "Neuropol X",                file = FONT_PATH .. "neuropolxrg.ttf" },
    { name = "Noto Sans",                 file = FONT_PATH .. "NotoSans-Regular.ttf" },
    { name = "Noto Sans SemiBold",        file = FONT_PATH .. "NotoSans-SemiBold.ttf" },
    { name = "Noto Sans Bold",            file = FONT_PATH .. "NotoSans-Bold.ttf" },
    { name = "Optimus Princeps",          file = FONT_PATH .. "OptimusPrinceps.ttf" },
    { name = "Oswald Light",              file = FONT_PATH .. "Oswald-Light.ttf" },
    { name = "Oswald",                    file = FONT_PATH .. "Oswald-Regular.ttf" },
    { name = "Oswald Bold",               file = FONT_PATH .. "Oswald-Bold.ttf" },
    { name = "Pepsi",                     file = FONT_PATH .. "Pepsi-Cyr-Lat.ttf" },
    { name = "Pricedown",                 file = FONT_PATH .. "pricedown.ttf" },
    { name = "Reckoner",                  file = FONT_PATH .. "Reckoner.ttf" },
    { name = "Reckoner Bold",             file = FONT_PATH .. "Reckoner_Bold.ttf" },
    { name = "RingLink Medium",           file = FONT_PATH .. "RingLink-Medium.otf" },
    { name = "RingLink Bold",             file = FONT_PATH .. "RingLink-Bold.otf" },
    { name = "Roboto Bold",               file = FONT_PATH .. "Roboto-Bold.ttf" },
    { name = "Simply Sans",               file = FONT_PATH .. "SimplySans-Book.ttf" },
    { name = "Simply Sans Bold",          file = FONT_PATH .. "SimplySans-Bold.ttf" },
    { name = "Ubuntu Medium",             file = FONT_PATH .. "Ubuntu-Medium.ttf" },
    { name = "Ubuntu Bold",               file = FONT_PATH .. "Ubuntu-Bold.ttf" },
}

local WOW_FONTS = {
    { name = "WoW Default (Friz Quadrata)", file = STANDARD_TEXT_FONT or [[Fonts\FRIZQT__.TTF]] },
    { name = "WoW Arial Narrow",            file = [[Fonts\ARIALN.TTF]] },
    { name = "WoW Morpheus",                file = [[Fonts\MORPHEUS.TTF]] },
}

function Media:OnInitialize()
    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    if not LSM then return end
    for _, f in ipairs(FONTS)     do LSM:Register("font", f.name, f.file) end
    for _, f in ipairs(WOW_FONTS) do LSM:Register("font", f.name, f.file) end
    self.LSM = LSM
end

function Media:GetFontList()
    local out = {}
    local names = self.LSM and self.LSM:List("font")
    if names and #names > 0 then
        for _, name in ipairs(names) do out[#out + 1] = name end
        return out
    end
    for _, f in ipairs(WOW_FONTS) do out[#out + 1] = f.name end
    for _, f in ipairs(FONTS)     do out[#out + 1] = f.name end
    return out
end

function Media:GetFontFile(name)
    if self.LSM then
        local f = self.LSM:Fetch("font", name or "Friz Quadrata TT")
        if f then return f end
    end
    for _, f in ipairs(FONTS)     do if f.name == name then return f.file end end
    for _, f in ipairs(WOW_FONTS) do if f.name == name then return f.file end end
    return STANDARD_TEXT_FONT
end

local function setShadow(fs, enabled, color, strength)
    if enabled then
        fs:SetShadowColor(color and color.r or 0, color and color.g or 0,
                          color and color.b or 0, color and color.a or 1)
        local d = strength or 2
        fs:SetShadowOffset(d, -d)
    else
        fs:SetShadowColor(0, 0, 0, 0)
        fs:SetShadowOffset(0, 0)
    end
end

function Media:ApplyTextShadow(fs)
    if not fs then return end
    local cfg = ns:GetModule("DB"):Tracker()
    if not cfg then return end
    setShadow(fs, cfg.textShadow, cfg.textShadowColor, cfg.textShadowStrength)
end

function Media:ApplyFont(fs, sizeDelta)
    if not fs then return end
    local cfg = ns:GetModule("DB"):Tracker()
    if not cfg then return end
    local file = self:GetFontFile(cfg.font)
    if file then
        fs:SetFont(file, math.max(8, (cfg.fontSize or 12) + (sizeDelta or 0)),
                   cfg.fontOutline or "")
    end
    setShadow(fs, cfg.textShadow, cfg.textShadowColor, cfg.textShadowStrength)
end

function Media:ApplyTitleFont(fs)
    local cfg = ns:GetModule("DB"):Tracker()
    self:ApplyFont(fs, cfg and cfg.titleSizeDelta or 0)
end

function Media:LineSpacing()
    local cfg = ns:GetModule("DB"):Tracker()
    return math.max(-8, math.min(24, (cfg and cfg.lineSpacing) or 0))
end

function Media:HeaderSpacing()
    local cfg = ns:GetModule("DB"):Tracker()
    return math.max(-8, math.min(24, (cfg and cfg.headerSpacing) or 0))
end
