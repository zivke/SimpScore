import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.Test;

// Unit tests for SimpScoreData. Compiled only through monkey-test.jungle
// (source + source-test, built with -t); run with `make test`.
// Each (:test) function returns true to pass.

(:test)
function pointsGoToTheRightSide(logger as Test.Logger) as Boolean {
  var data = new SimpScoreData();
  data.addHomePoint();
  data.addHomePoint();
  data.addAwayPoint();
  return data.getHomeScore() == 2 && data.getAwayScore() == 1;
}

(:test)
function undoIsLastInFirstOut(logger as Test.Logger) as Boolean {
  var data = new SimpScoreData();
  data.addHomePoint();   // 1-0
  data.addAwayPoint();   // 1-1
  data.addAwayPoint();   // 1-2
  data.undoLastAction(); // 1-1
  data.undoLastAction(); // 1-0
  return data.getHomeScore() == 1 && data.getAwayScore() == 0;
}

(:test)
function undoWithNoHistoryDoesNotUnderflow(logger as Test.Logger) as Boolean {
  var data = new SimpScoreData();
  data.undoLastAction();
  return data.getHomeScore() == 0 && data.getAwayScore() == 0;
}

(:test)
function winNeedsTwoPointMargin(logger as Test.Logger) as Boolean {
  var data = new SimpScoreData();
  data.setWinAt(5);
  // Alternate up to 5-4 without ever passing through a win state.
  var toHome = [true, false, true, false, true, false, true, false, true];
  for (var i = 0; i < toHome.size(); i++) {
    if (toHome[i]) { data.addHomePoint(); } else { data.addAwayPoint(); }
  }
  if (data.getHomeScore() != 5 || data.getAwayScore() != 4) { return false; }
  if (data.checkWin()) { return false; } // 5-4 is not a win
  data.addHomePoint();                    // 6-4
  return data.checkWin();                 // now it is
}

(:test)
function pointsAreIgnoredAfterWin(logger as Test.Logger) as Boolean {
  var data = new SimpScoreData();
  data.setWinAt(2);
  data.addHomePoint();
  data.addHomePoint(); // 2-0 -> won
  data.addHomePoint(); // ignored
  data.addAwayPoint(); // ignored
  return data.getHomeScore() == 2 && data.getAwayScore() == 0;
}

(:test)
function resetClearsScoreAndHistory(logger as Test.Logger) as Boolean {
  var data = new SimpScoreData();
  data.addHomePoint();
  data.addAwayPoint();
  data.reset();
  if (data.getHomeScore() != 0 || data.getAwayScore() != 0) { return false; }
  data.undoLastAction(); // history was cleared -> must not underflow
  return data.getHomeScore() == 0 && data.getAwayScore() == 0;
}

(:test)
function winAtIsConfigurable(logger as Test.Logger) as Boolean {
  var data = new SimpScoreData();
  data.setWinAt(11);
  return data.getWinAt() == 11;
}

(:test)
function winScoreOffNeverWins(logger as Test.Logger) as Boolean {
  var data = new SimpScoreData();
  data.setWinAt(null);
  for (var i = 0; i < 40; i++) {
    data.addHomePoint();
  }
  return data.getHomeScore() == 40 && !data.checkWin();
}

(:test)
function winScoreTogglesOffAndBackOn(logger as Test.Logger) as Boolean {
  var data = new SimpScoreData();
  data.setWinAt(null);
  if (data.getWinAt() != null) { return false; }
  data.setWinAt(11);
  return data.getWinAt() == 11;
}

function clearPersisted() as Void {
  Storage.deleteValue(STORAGE_HOME);
  Storage.deleteValue(STORAGE_AWAY);
  Storage.deleteValue(STORAGE_ACTIONS);
  Storage.deleteValue(STORAGE_WIN_AT);
}

(:test)
function persistRestoresScoreHistoryAndWinScore(logger as Test.Logger) as Boolean {
  clearPersisted();
  var a = new SimpScoreData();
  a.setWinAt(15);
  a.addHomePoint();
  a.addHomePoint();
  a.addAwayPoint();
  a.persist();

  var b = new SimpScoreData();
  b.restore();
  var ok = b.getHomeScore() == 2 && b.getAwayScore() == 1 && b.getWinAt() == 15;
  b.undoLastAction(); // restored history: drops the last (away) point
  ok = ok && b.getHomeScore() == 2 && b.getAwayScore() == 0;

  clearPersisted();
  return ok;
}

(:test)
function persistRoundTripsWinScoreOff(logger as Test.Logger) as Boolean {
  clearPersisted();
  var a = new SimpScoreData();
  a.setWinAt(null);
  a.persist();

  var b = new SimpScoreData();
  b.restore();
  var ok = b.getWinAt() == null;

  clearPersisted();
  return ok;
}
