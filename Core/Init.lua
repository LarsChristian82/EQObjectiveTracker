local addonName, ns = ...

_G.EQObjectiveTracker = ns
ns.NAME    = addonName
ns.VERSION = "0.2.0"

ns.modules     = {}
ns.moduleOrder = {}

function ns:RegisterModule(name, tbl)
    if self.modules[name] then
        error(("EQOT: module %q already registered"):format(name))
    end
    tbl = tbl or {}
    self.modules[name] = tbl
    self.moduleOrder[#self.moduleOrder + 1] = name
    return tbl
end

function ns:GetModule(name)
    return self.modules[name]
end

function ns:Print(...)
    print("|cffEBB706EQObjectiveTracker|r:", ...)
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function()
    for _, name in ipairs(ns.moduleOrder) do
        local m = ns.modules[name]
        if m.OnInitialize then xpcall(m.OnInitialize, geterrorhandler(), m) end
    end
    for _, name in ipairs(ns.moduleOrder) do
        local m = ns.modules[name]
        if m.OnEnable then xpcall(m.OnEnable, geterrorhandler(), m) end
    end
end)
