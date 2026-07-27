# Changelog

All notable changes to EQ Objective Tracker will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Three appearance ports from Everything Quests, bringing the tracker closer to the
parity needed before EQ can drop its own tracker and depend on this one.

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

### Notes

- Entry spacing has a 4px floor while the card layout is on. Below that, adjacent
  card borders touch and a list reads as one merged card.
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
