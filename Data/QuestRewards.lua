local _, ns = ...

local QR = ns:RegisterModule("QuestRewards", {})
local L  = ns.L

local EQUIP_SLOTS = {
    INVTYPE_HEAD           = { "HEADSLOT" },
    INVTYPE_NECK           = { "NECKSLOT" },
    INVTYPE_SHOULDER       = { "SHOULDERSLOT" },
    INVTYPE_CLOAK          = { "BACKSLOT" },
    INVTYPE_CHEST          = { "CHESTSLOT" },
    INVTYPE_ROBE           = { "CHESTSLOT" },
    INVTYPE_WAIST          = { "WAISTSLOT" },
    INVTYPE_LEGS           = { "LEGSSLOT" },
    INVTYPE_FEET           = { "FEETSLOT" },
    INVTYPE_WRIST          = { "WRISTSLOT" },
    INVTYPE_HAND           = { "HANDSSLOT" },
    INVTYPE_FINGER         = { "FINGER0SLOT", "FINGER1SLOT" },
    INVTYPE_TRINKET        = { "TRINKET0SLOT", "TRINKET1SLOT" },
    INVTYPE_WEAPON         = { "MAINHANDSLOT", "SECONDARYHANDSLOT" },
    INVTYPE_2HWEAPON       = { "MAINHANDSLOT" },
    INVTYPE_WEAPONMAINHAND = { "MAINHANDSLOT" },
    INVTYPE_WEAPONOFFHAND  = { "SECONDARYHANDSLOT" },
    INVTYPE_RANGED         = { "MAINHANDSLOT" },
    INVTYPE_RANGEDRIGHT    = { "MAINHANDSLOT" },
    INVTYPE_SHIELD         = { "SECONDARYHANDSLOT" },
    INVTYPE_HOLDABLE       = { "SECONDARYHANDSLOT" },
}

-- Wrapped here rather than at the lookup. EQ writes L[SLOT_LABEL[equipLoc]], which works
-- at runtime but is a computed index, so docs/_gen_enus.py never sees the phrases and
-- none of them are translatable in EQ to this day.
local SLOT_LABEL = {
    INVTYPE_HEAD           = L["Head"],
    INVTYPE_NECK           = L["Neck"],
    INVTYPE_SHOULDER       = L["Shoulder"],
    INVTYPE_CLOAK          = L["Back"],
    INVTYPE_CHEST          = L["Chest"],
    INVTYPE_ROBE           = L["Chest"],
    INVTYPE_WAIST          = L["Waist"],
    INVTYPE_LEGS           = L["Legs"],
    INVTYPE_FEET           = L["Feet"],
    INVTYPE_WRIST          = L["Wrist"],
    INVTYPE_HAND           = L["Hands"],
    INVTYPE_FINGER         = L["Finger"],
    INVTYPE_TRINKET        = L["Trinket"],
    INVTYPE_WEAPON         = L["Weapon"],
    INVTYPE_2HWEAPON       = L["Two-Hand"],
    INVTYPE_WEAPONMAINHAND = L["Main Hand"],
    INVTYPE_WEAPONOFFHAND  = L["Off Hand"],
    INVTYPE_RANGED         = L["Ranged"],
    INVTYPE_RANGEDRIGHT    = L["Ranged"],
    INVTYPE_SHIELD         = L["Off Hand"],
    INVTYPE_HOLDABLE       = L["Off Hand"],
}

local lines, pool = {}, {}

