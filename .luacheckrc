std = "lua51"
max_line_length = false
exclude_files = { "Libs/**" }

-- The addon namespace is the only global we are allowed to create.
globals = {
    "EQObjectiveTracker",
    "EQObjectiveTrackerDB",
    "EQObjectiveTrackerCharDB",
    "SLASH_EQOT1",
    "SLASH_EQOT2",
    "SlashCmdList",
    "BINDING_HEADER_EQOBJECTIVETRACKER",
    -- Classic's colour picker is driven by assigning callbacks onto the frame itself
    "ColorPickerFrame",
}

read_globals = {
    -- Lua-side Blizzard shims
    "wipe", "tremove", "tinsert", "strsplit", "strtrim", "strjoin", "format",
    "CopyTable", "Mixin", "CreateFromMixins", "geterrorhandler", "securecall",
    "date", "time", "bit",

    -- Core UI
    "CreateFrame", "UIParent", "GameTooltip", "GameFontNormal", "GameFontNormalLarge",
    "GameFontNormalSmall", "GameFontHighlightSmall", "ObjectiveTrackerHeaderFont",
    "InCombatLockdown", "IsModifiedClick", "GetCursorPosition", "GetTime",
    "RAID_CLASS_COLORS", "GetQuestDifficultyColor", "CreateColor", "UISpecialFrames",
    "STANDARD_TEXT_FONT", "OpacitySliderFrame",
    "UnitClass", "GetZoneText", "PlaySound", "ReloadUI",

    -- Namespaced API
    "C_Timer", "C_Map", "C_QuestLog", "C_QuestInfoSystem", "C_CampaignInfo",
    "C_SuperTrack", "C_TaskQuest", "C_ContentTracking", "C_PerksActivities",
    "C_Scenario", "C_ScenarioInfo", "GetInstanceInfo", "C_Texture", "C_AddOns", "Enum",
    "C_TradeSkillUI", "C_CurrencyInfo", "C_Item", "ProfessionsUtil", "QuestUtil",
    "C_LFGList", "LFGListUtil_FindQuestGroup", "C_TaxiMap", "FlightMapFrame",
    "PlaySoundFile", "ERR_QUEST_COMPLETE_S", "C_QuestLine", "MenuUtil",

    -- Blizzard format strings, used so reagent lines stay localized
    "PROFESSIONS_TRACKER_REAGENT_FORMAT", "PROFESSIONS_TRACKER_REAGENT_COUNT_FORMAT",
    "PROFESSIONS_TRACKER_REAGENT_RANGE_FORMAT", "PROFESSIONS_CRAFTING_FORM_RECRAFTING_HEADER",

    -- Legacy / cross-flavor globals guarded by Core/Compat.lua
    "GetAchievementInfo", "GetAchievementNumCriteria", "GetAchievementCriteriaInfo",
    "GetTrackedAchievements", "RemoveTrackedAchievement", "OpenAchievementFrameToAchievement",
    "GetQuestLogRewardMoney", "GetNumQuestLogRewards", "GetQuestLogRewardInfo",
    "HaveQuestRewardData", "GetCoinTextureString",
    "QuestUtils_IsQuestWorldQuest", "QuestUtils_GetQuestName",
    "QuestMapFrame_OpenToQuestDetails", "ToggleQuestLog", "GetQuestLogQuestText",
    "ObjectiveTrackerFrame",

    -- Libraries
    "LibStub",
}

ignore = {
    "212", -- unused argument, common in event handler signatures
}
