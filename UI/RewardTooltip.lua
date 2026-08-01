local _, ns = ...

local RT = ns:RegisterModule("RewardTooltip", {})

local INDENT = "    "
-- Escaped rather than literal so this file stays ASCII: \226\128\148 is an em dash and
-- \195\151 a multiplication sign, matching EQ's strings byte for byte.
local EM_DASH = "\226\128\148"
local TIMES   = "\195\151"

-- Both globals are deprecated in favour of the namespaced calls and may go away
local function coinText(amount)
    local f = (C_CurrencyInfo and C_CurrencyInfo.GetCoinTextureString) or GetCoinTextureString
    return (f and f(amount)) or tostring(amount)
end

-- Truncated to three deliberately: the API also returns a hex string, which would land in
-- AddLine's wrapText slot and word-wrap every item line.
local function qualityColor(quality)
    local f = (C_Item and C_Item.GetItemQualityColor) or GetItemQualityColor
    if not (quality and f) then return 1, 1, 1 end
    local r, g, b = f(quality)
    return r or 1, g or 1, b or 1
end

local function pickAnchor(owner)
    local cx = owner.GetCenter and select(1, owner:GetCenter())
    if not cx then return "ANCHOR_RIGHT" end
    local ownerPx   = cx * (owner:GetEffectiveScale() or 1)
    local screenMid = (UIParent:GetWidth() * (UIParent:GetEffectiveScale() or 1)) / 2
    return ownerPx > screenMid and "ANCHOR_LEFT" or "ANCHOR_RIGHT"
end

local function addComparison(e)
    if e.cmpEmpty then
        GameTooltip:AddLine(INDENT .. "Equip " .. EM_DASH .. " empty slot", 0.2, 1.0, 0.2)
        return
    end
    local lowest = e.cmpLowest
    if not lowest then return end

    local label = e.slotLabel or ""
    GameTooltip:AddLine((INDENT .. "Equipped: ilvl %d"):format(lowest)
        .. (label ~= "" and ("  (" .. label .. ")") or ""), 0.7, 0.7, 0.7)

    local delta = (e.ilvl or 0) - lowest
    if delta > 0 then
        GameTooltip:AddLine((INDENT .. "+%d ilvl upgrade"):format(delta), 0.2, 1.0, 0.2)
    elseif delta < 0 then
        GameTooltip:AddLine((INDENT .. "%d ilvl lower"):format(delta), 1.0, 0.3, 0.3)
    else
        GameTooltip:AddLine(INDENT .. "Same item level", 1.0, 0.82, 0.0)
    end
end

local function addItem(e)
    local label = e.name or ""
    if e.count and e.count > 1 then label = label .. " " .. TIMES .. e.count end
    if e.showIlvl and e.ilvl then
        label = label .. ("  |cff999999ilvl %d|r"):format(e.ilvl)
    end

    GameTooltip:AddLine(label, qualityColor(e.quality))

    addComparison(e)
end

RT.calls, RT.drawn = 0, 0

function RT:Show(owner, questID)
    self.calls = self.calls + 1
    if not (owner and questID) then return end
    local QR = ns:GetModule("QuestRewards")
    if not QR then return end

    GameTooltip:SetOwner(owner, pickAnchor(owner))
    GameTooltip:SetText(QR:Title(questID) or "", 1.0, 0.82, 0.0, 1, true)

    local lines = QR:Lines(questID)
    for i = 1, #lines do
        local e = lines[i]
        if e.kind == "objective" then
            if e.done then
                GameTooltip:AddLine("- " .. e.text, 0.40, 0.85, 0.40, true)
            else
                GameTooltip:AddLine("- " .. e.text, 0.95, 0.95, 0.95, true)
            end
        elseif e.kind == "money" then
            GameTooltip:AddLine(coinText(e.amount), 1, 1, 1)
        elseif e.kind == "xp" then
            GameTooltip:AddLine(("%d XP"):format(e.amount), 1, 1, 1)
        elseif e.kind == "item" then
            addItem(e)
        elseif e.kind == "choices" then
            GameTooltip:AddLine("Choose one:", 0.9, 0.8, 0.3)
        elseif e.kind == "currency" then
            local label = e.name or ""
            if e.count and e.count > 1 then label = label .. " " .. TIMES .. e.count end
            GameTooltip:AddLine(label, 0.85, 0.85, 1.0)
        end
    end

    GameTooltip:Show()
    self.drawn = self.drawn + 1
end

function RT:Hide()
    GameTooltip:Hide()
end
