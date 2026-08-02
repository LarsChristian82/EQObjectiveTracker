local _, ns = ...

local Options = ns:GetModule("Options")
local L       = ns.L

-- Slash tokens are never translated. Only the description beside each one is.
local COMMANDS = {
    { "/eqot",          L["Open this window"] },
    { "/eqot lock",     L["Lock moving and resizing"] },
    { "/eqot unlock",   L["Unlock moving and resizing"] },
    { "/eqot reset",    L["Restore the default position and size"] },
    { "/eqot toggle",   L["Show or hide the tracker"] },
    { "/eqot status",   L["Print provider status to chat"] },
    { "/eqot debug",    L["Toggle entry validation warnings"] },
}

Options:RegisterTab({
    id    = "about",
    title = L["About"],
    order = 90,
    build = function(self, content)
        self:CreateHeading(content, "EQ Objective Tracker")
        self:CreateLabel(content,
            L["Version %s"]:format(ns.VERSION) .. " " .. L["by Wheelbarrel00"])
        self:CreateLabel(content,
            L["A standalone replacement for the default objective tracker. It does not require Everything Quests, and never will."],
            0.6, 0.6, 0.6)

        self:CreateHeading(content, L["Commands"])
        for i = 1, #COMMANDS do
            self:CreateLabel(content,
                ("|cffEBB706%s|r  %s"):format(COMMANDS[i][1], COMMANDS[i][2]))
        end

        self:CreateHeading(content, L["Content providers"])
        self:CreateLabel(content,
            L["Providers are gated at load time by which TOC file your game flavor used. A provider that is not listed was never loaded."],
            0.6, 0.6, 0.6)

        content._providerLines = {}
        local Registry = ns:GetModule("Registry")
        for _, p in ipairs(Registry:Active()) do
            content._providerLines[p.id] = self:CreateLabel(content, p.id)
        end
    end,

    -- Live, because "is the provider empty or is the section not rendering" is the
    -- first question asked whenever something does not appear. Left untranslated with
    -- the rest of the diagnostic output - the counts are for bug reports, not reading.
    refresh = function(_, content)
        local Registry = ns:GetModule("Registry")
        for _, p in ipairs(Registry:Active()) do
            local fs = content._providerLines and content._providerLines[p.id]
            if fs then
                if not p._available then
                    fs:SetText(("|cff888888%-14s unavailable on this client|r"):format(p.id))
                else
                    local ok, entries = pcall(p.GetEntries, p)
                    local n = (ok and entries) and #entries or -1
                    fs:SetText(("|cff44ff44%-14s|r %d entries   |cff888888groups: %s|r")
                        :format(p.id, math.max(0, n), table.concat(p.groups, ", ")))
                end
            end
        end
    end,
})
