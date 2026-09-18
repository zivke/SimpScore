# Changelog

All notable user-visible changes to SimpScore. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
follows [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- "Count Down" option (options menu, hidden while off): points subtract
  instead of add, both sides start a new game at the Win Score number
  (relabeled "Start At" while this is on), and the game ends the instant
  either side reaches 0 — for games like Magic: the Gathering life totals or
  darts 301/501. "Win by 2" has no meaning here (no shared lead when each
  side counts down independently), so it's hidden from the menu and ignored
  while Count Down is on. Turning Count Down on/off, or changing the
  starting number while it's on, always starts a fresh game.

## [1.0.0] - 2026-09-15

### Added
- Score screen showing the home score, away score, the current win score
  (a dash when off) and the time of day.
- One point per button press to either side (Up = home, Down = away).
- Undo the last point, with full point-by-point history (Start / Enter).
- Options menu (hold Menu): New Game, Win Score, Win by 2. The menu is titled
  "Menu", centred by the system on every watch (a custom left-aligned title
  was tried on Instinct to clear its sub-screen, but overlapped it on a real
  device). On touch-first watches with no physical
  menu button (Venu X1 and siblings), swipe the on-screen action menu
  indicator instead to reach the same menu. On touch-first watches whose API
  level predates that swipe indicator (Venu 2/2 Plus/2S/3/3S, vívoactive 5,
  D2 Air, D2 Air X10, vívoactive 4/4S, and other touch watches with no
  physical menu button), touch-and-hold the screen instead — real devices in
  that group had no way to reach the menu at all before this. No launcher
  icon is shown on watches with a physical sub-screen (Instinct family) — it
  glitched there on a real device.
- Win Score opens a custom two-digit entry screen (tens, then ones; 00 = off),
  black-on-white with up/down arrows over the digit being edited, matching
  the score screen instead of the system picker's white-on-dark look. On
  touchscreen watches (no physical select button) it also shows an on-screen
  OK button. When a win score is set the watch buzzes on a win; when off,
  play continues indefinitely.
- "Win by 2" toggle (default on): a win also requires a two-point lead. Turn it
  off for first-to-the-win-score. Toggling the rule redraws the score screen
  right away, so it can win or reopen the current game immediately.
- The score, undo history, win score and Win-by-2 setting are saved and
  restored when you leave and reopen the app.
- Support for ~100 Garmin watches across round, rectangular and Instinct
  (semi-octagon) screens. The Instinct screen is unchanged; other shapes get a
  matching layout — clock band, big HOME / AWAY numbers, and the win score as a
  `WIN` caption where there is no sub-screen circle.

### Fixed
- The win buzz now fires exactly once, on the press that wins the game,
  instead of re-triggering on every subsequent point-button press while the
  game stays won.
- The options menu title no longer wraps to two lines on the narrower
  semi-octagon screens (instinct2 and siblings), which was pushing the menu
  item list down and clipping it. It now reads "Menu" instead of repeating
  the app name.
- More breathing room between the `WIN` caption and the win-score number on
  round screens.
- The Win Score entry screen's title sat too close to the top edge on
  semi-octagon (Instinct) screens; moved it down.
- On hybrid analog-digital watches (Instinct Crossover and siblings), the
  physical clock hands overlaid the whole score screen and win-score entry
  screen. Both now park the hands out of the way while they're showing, and
  restore them to system time on exit. The win-score number is also moved
  down on these watches, since parking the hands doesn't move the fixed
  physical hub they pivot on.
- Adding or undoing a point, and menu changes, had a noticeable lag on real
  hardware, from writing to flash storage on every single one. The score,
  undo history and settings are now only saved once, on exiting the app,
  instead of after every action — a deliberate tradeoff of losing an
  in-progress game on an unclean exit (crash, low battery, force-kill) for
  no per-action write cost.
- The Win Score entry screen's title was centred instead of left-inset on
  instinct3amoled45mm/50mm, sitting on top of their sub-screen — those two
  watches report a round screen shape even though they have a physical
  sub-screen like the rest of the Instinct family, and the title placement
  was keyed off screen shape instead of sub-screen presence.
