local _, ns = ...

local QuestItems = ns:RegisterModule("QuestItems", {})

-- The layering seam for the secure quest-item buttons, the same shape as
-- Scenarios:GetBanner. UI/ItemButtons.lua owns the frame and calls no quest API of its
-- own, and this file touches no frame.
local function logIndex(questID)
    if not (questID and ns.Has.QuestSpecialItem) then return nil end
    return C_QuestLog.GetLogIndexForQuestID(questID)
end

function QuestItems:Available()
    return ns.Has.QuestSpecialItem
end

function QuestItems:Get(questID)
    local idx = logIndex(questID)
    if not idx then return nil end
    local link, icon, charges = GetQuestLogSpecialItemInfo(idx)
    if not (link and icon) then return nil end
    return link, icon, charges, idx
end

function QuestItems:Has(questID)
    local link = self:Get(questID)
    return link and true or false
end

-- Diagnostic for /eqot status. Counts every quest in the log that has a usable item,
-- whatever the tracker is currently showing, so a zero tells "no quest has one" apart from
-- "the one that does is filtered out". The loop index IS the log index the API wants.
function QuestItems:CountInLog()
    if not (ns.Has.QuestSpecialItem and ns.Has.QuestLog) then return 0 end
    local n = 0
    for i = 1, C_QuestLog.GetNumQuestLogEntries() do
        local info = C_QuestLog.GetInfo(i)
        -- World quests are skipped: they render in their own region, which gets no buttons,
        -- so counting them would read as a filter problem rather than correct behavior.
        if info and not info.isHeader and not info.isHidden
           and not (C_QuestLog.IsWorldQuest and C_QuestLog.IsWorldQuest(info.questID)) then
            local link, icon = GetQuestLogSpecialItemInfo(i)
            if link and icon then n = n + 1 end
        end
    end
    return n
end

function QuestItems:Cooldown(questID)
    local idx = logIndex(questID)
    if not (idx and GetQuestLogSpecialItemCooldown) then return nil end
    return GetQuestLogSpecialItemCooldown(idx)
end

-- IsQuestLogSpecialItemInRange answers 0 out of range, 1 in range, and nil for an item
-- with no range concept at all. The nil case must not read as out of range or every
-- non-targeted quest item paints red.
function QuestItems:InRange(questID)
    local idx = logIndex(questID)
    if not (idx and IsQuestLogSpecialItemInRange) then return nil end
    local r = IsQuestLogSpecialItemInRange(idx)
    if r == nil then return nil end
    return r ~= 0
end
