local _, ns = ...

local Migrate = ns:RegisterModule("Migrate", {})

Migrate.CURRENT_SCHEMA = 1

-- Gated per profile rather than on the account-wide schemaVersion: the offsets it rewrites
-- live under profile.tracker, so an account stamp would leave every other profile
-- unconverted. Runs before Tracker:BuildFrame, which reads the offsets.
local function normalizeTrackerPosition(db)
    local t = db and db.profile and db.profile.tracker
    if not t or t.positionInScreenUnits then return end

    local s = t.scale or 1
    if s > 0 and s ~= 1 then
        t.xOffset = math.floor((t.xOffset or 0) * s + 0.5)
        t.yOffset = math.floor((t.yOffset or 0) * s + 0.5)
    end
    t.positionInScreenUnits = true
end

-- The EQ config import lands here, still unimplemented. Read the EverythingQuestsDB
-- global directly and never probe for an EQ addon table - EQ declares a dependency on
-- EQOT, so EQOT loads first and any EQ table would always be nil at this point.
-- Every tracker key copies across by name except one: EQ's achievements-only
-- simplifyAchievements becomes simplifyGroups.achievements here.
function Migrate:Run(db)
    normalizeTrackerPosition(db)

    local g = db and db.global
    if not g then return end

    if not g.schemaVersion or g.schemaVersion < 1 then
        g.schemaVersion = 1
    end

    g.schemaVersion = self.CURRENT_SCHEMA
end

function Migrate:HasEQConfig()
    return type(_G.EverythingQuestsDB) == "table"
end
