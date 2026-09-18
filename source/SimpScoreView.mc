import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

class SimpScoreView extends WatchUi.View {
  private var _data as SimpScoreData;
  private var _clockTimer as Timer.Timer?;

  function initialize(data as SimpScoreData) {
    self._data = data;

    View.initialize();
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    setLayout(Rez.Layouts.MainLayout(dc));
  }

  // Keep the clock roughly current while the view is up.
  function onShow() as Void {
    _clockTimer = new Timer.Timer();
    _clockTimer.start(method(:onClockTick), 20000, true);

    // Touch-first watches with no physical menu button/long-press (Venu X1
    // and its siblings) rely on this swipe-to-reveal indicator to reach the
    // menu at all (SimpScoreDelegate.onActionMenu handles the swipe).
    // Guarded with `has` since older API levels don't have the method.
    if (self has :setActionMenuIndicator) {
      setActionMenuIndicator({ :enabled => true });
    }

    // Hybrid analog-digital watches (Instinct Crossover and siblings)
    // overlay real physical hands on top of the whole digital area, right
    // through the middle of this layout. Park them out of the way while the
    // score screen is up; onHide puts them back on system time. Guarded
    // with `has`: setClockHandPosition is API 3.3.0, this app's minimum is
    // 3.2.0, and non-hybrid devices don't have it at all.
    if (self has :setClockHandPosition) {
      setClockHandPosition({ :clockState => WatchUi.ANALOG_CLOCK_STATE_RESTING });
    }
  }

  function onClockTick() as Void {
    WatchUi.requestUpdate();
  }

  // Update the view
  function onUpdate(dc as Dc) as Void {
    var clockLabel = View.findDrawableById("ClockLabel") as Text?;
    if (clockLabel != null) {
      clockLabel.setText(currentTimeText());
    }

    // "WIN"/"START" caption above the win-score number, on layouts that have
    // it (round, rectangle — semi-octagon uses the physical sub-screen
    // circle instead and has no such label, so the lookup is null there).
    var winScoreTextLabel = View.findDrawableById("WinScoreTextLabel") as Text?;
    if (winScoreTextLabel != null) {
      winScoreTextLabel.setText(WatchUi.loadResource(
        _data.getCountDown() ? Rez.Strings.label_start_at_target : Rez.Strings.label_win_target
      ) as String);
    }

    // Set the score to win value
    var scoreToWinValueLabel =
      View.findDrawableById("ScoreToWinValueLabel") as Text?;
    if (scoreToWinValueLabel != null) {
      var winAt = _data.getWinAt();
      if (winAt == null) {
        scoreToWinValueLabel.setText(
          WatchUi.loadResource(Rez.Strings.win_score_off_indicator) as String
        );
      } else {
        scoreToWinValueLabel.setText(winAt.format("%d").toString());
      }
    }

    // Set the Home score value. "%d" (not "%2d"): the labels are centre-
    // justified, and a padding space left a stray mark next to 1-digit scores.
    var homeScoreValueLabel =
      View.findDrawableById("HomeScoreValueLabel") as Text?;
    if (homeScoreValueLabel != null) {
      homeScoreValueLabel.setText(_data.getHomeScore().format("%d").toString());
    }

    // Set the Away score value
    var awayScoreValueLabel =
      View.findDrawableById("AwayScoreValueLabel") as Text?;
    if (awayScoreValueLabel != null) {
      awayScoreValueLabel.setText(_data.getAwayScore().format("%d").toString());
    }

    // Call the parent onUpdate function to redraw the layout
    View.onUpdate(dc);
  }

  // hh:mm, following the watch's 12/24-hour setting.
  private function currentTimeText() as String {
    var now = System.getClockTime();
    var hour = now.hour;
    if (!System.getDeviceSettings().is24Hour) {
      hour = hour % 12;
      if (hour == 0) {
        hour = 12;
      }
      return Lang.format("$1$:$2$", [hour, now.min.format("%02d")]);
    }
    return Lang.format("$1$:$2$", [hour.format("%02d"), now.min.format("%02d")]);
  }

  function onHide() as Void {
    if (_clockTimer != null) {
      _clockTimer.stop();
      _clockTimer = null;
    }

    if (self has :setClockHandPosition) {
      setClockHandPosition({ :clockState => WatchUi.ANALOG_CLOCK_STATE_SYSTEM_TIME });
    }
  }
}
