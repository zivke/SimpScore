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

  // Swipe-to-reveal menu access on touch-first watches with no physical
  // menu button (Venu X1 and siblings) that show the action menu indicator
  // SimpScoreView.onShow sets. Same menu as onMenu.
  function onActionMenu() as Boolean {
    return onMenu();
  }

  function onPreviousPage() as Boolean {
    if (_data.addHomePoint()) {
      _data.persist();
    }
    WatchUi.requestUpdate();
    if (_data.checkWin()) {
      vibrate();
    }
    return true;
  }

  function onNextPage() as Boolean {
    if (_data.addAwayPoint()) {
      _data.persist();
    }
    WatchUi.requestUpdate();
    if (_data.checkWin()) {
      vibrate();
    }
    return true;
  }

  function onSelect() as Boolean {
    if (_data.undoLastAction()) {
      _data.persist();
    }
    WatchUi.requestUpdate();
    return true;
  }

  function vibrate() as Void {
    if (Attention has :vibrate) {
      Attention.vibrate([
        // 100% strength, 3000ms duration: a long, unmissable win buzz.
        new Attention.VibeProfile(100, 3000),
      ]);
    }
  }
}
