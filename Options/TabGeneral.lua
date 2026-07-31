local _, ns = ...

local Options = ns:GetModule("Options")

local SORT_ORDER = { "zone", "title", "status", "level", "recent" }
local SORT_DESC  = {
    zone   = "Group by the quest log heading.",
    title  = "Alphabetical by name.",
    status = "Ready to turn in first.",
    level  = "Lowest quest level first.",
    recent = "Most recently accepted first.",
}

Options:RegisterTab({
    id    = "general",
    title = "General",
    order = 10,
    build = function(self, content)
        local DB = ns:GetModule("DB")

        self:CreateHeading(content, "Tracker window")

        self:CreateCheckbox(content, "Lock tracker",
            function() return DB:General().lockTracker end,
            function(v)
                DB:General().lockTracker = v
                ns:GetModule("Tracker"):ApplyLockState()
            end,
            "Stops the tracker being dragged or resized. The corner grip is hidden while locked.")

        self:CreateButton(content, "Reset position and size", 190, function()
            ns:GetModule("Tracker"):ResetPosition()
        end, "Returns the tracker to its default position and size.")

        self:CreateCheckbox(content, "Keep focused quest after relog",
            function() return DB:General().restoreSuperTrackOnLogin ~= false end,
            function(v) DB:General().restoreSuperTrackOnLogin = v end,
            "Restores the waypoint arrow.")

        local function hideRule(key, label, tooltip)
            self:CreateCheckbox(content, label,
                function() return DB:General()[key] end,
                function(v)
                    DB:General()[key] = v
                    ns:GetModule("Visibility"):Apply()
                end,
                tooltip)
        end

        hideRule("hideInCombat", "Hide tracker in combat",
            "Hides the tracker while you are in combat and brings it back when you leave.")
        hideRule("hideInInstances", "Hide tracker in instances",
            "Raids, dungeons, delves.")
        hideRule("hideOnMapOpen", "Hide tracker when world map is open",
            "Hides the tracker while the world map is up, so it does not sit over the map.")
        -- No Mythic+ API on this client, so the toggle could never fire
        if ns.Has.MythicPlus then
            hideRule("hideInMythicPlus", "Hide tracker in Mythic+",
                "Hides the tracker during an active Mythic+ run, then brings it back when the run ends.")
        end

        self:CreateCheckbox(content, "Auto-track accepted quests",
            function() return DB:General().autoTrackAccepted ~= false end,
            function(v) DB:General().autoTrackAccepted = v end,
            "Matches Blizzard's default.")

        self:CreateHeading(content, "What to show")

        self:CreateCheckbox(content, "Only show tracked quests",
            function() return DB:Tracker().showOnlyWatched end,
            function(v) DB:Tracker().showOnlyWatched = v end,
            "Hide quests you have not clicked to track in the quest log. Turn this off to see your whole log.")

        self:CreateCheckbox(content, "Show count beside section headers",
            function() return DB:Tracker().showQuestTotal ~= false end,
            function(v) DB:Tracker().showQuestTotal = v end,
            "Show visible out of total, for example 13/22, instead of just the visible count.")

        self:CreateCheckbox(content, "Show usable quest item buttons",
            function() return DB:Tracker().showItemButtons ~= false end,
            function(v)
                DB:Tracker().showItemButtons = v
                ns:GetModule("Row"):Invalidate()
            end,
            "Puts a button on the tracker row of any quest that carries a usable item, so you can use it without opening your bags.")

        self:CreateCheckbox(content, "Show Quest Discovered popups",
            function() return DB:Tracker().showQuestPopups ~= false end,
            function(v) DB:Tracker().showQuestPopups = v end,
            "Boxes for newly discovered / completed quests.")

        self:CreateHeading(content, "Objective text")

        self:CreateCheckbox(content, "Simplify objectives",
            function() return DB:Tracker().simplifyMode end,
            function(v)
                DB:Tracker().simplifyMode = v
                ns:GetModule("Row"):Invalidate()
            end,
            "Show only the first unfinished objective on each entry instead of the full list.")

        -- Stored per section behind the scenes, but only the achievements toggle is
        -- exposed - that is the one Everything Quests has, under the same label.
        self:CreateCheckbox(content, "Simplify tracked achievements",
            function()
                local t = DB:Tracker()
                return (t.simplifyGroups and t.simplifyGroups.achievements) and true or false
            end,
            function(v)
                local t = DB:Tracker()
                t.simplifyGroups = t.simplifyGroups or {}
                t.simplifyGroups.achievements = v or nil
                ns:GetModule("Row"):Invalidate()
            end,
            "Show only incomplete criteria for tracked achievements.")

        self:CreateCheckbox(content, "Show zone under title",
            function() return DB:Tracker().showZoneTag end,
            function(v)
                DB:Tracker().showZoneTag = v
                ns:GetModule("Row"):Invalidate()
            end,
            "Adds the quest log grouping under each title. Note this is the log heading, which is often a category such as Dungeon rather than a zone.")

        self:CreateCheckbox(content, "Show objective numbers",
            function() return DB:Tracker().showObjectiveNumbers ~= false end,
            function(v)
                DB:Tracker().showObjectiveNumbers = v
                ns:GetModule("Row"):Invalidate()
            end,
            "Keep the leading count, for example 3/10, at the start of each objective.")

        self:CreateHeading(content, "Quest Sound")

        self:CreateCheckbox(content, "Quest Sound",
            function() return DB:Tracker().questSoundEnabled ~= false end,
            function(v) DB:Tracker().questSoundEnabled = v end,
            "Plays when a quest is ready to turn in.")

        self:CreateDropdown(content, "Quest Complete Sound",
            function() return (ns:GetModule("Media"):GetSoundList()) end,
            function() return ns:GetModule("Media"):GetSoundLabel(DB:Tracker().questCompleteSound) end,
            function(label)
                local Media = ns:GetModule("Media")
                local _, values = Media:GetSoundList()
                local value = values[label] or "NONE"
                DB:Tracker().questCompleteSound = value
                local file = Media:GetSoundFile(value)
                if file and PlaySoundFile then PlaySoundFile(file, "Master") end
            end,
            "Which sound plays when a quest becomes ready to turn in.")

        self:CreateHeading(content, "Zone Progress Bar")

        self:CreateCheckbox(content, "Show zone progress bar",
            function() return DB:Tracker().showZoneProgressBar end,
            function(v) ns:GetModule("ZoneProgressBar"):SetEnabled(v) end,
            "Approximate questline progress.")

        self:CreateCheckbox(content, "Float as a movable bar",
            function()
                return (DB:Tracker().zoneProgressLocation or "floating") == "floating"
            end,
            function(v)
                ns:GetModule("ZoneProgressBar"):SetLocation(v and "floating" or "tracker")
            end,
            "Drag to move; right-click to lock or reset.")

        self:CreateHeading(content, "Sorting")

        local sortBtn
        local function sortLabel() return "Sort: " .. (DB:Tracker().sortMode or "zone") end
        sortBtn = self:CreateButton(content, sortLabel(), 190, function()
            local cur, idx = DB:Tracker().sortMode or "zone", 1
            for n = 1, #SORT_ORDER do if SORT_ORDER[n] == cur then idx = n break end end
            DB:Tracker().sortMode = SORT_ORDER[(idx % #SORT_ORDER) + 1]
            sortBtn:SetText(sortLabel())
            ns:GetModule("Tracker"):Render()
        end, "Click to cycle. Sorting applies within each section.")

        local desc = self:CreateLabel(content, "", 0.6, 0.6, 0.6)
        desc:SetText(SORT_DESC[DB:Tracker().sortMode or "zone"] or "")

        sortBtn:HookScript("OnClick", function()
            desc:SetText(SORT_DESC[DB:Tracker().sortMode or "zone"] or "")
        end)
    end,
})
