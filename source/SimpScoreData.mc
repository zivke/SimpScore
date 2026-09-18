import Toybox.Application.Storage;
import Toybox.Lang;

// Storage keys for persist()/restore().
const STORAGE_HOME = "homeScore";
const STORAGE_AWAY = "awayScore";
const STORAGE_ACTIONS = "actions";
const STORAGE_WIN_AT = "winAt";
const STORAGE_WIN_BY_2 = "winBy2";
const STORAGE_COUNT_DOWN = "countDown";

class SimpScoreData {
  enum Action {
    HOME_POINT = 0,
    AWAY_POINT = 1,
  }

  // null means no win score: checkWin() is always false and play continues.
  private var _winAt as Number? = 7;

  // When true, winning also requires a two-point lead; when false, first side
  // to reach the win score wins. Ignored entirely when _countDown is true
  // (see checkWin()) — a shared lead has no meaning when each side counts
  // down toward its own zero independently.
  private var _winBy2 as Boolean = true;

  // When true, points subtract instead of add, both sides start a new game
  // at _winAt (0 if Win Score is Off), and a side reaching 0 ends the game
  // — e.g. Magic: the Gathering life totals — as opposed to the default
  // count-up-to-a-target mode.
  private var _countDown as Boolean = false;

  private var _homeScore as Number;
  private var _awayScore as Number;

  private var _actions as Array<Action>;

  function initialize() {
    self._homeScore = startingScore();
    self._awayScore = startingScore();
    self._actions = [];
  }

  function reset() as Void {
    initialize();
  }

  // Both sides start here: _winAt in Count Down mode (0 if Win Score is
  // Off), otherwise always 0. Safe to read _countDown/_winAt from
  // initialize(): a hand-called reset() re-invokes this without re-running
  // field initializers, so it sees whatever settings the user last set,
  // same as _winAt/_winBy2 already relied on surviving reset().
  private function startingScore() as Number {
    return (_countDown && _winAt != null) ? (_winAt as Number) : 0;
  }

  // Persistence. Deliberately not called by this class's own mutators: only
  // the app lifecycle (onStop) drives it, so unit tests that exercise the
  // model never touch Storage. Win score persists as 0 = off.
  //
  // Called only on app exit, not after every point/undo/menu change: a real
  // device's flash write is slow enough to show up as input lag on every
  // single button press (rewriting the win-score settings and
  // re-serializing the whole, unbounded actions array each time), even
  // though it's free against the simulator's filesystem-backed Storage. The
  // deliberate tradeoff is that a game in progress is lost if the app is
  // killed uncleanly (crash, low-battery shutdown, force-kill) rather than
  // exited normally, in exchange for no per-press write cost at all.
  function persist() as Void {
    Storage.setValue(STORAGE_HOME, _homeScore);
    Storage.setValue(STORAGE_AWAY, _awayScore);
    Storage.setValue(STORAGE_ACTIONS, _actions as Array<Storage.ValueType>);
    Storage.setValue(STORAGE_WIN_AT, _winAt == null ? 0 : _winAt);
    Storage.setValue(STORAGE_WIN_BY_2, _winBy2);
    Storage.setValue(STORAGE_COUNT_DOWN, _countDown);
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

    var winBy2 = Storage.getValue(STORAGE_WIN_BY_2);
    if (winBy2 instanceof Boolean) {
      _winBy2 = winBy2;
    }

    var countDown = Storage.getValue(STORAGE_COUNT_DOWN);
    if (countDown instanceof Boolean) {
      _countDown = countDown;
    }
  }

  function getWinAt() as Number? {
    return self._winAt;
  }

  function setWinAt(winAt as Number?) as Void {
    self._winAt = winAt;
  }

  function getWinBy2() as Boolean {
    return self._winBy2;
  }

  function setWinBy2(winBy2 as Boolean) as Void {
    self._winBy2 = winBy2;
  }

  function getCountDown() as Boolean {
    return self._countDown;
  }

  function setCountDown(countDown as Boolean) as Void {
    self._countDown = countDown;
  }

  function getHomeScore() as Number {
    return self._homeScore;
  }

  function getAwayScore() as Number {
    return self._awayScore;
  }

  // The three mutators return whether they actually changed anything, so the
  // input delegates can skip a redundant persist() on a no-op press (a point
  // after the game is won, an undo with empty history).
  function addHomePoint() as Boolean {
    if (checkWin()) {
      return false;
    }

    self._homeScore += (_countDown ? -1 : 1);
    self._actions.add(HOME_POINT);
    return true;
  }

  function addAwayPoint() as Boolean {
    if (checkWin()) {
      return false;
    }

    self._awayScore += (_countDown ? -1 : 1);
    self._actions.add(AWAY_POINT);
    return true;
  }

  // The delta below reverses whatever direction addHomePoint()/
  // addAwayPoint() logged the action with. Always consistent with a given
  // action because toggling _countDown always resets the game (clears
  // _actions) rather than changing direction mid-history.
  function undoLastAction() as Boolean {
    if (self._actions.size() == 0) {
      return false;
    }

    var delta = _countDown ? 1 : -1;
    var lastAction = self._actions[_actions.size() - 1];
    if (lastAction == HOME_POINT) {
      self._homeScore += delta;
    } else if (lastAction == AWAY_POINT) {
      self._awayScore += delta;
    }

    _actions = _actions.slice(0, _actions.size() - 1);
    return true;
  }

  function checkWin() as Boolean {
    var winAt = self._winAt;
    if (winAt == null) {
      return false;
    }

    // Count Down: game ends the instant either side hits the floor. No
    // shared lead to speak of, so _winBy2 is never consulted here.
    if (_countDown) {
      return _homeScore <= 0 || _awayScore <= 0;
    }

    if (_homeScore < winAt && _awayScore < winAt) {
      return false;
    }

    if (_winBy2) {
      return (_homeScore - _awayScore).abs() > 1;
    }

    return _homeScore != _awayScore;
  }
}
