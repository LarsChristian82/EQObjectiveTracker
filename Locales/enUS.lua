-- Locales/enUS.lua
-- Default locale + source-of-truth phrase list for EQ Objective Tracker.
--
-- ns.L["English string"] returns the localized text for the player's client
-- (per GetLocale()), or the English string itself when no translation exists
-- (the metatable __index below). So EVERY wrapped string is safe to use even
-- with zero translations loaded. Untranslated text simply renders in English.
--
-- Translations are bundled directly in the other Locales/*.lua files as
-- L["key"] = "value" lines, NOT fetched through an @localization@ packager
-- token. That token fails the CurseForge build with errorCode 1002 on a project
-- without localization enabled, so it must never be added here.
--
-- Pattern: the English string IS the key (no semantic IDs). Keep keys in sync
-- with the code. If you reword an English string, update it here too or the
-- existing translation orphans (and the new text falls back to English).
--
-- GENERATED FILE: produced by docs/_gen_enus.py from the L[...] usages in the
-- code. Do not hand-edit. Re-run the generator after an extraction pass.


local _, ns = ...

ns.L = setmetatable({}, { __index = function(_, k) return k end })
local L = ns.L

-- Options/TabGeneral.lua
L["Zone"] = true
L["Title"] = true
L["Status"] = true
L["Level"] = true
L["Distance"] = true
L["Recent"] = true
L["Manual"] = true
L["Group by the quest log heading."] = true
L["Alphabetical by name."] = true
L["Ready to turn in first."] = true
L["Lowest quest level first."] = true
L["Nearest objective first. Updates as you move."] = true
L["Most recently accepted first."] = true
L["Drag and drop the quests in the tracker to reorder them however you like."] = true
L["General"] = true
L["Tracker window"] = true
L["Lock tracker"] = true
L["Stops the tracker being dragged or resized. The corner grip is hidden while locked."] = true
L["Reset position and size"] = true
L["Returns the tracker to its default position and size."] = true
L["Keep focused quest after relog"] = true
L["Restores the waypoint arrow."] = true
L["Hide tracker in combat"] = true
L["Hides the tracker while you are in combat and brings it back when you leave."] = true
L["Hide tracker in instances"] = true
L["Raids, dungeons, delves."] = true
L["Hide tracker when world map is open"] = true
L["Hides the tracker while the world map is up, so it does not sit over the map."] = true
L["Hide tracker in Mythic+"] = true
L["Hides the tracker during an active Mythic+ run, then brings it back when the run ends."] = true
L["Auto-track accepted quests"] = true
L["Matches Blizzard's default."] = true
L["Show Options icon on the tracker"] = true
L["A small cogwheel at the top-right of the tracker that opens the options panel."] = true
L["Split quest click"] = true
L["Click the icon to focus, click the title to open the quest log."] = true
L["What to show"] = true
L["Only show tracked quests"] = true
L["Hide quests you have not clicked to track in the quest log. Turn this off to see your whole log."] = true
L["Show count beside section headers"] = true
L["Show visible out of total, for example 13/22, instead of just the visible count."] = true
L["Show usable quest item buttons"] = true
L["Puts a button on the tracker row of any quest that carries a usable item, so you can use it without opening your bags."] = true
L["Show Quest Discovered popups"] = true
L["Boxes for newly discovered / completed quests."] = true
L["Objective text"] = true
L["Simplify objectives"] = true
L["Show only the first unfinished objective on each entry instead of the full list."] = true
L["Simplify tracked achievements"] = true
L["Show only incomplete criteria for tracked achievements."] = true
L["Show zone under title"] = true
L["Adds the quest log grouping under each title. Note this is the log heading, which is often a category such as Dungeon rather than a zone."] = true
L["Show objective numbers"] = true
L["Keep the leading count, for example 3/10, at the start of each objective."] = true
L["Show quest level prefix"] = true
L["For example, [60] Title."] = true
L["Show quest ID"] = true
L["Useful for bug reports."] = true
L["Show NEW tag on recently accepted quests"] = true
L["For about an hour after accepting."] = true
L["Quest Sound"] = true
L["Plays when a quest is ready to turn in."] = true
L["Quest Complete Sound"] = true
L["Which sound plays when a quest becomes ready to turn in."] = true
L["Zone Progress Bar"] = true
L["Show zone progress bar"] = true
L["Approximate questline progress."] = true
L["Float as a movable bar"] = true
L["Drag to move; right-click to lock or reset."] = true
L["Scenario Bonus Objectives"] = true
L["Show bonus objectives HUD"] = true
L["Shows a small movable checklist of the extra bonus objectives that appear during some scenarios and delves, so you do not miss their rewards. Drag to move, right-click to lock or reset. Off by default."] = true
L["HUD Scale"] = true
L["Sizes the bonus objectives HUD."] = true
L["Sorting"] = true
L["Sort: %s"] = true
L["Click to cycle. Sorting applies within each section."] = true
L["Profiles"] = true
L["Active profile"] = true
L["Switching profiles reloads the UI. Profiles are shared across characters, so use them to keep different setups such as raid and solo."] = true
L["New Profile"] = true
L["Profile name:"] = true
L["Create"] = true
L["Cancel"] = true
L["Overwrite profile?"] = true
L["A profile named \"%s\" already exists. Overwrite it with a copy of your current settings?"] = true
L["Overwrite"] = true
L["Prompts for a name, then creates a profile holding a copy of your current settings and switches to it."] = true
L["Reset all settings"] = true
L["Reset every EQ Objective Tracker setting to defaults?"] = true
L["Reset"] = true
L["Restores every setting on every tab to its default. Only the active profile is affected."] = true

-- Options/TabSections.lua
L["Top"] = true
L["Bottom"] = true
L["Sections"] = true
L["Reorder the tracker's sections. A section only shows while it has something in it."] = true
L["Hide this section entirely, even when it has entries."] = true
L["World Quests"] = true
L["Pinned to its own capped area, so it is not in the list above."] = true
L["Show %s"] = true
L["List every world quest in your zone"] = true
L["Shows every world quest on your current map without having to track each one. Only the map you are standing on, not the whole continent."] = true
L["Position"] = true
L["Whether the world quest area sits above or below the scrolling quest list."] = true
L["Maximum height"] = true
L["The most of the tracker the world quest area may take. Quest sections are given their space first, so this is a ceiling rather than a reservation."] = true
L["Set a custom height"] = true
L["By default the world quest area shares space with the quest list and gets squeezed when you have a lot of quests. Turn this on to give it a fixed height instead."] = true
L["Custom height"] = true
L["Fixed height for the world quest area. Only used while Set a custom height is on."] = true
L["Show quest types"] = true
L["Show or hide %s entries in the tracker."] = true
L["This zone only"] = true
L["Only show entries with an objective on your current map. Entries whose provider cannot tell are always shown."] = true

-- Options/TabAppearance.lua
L["None"] = true
L["Plain"] = true
L["Card"] = true
L["Horizontal"] = true
L["Vertical"] = true
L["Left"] = true
L["Center"] = true
L["Right"] = true
L["Same as tracker font"] = true
L["Appearance"] = true
L["Text"] = true
L["Font"] = true
L["Fonts registered through LibSharedMedia, so anything from ElvUI or SharedMedia appears here too."] = true
L["Font Size"] = true
L["Base size for objective text. Titles and headers offset from this."] = true
L["Outline"] = true
L["Outlines keep small text legible over bright terrain."] = true
L["Title Size Offset"] = true
L["Size difference between quest titles and their objective lines."] = true
L["Text Shadow"] = true
L["Drop shadow behind all tracker text. Helps a lot without an outline."] = true
L["Shadow Color"] = true
L["Shadow color and opacity."] = true
L["Shadow distance"] = true
L["How far the shadow is offset from the text."] = true
L["Scenario"] = true
L["Draws a drop shadow behind the scenario and delve banner text, the Stage and name lines. This is SEPARATE from the Text Shadow above, which affects only the quest and objective text - the banner is styled on its own."] = true
L["Color and opacity of the banner's drop shadow."] = true
L["How far the banner's drop shadow is cast. Only used while the Scenario Text Shadow above is on."] = true
L["Banner Alignment"] = true
L["Positions the scenario / delve banner within the tracker. Left lines it up with the quest text, Center keeps it centered (the default), and Right pushes it to the tracker's right edge."] = true
L["Banner Text Size"] = true
L["Grows or shrinks the scenario / delve banner's Stage and name text. 0 is the default size. The banner artwork is a fixed size, so large values may overflow it."] = true
L["Criteria Text Size"] = true
L["Sizes the scenario and delve objective lines under the banner, separately from the Banner Text Size above."] = true
L["Title colors"] = true
L["Color titles by difficulty"] = true
L["Tints each title by how hard the quest is for your level, the same way the quest log does. Turn it off for plain gold titles."] = true
L["Title color override"] = true
L["Forces every title to one color. Clear it to go back to difficulty coloring, or to plain gold when that is off."] = true
L["Use class color for titles"] = true
L["Colors titles with the class color of the character you are logged in on. Wins over the override above while it is on."] = true
L["Use title color when complete"] = true
L["Completed entries and finished objectives use your title color instead of green. Does nothing until a color override or class color is set, since it needs a color to use."] = true
L["Size and spacing"] = true
L["Tracker Scale"] = true
L["Scales the whole tracker. Takes effect immediately out of combat."] = true
L["Space between entries"] = true
L["Vertical gap between each entry and between sections."] = true
L["Space between objective lines"] = true
L["Extra spacing between the objective lines within one entry."] = true
L["Space under titles"] = true
L["Gap between an entry's title and its first objective line."] = true
L["Entry rows"] = true
L["Row Layout"] = true
L["Plain draws text straight on the tracker background. Card gives every entry its own panel, which makes long lists easier to tell apart."] = true
L["Card background color"] = true
L["Fill behind each card. Only used while Row Layout is Card."] = true
L["Card border color"] = true
L["Outline around each card. Only used while Row Layout is Card."] = true
L["Card border thickness"] = true
L["0 hides the outline and leaves just the fill."] = true
L["Card Padding"] = true
L["Breathing room between a card's edge and the text inside it. Larger values make taller cards."] = true
L["Tint cards by type"] = true
L["Gives campaign, legendary, dungeon and raid entries their own card color. Anything else uses the plain background color above."] = true
L["Campaign tint"] = true
L["Card color for campaign entries. Needs Tint cards by type switched on."] = true
L["Legendary tint"] = true
L["Card color for legendary entries. Needs Tint cards by type switched on."] = true
L["Dungeon tint"] = true
L["Card color for dungeon entries. Needs Tint cards by type switched on."] = true
L["Raid tint"] = true
L["Card color for raid entries. Needs Tint cards by type switched on."] = true
L["Section headers"] = true
L["Header Color"] = true
L["Color of the Quests, Campaign and World Quests headings."] = true
L["Use class color for headers"] = true
L["Colors the section headings with your character's class color. Wins over the Header Color above while it is on."] = true
L["Header divider color"] = true
L["The thin rule under each section heading."] = true
L["Header Size Offset"] = true
L["Size difference between section headings and objective text."] = true
L["Header bar"] = true
L["Draws a colored gradient bar behind each section heading, for a look closer to the default Blizzard tracker."] = true
L["Bar Color"] = true
L["Brightest end of the bar gradient. The other end is the same color darkened."] = true
L["Bar Style"] = true
L["Horizontal runs bright on the left to dark on the right. Vertical runs bright at the top to dark at the bottom."] = true
L["Bar Height"] = true
L["The bar is centered on the heading row, so larger values fill more of it."] = true
L["Soft bar edges"] = true
L["Feathers the top, left and right edges so the bar blends into the UI instead of sitting in a hard box. The bottom stays flush with the divider line."] = true
L["Edge Softness"] = true
L["Higher is softer. Only applies while Soft bar edges is on."] = true
L["Scroll bar"] = true
L["Hide scroll bar"] = true
L["Removes the scroll bar entirely and gives its gutter back to the text. The tracker still scrolls with the mouse wheel."] = true
L["Scroll Bar Background"] = true
L["Draws a track behind the scroll bar so it stays visible over bright terrain."] = true
L["Scroll Bar Color"] = true
L["Color and opacity of the scroll bar track."] = true
L["Solid color thumb"] = true
L["Replaces the textured draggable block with a flat single color one. Turning this off restores the stock Blizzard look."] = true
L["Thumb Color"] = true
L["Color and opacity of the draggable block. Only used while Solid color thumb is on."] = true
L["Thumb Width"] = true
L["How wide the draggable block is. Only used while Solid color thumb is on."] = true
L["Hide scroll bar arrows"] = true
L["Hides the up and down buttons at the ends of the bar. It still scrolls by dragging the thumb or using the mouse wheel."] = true
L["Frame"] = true
L["Show background"] = true
L["Fills the tracker behind the text. Useful over bright terrain."] = true
L["Background Color"] = true
L["Background color and opacity."] = true
L["Show border"] = true
L["Draws a border around the tracker."] = true
L["Border Color"] = true
L["Border color and opacity."] = true
L["Border Thickness"] = true
L["Border thickness in pixels."] = true
L["Zone Bar Appearance"] = true
L["Bar Texture"] = true
L["Fill texture for the zone progress bar. Textures registered through LibSharedMedia, so anything from ElvUI, SharedMedia or Details appears here too."] = true
L["Fill color and opacity of the bar itself."] = true
L["Scale"] = true
L["Size of the floating bar. The docked section follows the tracker's own scale instead."] = true
L["Font for the floating bar's zone name, count and percentage. The docked section uses the tracker font."] = true
L["Zone name color"] = true
L["Color of the zone name on the floating bar. The docked section uses the section header color."] = true
L["Count Color"] = true
L["Color of the completed-of-total count on the floating bar."] = true
L["Fills the floating bar behind its text. It fades slightly once the bar is locked."] = true
L["Draws a border around the floating bar."] = true
L["Border color and opacity for the floating bar."] = true

-- Options/TabAbout.lua
L["Open this window"] = true
L["Lock moving and resizing"] = true
L["Unlock moving and resizing"] = true
L["Restore the default position and size"] = true
L["Show or hide the tracker"] = true
L["Print provider status to chat"] = true
L["Toggle entry validation warnings"] = true
L["About"] = true
L["Version %s"] = true
L["by Wheelbarrel00"] = true
L["A standalone replacement for the default objective tracker. It does not require Everything Quests, and never will."] = true
L["Commands"] = true
L["Content providers"] = true
L["Providers are gated at load time by which TOC file your game flavor used. A provider that is not listed was never loaded."] = true

-- Options/Frame.lua
L["Clear"] = true

-- Core/Migrate.lua
L["imported %d settings from Everything Quests."] = true

-- Data/Filter.lua
L["World quests"] = true
L["Bonus Objectives"] = true
L["Campaign"] = true
L["Daily"] = true
L["Weekly"] = true
L["Normal"] = true

-- Data/Providers/Achievements.lua
L["Left-click to open, right-click to untrack."] = true

-- Data/Providers/Professions.lua
L["%s (Recraft)"] = true
L["Left-click to open the recipe, right-click to untrack."] = true

-- Data/Providers/Quests.lua
L["Left-click to super-track, right-click to untrack."] = true

-- Data/Providers/Scenarios.lua
L["Ritual Site"] = true
L["Delves"] = true
L["Mythic+"] = true
L["Dungeon"] = true
L["Warfront"] = true
L["Proving Grounds"] = true
L["Follower Dungeon"] = true
L["Void Incursion"] = true
L["Raid"] = true
L["Battleground"] = true
L["Arena"] = true
L["Stage %d of %d"] = true

-- Data/Providers/WorldQuests.lua
L["Ready to turn in"] = true
L["%s remaining"] = true

-- Data/QuestRewards.lua
L["Head"] = true
L["Neck"] = true
L["Shoulder"] = true
L["Back"] = true
L["Chest"] = true
L["Waist"] = true
L["Legs"] = true
L["Feet"] = true
L["Wrist"] = true
L["Hands"] = true
L["Finger"] = true
L["Trinket"] = true
L["Weapon"] = true
L["Two-Hand"] = true
L["Main Hand"] = true
L["Off Hand"] = true
L["Ranged"] = true

-- Data/ScenarioBonus.lua
L["Delve Bonus Loot"] = true
L["Nemesis Strongbox: %d/%d packs"] = true
L["Sanctified Banner: Grand Spoils earned"] = true
L["Sanctified Banner: bonus Spoils secured"] = true
L["Sanctified Banner: kill the Voidfused Rager"] = true
L["Sanctified Banner: find it for bonus loot"] = true

-- UI/AutoQuestPopup.lua
L["Click to view quest"] = true
L["Quest Complete!"] = true
L["Quest Discovered!"] = true

-- UI/Commands.lua
L["tracker locked."] = true
L["tracker unlocked."] = true
L["position and size reset."] = true
L["no Everything Quests configuration found to import."] = true
L["Import from Everything Quests"] = true
L["Reset this profile to defaults and replace it with your Everything Quests tracker settings?\n\nThis cannot be undone. Make a new profile first if you want to keep the current one."] = true
L["Import"] = true
L["commands:"] = true

-- UI/Dialog.lua
L["OK"] = true

-- UI/RewardTooltip.lua
L["Equip \226\128\148 empty slot"] = true
L["Equipped: ilvl %d"] = true
L["+%d ilvl upgrade"] = true
L["%d ilvl lower"] = true
L["Same item level"] = true
L["ilvl %d"] = true
L["%d XP"] = true
L["Choose one:"] = true

-- UI/Row.lua
L["Find Group"] = true
L["Open the Premade Group Finder for this quest."] = true

-- UI/Scenario.lua
L["Final Stage"] = true
L["Stage %d"] = true

-- UI/ScenarioBonusHUD.lua
L["Unlock (allow moving)"] = true
L["Lock position"] = true
L["Reset position"] = true

-- UI/Sections.lua
L["Zone Progress"] = true
L["Quests"] = true
L["Achievements"] = true
L["Endeavors"] = true
L["Profession"] = true

-- UI/Tracker.lua
L["Tracker locked"] = true
L["Use /eqot unlock to move it."] = true
L["Drag to move, corner grip to resize."] = true
L["/eqot for options"] = true
L["Open the options panel"] = true
L["a visibility rule is keeping the tracker hidden - see /eqot, General."] = true

-- Convert the `true` sentinels to their key (the self-keyed English default).
for k, v in pairs(L) do if v == true then L[k] = k end end
