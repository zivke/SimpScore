# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Garmin Connect IQ watch app **SimpScore**. It tracks a running score between
two sides, **home** and **away**, for sports or simple games:

- one point at a time to either side, with undo backed by a full action log
- a configurable target score ("win at"); reaching it with a two-point margin
  ends the game and buzzes the watch
- new-game / reset
- a single score screen plus an options menu

Planned but not yet built: an option for *no* win score at all, and a way to
enter arbitrary target scores rather than the fixed 7 / 11 / 21.

## Build & run

SDK, simulator, and signing key are already installed in the devcontainer.
Never install or regenerate them.

- **Build** (verified working):
  `monkeyc -f monkey.jungle -o bin/SimpScore.prg -y ~/.ciq/developer_key.der -d instinct2 -w`
  `-w` prints warnings; add `-r` for a release build. `instinct2` is the only
  product (`minApiLevel 3.2.0`); `monkey.jungle` sets nothing but the manifest.
- **Run in the simulator**: start it once with `connectiq`, then
  `monkeydo bin/SimpScore.prg instinct2`. The simulator must be up before `monkeydo`.
- **No test suite** — there is no `monkey-test.jungle` or `source-test/`.
- Type checking is **Strict** (`monkeyC.typeCheckLevel`): annotate every
  parameter and return, matching the existing code.

`.devcontainer/README.md` covers one-time SDK setup (`connect-iq-sdk-manager
…`). Both that file and earlier versions of this one describe a `Makefile`
workflow (`make build`, `make sim`, `make dev-device`, `make package`, …) — no
such Makefile is in the tree. Use the `monkeyc` / `monkeydo` commands above.

## Architecture

`SimpScoreApp` creates one `SimpScoreData` model and injects it into the view
and both delegates. Delegates mutate the model and call
`WatchUi.requestUpdate()`; the view reads the model back on `onUpdate`.

- **`source/SimpScoreData.mc`** — the model, no UI. Holds `_homeScore`,
  `_awayScore`, `_winAt` (default 7), and `_actions`, an `Array<Action>` of
  `HOME_POINT` / `AWAY_POINT` that `undoLastAction()` pops. `checkWin()` is true
  once a side has reached `_winAt` *and* leads by more than one point;
  `addHomePoint` / `addAwayPoint` become no-ops after that. `reset()` re-runs
  `initialize()`.
- **`source/SimpScoreDelegate.mc`** (`BehaviorDelegate`) — input mapping:
  previous-page = home point, next-page = away point, select = undo, menu =
  push `Rez.Menus.MainMenu`. Calls `Attention.vibrate` when a point wins.
- **`source/SimpScoreMenuDelegate.mc`** (`MenuInputDelegate`) — `item_1` new
  game; `item_2` / `item_3` / `item_4` set "win at" to 7 / 11 / 21.
- **`source/SimpScoreView.mc`** — `onLayout` loads `Rez.Layouts.MainLayout`;
  `onUpdate` writes the three numbers into `ScoreToWinValueLabel`,
  `HomeScoreValueLabel`, `AwayScoreValueLabel` via `findDrawableById`.

## Resources & devices

- `resources/` — base resources: `strings/strings.xml` (**all** user-visible
  text — `AppName`, `menu_label_1..4`), `menus/menu.xml`, `drawables/`.
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
- No `changelog.md` or `README.md` exists yet; add and maintain them if the app
  gains user-visible surface worth documenting.
