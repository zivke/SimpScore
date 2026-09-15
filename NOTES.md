## TODO

- win-score picker: the "Win Score" title clips off the left edge — finish
  tidying its placement (mid-edit: trying LAYOUT_HALIGN_LEFT).
- win-score picker: the "OK" confirm hint sits mid-screen, not in the Instinct 2
  sub-window. `WatchUi.Picker` doesn't expose its position — would need a fully
  custom picker view. Deferred (decided not to build that for now).
- polish the new top clock band (black strip + icon + time): alignment of the
  icon and the "12:46" label still rough.

## Parked

- stopwatch on the main screen (long-press up/down for start / stop / reset).
  Skipped for now; revisit if wanted.

## Problems

Fixed and confirmed in the simulator (venu2, instinct2, fenix7, d2mach2,
venux1) — see changelog.md for the user-visible descriptions:

- d2air, d2airx10, legacyherocaptainmarvel, legacyherofirstavenger,
  legacysagadarthvader, legacysagarey, venu, venud, venu2, venu2plus,
  venu2s, venu3, venu3s, vivoactive4, vivoactive4s, vivoactive5 - no menu -
  no button for that. `SimpScoreDelegate.onHold` now opens the menu on
  touch-and-hold for any touchscreen device, regardless of API level.
  Confirmed on venu2.
- d2mach2 - couldn't open the menu2 theme background image. Not an app bug —
  a case-mismatched filename in the downloaded device asset pack (only bites
  on this case-sensitive Linux devcontainer). Worked around with symlinks in
  `~/.Garmin/ConnectIQ/Devices/d2mach2/` (outside the repo). Confirmed.
- descentg1, instinct2, instinct3solar45mm, instincte45mm - menu title
  wrapped to two lines, pushing the item list down and clipping "Win Score".
  Menu title changed from the app name to a dedicated short string ("Menu").
  Confirmed on instinct2.
- round faces needed more space between the WIN label and the win-score
  number. Widened the gap in resources/layouts/layout.xml. Confirmed on
  fenix7.
- Win Score entry screen: on semi-octagon (Instinct) devices the title sat
  too close to the top edge. Moved it down (WinScoreView.mc, the left-inset
  branch only). Confirmed on instinct2.

Still open:

- fr970, marqgolfer (and maybe others also) - the up button stops working
  sometimes until another action is done. Happens even early in a fresh,
  low-score game (confirmed not tied to the win buzz). Likely cause: on
  these devices "up" is the same physical key as the hold-for-menu key
  (simulator.json's `keys` list maps both `up`/previousPage and
  `menu`/onMenu(hold) to the same location) — the tap-vs-hold disambiguation
  is done by the device firmware before any app behavior callback fires, and
  `WatchUi.InputDelegate.onKey` is only ever called as a fallback when a
  behavior handler returns false, so it can't bypass that. This pairing is
  common to nearly every physical-button device this app supports, not just
  these two, so device-specific testing won't isolate it further. Couldn't
  reproduce or fix from app code without real hardware.
- instinct2x - menu title partially hidden by the small round sub-display.
  instinct2x's simulator.json has byte-identical `display`/`subscreen`
  geometry to instinct2, so the simulator can't distinguish it from
  instinct2 at all — the menu-title fix above likely fixes this too, but it
  needs a real-hardware check to confirm since the simulator can't show it.

