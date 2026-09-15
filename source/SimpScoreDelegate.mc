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

  // Touch-and-hold on the screen also opens the menu. This is the only menu
  // access on touch-first watches with no physical menu button whose API
  // level predates setActionMenuIndicator/onActionMenu (e.g. venu2, venu3,
  // vivoactive5, d2air, vivoactive4 — real devices reported "no menu, no
  // button for that"): WatchUi.InputDelegate.onHold is a raw touch event
  // available since API 1.0.0, so it doesn't depend on that support.
  function onHold(clickEvent as WatchUi.ClickEvent) as Boolean {
    if (!isTouchScreen()) {
      return false;
    }
    return onMenu();
  }

  function onPreviousPage() as Boolean {
    var changed = _data.addHomePoint();
    if (changed) {
      _data.persist();
    }
    WatchUi.requestUpdate();
    if (changed && _data.checkWin()) {
      vibrate();
    }
    return true;
  }

  function onNextPage() as Boolean {
    var changed = _data.addAwayPoint();
    if (changed) {
      _data.persist();
    }
    WatchUi.requestUpdate();
    if (changed && _data.checkWin()) {
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
