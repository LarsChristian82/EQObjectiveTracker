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
L["General"] = true
L["Lock tracker"] = true
L["Disable drag-to-move and resize."] = true
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
L["Keep focused quest after relog"] = true
L["Restores the waypoint arrow."] = true
L["Options Window Scale"] = true
L["Resizes this EQ Objective Tracker options window only. It does not change the quest tracker or anything shown in the game world. The new size applies when you let go of the slider."] = true
L["Reset position and size"] = true
L["Returns the tracker to its default position and size."] = true
L["Reset all settings"] = true
L["Reset every EQ Objective Tracker setting to defaults?"] = true
L["Reset"] = true
L["Cancel"] = true
L["Restores every setting on every tab to its default. Only the active profile is affected."] = true
L["Profiles"] = true
L["Switching profiles reloads the UI. Profiles are shared across characters; use them to keep different setups (e.g. raid vs solo). |cffEBB706New Profile|r prompts for a name and creates it on the spot."] = true
L["Active profile"] = true
L["New Profile"] = true
L["Profile name:"] = true
L["Create"] = true
L["Overwrite profile?"] = true
L["A profile named \"%s\" already exists. Overwrite it with a copy of your current settings?"] = true
L["Overwrite"] = true
L["Prompts for a name, then creates a profile holding a copy of your current settings and switches to it."] = true

-- Options/TabTracker.lua
L["Zone"] = true
L["Title"] = true
L["Status"] = true
L["Type"] = true
L["Level"] = true
L["Distance"] = true
L["Recent"] = true
L["Manual"] = true
L["Campaign section"] = true
L["Quests section"] = true
L["Profession section"] = true
L["Endeavors section"] = true
L["Achievements section"] = true
L["World Quests section"] = true
L["Top"] = true
L["Bottom"] = true
L["Move %s up"] = true
L["Move %s down"] = true
L["Reorders where this section sits in the tracker. A section only shows while it has something in it, so empty sections won't visibly move."] = true
L["Tracker"] = true
L["On-Screen Tracker"] = true
L["Changes apply immediately to the on-screen tracker."] = true
L["Show only watched quests"] = true
L["Matches Blizzard's default tracker."] = true
L["Simplify Mode"] = true
L["Show only the first incomplete objective per quest."] = true
L["Simplify tracked achievements"] = true
L["Show only incomplete criteria for tracked achievements."] = true
L["Sort Order"] = true
L["|cffaaaaaaDrag and drop the quests in the tracker to reorder them however you like.|r"] = true
L["Filters"] = true
L["Show or hide %s entries in the tracker."] = true
L["Show only quests in current zone"] = true
L["Only show entries with an objective on your current map. Entries whose provider cannot tell are always shown."] = true
L["Reset filters to defaults"] = true
L["Tracker Visibility"] = true
L["Hide this section entirely, even when it has entries."] = true
L["Auto-list current-zone world quests"] = true
L["Lists every WQ in your zone without tracking each."] = true
L["Set a custom World Quests height"] = true
L["By default the World Quests area shares space with your quest list and gets squeezed when you have a lot of quests. Turn this on to give it its own height, set by the slider below."] = true
L["World Quests height"] = true
L["Maximum height"] = true
L["The most of the tracker the world quest area may take. Quest sections are given their space first, so this is a ceiling rather than a reservation."] = true
L["Section Order"] = true
L["Rearrange the tracker's sections with the arrows below. A section only appears on the tracker while it has something in it, so reordering an empty section won't look like anything changed. World Quests scroll in their own panel and can only sit at the very top or bottom \226\128\148 use the Top/Bottom control."] = true
L["World Quests position"] = true
L["Where the World Quests panel sits on the tracker. |cffffffffTop|r puts it above your quests; |cffffffffBottom|r keeps it below your quests (the default). World Quests scroll in their own capped panel, which is why they can't be mixed in between the other sections."] = true
L["Options"] = true
L["Quest Title Color By Difficulty"] = true
L["Show quest level prefix"] = true
L["For example, [60] Title."] = true
L["Show zone label under quest titles"] = true
L["Show objective progress numbers"] = true
L["For example, 0/4, 1/1, etc."] = true
L["Show quest ID"] = true
L["Useful for bug reports."] = true
L["Show tracked / total on the Quests & Campaign headers"] = true
L["For example, 3/9."] = true
L["Show usable quest item buttons"] = true
L["Puts a button on the tracker row of any quest that carries a usable item, so you can use it without opening your bags."] = true
L["Show Options icon on the tracker"] = true
L["A small cogwheel at the top-right of the tracker that opens the options panel."] = true
L["Hide scroll bar"] = true
L["Scroll with the mouse wheel instead."] = true
L["Show Quest Discovered popups"] = true
L["Boxes for newly discovered / completed quests."] = true
L["Show NEW tag on recently accepted quests"] = true
L["For about an hour after accepting."] = true
L["Split quest click"] = true
L["Click the icon to focus, click the title to open the quest log."] = true
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

