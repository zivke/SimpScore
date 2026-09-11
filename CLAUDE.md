# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Garmin Connect IQ watch app **SimpScore**. It tracks a running score between
two sides, **home** and **away**, for sports or simple games:

- one point at a time to either side, with undo backed by a full action log
- an optional win score, set with a two-digit picker (00 = off); reaching it
  wins, and off lets play continue indefinitely
- a toggleable "win by 2" rule (default on): winning also requires a two-point
  lead. When off, first to the win score wins
- time of day shown on the score screen
- new-game / reset
- a single score screen plus an options menu
- score, undo history, win score and settings survive leaving and reopening the app

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
  `monkeyc -f monkey.jungle -o bin/SimpScore.prg -y ~/.ciq/developer_key.der -d instinct2 -w -l 3`.
- Type checking is **Strict** (`monkeyC.typeCheckLevel`, and `-l 3` /
  `TYPECHECK` on every `monkeyc` line in the `Makefile`): annotate every
  parameter and return, matching the existing code. Constructors are the
  exception — `monkeyc` rejects a return annotation on `initialize()`.

`.devcontainer/README.md` covers one-time SDK setup (`connect-iq-sdk-manager …`).

## Architecture

`SimpScoreApp` creates one `SimpScoreData` model and injects it into the view
and both delegates. Delegates mutate the model and call
`WatchUi.requestUpdate()`; the view reads the model back on `onUpdate`.
`SimpScoreApp.onStart` restores persisted state and `onStop` saves it.

- **`source/SimpScoreData.mc`** — the model, no UI. Holds `_homeScore`,
  `_awayScore`, `_winAt` (`Number?`, default 7; `null` = no win score),
  `_winBy2` (`Boolean`, default true) and `_actions`, an `Array<Action>` of
  `HOME_POINT` / `AWAY_POINT` that `undoLastAction()` pops. `checkWin()` is
  false when `_winAt` is `null`; otherwise a side must reach `_winAt`, plus —
  when `_winBy2` — lead by more than one point. `addHomePoint` / `addAwayPoint`
  become no-ops after a win. The three mutators (`addHomePoint`, `addAwayPoint`,
  `undoLastAction`) return a `Boolean` — whether they actually changed anything
  — so the delegates can skip a redundant `persist()` on a no-op press.
  `reset()` re-runs `initialize()` (which leaves the settings alone). `persist()` / `restore()` move the five fields to/from
  `Application.Storage` (win score as `0` = off); they are **only** called from
  the app lifecycle and the delegates, never from this class's own mutators, so
  `SimpScoreData` unit tests stay Storage-free.
- **`source/SimpScoreDelegate.mc`** (`BehaviorDelegate`) — input mapping:
  previous-page = home point, next-page = away point, select = undo, menu /
  action-menu = push the main menu (`buildMainMenu`). `onActionMenu` exists
  because touch-first watches with no physical menu button/long-press (Venu
  X1 and siblings) have no other way to reach `onMenu` — they rely on the
  swipe-to-reveal action menu indicator `SimpScoreView.onShow` turns on via
  `setActionMenuIndicator` (`has`-guarded for older API levels). Calls
  `_data.persist()` after each change that mutated the model (write-through)
  and `Attention.vibrate` when a point wins.
- **`source/SimpScoreMenuDelegate.mc`** — the options menu (`Menu2`, built in
  code): "New Game", "Win Score" (sub-label = value or "Off"), and a "Win by 2"
  `ToggleMenuItem`. Round / rectangular Menu2 centres a plain-string title
  itself; on the Instinct semi-octagons the title is a left-inset `Text`
  drawable (`insetTitle`) so it clears the sub-screen. Selecting "Win Score"
  pushes `WinScoreView` / `WinScoreDelegate`; on confirm the pushed delegate
  writes the value back and the sub-label is updated in place. `menuString` /
  `centreTitles` / `titleInset` / `insetTitle` / `winScoreSubLabel` /
  `buildMainMenu` are file-scope helpers.
- **`source/WinScoreView.mc`** / **`source/WinScoreDelegate.mc`** — the win-score
  entry screen: a plain `WatchUi.View` (not a `WatchUi.Picker` subclass — an
  earlier attempt overrode `Picker.onUpdate` to draw black-on-white and fought
  the system widget's own repaint, going fully black on instinct3amoled and
  leaving artifacts on vivoactive3m/venusq2; a bare `View` owns the whole frame
  itself instead) drawing two big digits, black-on-white like the score
  screen, with up/down arrows above and below whichever digit (tens, then
  ones) is focused — echoing the stock `Picker`'s scroll arrows. Title
  placement reuses `centreTitles()` / `titleInset()` from
  `SimpScoreMenuDelegate.mc`. `WinScoreDelegate` (`BehaviorDelegate`) maps
  previous-page/next-page to bumping the focused digit (`wrapDigit`),
  select to advancing focus tens → ones → confirm, and back to ones → tens →
  cancel. On touchscreen devices (`isTouchScreen()`, no physical select
  button) the view also draws an on-screen "OK" button (`okButtonBounds()`,
  a plain function so the delegate can hit-test the same rectangle without a
  `Dc`); `WinScoreDelegate.onTap` treats a tap inside it exactly like select.
  `winScoreValue` (`tens*10 + ones`, `0` → `null`) and `wrapDigit` are
  file-scope helpers, kept WatchUi-free so `source-test` can reach them.
- **`source/SimpScoreView.mc`** — `onLayout` loads `Rez.Layouts.MainLayout`;
  `onUpdate` writes the scores into `HomeScoreValueLabel` /
  `AwayScoreValueLabel`, the win score (or `win_score_off_indicator` when
  `null`) into `ScoreToWinValueLabel`, and `hh:mm` (12/24h per device setting)
  into `ClockLabel`. A 20-second `Timer` started in `onShow` / stopped in
  `onHide` keeps the clock current; `onShow` also enables the action menu
  indicator (see `SimpScoreDelegate.mc` above).

## Resources & devices

- `resources/` — base resources: `strings/strings.xml` (**all** user-visible
  text), `drawables/`, and `layouts/layout.xml`, the fallback score screen
  (percentage coords) used by any device without a more specific folder. The
  menu is built in code, not from a menu resource.
- Layout folders, most specific wins: `resources-semioctagon-176x176/layout.xml`
  (instinct2 and its 176×176 semi-octagon siblings — has the sub-screen circle
  and clock band, **the reference look**); `resources-semioctagon/layouts/`
  (smaller Instincts, instinct2s / instincte40mm); `resources-rectangle/layouts/`
  (venu sq, venu x1); `resources/layouts/` catches round + semiround. The
  non-Instinct layouts have no sub-screen, so the win score shows as a `WIN`
  caption (`label_win_target`) plus `ScoreToWinValueLabel` between the clock band
  and the score columns. Every layout must define `ClockLabel`,
  `ScoreToWinValueLabel`, `HomeScoreValueLabel`, `AwayScoreValueLabel` (the ids
  `SimpScoreView.onUpdate` looks up).
- `manifest.xml` lists ~100 products (round, rectangle and semi-octagon watches).
  Adding one means editing `iq:products` (VS Code palette "Monkey C: Edit
  Products", or by hand) and downloading that device; check it renders with
  `make build DEVICE=<id>` and a sim screenshot.
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
