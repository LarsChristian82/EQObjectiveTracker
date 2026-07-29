# EQ Objective Tracker

A standalone replacement for World of Warcraft's default objective tracker.

It is the tracker half of [Everything Quests](https://github.com/wheelbarrel00/EverythingQuests),
extracted so you can use just the tracker without the rest of EQ. It does not require
Everything Quests, and never will.

## Status

In development, retail only. Tracks quests and campaign quests, world quests,
scenarios and delves, achievements, professions, and Traveler's Log endeavors.

Also included: a zone progress bar, a sound when a quest is ready to turn in, and a
highlight on the flight point nearest your tracked quest.

Quest-item buttons are the main thing still missing.

## What it tracks

- **Quests and Campaign**, in separate sections, with objectives and completion
- **World quests** in their own capped area, with the quest type on the marker, a
  colour-coded countdown, and a Find Group button where the game allows one
- **Scenarios and delves**, with the stage banner and its criteria
- **Achievements**, **professions** with reagent counts, and **endeavors**

## Usage

| Command | Effect |
|---|---|
| `/eqot` | Open the options panel |
| `/eqot lock` / `unlock` | Lock or unlock moving and resizing |
| `/eqot reset` | Restore the default position and size |
| `/eqot toggle` | Show or hide the tracker |
| `/eqot status` | Print what each provider emitted and what reached the screen |

Drag the strip along the top to move the tracker, and the corner grip to resize it.
Left-click a quest to super-track it, right-click to untrack it, shift-click to hide it.

Almost everything is configurable: fonts (41 bundled, plus anything from
LibSharedMedia), sizes, spacing, colours, a card layout, section order and visibility,
filters by quest type, and five sort modes.

## Building

There is no build step. The repository is the addon - clone it straight into
`Interface\AddOns\EQObjectiveTracker`, or junction it there.

Releases are produced by the [BigWigs packager](https://github.com/BigWigsMods/packager)
on an annotated `v` tag.

## License

[MIT](LICENSE)
