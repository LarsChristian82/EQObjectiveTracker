local _, ns = ...

local Util = ns:RegisterModule("Util", {})

local function progressRepl(have, need)
    local h, n = tonumber(have), tonumber(need)
    if not (h and n) then return have .. "/" .. need end
    local color
    if h == 0    then color = "|cffff5050"
    elseif h < n then color = "|cffeeaa00"
    else              color = "|cff44ff44"
    end
    return color .. have .. "/" .. need .. "|r"
end

function Util.ColorizeProgress(text)
    if not text or text == "" then return text end
    return (text:gsub("(%d+)%s*/%s*(%d+)", progressRepl))
end

function Util.StripLeadingCount(text)
    if not text then return "" end
    return (text:gsub("^%s*%d+%s*/%s*%d+%s*", ""))
end

function Util.Hex(r, g, b)
    return ("%02x%02x%02x"):format(
        math.floor((r or 0) * 255 + 0.5),
        math.floor((g or 0) * 255 + 0.5),
        math.floor((b or 0) * 255 + 0.5))
end

function Util.FmtDuration(secs)
    secs = math.max(0, math.floor(secs or 0))
    local h = math.floor(secs / 3600)
    local m = math.floor((secs % 3600) / 60)
    if h > 0 then return ("%dh %dm"):format(h, m) end
    if m > 0 then return ("%dm"):format(m) end
    return ("%ds"):format(secs)
end

function Util.TimeShort(mins)
    if not mins or mins <= 0 then return "" end
    if mins < 60   then return ("%dm"):format(mins) end
    if mins < 1440 then return ("%dh"):format(math.floor(mins / 60)) end
    return ("%dd"):format(math.floor(mins / 1440))
end

function Util.TimeColor(mins)
    if not mins or mins <= 0 then return 1.00, 0.10, 0.10 end
    if mins < 30   then return 1.00, 0.25, 0.25 end
    if mins < 120  then return 1.00, 0.65, 0.10 end
    if mins < 720  then return 1.00, 1.00, 0.40 end
    return 0.50, 1.00, 0.50
end

local _atlasOK = {}
function Util.AtlasExists(atlas)
    if not atlas or atlas == "" then return false end
    if not ns.Has.Atlas then return false end
    local ok = _atlasOK[atlas]
    if ok == nil then
        ok = C_Texture.GetAtlasInfo(atlas) and true or false
        _atlasOK[atlas] = ok
    end
    return ok
end

function Util.SafeSetAtlas(tex, atlas)
    if Util.AtlasExists(atlas) then
        tex:SetAtlas(atlas, false)
        return true
    end
    tex:SetTexture(nil)
    return false
end

ns.Util = Util
