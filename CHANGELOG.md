# Changelog

All notable changes to EQ Objective Tracker will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0] - 2026-08-05

A correctness pass over the whole addon, following a full read of the code. Most of what
changed is settings and saved state that could be lost or quietly ignored, so day to day the
tracker behaves as it did.

### New Features

- `/eqot unhide` brings back every entry you have hidden by shift-clicking it. Hiding was
  previously one way, short of resetting the whole profile.

### Improvements

- Quest icons are drawn at their full size, so the icon fills its ring instead of sitting
  small inside it.
- Importing from Everything Quests now carries the zone progress bar's styling as well as its
  position: bar texture, bar color, border color, zone name color, count color and font.
- Several internal caches are now pruned as you play, instead of growing for a whole session.
- `/eqot status` reports how many entries are hidden, and which sections they came from.

### Bug Fixes

- Reset to Defaults on the Appearance tab no longer switches off a configured zone progress
  bar, or pulls a docked one back out into a floating bar. It restyles the tracker, which is
  what it says it does.
- Cancelling the color picker no longer writes a value. Opening Quest Title Color Override
  and pressing Escape used to turn every quest title flat white and silently switch off
  coloring by difficulty. Closing the options window part way through a pick is covered too.
- World quests you tracked by hand are no longer dropped from the saved watch list, so they
  are still tracked when you log back in.
- Bonus objectives reset on leaving a delve, instead of carrying the previous run's progress
  into the next one.
- Quest sounds stop as soon as the setting is switched off, rather than only after a reload.
- Hiding an entry now keeps it hidden. It could previously come back under a different
  section.
- A quest that turns out to be Legendary now takes the matching card tint, not just the
  matching icon.
- Blizzard's quest log no longer opens on a quest you did not select.
- The tracker no longer resizes its contents while you are in combat.

## [1.1.0] - 2026-08-04

Richer tracker tooltips, and a pass over the whole options panel: controls that do nothing
right now are dimmed instead of looking active, related settings are grouped together, and a
number of labels and tooltips that described the wrong thing have been corrected.

### New Features

- Hovering a quest in the tracker now shows its objectives and its full rewards: money,
  currencies, and items with an item level comparison against what you have equipped.
  Previously it showed only the quest name and a note about clicking.
- Hovering a world quest additionally shows its faction and how long is left, with the time
  coloured by how close it is to expiring, matching the countdown on the row itself.
- A control that only applies while another setting is on is now dimmed while that setting
  is off, so it is clear at a glance which settings are actually in effect.
- Each of the eight sort orders now explains what it sorts by on hover.
- The zone progress bar has a Background Color of its own. Left unset it keeps the plain
  black fill that fades slightly once the bar is locked.
- The Scenario Bonus Objectives group has a Test button, so the HUD can be positioned and
  sized without waiting to be inside a scenario or delve.

### Improvements

- The zone progress bar's settings are all in one place. Its two switches moved from the
  Tracker tab to join its styling on the Appearance tab.
- Hide scroll bar moved to the Appearance tab, at the top of the scroll bar settings it
  turns off, rather than sitting two tabs away from them.
- Buttons, tabs, dropdowns and colour swatches now respond to the mouse.
- Colour settings line up in a column, and the whole row is clickable rather than just the
  small swatch.
- A dropdown list marks the setting you are using, opens scrolled to it, and opens upward
  when there is no room below.
- Control text is white throughout instead of gold.
- Spacing around section headings is consistent across all four tabs.
- Show only watched quests is now Show only tracked quests, matching the word the game and
  the rest of the addon use, and its tooltip explains what it hides.
- Show tracked / total on the Quests & Campaign headers is now Show the visible / total
  count on section headers, which is what it has always done.
- The click hint has been removed from quest and world quest tooltips. It described only
  half of what a click does once Split quest click is turned on.

### Bug Fixes

- Cancelling the colour picker no longer writes a colour. Opening an unset colour and
  pressing Cancel or Escape used to save white, which turned every quest title white and
  silently stopped difficulty colouring from applying.
- Options Window Scale can no longer push the window's tabs and close button off the top of
  the screen, and the window is kept on screen if dragged to an edge.
