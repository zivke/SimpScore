# SimpScore

A Garmin Connect IQ watch app for keeping score in two-sided games — sports,
board games, anything with a **home** and an **away** side.

- one button per side, one point at a time
- undo the last point (full history, not just the last one)
- optional win score, set with a two-digit picker (00 = off)
- "win by 2" rule, toggleable
- time of day on the score screen
- new game / reset from the options menu
- one score screen, one menu
- score, history, win score and settings are kept when you leave and reopen the app

See **[MANUAL.md](MANUAL.md)** for the full user guide.

## Controls

| Button        | Action                          |
|---------------|---------------------------------|
| Up            | Home point                      |
| Down          | Away point                      |
| Start / Enter | Undo last point                 |
| Menu (hold)   | Options (new game, win score, win by 2) |

## Build & run

The [devcontainer](.devcontainer/README.md) has the SDK, simulator and signing
key set up already — don't install them. All commands go through the `Makefile`:

```sh
make build        # compile a debug .prg for $(DEVICE) (default: instinct2)
make sim          # start the simulator (no-op if already running)
make run          # build, then push and run on the simulator
make test         # build and run the unit tests in the simulator
make release      # debug info stripped
make clean        # remove build output
make help         # list every target
```

Target another device with `make run DEVICE=fenix7` (download it first with
`make dev-device DEVICE=fenix7`).

## Tests

`source-test/` holds the unit tests for `SimpScoreData` (scoring, undo, the
win-by-two rule). They compile via `monkey-test.jungle` and run in the
simulator: `make test`. It exits non-zero if any test fails or the runner
never reports a result.

## Layout

| Path                                | What                                             |
|-------------------------------------|--------------------------------------------------|
| `source/`                           | app code                                         |
| `source-test/`                      | unit tests (test build only)                     |
| `resources/`                        | strings and drawables (the menu is built in code) |
| `resources-semioctagon-176x176/`    | layout for the instinct2's screen shape/size     |
| `manifest.xml`                      | product list, permissions, languages             |
| `monkey.jungle` / `monkey-test.jungle` | app build / test build                        |

All user-visible text lives in `resources/strings/strings.xml`.

## Supported devices

- Instinct 2 (`instinct2`)

More devices need a manifest entry plus a `resources-<shape>/layout.xml` for
their screen shape.

## License

[0BSD](LICENSE) — do anything, no attribution required, no warranty.
