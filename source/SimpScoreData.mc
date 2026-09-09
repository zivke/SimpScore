import Toybox.Application;
import Toybox.Lang;
import Toybox.System;

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
