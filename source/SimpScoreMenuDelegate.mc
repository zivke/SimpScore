import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class SimpScoreMenuDelegate extends WatchUi.MenuInputDelegate {
  private var _data as SimpScoreData;

  function initialize(data as SimpScoreData) {
    self._data = data;

    MenuInputDelegate.initialize();
  }

  function onMenuItem(item as Symbol) as Void {
    if (item == :item_1) {
      _data.reset();
    } else if (item == :item_2) {
      _data.setWinAt(7);
    } else if (item == :item_3) {
      _data.setWinAt(11);
    } else if (item == :item_4) {
      _data.setWinAt(21);
    }
  }
}
