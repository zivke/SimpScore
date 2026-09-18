# SimpScore — User Manual

SimpScore keeps the score in any two‑sided game: **HOME** vs **AWAY**. One
point at a time, an undo, an optional target score, and nothing else to get in
the way.

## The screen

```
        12:34            <- time of day
         (7)             <- win score, in the round sub‑window (a dash = off)
   HOME       AWAY
     4          3        <- the score
```

The screen stays on the score the whole time the app is open.

## Buttons

| Button        | Press        | What it does              |
|---------------|--------------|---------------------------|
| **UP**        | short        | +1 to HOME (−1 in Count Down mode) |
| **DOWN**      | short        | +1 to AWAY (−1 in Count Down mode) |
| **START**     | short        | undo the last point       |
| **MENU**      | hold         | open the options menu     |
| **BACK**      | short        | leave the app             |

Undo steps back through every point, in order, as many times as you press it —
not just the last one.

On watches with a touchscreen and no physical MENU button, touch and hold
anywhere on the screen to open the options menu instead. A few touch watches
(Venu X1 and similar) show a swipe indicator at the edge of the screen for the
same thing.

When a side reaches the win score (or, in Count Down mode, drops to 0) the
watch buzzes and further points are ignored until you start a new game.

## Options menu

Hold **MENU** to open it.

### New Game

Resets HOME and AWAY to 0 (or to the win score, in Count Down mode) and
clears the undo history. Your settings are kept.

### Win Score / Start At

Opens a two‑wheel picker: a **tens** wheel and a **ones** wheel, 0–9 each. In
the default mode, set any target from 1 to 99 to win at. In Count Down mode
(where this screen is titled "Start At" instead) set the number both sides
start from and count down toward 0.

- **UP / DOWN** change the highlighted wheel (hold to repeat).
- **START** moves to the next wheel, then confirms.
- **BACK** cancels.

On touchscreen watches with no physical START button, tap the on-screen **OK**
button instead.

Set both wheels to **0** for **Off** — no target/starting point, play
continues indefinitely. The current value (or `Off`) is shown next to "Win
Score"/"Start At" in the menu and on the score screen. Changing this number
while Count Down is on starts a fresh game at the new number.

### Win by 2

A toggle, only shown while Count Down is off.

- **On** (default): to win, a side must reach the win score **and** lead by at
  least two points — like table tennis or volleyball. At 10–10 with a win
  score of 11, play continues until someone is two ahead.
- **Off**: the first side to reach the win score wins, margin or not.

Has no effect while the win score is Off.

### Count Down

A toggle (default off), last in the menu. Games like Magic: the Gathering
(life totals) or darts (301/501) count *down* to zero instead of up to a
target:

- **On**: UP/DOWN subtract instead of add. Both sides start a new game at the
  Start At number (0 if it's Off), and the game ends the instant either side
  reaches 0. The "WIN" caption on the score screen (and the menu item) reads
  "START" instead, and "Win by 2" disappears from the menu — there's no
  shared lead to speak of when each side is falling toward its own zero.
- **Off** (default): the usual count-up-to-a-target scoring.

Turning this on or off always starts a fresh game.

## Saving

Everything — the score, the full undo history, the win score and the Win‑by‑2
and Count Down settings — is saved when you leave the app, and comes back
exactly where you left it next time you open it. If the watch loses power or
the app is otherwise closed unexpectedly rather than being left normally,
whatever game was in progress is not saved.

## Supported watches

Most current Garmin watches — the fēnix, Forerunner, Instinct, Venu, epix, MARQ,
D2, Descent, vívoactive and Approach families, round, rectangular and
Instinct-shaped screens alike. See `manifest.xml` for the exact list.
