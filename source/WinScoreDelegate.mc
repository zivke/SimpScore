import Toybox.Lang;
import Toybox.WatchUi;

// Drives WinScoreView: previous-page/next-page bump the focused digit,
// select moves focus tens -> ones -> confirms, back moves ones -> tens ->
// cancels. Mirrors the accept/cancel semantics WatchUi.PickerDelegate gave
// the old stock picker for free. On touchscreen devices (no physical select
// button), tapping the on-screen OK button does the same thing as select.
class WinScoreDelegate extends WatchUi.BehaviorDelegate {
  private var _data as SimpScoreData;
  private var _view as WinScoreView;
  private var _winScoreItem as WatchUi.MenuItem;

  function initialize(
    data as SimpScoreData,
    view as WinScoreView,
    winScoreItem as WatchUi.MenuItem
  ) {
    BehaviorDelegate.initialize();
    _data = data;
    _view = view;
    _winScoreItem = winScoreItem;
  }

  function onPreviousPage() as Boolean {
    _view.bumpFocused(1);
    WatchUi.requestUpdate();
    return true;
  }

  function onNextPage() as Boolean {
    _view.bumpFocused(-1);
    WatchUi.requestUpdate();
    return true;
  }

  // First select moves focus from tens to ones; the second confirms.
  function onSelect() as Boolean {
    if (_view.focusOnes()) {
      WatchUi.requestUpdate();
      return true;
    }
    confirm();
    return true;
  }

  // First back moves focus from ones back to tens; the second cancels.
  function onBack() as Boolean {
    if (_view.focusTens()) {
      WatchUi.requestUpdate();
      return true;
    }
    WatchUi.popView(WatchUi.SLIDE_DOWN);
    return true;
  }

  // Tapping the on-screen OK button (touchscreen devices only) does exactly
  // what select does.
  function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
    if (!isTouchScreen()) {
      return false;
    }
    var coords = clickEvent.getCoordinates();
    var bounds = okButtonBounds();
    if (
      coords[0] >= bounds[0] && coords[0] <= bounds[2] &&
      coords[1] >= bounds[1] && coords[1] <= bounds[3]
    ) {
      return onSelect();
    }
    return false;
  }

  private function confirm() as Void {
    _data.setWinAt(winScoreValue(_view.getTens(), _view.getOnes()));
    _data.persist();
    _winScoreItem.setSubLabel(winScoreSubLabel(_data.getWinAt()));
    WatchUi.popView(WatchUi.SLIDE_DOWN);
    WatchUi.requestUpdate();
  }
}
