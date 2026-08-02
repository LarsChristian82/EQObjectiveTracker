local _, ns = ...

local DB = ns:RegisterModule("DB", {})

-- Key names under profile.tracker and profile.general are deliberately identical to
-- Everything Quests so the future EQ config import stays a filtered table copy rather
-- than a semantic translation. Do not rename these for taste.
DB.defaults = {
    profile = {
        general = {
            lockTracker      = false,
            hideInCombat     = false,
            hideInInstances  = false,
            hideOnMapOpen    = false,
            hideInMythicPlus = false,
            autoTrackAccepted = true,
            restoreSuperTrackOnLogin = true,
        },
        tracker = {
            anchor        = "TOPRIGHT",
            relativePoint = "TOPRIGHT",
            -- In UIParent units, NOT the frame's own scaled space. Tracker divides by the
            -- live scale on apply and multiplies on save, so the tracker grows in place
            -- rather than sliding when the scale slider moves.
            xOffset       = -85,
            yOffset       = -200,
            width         = 305,
            maxHeight     = 600,
            scale         = 1.0,

            questSoundEnabled    = true,
            questCompleteSound   = "EQ: Work Complete",

            showOnlyWatched      = true,
            sortMode             = "zone",
            manualOrder          = {},
            simplifyMode         = false,
            simplifyGroups       = {},

            font               = "GothamXNarrow Black",
            fontSize           = 15,
            fontOutline        = "OUTLINE",
            titleSizeDelta     = 0,
            textShadow         = false,
            textShadowColor    = { r = 0, g = 0, b = 0, a = 1 },
            textShadowStrength = 2,

            scenarioTextShadow         = true,
            scenarioTextShadowColor    = { r = 0, g = 0, b = 0, a = 1 },
            scenarioTextShadowStrength = 1,
            scenarioTextAlign          = "CENTER",
            scenarioTextSizeDelta      = 0,
            scenarioFontSize           = 13,

            blockSpacing         = 2,
            lineSpacing          = 0,
            headerSpacing        = 0,

            blockLayout          = "classic",
            cardColor            = { r = 0.09, g = 0.10, b = 0.12, a = 0.73 },
            cardBorderColor      = { r = 0.00, g = 0.00, b = 0.00, a = 0.45 },
            cardBorderSize       = 1,
            cardPadding          = 6,
            cardTintByType       = false,
            cardTintCampaign     = { r = 0.20, g = 0.14, b = 0.04, a = 0.80 },
            cardTintLegendary    = { r = 0.24, g = 0.12, b = 0.01, a = 0.80 },
            cardTintDungeon      = { r = 0.02, g = 0.11, b = 0.20, a = 0.80 },
            cardTintRaid         = { r = 0.02, g = 0.15, b = 0.03, a = 0.80 },

            showBackground     = false,
            backgroundColor    = { r = 0, g = 0, b = 0, a = 0.6 },
            showBorder         = false,
            borderColor        = { r = 0.635, g = 0.000, b = 0.039, a = 1 },
            borderSize         = 1,

            headerColor        = { r = 0.93, g = 0.32, b = 0.10, a = 1 },
            headerDividerColor = { r = 0.92, g = 0.72, b = 0.02, a = 0.85 },
            headerSizeDelta    = 4,
            headerColorUseClass = false,

            headerBar            = false,
            headerBarColor       = { r = 0.80, g = 0.60, b = 0.20, a = 0.85 },
            headerBarHeight      = 22,
            headerBarStyle       = 1,
            headerBarSoftEdges   = false,
            headerBarSoftEdgeStrength = 10,

            scrollBarBg          = true,
            scrollBarBgColor     = { r = 0.60, g = 0.60, b = 0.65, a = 0.25 },
            hideScrollBar        = false,
            skinScrollBar        = false,
            scrollBarThumbColor  = { r = 0.60, g = 0.60, b = 0.65, a = 0.90 },
            scrollBarThumbWidth  = 8,
            hideScrollArrows     = false,
            showZoneTag          = false,
            showObjectiveNumbers = true,
            showQuestTotal       = true,
            showItemButtons       = true,
            showQuestPopups       = true,
            colorByDifficulty     = true,
            titleColorUseClass    = false,
            overrideCompleteGreen = true,
            -- Left unset on purpose: nil is what makes titles fall through to difficulty
            -- colouring, so AceDB must not seed a default the Clear button cannot restore.
            titleColorOverride    = nil,

            filters = {
                showNormal      = true,
                showDaily       = true,
                showWeekly      = true,
                showCampaign    = true,
                showWorld       = true,
                showBonus       = true,
                onlyCurrentZone = false,
            },

            -- positionInScreenUnits is deliberately NOT defaulted here, and must never be.
            -- Its ABSENCE is what marks a profile whose xOffset and yOffset predate the
            -- units change above, and Core/Migrate.lua converts on that. Give it a default
            -- and every unconverted profile silently reads as already converted.

            -- sectionOrder is deliberately NOT defaulted here, and must never be. AceDB
            -- merges an array default per index and strips matching indices at logout, so a
            -- saved order returns as a sparse fragment and any later change to the default's
            -- shape silently reinterprets it. Sections.DEFAULT_ORDER holds it instead.
            sectionsHidden = {},

            showZoneProgressBar  = false,
            zoneProgressLocation = "floating",
            zoneProgressBar = {
                point = "CENTER", relPoint = "CENTER", x = 0, y = 220,
                scale = 1.0,
                locked = false,
                showBorder = true,
                showBackground = true,
            },

            scenarioBonusHUD = {
                enabled = false,
                point = "CENTER", relPoint = "CENTER", x = 0, y = -120,
                scale = 1.0,
                locked = false,
                showBorder = true,
                showBackground = true,
            },

            autoListZoneWorldQuests      = false,
            worldQuestsPosition          = "bottom",
            worldQuestsPinnedMaxFraction = 0.40,
            worldQuestsHeightOverride    = false,
            worldQuestsHeight            = 120,
        },
    },
    char = {
        sectionsCollapsed  = {},
        hidden             = {},
        trackedWorldQuests = {},
    },
    global = {
        schemaVersion = 1,
    },
}

function DB:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("EQObjectiveTrackerDB", self.defaults, true)
    ns.db = self.db

    local Migrate = ns:GetModule("Migrate")
    if Migrate and Migrate.Run then Migrate:Run(self.db) end
end

function DB:Profile()
    return self.db and self.db.profile
end

function DB:Tracker()
    return self.db and self.db.profile and self.db.profile.tracker
end

function DB:General()
    return self.db and self.db.profile and self.db.profile.general
end

function DB:Char()
    return self.db and self.db.char
end
