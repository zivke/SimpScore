import Toybox.Lang;
import Toybox.WatchUi;

class SimpScoreDelegate extends WatchUi.BehaviorDelegate {
  private var _data as SimpScoreData;

  function initialize(data as SimpScoreData) {
    self._data = data;

    BehaviorDelegate.initialize();
  }

  function onMenu() as Boolean {
    WatchUi.pushView(
      buildMainMenu(_data),
      new SimpScoreMenuDelegate(_data),
      WatchUi.SLIDE_UP
    );
    return true;
  }

  function onPreviousPage() as Boolean {
    _data.addHomePoint();
    WatchUi.requestUpdate();
    if (_data.checkWin()) {
      vibrate();
    }
    return true;
  }

  function onNextPage() as Boolean {
    _data.addAwayPoint();
    WatchUi.requestUpdate();
    if (_data.checkWin()) {
      vibrate();
    }
    return true;
  }

  function onSelect() as Boolean {
    _data.undoLastAction();
    WatchUi.requestUpdate();
    return true;
  }

  function vibrate() as Void {
    if (Attention has :vibrate) {
      Attention.vibrate([
        // 100% strength, 500ms duration
        new Attention.VibeProfile(100, 3000),
      ]);
    }
  }
}
