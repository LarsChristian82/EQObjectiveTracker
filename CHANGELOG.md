# Changelog

All notable changes to EQ Objective Tracker will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
- Appearance options for text and frame: font through LibSharedMedia with 41 bundled
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
