import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;


class ARCANE570App extends Application.AppBase {

    // ====================================================
    // MAIN WATCH FACE
    // ====================================================

    private var mainView;


    function initialize() {

        AppBase.initialize();

        mainView = null;
    }


    // ====================================================
    // APPLICATION START
    // ====================================================

    function onStart(
        state as Dictionary?
    ) as Void {
    }


    // ====================================================
    // APPLICATION STOP
    // ====================================================

    function onStop(
        state as Dictionary?
    ) as Void {
    }


    // ====================================================
    // INITIAL WATCH FACE
    //
    // Return:
    //
    // [ View, WatchFaceDelegate ]
    //
    // Delegate handles long-press interaction.
    // ====================================================

    function getInitialView()
        as [Views]
        or [Views, InputDelegates] {

        mainView =
            new ARCANE570View();


        var delegate =
            new ARCANE570Delegate();


        return [
            mainView,
            delegate
        ];
    }


    // ====================================================
    // SETTINGS CHANGED
    // ====================================================

    function onSettingsChanged()
        as Void {

        if (mainView != null) {

            mainView.refreshSettings();
        }


        WatchUi.requestUpdate();
    }
}


// ========================================================
// GET APPLICATION
// ========================================================

function getApp()
    as ARCANE570App {

    return Application.getApp()
        as ARCANE570App;
}