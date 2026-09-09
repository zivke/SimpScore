# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Garmin Connect IQ watch app **SimpScore**. It tracks a running score between
two sides, **home** and **away**, for sports or simple games:

- one point at a time to either side, with undo backed by a full action log
- an optional win score, set with a number picker (0 = off); reaching it with a
  two-point margin ends the game and buzzes the watch, and off lets play
  continue indefinitely
- new-game / reset
- a single score screen plus an options menu
- score, undo history and win score survive leaving and reopening the app

## Build & run

SDK, simulator, and signing key are already installed in the devcontainer.
Never install or regenerate them. Everything goes through the `Makefile`
(`make help` lists targets); `DEVICE` defaults to `instinct2`.

- `make build` — debug `.prg`; `make release` strips debug info.
- `make sim` — start the simulator (no-op if already running); `make run`
  does `sim` + build + `monkeydo`.
- `make test` — compiles `monkey-test.jungle` (`source` + `source-test`, `-t`)
  and runs the unit tests in the simulator. `monkeydo -t` exits non-zero even
  on success, so the target keys pass/fail off the runner's `PASSED` line.
- `make package` — store `.iq`; needs `make all-devices` first.
- Underneath, a build is just
  `monkeyc -f monkey.jungle -o bin/SimpScore.prg -y ~/.ciq/developer_key.der -d instinct2 -w`.
- Type checking is **Strict** (`monkeyC.typeCheckLevel`): annotate every
  parameter and return, matching the existing code.

`.devcontainer/README.md` covers one-time SDK setup (`connect-iq-sdk-manager …`).

## Architecture

`SimpScoreApp` creates one `SimpScoreData` model and injects it into the view
and both delegates. Delegates mutate the model and call
`WatchUi.requestUpdate()`; the view reads the model back on `onUpdate`.
`SimpScoreApp.onStart` restores persisted state and `onStop` saves it.

- **`source/SimpScoreData.mc`** — the model, no UI. Holds `_homeScore`,
  `_awayScore`, `_winAt` (`Number?`, default 7; `null` = no win score) and
  `_actions`, an `Array<Action>` of `HOME_POINT` / `AWAY_POINT` that
  `undoLastAction()` pops. `checkWin()` is false when `_winAt` is `null`,
  otherwise true once a side reaches `_winAt` *and* leads by more than one
  point; `addHomePoint` / `addAwayPoint` become no-ops after a win. `reset()`
  re-runs `initialize()` (which leaves `_winAt` alone). `persist()` / `restore()`
  move the four fields to/from `Application.Storage` (win score as `0` = off);
  they are **only** called from the app lifecycle and the delegates, never from
  this class's own mutators, so `SimpScoreData` unit tests stay Storage-free.
- **`source/SimpScoreDelegate.mc`** (`BehaviorDelegate`) — input mapping:
  previous-page = home point, next-page = away point, select = undo, menu =
  push the main menu (`buildMainMenu`). Calls `_data.persist()` after each
  change (write-through) and `Attention.vibrate` when a point wins.
- **`source/SimpScoreMenuDelegate.mc`** — the options menu (`Menu2`, built in
  code): "New Game" and "Win Score" (sub-label = current value or "Off").
  Selecting "Win Score" pushes a `WatchUi.Picker` number spinner
  (`WinScorePickerFactory`, index 0 = "Off", `1..WIN_SCORE_MAX`); on accept,
  `WinScorePickerDelegate` calls `setWinAt` (0 → `null`) and updates the parent
  row's sub-label in place. `menuString` / `winScoreSubLabel` / `buildMainMenu`
  / `buildWinScorePicker` are file-scope helpers.
- **`source/SimpScoreView.mc`** — `onLayout` loads `Rez.Layouts.MainLayout`;
  `onUpdate` writes the scores into `HomeScoreValueLabel` /
  `AwayScoreValueLabel` and the win score (or `win_score_off_indicator` when
  `null`) into `ScoreToWinValueLabel`, via `findDrawableById`.

## Resources & devices

- `resources/` — base resources: `strings/strings.xml` (**all** user-visible
  text) and `drawables/`. The menu is built in code, not from a menu resource.
- `resources-semioctagon-176x176/layout.xml` — the **only** layout definition,
  written for the instinct2's screen shape and size; base `resources/` has no
  layout. A device with a different shape needs its own
  `resources-<shape>[-<size>]/layout.xml` layered over `resources/`.
- Adding a product means editing `manifest.xml`'s `iq:products` (use the VS Code
  command palette, "Monkey C: Edit Products") and downloading that device.
- **Never change `manifest.xml`'s `id`** (`734088d3-…`) — it is the published
  app's identity. The "generated file, do not edit" banner refers to
  hand-editing; the palette commands are the supported way to change it.

## Conventions

- User-visible text goes in `resources/strings/strings.xml`, never inline.
- Keep parameters and returns annotated (Strict type checking).
- Two-space indent (`.editorconfig`).
- Update `changelog.md` (Keep a Changelog, everything under Unreleased until
  the first store release) for any user-visible change; update `README.md`'s
  supported-devices list when products change.
- `SimpScoreData` is pure logic apart from the explicit `persist()` / `restore()`
  methods — don't call `Storage` from its mutators, so the tests stay isolated.
  Add a `(:test)` case in `source-test/SimpScoreDataTest.mc` when you change
  scoring, undo, win, or persistence rules.
