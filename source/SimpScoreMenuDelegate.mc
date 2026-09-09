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
// "Win Score" opens a two-wheel number Picker (tens, ones); 00 means "off".
// On accept the value is written to the model and the "Win Score" sub-label
// is refreshed in place.

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

// Horizontal anchor + justification for a menu / picker title. Menu2 anchors
// the title's left edge at locX and ignores justification, so centring uses
// the LAYOUT_HALIGN_CENTER sentinel rather than a pixel position.
function titleLocX() as Number {
  return centreTitles()
    ? WatchUi.LAYOUT_HALIGN_CENTER
    : titleInset();
}

function titleJustification() as Graphics.TextJustification {
  return centreTitles()
    ? Graphics.TEXT_JUSTIFY_CENTER
    : Graphics.TEXT_JUSTIFY_LEFT;
}

function winScoreSubLabel(winAt as Number?) as String {
  if (winAt == null) {
    return menuString(Rez.Strings.menu_win_score_off);
  }
  return winAt.toString();
}

function buildMainMenu(data as SimpScoreData) as WatchUi.Menu2 {
  // The app name as the title, via a Text drawable (a plain string title
  // wraps mid-word in the narrow Menu2 title area). Left-inset on Instinct,
  // centred elsewhere. :icon is also set for the sub-window on devices that
  // use it.
  var title = new WatchUi.Text({
    :text => menuString(Rez.Strings.AppName),
    :color => Graphics.COLOR_WHITE,
    :font => Graphics.FONT_SMALL,
    :justification => titleJustification(),
    :locX => titleLocX(),
    :locY => WatchUi.LAYOUT_VALIGN_CENTER,
  });
  var menu = new WatchUi.Menu2({
    :title => title,
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

function buildWinScorePicker(data as SimpScoreData) as WatchUi.Picker {
  var current = data.getWinAt();
  var value = (current == null) ? 0 : current;

  var title = new WatchUi.Text({
    :text => menuString(Rez.Strings.menu_win_score),
    :color => Graphics.COLOR_BLACK,
    :font => Graphics.FONT_TINY,
    :justification => titleJustification(),
    :locX => titleLocX(),
    :locY => WatchUi.LAYOUT_VALIGN_BOTTOM,
  });

  return new WinScorePicker({
    :title => title,
    :pattern =>
      [new DigitPickerFactory(), new DigitPickerFactory()] as Array<WatchUi.PickerFactory>,
    :defaults => [value / 10, value % 10] as Array<Number>,
    // Picker's built-in arrows and confirm mark are white; override them so
    // they show on the white background too.
    :previousArrow => pickerArrow(Rez.Drawables.PickerArrowDown),
    :nextArrow => pickerArrow(Rez.Drawables.PickerArrowUp),
    :confirm => new WatchUi.Text({
      :text => menuString(Rez.Strings.picker_confirm),
      :color => Graphics.COLOR_BLACK,
      :font => Graphics.FONT_MEDIUM,
      :locX => WatchUi.LAYOUT_HALIGN_CENTER,
      :locY => WatchUi.LAYOUT_VALIGN_CENTER,
    }),
  });
}

// A centred black arrow bitmap for one of the Picker's scroll slots.
function pickerArrow(rezId as ResourceId) as WatchUi.Bitmap {
  return new WatchUi.Bitmap({
    :rezId => rezId,
    :locX => WatchUi.LAYOUT_HALIGN_CENTER,
    :locY => WatchUi.LAYOUT_VALIGN_CENTER,
  });
}

// Black-on-white to match the score screen; WatchUi.Picker is dark by default.
class WinScorePicker extends WatchUi.Picker {
  function initialize(options as {
    :title as WatchUi.Drawable,
    :pattern as Array<WatchUi.PickerFactory>,
    :defaults as Array<Number>,
    :previousArrow as WatchUi.Drawable,
    :nextArrow as WatchUi.Drawable,
    :confirm as WatchUi.Drawable,
  }) {
    Picker.initialize(options);
  }

  function onUpdate(dc as Graphics.Dc) as Void {
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
    dc.clear();
    Picker.onUpdate(dc);
  }
}

// One 0-9 wheel. Two of these make the two-digit win-score picker.
class DigitPickerFactory extends WatchUi.PickerFactory {
  function initialize() {
    PickerFactory.initialize();
  }

  function getSize() as Number {
    return 10;
  }

  function getValue(index as Number) as Object? {
    return index;
  }

  function getDrawable(index as Number, isSelected as Boolean) as Drawable? {
    return new WatchUi.Text({
      :text => index.toString(),
      :color => Graphics.COLOR_BLACK,
      :font => Graphics.FONT_NUMBER_MEDIUM,
      :locX => WatchUi.LAYOUT_HALIGN_CENTER,
      :locY => WatchUi.LAYOUT_VALIGN_CENTER,
    });
  }
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
      WatchUi.pushView(
        buildWinScorePicker(_data),
        new WinScorePickerDelegate(_data, item),
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

class WinScorePickerDelegate extends WatchUi.PickerDelegate {
  private var _data as SimpScoreData;
  private var _winScoreItem as WatchUi.MenuItem;

  function initialize(data as SimpScoreData, winScoreItem as WatchUi.MenuItem) {
    PickerDelegate.initialize();
    _data = data;
    _winScoreItem = winScoreItem;
  }

  function onAccept(values as Array) as Boolean {
    var tens = values[0] as Number;
    var ones = values[1] as Number;
    var value = tens * 10 + ones;
    _data.setWinAt(value == 0 ? null : value);
    _data.persist();
    _winScoreItem.setSubLabel(winScoreSubLabel(_data.getWinAt()));
    WatchUi.popView(WatchUi.SLIDE_DOWN);
    WatchUi.requestUpdate();
    return true;
  }

  function onCancel() as Boolean {
    WatchUi.popView(WatchUi.SLIDE_DOWN);
    return true;
  }
}
