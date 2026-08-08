# EQ Objective Tracker

A standalone replacement for World of Warcraft's default objective tracker.

It is the tracker half of [Everything Quests](https://github.com/wheelbarrel00/EverythingQuests),
extracted so you can use just the tracker without the rest of EQ. It does not require
Everything Quests, and never will.

The relationship runs the other way: as of Everything Quests v1.38.0, EQ has no tracker of its
own and installs this one as a dependency. There is one copy of the tracker code now, so a fix
lands in both places at once.

[Discord](https://discord.gg/vm8K2WfQUE) &middot;
[CurseForge](https://www.curseforge.com/wow/addons/eq-objective-tracker) &middot;
[Report a bug](https://github.com/wheelbarrel00/EQObjectiveTracker/issues)

## Status

Released, retail only. Tracks quests and campaign quests, world quests,
scenarios and delves, achievements, professions, and Traveler's Log endeavors.

Also included: usable quest-item buttons, popups for newly discovered and completed
quests, a zone progress bar, a movable bonus objectives HUD, a sound when a quest is
ready to turn in, and a highlight on the flight point nearest your tracked quest.

A setting that only applies while another one is on is dimmed while that one is off, so it is
clear which settings are actually in effect.

If you already ran Everything Quests, your tracker settings are imported the first time this
addon loads, so it starts out looking the way yours already did. Your per-character state
comes across too, on every character: pinned quests, hidden quests, collapsed sections and
saved world quest watches.

Partly translated into French, Russian and Korean. Anything not yet translated falls
back to English on its own, so a partial translation is never a broken one.

## What it tracks

- **Quests and Campaign**, in separate sections, with objectives and completion
- **World quests** in their own capped area, with the quest type on the marker, a
  colour-coded countdown, and a Find Group button where the game allows one. Every world
  quest in your current zone is listed, not only the ones you have tracked, which you can
  turn off
- **Scenarios and delves**, with the stage banner and its criteria
- **Bonus objectives**, on their own movable HUD, including the bonus loot
  mechanics inside a delve. Off by default
- **Achievements**, **professions** with reagent counts, and **endeavors**
- **Quest items**, as a button on the row of any quest that carries one
- **Quest popups** for newly discovered quests and ones ready to hand in remotely
- **Hover any quest** for its objectives and full rewards, including item level
  comparisons against what you have equipped. World quests also show their faction and
  how long is left

## Usage

| Command | Effect |
|---|---|
| `/eqot` | Open the options panel |
| `/eqot lock` / `unlock` | Lock or unlock moving and resizing |
| `/eqot reset` | Restore the default position and size |
| `/eqot toggle` | Show or hide the tracker |
| `/eqot unhide` | Bring back every entry you have hidden from the tracker |
| `/eqot status` | Print what each provider emitted and what reached the screen |
| `/eqot bonushud` | Print what the bonus objectives HUD can see, or `test` to place it |
| `/eqot importeq` | Replace this profile with your Everything Quests tracker settings |
| `/eqot modules` | List the optional parts, and which are switched off |
| `/eqot disable <name>` | Switch off one part, or `all`, to narrow down a fault |
| `/eqot enable <name>` | Switch a part back on, or `all` |
| `/eqot debug` | Toggle entry validation warnings |

Drag the strip along the top to move the tracker, and the corner grip to resize it.
Left-click a quest to super-track it, and shift-click to hide it. Right-click opens a menu
to pin, track, focus, open the quest log, pop out the details, look the quest up on
Wowhead, or abandon it. A pinned quest stays on the tracker whatever your filters say.
In manual sort mode you can also drag quests into whatever order you like.

The tracker can hide itself while you are in combat, inside an instance, on a Mythic+ run,
or while the world map is open. Each is its own toggle, and all are off by default.

Almost everything is configurable: fonts (42 bundled, plus anything from
LibSharedMedia, each shown in its own typeface in the picker), sizes, spacing, colours, a
card layout, section order and visibility, filters by quest type, and eight sort modes
including by distance and by hand.

Settings live in profiles, so you can keep separate setups and switch between them.
Profiles are shared across all your characters.

## Translations

`Locales/frFR.lua`, `ruRU.lua` and `koKR.lua` are generated, and so is the `enUS.lua` phrase
list. The translations live in
[EverythingLocales](https://github.com/wheelbarrel00/EverythingLocales), shared with
Everything Quests so that a phrase used by both is only ever translated once, and so that a
phrase moving between the two addons keeps its translation.

**To add or correct a translation, edit `store/<language>.lua` there and open a pull request
against that repository.** A change made in this repo is overwritten the next time the files
are built. A phrase left untranslated simply stays English, so partial work is always safe.

A new language needs adding to that repo's language list, and its `Locales/<code>.lua` listed
in both `.toc` files here.

Every non-English string in this addon is somebody else's work. Thanks to **Zox** for the
French, **Malevi4** for the Russian, and **labrie75** for the Korean.

## Building

There is no build step. The repository is the addon - clone it straight into
`Interface\AddOns\EQObjectiveTracker`, or junction it there.

Releases are produced by the [BigWigs packager](https://github.com/BigWigsMods/packager)
on an annotated `v` tag. A tag whose name carries a prerelease suffix, such as
`v1.4.0-beta1`, publishes to the beta channel instead.

## Extending it

Another addon can add its own entries to a quest's right-click menu and its own icons to the
tracker header, through the global `EQObjectiveTracker`:

```lua
local API = EQObjectiveTracker:GetModule("API")
API:AddMenuItem{ id = "mine", providerID = "quests", label = "Do a thing", order = 35,
                 onClick = function(providerID, questID) end }
API:AddHeaderIcon{ id = "mine", texture = [[Interface\Icons\INV_Misc_QuestionMark]],
                   tooltip = "Do a thing", order = 20, onClick = function() end }
```

Callbacks receive the provider ID and the entry ID, never the entry table, because entries are
rebuilt on every quest event. `/eqot status` reports what is registered. Everything Quests uses
this for its Chain Guide icon and its "Get Directions" menu entry.

## License

[MIT](LICENSE)
