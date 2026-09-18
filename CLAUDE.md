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
- a toggleable "Count Down" mode: points subtract instead of add, both sides
  start at the win score (relabeled "Start At"), and a side reaching 0 ends
  the game — e.g. Magic: the Gathering life totals. Hides and ignores
  "win by 2" while on, since there's no shared lead to speak of
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
`SimpScoreApp.onStart` restores persisted state and `onStop` saves it —
persistence happens **only** on app exit, nowhere else (see `persist()`
below).

- **`source/SimpScoreData.mc`** — the model, no UI. Holds `_homeScore`,
  `_awayScore`, `_winAt` (`Number?`, default 7; `null` = no win score),
  `_winBy2` (`Boolean`, default true), `_countDown` (`Boolean`, default
  false) and `_actions`, an `Array<Action>` of `HOME_POINT` / `AWAY_POINT`
  that `undoLastAction()` pops. `checkWin()` is false when `_winAt` is
  `null`; when `_countDown`, it's true the instant either side is `<= 0`
  (`_winBy2` is never consulted there — no shared lead when each side counts
  down independently); otherwise a side must reach `_winAt`, plus — when
  `_winBy2` — lead by more than one point. `addHomePoint` / `addAwayPoint`
  add 1, or subtract 1 when `_countDown`, and become no-ops after a win (so
  a countdown score can never go below 0: the guard only allows a press when
  no side is at `<= 0` yet, and each press moves a score by exactly 1).
  `undoLastAction()` reverses whichever direction was used. The three
  mutators (`addHomePoint`, `addAwayPoint`, `undoLastAction`) return a
  `Boolean` — whether they actually changed anything — so `SimpScoreDelegate`
  can skip a redundant win-buzz check on a no-op press. `reset()` re-runs
  `initialize()` (which leaves the settings alone), which starts both scores
  at `_winAt` when `_countDown` (0 if Win Score is Off), otherwise always 0.
  Toggling `_countDown`, or changing `_winAt` while it's already on, always
  calls `reset()` (see `SimpScoreMenuDelegate.mc` / `WinScoreDelegate.mc`
  below) rather than trying to transform an in-progress score, which also
  keeps `_actions` from ever mixing add-direction and subtract-direction
  entries. `persist()` / `restore()` move all six fields to/from
  `Application.Storage` (win score as `0` = off); `persist()` is called
  **only** from `SimpScoreApp.onStop`, not after individual points, undos, or
  menu changes — a real device's flash write is slow enough to show up as
  input lag on every single button press (rewriting the win-score settings
  and re-serializing the whole, unbounded actions array each time), even
  though it's free against the simulator's filesystem-backed Storage. The
  deliberate tradeoff: a game in progress is lost if the app is killed
  uncleanly (crash, low-battery shutdown, force-kill) rather than exited
  normally. Neither method is called from this class's own mutators, so
  `SimpScoreData` unit tests stay Storage-free.
- **`source/SimpScoreDelegate.mc`** (`BehaviorDelegate`) — input mapping:
  previous-page = home point, next-page = away point, select = undo, menu /
  action-menu = push the main menu (`buildMainMenu`). `onActionMenu` exists
  because touch-first watches with no physical menu button/long-press (Venu
  X1 and siblings) have no other way to reach `onMenu` — they rely on the
  swipe-to-reveal action menu indicator `SimpScoreView.onShow` turns on via
  `setActionMenuIndicator` (`has`-guarded for older API levels). Does not
  persist (see `SimpScoreData.persist()`); calls `Attention.vibrate` when a
  point wins.
