import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// The options menu, built in code as a Menu2:
//
//   New Game
//   Win Score            <current value, or "Off">
//
// Selecting "Win Score" opens a number Picker: index 0 is "Off", 1..WIN_SCORE_MAX
// are the score. On accept the value is written to the model (0 -> null) and the
// "Win Score" row's sub-label is updated in place so it is current when the
// picker pops.

const WIN_SCORE_MAX = 99;

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
  var menu = new WatchUi.Menu2({ :title => menuString(Rez.Strings.AppName) });
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
  return menu;
}

function buildWinScorePicker(data as SimpScoreData) as WatchUi.Picker {
  var current = data.getWinAt();
  var startIndex = (current == null) ? 0 : current;
  if (startIndex > WIN_SCORE_MAX) {
    startIndex = WIN_SCORE_MAX;
  }

  var title = new WatchUi.Text({
    :text => menuString(Rez.Strings.menu_win_score),
    :color => Graphics.COLOR_WHITE,
    :font => Graphics.FONT_TINY,
    :locX => WatchUi.LAYOUT_HALIGN_CENTER,
    :locY => WatchUi.LAYOUT_VALIGN_BOTTOM,
  });

  return new WatchUi.Picker({
    :title => title,
    :pattern => [new WinScorePickerFactory()] as Array<WatchUi.PickerFactory>,
    :defaults => [startIndex] as Array<Number>,
  });
}

class WinScorePickerFactory extends WatchUi.PickerFactory {
  function initialize() {
    PickerFactory.initialize();
  }

  function getSize() as Number {
    return WIN_SCORE_MAX + 1; // index 0 == "Off", 1..WIN_SCORE_MAX
  }

  function getValue(index as Number) as Object? {
    return index;
  }

  function getDrawable(index as Number, isSelected as Boolean) as Drawable? {
    var label = (index == 0) ? menuString(Rez.Strings.menu_win_score_off) : index.toString();
    return new WatchUi.Text({
      :text => label,
      :color => Graphics.COLOR_WHITE,
      :font => Graphics.FONT_NUMBER_MILD,
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
    var value = values[0] as Number?;
    _data.setWinAt((value == null || value == 0) ? null : value);
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
