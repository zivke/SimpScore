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
| **UP**        | short        | +1 to HOME                |
| **DOWN**      | short        | +1 to AWAY                |
| **START**     | short        | undo the last point       |
| **MENU**      | hold         | open the options menu     |
| **BACK**      | short        | leave the app             |

Undo steps back through every point, in order, as many times as you press it —
not just the last one.

When a side reaches the win score the watch buzzes and further points are
ignored until you start a new game.

## Options menu

Hold **MENU** to open it.

### New Game

Resets HOME and AWAY to 0 and clears the undo history. Your win‑score settings
are kept.

### Win Score

Opens a two‑wheel picker: a **tens** wheel and a **ones** wheel, 0–9 each. Set
any target from 1 to 99.

- **UP / DOWN** change the highlighted wheel (hold to repeat).
- **START** moves to the next wheel, then confirms.
- **BACK** cancels.

Set both wheels to **0** for **Off** — no target, play continues indefinitely.
The current value (or `Off`) is shown next to "Win Score" in the menu and in
the round sub‑window on the score screen.

### Win by 2

A toggle.

- **On** (default): to win, a side must reach the win score **and** lead by at
  least two points — like table tennis or volleyball. At 10–10 with a win
  score of 11, play continues until someone is two ahead.
- **Off**: the first side to reach the win score wins, margin or not.

Has no effect while the win score is Off.

## Saving

Everything — the score, the full undo history, the win score and the Win‑by‑2
setting — is saved automatically. Leave the app or restart the watch and it
comes back exactly where you left it.

## Supported watches

Most current Garmin watches — the fēnix, Forerunner, Instinct, Venu, epix, MARQ,
D2, Descent, vívoactive and Approach families, round, rectangular and
Instinct-shaped screens alike. See `manifest.xml` for the exact list.
