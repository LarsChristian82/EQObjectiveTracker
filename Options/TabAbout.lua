local _, ns = ...

local Options = ns:GetModule("Options")

local COMMANDS = {
    { "/eqot",          "Open this window" },
    { "/eqot lock",     "Lock moving and resizing" },
    { "/eqot unlock",   "Unlock moving and resizing" },
    { "/eqot reset",    "Restore the default position and size" },
    { "/eqot toggle",   "Show or hide the tracker" },
    { "/eqot status",   "Print provider status to chat" },
    { "/eqot debug",    "Toggle entry validation warnings" },
}

Options:RegisterTab({
    id    = "about",
    title = "About",
    order = 90,
    build = function(self, content)
        self:CreateHeading(content, "EQ Objective Tracker")
        self:CreateLabel(content, "Version " .. ns.VERSION .. " by Wheelbarrel00")
        self:CreateLabel(content,
            "A standalone replacement for the default objective tracker. It does not require Everything Quests, and never will.",
            0.6, 0.6, 0.6)

        self:CreateHeading(content, "Commands")
        for i = 1, #COMMANDS do
            self:CreateLabel(content,
                ("|cffEBB706%s|r  %s"):format(COMMANDS[i][1], COMMANDS[i][2]))
        end

        self:CreateHeading(content, "Content providers")
        self:CreateLabel(content,
            "Providers are gated at load time by which TOC file your game flavor used. A provider that is not listed was never loaded.",
            0.6, 0.6, 0.6)

        content._providerLines = {}
        local Registry = ns:GetModule("Registry")
        for _, p in ipairs(Registry:Active()) do
            content._providerLines[p.id] = self:CreateLabel(content, p.id)
        end
    end,

    -- Live, because "is the provider empty or is the section not rendering" is the
    -- first question asked whenever something does not appear
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
