import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

// The options menu (Menu2, built in code):
//
//   New Game
//   Win Score / Start At <current value, or "Off">
//   Win by 2             [toggle, hidden while Count Down is on]
//   Count Down           [toggle]
//
// "Win Score"/"Start At" opens WinScoreView, a custom two-digit (tens,
// ones) entry screen; 00 means "off". On confirm the value is written to
// the model and the sub-label is refreshed in place. Count Down flips
// scoring direction (see SimpScoreData._countDown); Win by 2 has no meaning
// there (no shared lead when each side counts down independently), so it's
// omitted from the menu rather than left as a dead control.

function menuString(id as ResourceId) as String {
  return WatchUi.loadResource(id) as String;
}

// Watches with a physical sub-screen have WinScoreView's title stay
// left-inset there (the score screen is off-centre too) to clear it. Every
// other watch centres it. Deliberately keyed on hasSubscreen() below, not
// screen shape: instinct3amoled45mm/50mm report a round shape but still
// have a real sub-screen, so a shape check centred the title right over it.
// The options menu itself uses a system-positioned plain-string title on
// every shape (see buildMainMenu) — a custom Text-drawable title didn't
// hold up on real hardware (c09f72d had already reverted this for
// round/rectangular; a real Instinct 2 then showed the same class of bug:
// the title overlapping the sub-screen despite the simulator measuring a
// clear gap).
function centreTitles() as Boolean {
  return !hasSubscreen();
}

// Left inset for WinScoreView's title on Instinct: 6% of the screen width,
// so the text sits just off the edge rather than flush against it.
function titleInset() as Number {
  return System.getDeviceSettings().screenWidth * 6 / 100;
}

// "Win Score" reaches a target; "Start At" is the number a Count Down game
// starts from and falls away from. Shared with WinScoreView's own title.
function winScoreMenuLabel(countDown as Boolean) as String {
  return menuString(countDown ? Rez.Strings.menu_start_at : Rez.Strings.menu_win_score);
}

function winScoreSubLabel(winAt as Number?) as String {
  if (winAt == null) {
    return menuString(Rez.Strings.menu_win_score_off);
  }
  return winAt.toString();
}

// Menu2's :icon option is only used on devices with a physical sub-screen
// (per the SDK docs), where it's rendered on that sub-screen's own hardware.
// Reported on a real Instinct 2: our launcher icon glitches there, so
// buildMainMenu omits :icon entirely rather than risk it looking broken.
// `has`-guarded: getSubscreen() is API 3.2.7, this app's minApiLevel is
// 3.2.0.
function hasSubscreen() as Boolean {
  return (WatchUi has :getSubscreen) && (WatchUi.getSubscreen() != null);
}

function buildMainMenu(data as SimpScoreData) as WatchUi.Menu2 {
  // Plain string on every shape, including Instinct (see centreTitles()
  // above for why). Not the app name: "SimpScore" wraps to two lines on the
  // narrower semi-octagon screens, pushing the item list down and clipping
  // it (a real Instinct 2 showed this).
  var title = menuString(Rez.Strings.menu_title);

  var menu = hasSubscreen()
    ? new WatchUi.Menu2({ :title => title })
    : new WatchUi.Menu2({ :title => title, :icon => Rez.Drawables.LauncherIcon });
  menu.addItem(
    new WatchUi.MenuItem(menuString(Rez.Strings.menu_new_game), null, :new_game, null)
  );
  menu.addItem(
    new WatchUi.MenuItem(
      winScoreMenuLabel(data.getCountDown()),
      winScoreSubLabel(data.getWinAt()),
      :win_score,
      null
    )
  );
  if (!data.getCountDown()) {
    menu.addItem(
      new WatchUi.ToggleMenuItem(
        menuString(Rez.Strings.menu_win_by_2),
        null,
        :win_by_2,
        data.getWinBy2(),
        null
      )
    );
  }
  menu.addItem(
    new WatchUi.ToggleMenuItem(
      menuString(Rez.Strings.menu_count_down),
      null,
      :count_down,
      data.getCountDown(),
      null
    )
  );
  return menu;
}

class SimpScoreMenuDelegate extends WatchUi.Menu2InputDelegate {
  private var _data as SimpScoreData;

  function initialize(data as SimpScoreData) {
    Menu2InputDelegate.initialize();
    _data = data;
  }

  function onSelect(item as WatchUi.MenuItem) as Void {
    var id = item.getId();
    if (id == :new_game) {
      _data.reset();
      WatchUi.popView(WatchUi.SLIDE_DOWN);
      WatchUi.requestUpdate();
    } else if (id == :win_score) {
      var view = new WinScoreView(_data.getWinAt(), _data.getCountDown());
      WatchUi.pushView(
        view,
        new WinScoreDelegate(_data, view, item),
        WatchUi.SLIDE_LEFT
      );
    } else if (id == :win_by_2) {
      _data.setWinBy2((item as WatchUi.ToggleMenuItem).isEnabled());
      // The rule change can win or un-win the current game; redraw the
      // score screen behind the menu so it reflects the new state.
      WatchUi.requestUpdate();
    } else if (id == :count_down) {
      _data.setCountDown((item as WatchUi.ToggleMenuItem).isEnabled());
      _data.reset();
      // Unlike Win by 2, this always starts a fresh game and changes the
      // Win Score/Start At item's title, which Menu2 can't relabel live —
      // pop back to the score screen instead of leaving a stale menu open.
      WatchUi.popView(WatchUi.SLIDE_DOWN);
      WatchUi.requestUpdate();
    }
  }
}
