import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Composes a two-digit win-score value; 0 means "off". Shared by the view
// (to render) and the delegate (to confirm), kept as a plain function so it's
// reachable from source-test without any WatchUi involved.
function winScoreValue(tens as Number, ones as Number) as Number? {
  var value = tens * 10 + ones;
  return value == 0 ? null : value;
}

// A digit wrapped by 1 within 0-9, used for both tens and ones.
function wrapDigit(digit as Number, delta as Number) as Number {
  return (digit + delta + 10) % 10;
}

// Custom win-score entry screen: replaces the stock WatchUi.Picker (see
// CLAUDE.md) with a plain View so onUpdate fully owns the frame instead of
// fighting a system widget's internal repaint. Two big digits, black-on-white
// like the score screen, with up/down arrows over whichever digit (tens
// first, then ones) is focused. WinScoreDelegate drives _tens / _ones /
// _focusOnes and calls requestUpdate() after each change.
class WinScoreView extends WatchUi.View {
  private var _tens as Number;
  private var _ones as Number;
  private var _focusOnes as Boolean = false;

  function initialize(current as Number?) {
    View.initialize();
    var value = (current == null) ? 0 : current;
    self._tens = value / 10;
    self._ones = value % 10;
  }

  function getTens() as Number {
    return _tens;
  }

  function getOnes() as Number {
    return _ones;
  }

  function bumpFocused(delta as Number) as Void {
    if (_focusOnes) {
      _ones = wrapDigit(_ones, delta);
    } else {
      _tens = wrapDigit(_tens, delta);
    }
  }

  // Returns false if already on the ones digit (caller then confirms).
  function focusOnes() as Boolean {
    if (_focusOnes) {
      return false;
    }
    _focusOnes = true;
    return true;
  }

  // Returns false if already on the tens digit (caller then cancels).
  function focusTens() as Boolean {
    if (!_focusOnes) {
      return false;
    }
    _focusOnes = false;
    return true;
  }

  function onUpdate(dc as Dc) as Void {
    // Own the whole frame: no layout, no system widget underneath to leave
    // stale content behind (the bug that sank the earlier Picker subclass).
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
    dc.clear();

    var width = dc.getWidth();
    var height = dc.getHeight();

    // Title placement follows the same left-inset-on-Instinct / centred-
    // elsewhere convention as the menu and the old picker (centreTitles() /
    // titleInset(), from SimpScoreMenuDelegate.mc) so it clears the physical
    // sub-screen on the semi-octagon watches.
    var titleY = height * 12 / 100;
    if (centreTitles()) {
      dc.drawText(
        width / 2,
        titleY,
        Graphics.FONT_TINY,
        menuString(Rez.Strings.menu_win_score),
        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
      );
    } else {
      // A little further right than titleInset() alone: this screen's title
      // sits over blank space (no sub-screen circle to clear at this height),
      // so it can sit closer to centre than the menu title does.
      dc.drawText(
        titleInset() + width * 4 / 100,
        titleY,
        Graphics.FONT_TINY,
        menuString(Rez.Strings.menu_win_score),
        Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
      );
    }

    var text = Lang.format("$1$$2$", [_tens, _ones]);
    var font = Graphics.FONT_NUMBER_HOT;
    var textDims = dc.getTextDimensions(text, font);
    var textWidth = textDims[0];
    var textY = height / 2;
    dc.drawText(
      width / 2,
      textY,
      font,
      text,
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );

    // Up/down arrows above and below the focused digit, echoing the stock
    // Picker's scroll arrows: tens is the left half of the glyph box, ones
    // the right half.
    var textX = (width - textWidth) / 2;
    var digitWidth = textWidth / 2;
    var centerX = _focusOnes ? textX + digitWidth + digitWidth / 2 : textX + digitWidth / 2;
    var textTop = textY - textDims[1] / 2;
    var textBottom = textY + textDims[1] / 2;
    var gap = height * 2 / 100;
    var arrowHeight = height * 5 / 100;
    var arrowHalfWidth = digitWidth * 15 / 100;

    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
    dc.fillPolygon([
      [centerX, textTop - gap - arrowHeight],
      [centerX - arrowHalfWidth, textTop - gap],
      [centerX + arrowHalfWidth, textTop - gap],
    ] as Array<Graphics.Point2D>);
    dc.fillPolygon([
      [centerX, textBottom + gap + arrowHeight],
      [centerX - arrowHalfWidth, textBottom + gap],
      [centerX + arrowHalfWidth, textBottom + gap],
    ] as Array<Graphics.Point2D>);
  }
}