- The section visibility tooltips said they hide a section when the box shows it.
- Reset all settings said only the active profile was affected. It also clears the Options
  Window Scale, which every character shares, and this character's collapsed sections and
  hidden entries. The confirmation now says so, and both reset dialogs mention the reload.
- The Appearance tab's Reset to Defaults no longer changes two settings on the Tracker tab.
- Quest Title Color By Difficulty and Show zone label under quest titles could not be
  clicked by their labels, unlike every other checkbox.
- Reset filters to defaults no longer turns Show only tracked quests back on.
- Dropdown lists follow the options window scale, and a list or colour picker left open no
  longer floats over the game world after the window is closed.
- The Maximum height slider had no effect while a custom World Quests height was set, with
  nothing to indicate it.
- Creating a profile with an empty name closed the dialog without creating anything.
- Pressing Enter on a confirmation dialog opened the chat box behind it.
- The section reorder arrows kept naming the previous section after a move.
- Filter tooltips read "Show or hide world quests entries in the tracker."
- The tracker no longer rebuilds twice every time a checkbox or colour is changed.

## [1.0.0] - 2026-08-03

Out of beta. The options panel has been rebuilt to match Everything Quests control for
control, so moving between the two addons no longer means learning a second layout.

### Improvements

- The options window is rebuilt throughout: wider, laid out in two columns, and restyled to
  match Everything Quests. Dropdowns, buttons, sliders, colour swatches and section headers
  all follow the same look now.
- Sort order is a row of buttons instead of a button you had to click through to find the
  mode you wanted. All eight modes are visible at once.
- Section order uses arrows, and section visibility is a plain checkbox list, so reordering
  and hiding are no longer tangled together in one row.
- The Sections tab is gone. Everything on it now lives on a new Tracker tab, alongside the
  tracker settings that used to be spread across General. The tabs are General, Tracker,
  Appearance and About.
- Quest sorting by type is available, ordering weekly above daily above normal.
- Font outline offers the three monochrome options as well, for six in total.
- A new Options Window Scale slider resizes the options window itself.
- Wording throughout the panel now matches Everything Quests, which also means far more of
  it arrives already translated. French and Russian cover 72% of the addon's phrases and
  Korean 66%, up from 44%.
- Many controls gained explanations on hover, and existing ones were reworded to match.

### Bug Fixes

- Reset all settings now genuinely resets everything. The tracker's size and position, any
  collapsed or hidden sections, and the options window scale all return to their defaults;
  previously they survived the reset. Your tracked world quests are deliberately left alone.
- Sliders no longer quietly rewrite a saved value that sits outside their range simply
  because you opened the tab they live on.
- Picking an option from a dropdown stores the setting itself rather than the label shown on
  screen, so dropdowns keep working correctly in every language.
- On-panel description text no longer overflows the window; explanations are on hover.

## [0.7.1] - 2026-08-02

Fixes to the drag ghost and to how equipment slots are named, found by comparing notes with
Everything Quests after v0.7.0 shipped.

### Bug Fixes

- The drag ghost is now genuinely see-through, so you can read the quest you are dropping
  onto. It had a gold outline but a solid interior, which hid the row underneath.
- The drag ghost is now the right width when the tracker is scaled. It was sized in the
  row's own space rather than the screen's, so it came out too narrow on a scaled-up
  tracker and too wide on a scaled-down one.
- Equipment slot names in the quest reward tooltip now come from the game itself, so they
  appear in your language and match the wording on the item tooltip you are comparing
  against. They were previously an English list that only ever showed English.

### Notes

- Three slot names change wording slightly to match the game's own terms.
- The locale check used by the release build now understands the game's numbered format
  placeholders, so a translation that reorders them is no longer reported as an error.

## [0.7.0] - 2026-08-02

The tracker speaks more than English now.

### New Features

- Translations. The addon is partly translated into French, Russian and Korean, and picks
  the language up from your game client automatically. Anything not yet translated shows in
  English on its own, so a partial translation is never a broken one.
- `Locales/` holds the phrase list and one file per language. Adding or correcting a
  translation is a matter of editing the file for that language, and adding a new language
  is a matter of copying one.

### Improvements

- Every dropdown in the options panel now keeps the setting it saves separate from the text
  it shows. Picking an option stores the same value whatever language you play in.
- The Sort button reads Sort: Zone rather than Sort: zone, and the sort names translate with
  the rest of the panel.

