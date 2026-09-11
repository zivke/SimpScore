# Changelog

All notable user-visible changes to SimpScore. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); this project is not
yet released, so everything currently lives under Unreleased.

## [Unreleased]

### Added
- Score screen showing the home score, away score, the current win score
  (a dash when off) and the time of day.
- One point per button press to either side (Up = home, Down = away).
- Undo the last point, with full point-by-point history (Start / Enter).
- Options menu (hold Menu): New Game, Win Score, Win by 2. The menu is titled
  with the app name — left-aligned on Instinct (clearing the sub-screen),
  centred on every other watch.
- Win Score opens a custom two-digit entry screen (tens, then ones; 00 = off),
  black-on-white with up/down arrows over the digit being edited, matching
  the score screen instead of the system picker's white-on-dark look. When a
  win score is set the watch buzzes on a win; when off, play continues
  indefinitely.
- "Win by 2" toggle (default on): a win also requires a two-point lead. Turn it
  off for first-to-the-win-score. Toggling the rule redraws the score screen
  right away, so it can win or reopen the current game immediately.
- The score, undo history, win score and Win-by-2 setting are saved and
  restored when you leave and reopen the app.
- Support for ~100 Garmin watches across round, rectangular and Instinct
  (semi-octagon) screens. The Instinct screen is unchanged; other shapes get a
  matching layout — clock band, big HOME / AWAY numbers, and the win score as a
  `WIN` caption where there is no sub-screen circle.
