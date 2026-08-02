local _, ns = ...

local Options = ns:GetModule("Options")
local L       = ns.L

local SORT_ORDER = { "zone", "title", "status", "level", "distance", "recent", "manual" }

-- Wrapped here rather than at the point of use: docs/_gen_enus.py extracts literal
-- L["..."] occurrences, so L[SORT_DESC[mode]] would keep working and silently never
-- reach the manifest. The stored value stays the lowercase id, so a profile written
-- in one locale still reads correctly in another.
local SORT_LABEL = {
    zone     = L["Zone"],
    title    = L["Title"],
    status   = L["Status"],
    level    = L["Level"],
    distance = L["Distance"],
    recent   = L["Recent"],
    manual   = L["Manual"],
}

local SORT_DESC  = {
    zone     = L["Group by the quest log heading."],
    title    = L["Alphabetical by name."],
    status   = L["Ready to turn in first."],
    level    = L["Lowest quest level first."],
    distance = L["Nearest objective first. Updates as you move."],
    recent   = L["Most recently accepted first."],
    manual   = L["Drag and drop the quests in the tracker to reorder them however you like."],
}

Options:RegisterTab({
    id    = "general",
    title = L["General"],
    order = 10,
    build = function(self, content)
        local DB = ns:GetModule("DB")

        self:CreateHeading(content, L["Tracker window"])

        self:CreateCheckbox(content, L["Lock tracker"],
            function() return DB:General().lockTracker end,
            function(v)
                DB:General().lockTracker = v
                ns:GetModule("Tracker"):ApplyLockState()
            end,
            L["Stops the tracker being dragged or resized. The corner grip is hidden while locked."])

        self:CreateButton(content, L["Reset position and size"], 190, function()
            ns:GetModule("Tracker"):ResetPosition()
        end, L["Returns the tracker to its default position and size."])

        self:CreateCheckbox(content, L["Keep focused quest after relog"],
            function() return DB:General().restoreSuperTrackOnLogin ~= false end,
            function(v) DB:General().restoreSuperTrackOnLogin = v end,
            L["Restores the waypoint arrow."])

        local function hideRule(key, label, tooltip)
            self:CreateCheckbox(content, label,
                function() return DB:General()[key] end,
                function(v)
                    DB:General()[key] = v
                    ns:GetModule("Visibility"):Apply()
                end,
                tooltip)
        end

        hideRule("hideInCombat", L["Hide tracker in combat"],
            L["Hides the tracker while you are in combat and brings it back when you leave."])
        hideRule("hideInInstances", L["Hide tracker in instances"],
            L["Raids, dungeons, delves."])
        hideRule("hideOnMapOpen", L["Hide tracker when world map is open"],
            L["Hides the tracker while the world map is up, so it does not sit over the map."])
        -- No Mythic+ API on this client, so the toggle could never fire
        if ns.Has.MythicPlus then
            hideRule("hideInMythicPlus", L["Hide tracker in Mythic+"],
                L["Hides the tracker during an active Mythic+ run, then brings it back when the run ends."])
        end

        self:CreateCheckbox(content, L["Auto-track accepted quests"],
            function() return DB:General().autoTrackAccepted ~= false end,
            function(v) DB:General().autoTrackAccepted = v end,
            L["Matches Blizzard's default."])

        self:CreateCheckbox(content, L["Show Options icon on the tracker"],
            function() return DB:Tracker().showOptionsIcon ~= false end,
            function(v)
                DB:Tracker().showOptionsIcon = v
                ns:GetModule("Tracker"):ApplyHeaderIcons()
            end,
            L["A small cogwheel at the top-right of the tracker that opens the options panel."])

        self:CreateCheckbox(content, L["Split quest click"],
            function() return DB:Tracker().splitQuestClick end,
            function(v) DB:Tracker().splitQuestClick = v end,
            L["Click the icon to focus, click the title to open the quest log."])

        self:CreateHeading(content, L["What to show"])

        self:CreateCheckbox(content, L["Only show tracked quests"],
            function() return DB:Tracker().showOnlyWatched end,
            function(v) DB:Tracker().showOnlyWatched = v end,
            L["Hide quests you have not clicked to track in the quest log. Turn this off to see your whole log."])

        self:CreateCheckbox(content, L["Show count beside section headers"],
            function() return DB:Tracker().showQuestTotal ~= false end,
            function(v) DB:Tracker().showQuestTotal = v end,
            L["Show visible out of total, for example 13/22, instead of just the visible count."])

        self:CreateCheckbox(content, L["Show usable quest item buttons"],
            function() return DB:Tracker().showItemButtons ~= false end,
            function(v)
                DB:Tracker().showItemButtons = v
                ns:GetModule("Row"):Invalidate()
            end,
            L["Puts a button on the tracker row of any quest that carries a usable item, so you can use it without opening your bags."])

        self:CreateCheckbox(content, L["Show Quest Discovered popups"],
            function() return DB:Tracker().showQuestPopups ~= false end,
            function(v) DB:Tracker().showQuestPopups = v end,
            L["Boxes for newly discovered / completed quests."])

        self:CreateHeading(content, L["Objective text"])

        self:CreateCheckbox(content, L["Simplify objectives"],
            function() return DB:Tracker().simplifyMode end,
            function(v)
                DB:Tracker().simplifyMode = v
                ns:GetModule("Row"):Invalidate()
            end,
            L["Show only the first unfinished objective on each entry instead of the full list."])

        -- Stored per section behind the scenes, but only the achievements toggle is
        -- exposed - that is the one Everything Quests has, under the same label.
        self:CreateCheckbox(content, L["Simplify tracked achievements"],
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
            L["Show only incomplete criteria for tracked achievements."])

        self:CreateCheckbox(content, L["Show zone under title"],
            function() return DB:Tracker().showZoneTag end,
            function(v)
                DB:Tracker().showZoneTag = v
                ns:GetModule("Row"):Invalidate()
            end,
            L["Adds the quest log grouping under each title. Note this is the log heading, which is often a category such as Dungeon rather than a zone."])

        self:CreateCheckbox(content, L["Show objective numbers"],
            function() return DB:Tracker().showObjectiveNumbers ~= false end,
            function(v)
                DB:Tracker().showObjectiveNumbers = v
                ns:GetModule("Row"):Invalidate()
            end,
            L["Keep the leading count, for example 3/10, at the start of each objective."])

        self:CreateCheckbox(content, L["Show quest level prefix"],
            function() return DB:Tracker().showLevelInTracker end,
            function(v)
                DB:Tracker().showLevelInTracker = v
                ns:GetModule("Row"):Invalidate()
            end,
            L["For example, [60] Title."])

        self:CreateCheckbox(content, L["Show quest ID"],
            function() return DB:Tracker().showQuestID end,
            function(v)
                DB:Tracker().showQuestID = v
                ns:GetModule("Row"):Invalidate()
            end,
            L["Useful for bug reports."])

        self:CreateCheckbox(content, L["Show NEW tag on recently accepted quests"],
            function() return DB:Tracker().showRecentlyAddedTag ~= false end,
            function(v)
                DB:Tracker().showRecentlyAddedTag = v
                ns:GetModule("Row"):Invalidate()
            end,
            L["For about an hour after accepting."])


        self:CreateHeading(content, L["Quest Sound"])

        self:CreateCheckbox(content, L["Quest Sound"],
            function() return DB:Tracker().questSoundEnabled ~= false end,
            function(v) DB:Tracker().questSoundEnabled = v end,
            L["Plays when a quest is ready to turn in."])

        self:CreateDropdown(content, L["Quest Complete Sound"],
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
            L["Which sound plays when a quest becomes ready to turn in."])

        self:CreateHeading(content, L["Zone Progress Bar"])

        self:CreateCheckbox(content, L["Show zone progress bar"],
            function() return DB:Tracker().showZoneProgressBar end,
            function(v) ns:GetModule("ZoneProgressBar"):SetEnabled(v) end,
            L["Approximate questline progress."])

        self:CreateCheckbox(content, L["Float as a movable bar"],
            function()
                return (DB:Tracker().zoneProgressLocation or "floating") == "floating"
            end,
            function(v)
                ns:GetModule("ZoneProgressBar"):SetLocation(v and "floating" or "tracker")
            end,
            L["Drag to move; right-click to lock or reset."])

        -- Gated so the controls are absent rather than dead on a flavor with no bonus steps
        if ns.Has.ScenarioBonus then
            self:CreateHeading(content, L["Scenario Bonus Objectives"])

            self:CreateCheckbox(content, L["Show bonus objectives HUD"],
                function()
                    local st = DB:Tracker().scenarioBonusHUD
                    return st and st.enabled
                end,
                function(v) ns:GetModule("ScenarioBonusHUD"):SetEnabled(v) end,
                L["Shows a small movable checklist of the extra bonus objectives that appear during some scenarios and delves, so you do not miss their rewards. Drag to move, right-click to lock or reset. Off by default."])

            self:CreateSlider(content, L["HUD Scale"], 0.5, 2.0, 0.05,
                function()
                    local st = DB:Tracker().scenarioBonusHUD
                    return (st and st.scale) or 1.0
                end,
                function(v) ns:GetModule("ScenarioBonusHUD"):SetScale(v) end,
                L["Sizes the bonus objectives HUD."])
        end

        self:CreateHeading(content, L["Sorting"])

        local sortBtn
        local function sortLabel()
            local mode = DB:Tracker().sortMode or "zone"
            return L["Sort: %s"]:format(SORT_LABEL[mode] or SORT_LABEL.zone)
        end
        local function sortDesc()
            return SORT_DESC[DB:Tracker().sortMode or "zone"] or ""
        end
        sortBtn = self:CreateButton(content, sortLabel(), 190, function()
            local cur, idx = DB:Tracker().sortMode or "zone", 1
            for n = 1, #SORT_ORDER do if SORT_ORDER[n] == cur then idx = n break end end
            DB:Tracker().sortMode = SORT_ORDER[(idx % #SORT_ORDER) + 1]
            sortBtn:SetText(sortLabel())
            ns:GetModule("Tracker"):Render()
        end, L["Click to cycle. Sorting applies within each section."])

        local desc = self:CreateLabel(content, "", 0.6, 0.6, 0.6)
        desc:SetText(sortDesc())

        sortBtn:HookScript("OnClick", function()
            desc:SetText(sortDesc())
        end)

        self:CreateHeading(content, L["Profiles"])

        -- CreateDropdown takes a flat list of strings and hands the picked string straight
        -- to the setter. EQ's dropdown takes {value=, label=} pairs - do not copy that shape.
        local function profileList()
            local out = {}
            if not (DB.db and DB.db.GetProfiles) then return out end
            for _, name in ipairs(DB.db:GetProfiles()) do
                out[#out + 1] = name
            end
            -- AceDB builds that list with pairs(), so its order is arbitrary and can differ
            -- between sessions with nothing having changed. EQ leaves it unsorted.
            table.sort(out)
            return out
        end

        local function currentProfile()
            return (DB.db and DB.db.GetCurrentProfile and DB.db:GetCurrentProfile()) or "Default"
        end

        local function profileExists(name)
            if not (DB.db and DB.db.GetProfiles) then return false end
            for _, p in ipairs(DB.db:GetProfiles()) do
                if p == name then return true end
            end
            return false
        end

        -- Every one of these reloads, exactly as EQ does. Migrate:Run only fires from
        -- DB:OnInitialize, so swapping a profile in place would leave it unconverted.
        local function setProfile(name)
            if not (DB.db and DB.db.SetProfile) then return end
            DB.db:SetProfile(name)
            ReloadUI()
        end

        local function createProfileCopiedFromCurrent(name)
            if not DB.db then return end
            local source = DB.db:GetCurrentProfile()
            DB.db:SetProfile(name)
            if source and source ~= name and DB.db.CopyProfile then
                DB.db:CopyProfile(source, true)
            end
            ReloadUI()
        end

        self:CreateDropdown(content, L["Active profile"], profileList, currentProfile, setProfile,
            L["Switching profiles reloads the UI. Profiles are shared across characters, so use them to keep different setups such as raid and solo."])

        self:CreateButton(content, L["New Profile"], 190, function()
            local Dialog = ns:GetModule("Dialog")
            if not Dialog then return end
            Dialog:Show({
                title      = L["New Profile"],
                text       = L["Profile name:"],
                hasEditBox = true,
                maxLetters = 32,
                button1    = L["Create"],
                button2    = L["Cancel"],
                onAccept = function(text)
                    local name = (text or ""):gsub("^%s+", ""):gsub("%s+$", "")
                    if name == "" then return end
                    if name ~= currentProfile() and profileExists(name) then
                        Dialog:Show({
                            title    = L["Overwrite profile?"],
                            text     = L["A profile named \"%s\" already exists. Overwrite it with a copy of your current settings?"]:format(name),
                            button1  = L["Overwrite"],
                            button2  = L["Cancel"],
                            onAccept = function() createProfileCopiedFromCurrent(name) end,
                        })
                    else
                        createProfileCopiedFromCurrent(name)
                    end
                end,
            })
        end, L["Prompts for a name, then creates a profile holding a copy of your current settings and switches to it."])

        self:CreateButton(content, L["Reset all settings"], 190, function()
            local Dialog = ns:GetModule("Dialog")
            if not Dialog then return end
            Dialog:Show({
                title    = "EQ Objective Tracker",
                text     = L["Reset every EQ Objective Tracker setting to defaults?"],
                button1  = L["Reset"],
                button2  = L["Cancel"],
                onAccept = function()
                    if DB.db and DB.db.ResetProfile then DB.db:ResetProfile() end
                    ReloadUI()
                end,
            })
        end, L["Restores every setting on every tab to its default. Only the active profile is affected."])
    end,
})
