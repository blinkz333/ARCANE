using Toybox.Complications;
using Toybox.WatchUi;


class ARCANE570Delegate extends WatchUi.WatchFaceDelegate {

    // ====================================================
    // HIT AREA
    //
    // Main face centers:
    //
    // HR      X = 106
    // STEPS   X = 227
    // BATTERY X = 348
    //
    // Data Y  = 301
    //
    // Battery intentionally has no action.
    // ====================================================

    private var hrCenterX = 106;
    private var stepsCenterX = 227;

    private var dataCenterY = 310;

    private var hitRadius = 55;


    function initialize() {

        WatchFaceDelegate.initialize();
    }


    // ====================================================
    // LONG PRESS
    //
    // WatchFaceDelegate.onPress() is Garmin's
    // touch-and-hold callback for watch faces.
    // ====================================================

    function onPress(clickEvent) {

        var coordinates =
            clickEvent.getCoordinates();


        // ================================================
        // HEART RATE AREA
        // ================================================

        if (isInsideCircle(
            coordinates[0],
            coordinates[1],
            hrCenterX,
            dataCenterY,
            hitRadius
        )) {

            launchComplication(
                Complications.COMPLICATION_TYPE_HEART_RATE
            );

            return true;
        }


        // ================================================
        // STEPS AREA
        // ================================================

        if (isInsideCircle(
            coordinates[0],
            coordinates[1],
            stepsCenterX,
            dataCenterY,
            hitRadius
        )) {

            launchComplication(
                Complications.COMPLICATION_TYPE_STEPS
            );

            return true;
        }


        // ================================================
        // OUTSIDE INTERACTIVE AREA
        // ================================================

        return false;
    }


    // ====================================================
    // CHECK TOUCH AREA
    // ====================================================

    function isInsideCircle(
        x,
        y,
        centerX,
        centerY,
        radius
    ) {

        var dx =
            x - centerX;

        var dy =
            y - centerY;


        return (
            (dx * dx) +
            (dy * dy)
        ) <= (
            radius * radius
        );
    }


    // ====================================================
    // FIND + LAUNCH SYSTEM COMPLICATION
    // ====================================================

    function launchComplication(
        complicationType
    ) {

        var iterator =
            Complications.getComplications();


        if (iterator == null) {

            return;
        }


        var complication =
            iterator.next();


        while (complication != null) {

            // ============================================
            // MATCH SYSTEM COMPLICATION TYPE
            // ============================================

            if (
                complication.getType()
                ==
                complicationType
            ) {

                var complicationId =
                    complication.complicationId;


                if (complicationId != null) {

                    Complications.exitTo(
                        complicationId
                    );

                    return;
                }
            }


            complication =
                iterator.next();
        }
    }
}