-- Options/TabAppearance.lua
L["None"] = true
L["Outline"] = true
L["Thick"] = true
L["Mono"] = true
L["Mono Outline"] = true
L["Mono Thick"] = true
L["Plain"] = true
L["Card"] = true
L["Header Bar 1"] = true
L["Header Bar 2"] = true
L["Left"] = true
L["Center"] = true
L["Right"] = true
L["Same as tracker font"] = true
L["Appearance"] = true
L["Font"] = true
L["Fonts registered through LibSharedMedia, so anything from ElvUI or SharedMedia appears here too."] = true
L["Font Size"] = true
L["Base size for objective text. Titles and headers offset from this."] = true
L["Title Size Offset"] = true
L["Sizes quest and achievement titles separately from the objective text. This value is added to the Font Size above: 0 keeps titles the same size as the base font, positive makes them larger, negative smaller."] = true
L["Header Size Offset"] = true
L["Sizes the section headers (Quests, Campaign, and so on) independently of the quest text. Added on top of the Font Size above: the default 4 keeps headers at their current size, lower shrinks them (handy on a low UI scale), higher enlarges them."] = true
L["Font Outline"] = true
L["Outlines keep small text legible over bright terrain."] = true
L["Text Shadow"] = true
L["Draws a soft drop-shadow behind all tracker text so it stays readable over bright or busy backgrounds. Use Shadow Color to tint it and Shadow Size to set how far it's cast."] = true
L["Shadow Color"] = true
L["Shadow color and opacity."] = true
L["Shadow Size"] = true
L["How far the text drop-shadow is cast behind the letters. Higher values give a larger, more pronounced shadow; lower values keep it tight. Only applies while Text Shadow is on."] = true
L["Scenario"] = true
L["Draws a drop-shadow behind the scenario / delve banner text (the Stage and name lines). This is SEPARATE from the Text Shadow above, which affects only the quest and objective text \226\128\148 the banner is styled on its own."] = true
L["Color and opacity of the banner's drop shadow."] = true
L["How far the scenario banner's drop-shadow is cast. Higher values give a larger, more pronounced shadow; lower values keep it tight. Only applies while the Scenario Text Shadow above is on."] = true
L["Banner Alignment"] = true
L["Positions the scenario / delve banner within the tracker. Left lines it up with the quest text, Center keeps it centered (the default), and Right pushes it to the tracker's right edge."] = true
L["Banner Text Size"] = true
L["Grows or shrinks the scenario / delve banner's Stage and name text. 0 is the default size. The banner artwork is a fixed size, so large values may overflow it."] = true
L["Criteria Text Size"] = true
L["Sizes the scenario / delve objective (criteria) lines shown under the banner, separately from the Banner Text Size above. Raise it if the criteria text looks small next to your quest and World Quest text."] = true
L["Tracker Skins"] = true
L["Scroll Bar Background"] = true
L["Draws a track behind the scroll bar so it stays visible over bright terrain."] = true
L["Scroll Bar Color"] = true
L["Color and opacity of the scroll bar track."] = true
L["Solid color thumb"] = true
L["Replaces the tracker scroll bar's textured thumb (the draggable block) with a flat single-colour block. Use the Thumb Color and Thumb Width controls to style it. Off restores the stock Blizzard bar."] = true
L["Thumb Color"] = true
L["Color and opacity of the draggable block. Only used while Solid color thumb is on."] = true
L["Thumb Width"] = true
L["How wide the draggable block is. Only used while Solid color thumb is on."] = true
L["Hide scroll bar arrows"] = true
L["Hides the up and down arrow buttons at the ends of the tracker scroll bar. The bar still scrolls by dragging the thumb or using the mouse wheel."] = true
L["Background"] = true
L["Fills the tracker behind the text. Useful over bright terrain."] = true
L["Background Color"] = true
L["Background color and opacity."] = true
L["Border"] = true
L["Draws a border around the tracker."] = true
L["Border Color"] = true
L["Border color and opacity."] = true
L["Border Thickness"] = true
L["Border thickness in pixels."] = true
L["Header Bar"] = true
L["Header bar"] = true
L["Draws a coloured gradient bar behind each section header (Quests, Campaign, World Quests, and so on), for a look closer to the default Blizzard tracker. Off by default."] = true
L["Bar Color"] = true
L["Brightest end of the bar gradient. The other end is the same color darkened."] = true
L["Bar Style"] = true
L["Header Bar 1 is a horizontal gradient (bright on the left, dark on the right). Header Bar 2 is a vertical gradient (bright at the top, dark at the bottom). Bar Color, Bar Height, and Soft edges all apply to whichever style you pick."] = true
L["Soft edges"] = true
L["Feathers the top, left, and right edges of the header bar so it blends into the UI instead of sitting in a hard box. The gradient colour is unchanged. Only applies while Header bar is on; off by default."] = true
L["Bar Height"] = true
L["How tall the section-header bar is. The bar is centred on the header row, so larger values fill more of it."] = true
L["Edge Softness"] = true
L["How soft the header bar's feathered edges are when Soft edges is on. Higher is softer; lower tightens toward a hard edge."] = true
L["Colors & Dimensions"] = true
L["Reset to Defaults"] = true
L["Reset all Appearance settings to defaults?"] = true
L["Quest Title Color Override"] = true
L["When cleared, falls back to difficulty coloring or default yellow."] = true
L["Clear"] = true
L["Use class color"] = true
L["Colors quest, achievement, and endeavor titles with the class color of the character you are currently logged in on. Overrides the color above while it is on. Off by default."] = true
L["Use title color for completed quests"] = true
L["Instead of green."] = true
L["Section Header Color"] = true
L["Color of the Quests, Campaign and World Quests headings."] = true
L["Colors the section headers (Quests, Campaign, and so on) with the class color of the character you are currently logged in on. Overrides the color above while it is on. Off by default."] = true
L["Divider Line Color"] = true
L["Sets the color of the thin line under each section header. Defaults to the original gold."] = true
L["Tracker Scale"] = true
L["Scales the whole tracker. Takes effect immediately out of combat."] = true
L["Block Spacing"] = true
L["Vertical gap between each entry and between sections."] = true
L["Line Spacing"] = true
L["Adds vertical space between a quest's objective lines, across the whole tracker. 0 keeps the default spacing."] = true
L["Header Spacing"] = true
L["Adds or removes space around section headers and beneath each quest's title. 0 keeps the default spacing."] = true
L["Quest Rows"] = true
L["Row Layout"] = true
L["How each quest is drawn in the tracker. |cffffffffPlain|r is the default look - text straight on the tracker background. |cffffffffCard|r gives every quest its own panel with a background and border, which makes long lists easier to read apart."] = true
L["Fill color behind each quest card. Only used while Row Layout is set to Card."] = true
L["Outline color around each quest card. Only used while Row Layout is set to Card."] = true
L["How thick the card outline is, in pixels. 0 hides the outline and leaves just the fill."] = true
L["Card Padding"] = true
L["Breathing room between a card's edge and the text inside it. Larger values make taller cards."] = true
L["Tint cards by quest type"] = true
L["Gives campaign, legendary, dungeon and raid entries their own card color. Anything else uses the plain background color above."] = true
L["Campaign"] = true
L["Card color for campaign entries. Needs Tint cards by quest type switched on."] = true
L["Legendary"] = true
L["Card color for legendary entries. Needs Tint cards by quest type switched on."] = true
L["Dungeon"] = true
L["Card color for dungeon entries. Needs Tint cards by quest type switched on."] = true
L["Raid"] = true
L["Card color for raid entries. Needs Tint cards by quest type switched on."] = true
L["Zone Bar Scale"] = true
L["Size of the floating bar. The docked section follows the tracker's own scale instead."] = true
L["Zone Bar Appearance"] = true
L["Fills the floating bar behind its text. It fades slightly once the bar is locked."] = true
L["Draws a border around the floating bar."] = true
L["Border color and opacity for the floating bar."] = true
L["Font for the floating bar's zone name, count and percentage. The docked section uses the tracker font."] = true
L["Bar Texture"] = true
L["Sets the fill texture of the zone progress bar. Textures added by other media addons (such as SharedMedia, ElvUI, or Details) appear here too."] = true
L["Fill color and opacity of the bar itself."] = true
L["Header Color"] = true
L["Color of the zone name on the floating bar. The docked section uses the section header color."] = true
L["Count Color"] = true
L["Color of the completed-of-total count on the floating bar."] = true

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

-- Core/Migrate.lua
L["imported %d settings from Everything Quests."] = true

-- Data/Filter.lua
L["World quests"] = true
L["Bonus Objectives"] = true
L["Campaign quests"] = true
L["Daily quests"] = true
L["Weekly quests"] = true
L["Normal quests"] = true

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
L["Warfront"] = true
L["Proving Grounds"] = true
L["Follower Dungeon"] = true
L["Void Incursion"] = true
L["Battleground"] = true
L["Arena"] = true
L["Stage %d of %d"] = true

-- Data/Providers/WorldQuests.lua
L["Ready to turn in"] = true
L["%s remaining"] = true

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
L["World Quests"] = true
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
