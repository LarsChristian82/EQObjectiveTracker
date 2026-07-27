local _, ns = ...

local Migrate = ns:RegisterModule("Migrate", {})

Migrate.CURRENT_SCHEMA = 1

-- The EQ config import lands here, still unimplemented. Read the EverythingQuestsDB
-- global directly and never probe for an EQ addon table - EQ declares a dependency on
-- EQOT, so EQOT loads first and any EQ table would always be nil at this point.
function Migrate:Run(db)
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
