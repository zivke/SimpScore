import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class SimpScoreApp extends Application.AppBase {
  private var _data as SimpScoreData;

  function initialize() {
    AppBase.initialize();

    self._data = new SimpScoreData();
  }

  // onStart() is called on application start up
  function onStart(state as Dictionary?) as Void {
  }

  // onStop() is called when your application is exiting
  function onStop(state as Dictionary?) as Void {
  }

  // Return the initial view of your application here
  function getInitialView() as [Views] or [Views, InputDelegates] {
    return [new SimpScoreView(_data), new SimpScoreDelegate(_data)];
  }
}

function getApp() as SimpScoreApp {
  return Application.getApp() as SimpScoreApp;
}
