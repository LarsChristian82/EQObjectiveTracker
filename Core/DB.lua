local _, ns = ...

local DB = ns:RegisterModule("DB", {})

-- Key names under profile.tracker and profile.general are deliberately identical to
-- Everything Quests so the future EQ config import stays a filtered table copy rather
-- than a semantic translation. Do not rename these for taste.
DB.defaults = {
    profile = {
        general = {
            lockTracker  = false,
            hideInCombat = false,
        },
        tracker = {
            anchor        = "TOPRIGHT",
            relativePoint = "TOPRIGHT",
            xOffset       = -85,
            yOffset       = -200,
            width         = 305,
            maxHeight     = 600,
            scale         = 1.0,

            showOnlyWatched      = true,
            sortMode             = "zone",
            simplifyMode         = false,

            font               = "GothamXNarrow Black",
            fontSize           = 15,
            fontOutline        = "OUTLINE",
            titleSizeDelta     = 0,
            textShadow         = false,
            textShadowColor    = { r = 0, g = 0, b = 0, a = 1 },
            textShadowStrength = 2,

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

            sectionOrder  = { "campaign", "quests", "worldquests" },
            sectionsHidden = {},
        },
    },
    char = {
        sectionsCollapsed = {},
        hidden            = {},
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
