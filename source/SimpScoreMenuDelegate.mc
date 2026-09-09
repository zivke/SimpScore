import Toybox.Graphics;
import Toybox.Lang;
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

function winScoreSubLabel(winAt as Number?) as String {
  if (winAt == null) {
    return menuString(Rez.Strings.menu_win_score_off);
  }
  return winAt.toString();
}

function buildMainMenu(data as SimpScoreData) as WatchUi.Menu2 {
  // The app name as the title, drawn left-aligned via a Text drawable (a
  // plain string title centres and wraps mid-word in the narrow Menu2 title
  // area). :icon is also set for the sub-window on devices that use it.
  var title = new WatchUi.Text({
    :text => menuString(Rez.Strings.AppName),
    :color => Graphics.COLOR_WHITE,
    :font => Graphics.FONT_SMALL,
    :justification => Graphics.TEXT_JUSTIFY_LEFT,
    :locX => WatchUi.LAYOUT_HALIGN_LEFT,
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
    :color => Graphics.COLOR_WHITE,
    :font => Graphics.FONT_TINY,
    :locX => WatchUi.LAYOUT_HALIGN_LEFT,
    :locY => WatchUi.LAYOUT_VALIGN_BOTTOM,
  });

  return new WatchUi.Picker({
    :title => title,
    :pattern =>
      [new DigitPickerFactory(), new DigitPickerFactory()] as Array<WatchUi.PickerFactory>,
    :defaults => [value / 10, value % 10] as Array<Number>,
  });
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
      :color => Graphics.COLOR_WHITE,
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