### Notes

- A handful of labels changed capitalization to match Everything Quests exactly, such as
  Font Size and Border Color. This is what lets the two addons share translations.
- Fonts, status bar textures and sound names are deliberately left untranslated. Your
  profile stores them by name, so translating them would silently reset your choices.

## [0.6.0] - 2026-08-01

The last of the display options from Everything Quests.

### New Features

- Show a quest's level in front of its title, as [60] Title. Off by default.
- Show a quest's ID after its title, which is handy when reporting a bug. Off by default.
- A NEW tag on quests accepted in the last hour. On by default.
- Split quest click: click a quest's icon to focus it, click its title to open the quest log
  instead. Off by default, so a click anywhere on the row still focuses the quest.
- A cogwheel at the top-right of the tracker that opens the options panel. On by default,
  and it can be turned off under General.

### Notes

- The level, ID and NEW tag appear on quests and campaign quests only, matching Everything
  Quests. Achievements, professions, endeavors and world quests are unaffected.

## [0.5.0] - 2026-08-01

Bringing your setup with you. Settings can now live in named profiles, and if you already run
Everything Quests your tracker settings come across on first install.

### New Features

- Distance sorting. Pick Distance under Sorting on the General tab and quests order by how
  close their objective is, re-sorting as you move. Quests ready to hand in sort by where you
  hand them in, rather than dropping to the bottom of the list.
- Profiles. Keep separate setups and switch between them from the General tab, with a New
  profile button that starts from a copy of your current settings. Profiles are shared across
  all your characters.
- Reset all settings, which returns the active profile to defaults behind a confirmation.
- Everything Quests settings are imported automatically the first time this addon runs, if
  Everything Quests is installed. Position, size, fonts, colors, filters, section order,
  sorting and your manual quest order all come across. Nothing is imported over an existing
  setup, and `/eqot importeq` runs it by hand if you want it later.
- `/eqot status` reports distance sorting state, and whether an Everything Quests
  configuration was found and imported.

### Notes

- Switching, creating or resetting a profile reloads the interface, matching Everything
  Quests.
- The profile list is sorted by name. The library underneath returns it in no particular
  order, which meant it could rearrange itself between sessions on its own.

## [0.4.0] - 2026-08-01

Put the quests in whatever order you want them.

### New Features

- Manual sorting. Pick Manual under Sorting on the General tab, then drag any quest or
  campaign quest to where you want it. A gold line shows where it will land, and the order
  survives logging out. Quests you are not currently showing keep their place in the order,
  so filtering the tracker and rearranging it no longer discards the rest.
- `/eqot status` reports how many quests carry a manual position and how many of those are
  still in your log.

### Notes

- Only quests and campaign quests can be dragged, matching Everything Quests. The drop line
  stays inside the section you picked the quest up from, since a quest cannot move between
  Campaign and Quests.
- The dragged quest is shown on a translucent panel with a gold edge, so the row you are
  dropping it onto stays readable underneath it. Everything Quests draws that panel opaque,
  which covers the row you are aiming at.

## [0.3.0] - 2026-08-01

Getting the tracker out of your way without missing anything. It can now hide itself in
combat, in instances and while the map is open. Quests carrying a usable item get a button
on their row, newly discovered and completed quests get popups, and bonus objectives get
their own movable HUD. Two separate causes of a blocked-action error around the world map
are also fixed.

### New Features

- Bonus objectives HUD, off by default. A small movable checklist of the extra bonus
  objectives that appear during some scenarios and delves, so their rewards are not
  missed. Inside a delve it follows the bonus loot mechanics as well. Drag it anywhere,
  right-click to lock it or reset its position, and size it with its own scale slider.
  Turn it on under General, Scenario Bonus Objectives.
- Hovering a bonus objective's reward icon shows what that step pays out, with each item's
  level and how it compares against what you have equipped.
- Usable quest items now appear as a button on the row of any quest that carries one, with
  its charges, its cooldown, and a tint while the target is out of range. Only rows that
  have an item pay for the space.
- Popups for newly discovered quests and for quests that can be handed in remotely, drawn
  at the top of their section and counted in its header. On by default.
- Accepted quests are now tracked automatically, matching the default UI. On by default.
- Visibility rules: the tracker can hide itself during combat, inside instances, during a
  Mythic+ run, and while the world map is open. Each is its own toggle.
