import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class SimpScoreView extends WatchUi.View {
  private var _data as SimpScoreData;

  function initialize(data as SimpScoreData) {
    self._data = data;

    View.initialize();
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    setLayout(Rez.Layouts.MainLayout(dc));
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {}

  // Update the view
  function onUpdate(dc as Dc) as Void {
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

    // Set the Home score value
    var homeScoreValueLabel =
      View.findDrawableById("HomeScoreValueLabel") as Text?;
    if (homeScoreValueLabel != null) {
      homeScoreValueLabel.setText(
        _data.getHomeScore().format("%2d").toString()
      );
    }

    // Set the Home score value
    var awayScoreValueLabel =
      View.findDrawableById("AwayScoreValueLabel") as Text?;
    if (awayScoreValueLabel != null) {
      awayScoreValueLabel.setText(
        _data.getAwayScore().format("%2d").toString()
      );
    }

    // Call the parent onUpdate function to redraw the layout
    View.onUpdate(dc);
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {}
}
