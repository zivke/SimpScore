import Toybox.Application.Storage;
import Toybox.Lang;

// Storage keys for persist()/restore().
const STORAGE_HOME = "homeScore";
const STORAGE_AWAY = "awayScore";
const STORAGE_ACTIONS = "actions";
const STORAGE_WIN_AT = "winAt";

class SimpScoreData {
  enum Action {
    HOME_POINT = 0,
    AWAY_POINT = 1,
  }

  // null means no win score: checkWin() is always false and play continues.
  private var _winAt as Number? = 7;

  private var _homeScore as Number;
  private var _awayScore as Number;

  private var _actions as Array<Action>;

  function initialize() {
    self._homeScore = 0;
    self._awayScore = 0;
    self._actions = [];
  }

  function reset() as Void {
    initialize();
  }

  // Persistence. Deliberately not called by this class's own mutators: the app
  // lifecycle (onStart/onStop) and the input delegates drive it, so unit tests
  // that exercise the model never touch Storage. Win score persists as 0 = off.
  function persist() as Void {
    Storage.setValue(STORAGE_HOME, _homeScore);
    Storage.setValue(STORAGE_AWAY, _awayScore);
    Storage.setValue(STORAGE_ACTIONS, _actions as Array<Number>);
    Storage.setValue(STORAGE_WIN_AT, _winAt == null ? 0 : _winAt);
  }

  function restore() as Void {
    var home = Storage.getValue(STORAGE_HOME);
    if (home instanceof Number) {
      _homeScore = home;
    }

    var away = Storage.getValue(STORAGE_AWAY);
    if (away instanceof Number) {
      _awayScore = away;
    }

    var actions = Storage.getValue(STORAGE_ACTIONS);
    if (actions instanceof Array) {
      _actions = actions as Array<Action>;
    }

    var winAt = Storage.getValue(STORAGE_WIN_AT);
    if (winAt instanceof Number) {
      _winAt = (winAt == 0) ? null : winAt;
    }
  }

  function getWinAt() as Number? {
    return self._winAt;
  }

  function setWinAt(winAt as Number?) as Void {
    self._winAt = winAt;
  }

  function getHomeScore() as Number {
    return self._homeScore;
  }

  function getAwayScore() as Number {
    return self._awayScore;
  }

  function addHomePoint() as Void {
    if (checkWin()) {
      return;
    }

    self._homeScore += 1;
    self._actions.add(HOME_POINT);
  }

  function addAwayPoint() as Void {
    if (checkWin()) {
      return;
    }

    self._awayScore += 1;
    self._actions.add(AWAY_POINT);
  }

  function undoLastAction() as Void {
    if (self._actions.size() == 0) {
      return;
    }

    var lastAction = self._actions[_actions.size() - 1];
    if (lastAction == HOME_POINT) {
      self._homeScore -= 1;
    } else if (lastAction == AWAY_POINT) {
      self._awayScore -= 1;
    }

    _actions = _actions.slice(0, _actions.size() - 1);
  }

  function checkWin() as Boolean {
    var winAt = self._winAt;
    if (winAt == null) {
      return false;
    }

    if (
      (_homeScore >= winAt || _awayScore >= winAt) &&
      (_homeScore - _awayScore).abs() > 1
    ) {
      return true;
    }

    return false;
  }
}