- The zone progress bar can be docked into the tracker as an ordinary section instead of
  floating, and reordered along with the rest.
- Zone progress bar appearance options: bar texture with a live preview of the artwork,
  bar color, scale, font, zone name and count colors, background, border and border color.
- `/eqot bonushud` reports what the bonus objectives HUD can see, and `/eqot bonushud test`
  draws a sample so it can be positioned without being in a delve.
- `/eqot modules`, `/eqot disable <name>` and `/eqot enable <name>` switch individual parts
  of the addon off for a session, to narrow a fault down to one of them. `/eqot disable
  all` is a safe mode that turns off every optional part at once.

### Bug Fixes

- Opening the world map in combat could produce a blocked-action error naming this addon,
  from a stack containing none of its code. Two separate causes are fixed: the options
  window no longer registers for Escape-to-close through the list the panel manager reads
  by name, and the world quest group finder check now resolves off the render path.
- Blizzard's tracker could reappear beside this one for the rest of a fight, because the
  re-hide stood down while in combat. It now runs in combat as well.
- The tracker no longer drifts across the screen as its scale changes. Positions are
  stored in screen units, and a position saved under the old units is converted once.
- The floating zone progress bar no longer drifts as its scale changes, for the same
  reason.
- Turning the scroll bar skin back off could erase the thumb outright rather than restore
  it, where the stock thumb was neither an atlas nor a plain texture. A thumb whose width
  was read before it had been sized also never got that width back.
- An endeavor requirement beginning with a negative number lost its minus sign.

### Improvements

- The tracker is now hidden outright rather than only faded wherever the game allows it.
  In the one case where it can only fade, it no longer swallows clicks, tooltips or the
  mouse wheel.

### Notes

- Blizzard's tracker sub-modules are no longer silenced. Doing that meant writing to
  eleven of its frames, which feed the quest marker system, and Everything Quests has
  never done it.

## [0.2.0] - 2026-07-28

A large step toward the parity needed before Everything Quests can drop its own tracker
and depend on this one. The appearance options, the world quest area, professions,
endeavors and the full scenario and delve display are all ported across.

### New Features

- Title colors: difficulty coloring can now be turned off, titles take an explicit
  color override with a Clear button to undo it, and either titles or section
  headings can use your character's class color.
- Completed entries can use the title color instead of green. This applies to
  finished objective lines as well as titles, so quests, world quests and
  achievements all follow the same setting.
- Card row layout: each entry is drawn on its own bordered panel, with separate
  background and border colors, adjustable border thickness and padding.
- Cards can be tinted by type, giving campaign, legendary, dungeon and raid entries
  their own color. Instance types take priority over storyline ones.
- Section header bars: an optional gradient bar behind each heading, in horizontal
  or vertical style, with its own color, height, and feathered edges.
- Scroll bar skinning: a track background with its own color, a flat single color
  thumb with adjustable color and width, and options to hide the end arrows or the
  scroll bar entirely. Hiding the bar gives its gutter back to the text.
- `/eqot status` now reports the scroll bar's live state, including which thumb
  widget the current client actually uses.
- World quests now render in their own capped, separately scrolling area pinned above
  or below the quest list, rather than as an ordinary section. Its share of the
  tracker is capped, and the quest sections are given their space first, so a long
  world quest list can no longer push quests off screen. The cap is adjustable, or it
  can be replaced with a fixed height.
- Optionally list every world quest on your current map without tracking each one.
- Tracked profession recipes are now shown, with their required reagents and how many
  of each you hold. Reagent counts sum every quality tier, so a stack of nothing but
  rank two or rank three still counts toward the total. Reagents whose amount depends
  on choices made in the crafting window show their range instead of a false total. A
  recipe tracked both normally and as a recraft gets a row for each.
- Endeavors are now tracked, showing each activity and its requirements. Completed
  requirements follow your complete-entry color like every other section, rather than
  being locked to green.
- Tracked world quests now survive logout. Blizzard drops world quest watches between
  sessions, so they are saved per character and restored shortly after login, once the
  world quest data exists. Expired ones are pruned rather than restored, and quests the
  game auto-watches as you walk past are not saved.
