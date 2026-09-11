import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

// The options menu (Menu2, built in code):
//
//   New Game
//   Win Score            <current value, or "Off">
//   Win by 2             [toggle]
//
// "Win Score" opens WinScoreView, a custom two-digit (tens, ones) entry
// screen; 00 means "off". On confirm the value is written to the model and
// the "Win Score" sub-label is refreshed in place.

function menuString(id as ResourceId) as String {
  return WatchUi.loadResource(id) as String;
}

// Instinct-style watches have a physical sub-screen; there the menu / picker
// titles stay left-inset (the score screen is off-centre too). Every other
// watch centres them.
function centreTitles() as Boolean {
  return System.getDeviceSettings().screenShape != System.SCREEN_SHAPE_SEMI_OCTAGON;
}

// Left inset for menu / picker titles: 6% of the screen width, so the text
// sits just off the edge rather than flush against it.
function titleInset() as Number {
  return System.getDeviceSettings().screenWidth * 6 / 100;
}

// A left-inset Text drawable for a menu / picker title on Instinct, where the
// score screen is left-of-centre too (to clear the sub-screen). Used only when
// centreTitles() is false.
function insetTitle(text as String, color as Graphics.ColorType) as WatchUi.Text {
  return new WatchUi.Text({
    :text => text,
    :color => color,
    :font => Graphics.FONT_TINY,
    :justification => Graphics.TEXT_JUSTIFY_LEFT,
    :locX => titleInset(),
    :locY => WatchUi.LAYOUT_VALIGN_CENTER,
  });
}

function winScoreSubLabel(winAt as Number?) as String {
  if (winAt == null) {
    return menuString(Rez.Strings.menu_win_score_off);
  }
  return winAt.toString();
}

function buildMainMenu(data as SimpScoreData) as WatchUi.Menu2 {
  // Round / rectangular Menu2 centres a plain-string title itself; Instinct's
  // narrow title area needs a left-inset Text drawable to clear the sub-screen
  // (and a bare string wraps mid-word there). :icon is also set for the
  // sub-window on devices that use it.
  var menu = new WatchUi.Menu2({
    :title => centreTitles()
      ? menuString(Rez.Strings.AppName)
      : insetTitle(menuString(Rez.Strings.AppName), Graphics.COLOR_WHITE),
    :icon => Rez.Drawables.LauncherIcon,
  });
  menu.addItem(
    new WatchUi.MenuItem(menuString(Rez.Strings.menu_new_game), null, :new_game, null)
  );
  menu.addItem(
    new WatchUi.MenuItem(
      menuString(Rez.Strings.menu_win_score),
      winScoreSubLabel(data.getWinAt()),
      :win_score,
      null
    )
  );
  menu.addItem(
    new WatchUi.ToggleMenuItem(
      menuString(Rez.Strings.menu_win_by_2),
      null,
      :win_by_2,
      data.getWinBy2(),
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
      _data.persist();
      WatchUi.popView(WatchUi.SLIDE_DOWN);
      WatchUi.requestUpdate();
    } else if (id == :win_score) {
      var view = new WinScoreView(_data.getWinAt());
      WatchUi.pushView(
        view,
        new WinScoreDelegate(_data, view, item),
        WatchUi.SLIDE_LEFT
      );
    } else if (id == :win_by_2) {
      _data.setWinBy2((item as WatchUi.ToggleMenuItem).isEnabled());
      _data.persist();
      // The rule change can win or un-win the current game; redraw the
      // score screen behind the menu so it reflects the new state.
      WatchUi.requestUpdate();
    }
  }
}