local function reset()
    for i = #lines, 1, -1 do
        pool[#pool + 1] = lines[i]
        lines[i] = nil
    end
end

local function push(kind)
    local e = tremove(pool) or {}
    e.kind = kind
    e.text, e.done, e.amount                 = nil, nil, nil
    e.name, e.count, e.quality               = nil, nil, nil
    e.ilvl, e.showIlvl, e.slotLabel          = nil, nil, nil
    e.cmpEmpty, e.cmpLowest                  = nil, nil
    lines[#lines + 1] = e
    return e
end

local _slotID = {}
local function slotID(name)
    local id = _slotID[name]
    if id == nil then
        id = (GetInventorySlotInfo and GetInventorySlotInfo(name)) or false
        _slotID[name] = id
    end
    return id or nil
end

local function equipLocOf(itemID)
    if not itemID then return nil end
    local instant = (C_Item and C_Item.GetItemInfoInstant) or GetItemInfoInstant
    if not instant then return nil end
    return select(4, instant(itemID))
end

local function detailedIlvl(link)
    if not (link and C_Item and C_Item.GetDetailedItemLevelInfo) then return nil end
    return C_Item.GetDetailedItemLevelInfo(link)
end

local function lowestEquipped(equipLoc)
    local slots = EQUIP_SLOTS[equipLoc]
    if not slots then return nil, false end
    local lowest, hasEmpty
    for i = 1, #slots do
        local id = slotID(slots[i])
        if id then
            local link = GetInventoryItemLink and GetInventoryItemLink("player", id)
            if link then
                local il = detailedIlvl(link)
                if il and (not lowest or il < lowest) then lowest = il end
            else
                hasEmpty = true
            end
        end
    end
    return lowest, hasEmpty and true or false
end

local function addItem(questID, kind, index, name, count, quality, itemID, rewardIlvl)
    local equipLoc = equipLocOf(itemID)
    if not rewardIlvl then
        local link = GetQuestLogItemLink and GetQuestLogItemLink(kind, index, questID)
        if link then rewardIlvl = detailedIlvl(link) end
    end

    local e = push("item")
    e.name, e.count, e.quality, e.ilvl = name, count, quality, rewardIlvl
    e.showIlvl = (equipLoc and EQUIP_SLOTS[equipLoc] and rewardIlvl and rewardIlvl > 0) and true or false

    if equipLoc and rewardIlvl and rewardIlvl > 0 and EQUIP_SLOTS[equipLoc] then
        local lowest, hasEmpty = lowestEquipped(equipLoc)
        e.cmpEmpty  = hasEmpty
        e.cmpLowest = (not hasEmpty) and lowest or nil
        e.slotLabel = SLOT_LABEL[equipLoc] or ""
    end
end

-- Total by construction, as EQ's Util.QuestTitle(id, true) is: a bonus step's reward quest
-- is a hidden container whose name streams in late, and the tooltip header is drawn once on
-- hover with no re-show, so returning nil leaves a blank line there for the whole hover.
function QR:Title(questID)
    if questID then
        if C_QuestLog and C_QuestLog.GetTitleForQuestID then
            local t = C_QuestLog.GetTitleForQuestID(questID)
            if t and t ~= "" then return t end
        end
        if QuestUtils_GetQuestName then
            local n = QuestUtils_GetQuestName(questID)
            if n and n ~= "" then return n end
        end
        if ns.Has.TaskQuestInfo then
            local t = C_TaskQuest.GetQuestInfoByQuestID(questID)
            if t and t ~= "" then return t end
        end
    end
    return "Quest #" .. tostring(questID)
end

-- Structured rather than pre-formatted: the colour and the indent are the renderer's, which
-- is what keeps every escape sequence out of this layer. Valid until the next call.
function QR:Lines(questID)
    reset()
    if not questID then return lines end

    if C_QuestLog and C_QuestLog.GetQuestObjectives then
        local objs = C_QuestLog.GetQuestObjectives(questID)
        for i = 1, (objs and #objs or 0) do
            local o = objs[i]
            if o and o.text and o.text ~= "" then
                local e = push("objective")
                e.text = o.text
                e.done = o.finished and true or false
            end
        end
    end

    if C_TaskQuest and C_TaskQuest.RequestPreloadRewardData then
        C_TaskQuest.RequestPreloadRewardData(questID)
    end

    local money = GetQuestLogRewardMoney and GetQuestLogRewardMoney(questID) or 0
    if money and money > 0 then
        push("money").amount = money
    end

    local xp = GetQuestLogRewardXP and GetQuestLogRewardXP(questID) or 0
    if xp and xp > 0 then
        push("xp").amount = xp
    end

    local numItems = GetNumQuestLogRewards and GetNumQuestLogRewards(questID) or 0
    for i = 1, numItems do
        local name, _, count, quality, _, itemID, ilvl = GetQuestLogRewardInfo(i, questID)
        if name then addItem(questID, "reward", i, name, count, quality, itemID, ilvl) end
    end

    local numChoices = GetNumQuestLogChoices and GetNumQuestLogChoices(questID) or 0
    if numChoices and numChoices > 0 then
        push("choices")
        for i = 1, numChoices do
            local name, _, count, quality, _, itemID = GetQuestLogChoiceInfo(i, questID)
            if name then addItem(questID, "choice", i, name, count, quality, itemID, nil) end
        end
    end

    local currencies = C_QuestLog and C_QuestLog.GetQuestRewardCurrencies
                       and C_QuestLog.GetQuestRewardCurrencies(questID)
    for i = 1, (currencies and #currencies or 0) do
        local c = currencies[i]
        if c and c.name then
            local e = push("currency")
            e.name  = c.name
            e.count = c.totalRewardAmount
        end
    end

    return lines
end