- Simplify tracked achievements: show only the criteria you have not finished yet.
- Keep focused quest after relog, on by default. With it off, the waypoint arrow is
  cleared shortly after you log in. Reloading and changing zone never disturb it either
  way.
- Opening the flight map highlights the flight point nearest your focused quest.
- A sound plays when a quest becomes ready to turn in, with 27 voices to pick from and
  a preview when you choose one. On by default, and it can be turned off.
- Everything Quests' seven status bar textures are bundled and offered through
  LibSharedMedia, so they are available to other addons as well.
- Zone progress bar, off by default. Shows how much of the current zone's questlines you
  have finished, as a movable bar you can drag anywhere, with right-click to lock it or
  reset its position. Standing in a capital shows the surrounding zone's progress.
- World quests that support it now carry a Find Group button, which opens the Premade
  Group Finder for that quest. It only appears where a group can actually be made for
  the quest, so most rows will not show one.
- Scenarios, delves, dungeons and battlegrounds now show their current stage and its
  criteria, with progress counts and completion. The content type is worked out from the
  scenario type, texture kit and difficulty together, so Ritual Sites are told apart from
  Delves and Follower Dungeons from ordinary ones, and it is shown in the entry's tooltip.
  Unreleased steps that report an internal build string in place of real criteria text no
  longer show that string. Scenarios draw in their own area pinned above the quest list
  rather than scrolling with it, so the rest of the tracker moves down to make room.
- The scenario banner, with its stage artwork, the content type above the instance name,
  the final-stage filigree on the last stage, and the themed tint some scenarios carry.
  Where a scenario supplies its own display widgets, those replace the banner as they do
  in the default tracker. Criteria that track a percentage draw a progress bar.
- Appearance options for the scenario banner: its own text shadow with color and
  distance, kept separate from the tracker's text shadow, plus banner alignment, banner
  text size and criteria text size.

### Bug Fixes

- World quests now show the quest type on their marker, matching Everything Quests and
  the default tracker: a map pin ring, which brightens while super-tracked, with the
  pet battle, profession or other type icon on it. They previously showed the quest's
  reward instead, which also meant the icon visibly changed as reward data loaded, most
  noticeably when listing every world quest in the zone at once.

### Improvements

- A finished progress bar now reads as its label alone. The tracker was still showing
  the count beside it, so a completed bar read as "100/100 Rescued Villagers" where the
  default tracker and Everything Quests both show just the label.

### Notes

- Entry spacing has a 4px floor while the card layout is on. Below that, adjacent
  card borders touch and a list reads as one merged card.
- World Quests no longer appears in the section reorder list, because a pinned region
  has no position within the scrolling run. Its Top or Bottom placement, and its
  show and hide toggle, moved to the World Quests group on the Sections tab.
- Turning the solid color thumb back off restores the original scroll bar thumb.
  Everything Quests only restores an atlas-based thumb, so where the stock thumb is a
  plain texture it stays stuck as a solid block until the UI is reloaded.

## [0.1.0] - 2026-07-26

First milestone. Not yet released.

### New Features

- Replaces the default objective tracker with a movable, resizable frame that
  remembers its position, size, and collapsed sections across sessions.
- Tracks quests from the quest log, with objective progress, completion state,
  and super-tracking on left-click.
- Section headers show visible and total counts and collapse on click.
- Options panel and slash commands: `/eqot`, plus `lock`, `unlock`, `reset`,
  `toggle`, `status`, `debug`.
- Separate Campaign and Quests sections.
- Tracks watched world quests with their reward icon and a colored expiry countdown.
- Tracks achievements with their criteria and progress bars.
- Filter by quest type: campaign, daily, weekly, normal, and this zone only.
- Sort by zone, title, status, level, or recently added.
- Shift-click a row to hide it from the tracker.
- Appearance options for text and frame: font through LibSharedMedia with 42 bundled
  fonts, size, outline, title and header size offsets, text shadow with its own color
  and distance, tracker scale, line and header spacing, section header and divider
  colors, and a background and border with colors and thickness.
- Every option carries a mouseover description.

### Notes

- Retail only for now. The architecture gates flavor differences at load time, so
  Classic support is additive.
- World quests render as an ordinary section. The capped, separately placed region
  from Everything Quests is not in this milestone.
- Professions, scenarios and quest-item buttons are not in this milestone.