- **`source/SimpScoreMenuDelegate.mc`** — the options menu (`Menu2`, built in
  code): "New Game", "Win Score"/"Start At" (sub-label = value or "Off", title
  keyed off `_countDown` via `winScoreMenuLabel`), a "Win by 2"
  `ToggleMenuItem` — omitted from the menu entirely while Count Down is on,
  since it has no effect there (see `SimpScoreData.mc`) — and a "Count Down"
  `ToggleMenuItem` last. The title is a plain string on every shape,
  including Instinct — a custom left-inset `Text` drawable was tried there to
  clear the sub-screen, but a real Instinct 2 showed it overlapping the
  sub-screen anyway (the same class of bug `c09f72d` had already hit and
  reverted for round/rectangular's `HALIGN_CENTER` title, and the simulator
  didn't catch either time); letting the system position the title is what
  actually holds up on hardware. `buildMainMenu` omits `:icon` on devices with
  a physical sub-screen (`hasSubscreen()`, `has`-guarded — `WatchUi.getSubscreen()`
  is API 3.2.7 vs. this app's 3.2.0 minimum): a real Instinct 2 showed the
  launcher icon glitching on that hardware, since `:icon` is only used (and
  rendered on the sub-screen itself) on such devices. Selecting "Win Score"/
  "Start At" pushes `WinScoreView` / `WinScoreDelegate`; on confirm the pushed
  delegate writes the value back (resetting the game first if `_countDown`)
  and the sub-label is updated in place. Toggling "Count Down" calls
  `setCountDown` + `reset()` and pops back to the score screen — unlike "Win
  by 2", which redraws in place and leaves the menu open — because it always
  starts a fresh game and changes the Win Score/Start At item's *title*,
  which `Menu2` has no live way to relabel short of rebuilding the menu.
  `centreTitles` / `titleInset` are now only used by `WinScoreView`'s own
  title placement. `menuString` / `winScoreMenuLabel` / `winScoreSubLabel` /
  `hasSubscreen` / `buildMainMenu` are file-scope helpers.
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
  file-scope helpers, kept WatchUi-free so `source-test` can reach them. The
  title text itself comes from `winScoreMenuLabel(_countDown)`
  (`SimpScoreMenuDelegate.mc`), a constructor parameter passed in alongside
  the current win score, so it reads "Win Score" or "Start At" to match the
  mode. `WinScoreDelegate.confirm()` resets the game (see `SimpScoreData.mc`)
  when `_countDown` is on, since the number just entered is a new starting
  point, not a target.
- **`source/SimpScoreView.mc`** — `onLayout` loads `Rez.Layouts.MainLayout`;
  `onUpdate` writes the scores into `HomeScoreValueLabel` /
  `AwayScoreValueLabel`, the win score (or `win_score_off_indicator` when
  `null`) into `ScoreToWinValueLabel`, `hh:mm` (12/24h per device setting)
  into `ClockLabel`, and — on layouts that have it (round, rectangle; the
  lookup is a no-op elsewhere) — "WIN" or "START" into `WinScoreTextLabel`
  depending on `_countDown`. A 20-second `Timer` started in `onShow` / stopped in
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
- **Never change `manifest.xml`'s `id`** (`a3a03d94-…`) — it is the published
  app's identity. The "generated file, do not edit" banner refers to
  hand-editing; the palette commands are the supported way to change it.

## Conventions

- User-visible text goes in `resources/strings/strings.xml`, never inline.
- Keep parameters and returns annotated (Strict type checking).
- Two-space indent (`.editorconfig`).
- Update `changelog.md` (Keep a Changelog, everything under Unreleased until
  the first store release) for any user-visible change; update `README.md`'s
  supported-devices list when products change.
- `SimpScoreData` is pure logic apart from the explicit `persist()` /
  `restore()` methods — don't call `Storage` from its mutators, so the tests
  stay isolated. `persist()` is called only from `SimpScoreApp.onStop`,
  deliberately not after individual actions (see `SimpScoreData.mc`) — don't
  reintroduce per-action persistence without revisiting that tradeoff.
  Add a `(:test)` case in `source-test/SimpScoreDataTest.mc` when you change
  scoring, undo, win, or persistence rules.
