# EQ Objective Tracker

A standalone replacement for World of Warcraft's default objective tracker.

It is the tracker half of [Everything Quests](https://github.com/wheelbarrel00/EverythingQuests),
extracted so you can use just the tracker without the rest of EQ. It does not require
Everything Quests, and never will.

## Status

Early. Milestone 1 tracks quests only. World Quests, achievements, scenarios,
professions, and quest-item buttons are on the way.

## Usage

| Command | Effect |
|---|---|
| `/eqot` | Open the options panel |
| `/eqot lock` / `unlock` | Lock or unlock moving and resizing |
| `/eqot reset` | Restore the default position and size |
| `/eqot toggle` | Show or hide the tracker |
| `/eqot status` | Print active providers and row-pool counts |

Drag the strip along the top to move the tracker, and the corner grip to resize it.
Left-click a quest to super-track it, right-click to untrack it, shift-click to hide it.

## Building

There is no build step. The repository is the addon - clone it straight into
`Interface\AddOns\EQObjectiveTracker`, or junction it there.

Releases are produced by the [BigWigs packager](https://github.com/BigWigsMods/packager)
on an annotated `v` tag.

## License

[MIT](LICENSE)
