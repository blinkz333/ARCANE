using Toybox.ActivityMonitor;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.SensorHistory;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.WatchUi;


class ARCANE570View extends WatchUi.WatchFace {

    // ====================================================
    // RESOURCES
    // ====================================================

    private var background;
    private var timeFont;
    private var dataFont;
    private var headerFont;


    // ====================================================
    // SETTINGS CACHE
    // ====================================================

    private var cachedTimeFormat = 0;
    private var cachedStepGoal = 10000;


    // ====================================================
    // AOD STATE
    // ====================================================

    private var isAod = false;


    // ====================================================
    // INITIALIZE
    // ====================================================

    function initialize() {

        WatchFace.initialize();

        background = WatchUi.loadResource(
            Rez.Drawables.ArcaneBackground
        );

        timeFont = WatchUi.loadResource(
            Rez.Fonts.TimeFont
        );

        dataFont = WatchUi.loadResource(
            Rez.Fonts.DataFont
        );

        headerFont = WatchUi.loadResource(
            Rez.Fonts.HeaderFont
        );

        loadSettings();
    }


    // ====================================================
    // WATCH FACE EVENTS
    // ====================================================

    function onLayout(dc) {
    }


    function onShow() {

        loadSettings();
    }


    function onHide() {
    }


    // ====================================================
    // SETTINGS
    // ====================================================

    function refreshSettings() {

        loadSettings();
    }


    function loadSettings() {

        // ------------------------------------------------
        // Time format
        //
        // 0 = System Default
        // 1 = 12 Hour
        // 2 = 24 Hour
        // ------------------------------------------------

        cachedTimeFormat = 0;

        var storedFormat =
            Application.Properties.getValue(
                "timeFormat"
            );

        if (storedFormat != null) {

            cachedTimeFormat =
                storedFormat;
        }


        // ------------------------------------------------
        // Step goal
        // ------------------------------------------------

        cachedStepGoal = 10000;

        var storedGoal =
            Application.Properties.getValue(
                "stepGoal"
            );

        if (storedGoal != null) {

            cachedStepGoal =
                storedGoal;
        }


        if (cachedStepGoal <= 0) {

            cachedStepGoal = 10000;
        }
    }


    // ====================================================
    // UPDATE DISPATCHER
    // ====================================================

    function onUpdate(dc) {

        if (isAod) {

            drawAodFace(dc);

        } else {

            drawMainFace(dc);
        }
    }


    // ====================================================
    // AOD / LOW POWER FACE
    //
    // All AOD elements share the same center axis.
    //
    // Pixel Shift moves the complete AOD layout together.
    // ====================================================

    function drawAodFace(dc) {

        // ------------------------------------------------
        // Background
        // ------------------------------------------------

        dc.setColor(
            Graphics.COLOR_BLACK,
            Graphics.COLOR_BLACK
        );

        dc.clear();


        // ------------------------------------------------
        // Time
        // ------------------------------------------------

        var clockTime =
            System.getClockTime();


        var hour =
            getDisplayHour(
                clockTime.hour
            );


        var hourText =
            hour.format("%02d");


        var minuteText =
            clockTime.min.format("%02d");


        // ------------------------------------------------
        // Pixel Shift
        //
        // 0 = Center
        // 1 = Right
        // 2 = Down
        // 3 = Left
        // 4 = Up
        // ------------------------------------------------

        var shiftX = 0;
        var shiftY = 0;


        var shiftPhase =
            clockTime.min % 5;


        if (shiftPhase == 1) {

            shiftX = 2;

        } else if (shiftPhase == 2) {

            shiftY = 2;

        } else if (shiftPhase == 3) {

            shiftX = -2;

        } else if (shiftPhase == 4) {

            shiftY = -2;
        }


        // ------------------------------------------------
        // Master center
        // ------------------------------------------------

        var centerX =
            (dc.getWidth() / 2) + shiftX;


        // ------------------------------------------------
        // Locked AOD positions
        // ------------------------------------------------

        var quoteY =
            91 + shiftY;

        var timeY =
            115 + shiftY;

        var colonY =
            108 + shiftY;

        var dateY =
            215 + shiftY;

        var metricsY =
            280 + shiftY;


        var timeOffset = 20;


        // ------------------------------------------------
        // Quote
        // ------------------------------------------------

        dc.setColor(
            0x666B69,
            Graphics.COLOR_TRANSPARENT
        );


        dc.drawText(
            centerX,
            quoteY,
            headerFont,
            "DESTINY BENDS TO WILL",
            Graphics.TEXT_JUSTIFY_CENTER
        );


        // ------------------------------------------------
        // Hours
        // ------------------------------------------------

        dc.setColor(
            0xAEB6B7,
            Graphics.COLOR_TRANSPARENT
        );


        dc.drawText(
            centerX - timeOffset,
            timeY,
            timeFont,
            hourText,
            Graphics.TEXT_JUSTIFY_RIGHT
        );


        // ------------------------------------------------
        // Minutes
        // ------------------------------------------------

        dc.drawText(
            centerX + timeOffset,
            timeY,
            timeFont,
            minuteText,
            Graphics.TEXT_JUSTIFY_LEFT
        );


        // ------------------------------------------------
        // Static AOD colon
        // ------------------------------------------------

        dc.setColor(
            0x004D1E,
            Graphics.COLOR_TRANSPARENT
        );


        dc.drawText(
            centerX,
            colonY,
            timeFont,
            ":",
            Graphics.TEXT_JUSTIFY_CENTER
        );


        // ------------------------------------------------
        // Date
        // ------------------------------------------------

        var dateText =
            getDateText();


        dc.setColor(
            0x59605D,
            Graphics.COLOR_TRANSPARENT
        );


        dc.drawText(
            centerX,
            dateY,
            dataFont,
            dateText,
            Graphics.TEXT_JUSTIFY_CENTER
        );


        // ------------------------------------------------
        // Steps
        // ------------------------------------------------

        var currentSteps =
            getCurrentSteps();


        var stepsText =
            formatSteps(
                currentSteps
            );


        // ------------------------------------------------
        // Battery
        // ------------------------------------------------

        var batteryText =
            getBatteryText();


        // ------------------------------------------------
        // Centered AOD metrics
        //
        // 2,500   •   100 %
        //
        // Green dot remains exactly on centerX.
        // ------------------------------------------------

        var metricsGap = 18;


        // Steps

        dc.setColor(
            0x858C89,
            Graphics.COLOR_TRANSPARENT
        );


        dc.drawText(
            centerX - metricsGap,
            metricsY,
            headerFont,
            stepsText,
            Graphics.TEXT_JUSTIFY_RIGHT
        );


        // Green center dot

        dc.setColor(
            0x004D1E,
            Graphics.COLOR_TRANSPARENT
        );


        dc.fillCircle(
            centerX,
            metricsY + 8,
            2
        );


        // Battery

        dc.setColor(
            0x858C89,
            Graphics.COLOR_TRANSPARENT
        );


        dc.drawText(
            centerX + metricsGap,
            metricsY,
            headerFont,
            batteryText + " %",
            Graphics.TEXT_JUSTIFY_LEFT
        );
    }


    // ====================================================
    // MAIN FACE
    // ====================================================

    function drawMainFace(dc) {

        // ------------------------------------------------
        // Background
        // ------------------------------------------------

        dc.setColor(
            Graphics.COLOR_BLACK,
            Graphics.COLOR_BLACK
        );

        dc.clear();


        dc.drawBitmap(
            0,
            0,
            background
        );


        // ------------------------------------------------
        // Time
        // ------------------------------------------------

        var clockTime =
            System.getClockTime();


        var hour =
            getDisplayHour(
                clockTime.hour
            );


        var minute =
            clockTime.min;


        var second =
            clockTime.sec;


        var hourText =
            hour.format("%02d");


        var minuteText =
            minute.format("%02d");


        // ------------------------------------------------
        // Activity data
        // ------------------------------------------------

        var currentSteps =
            getCurrentSteps();


        // ------------------------------------------------
        // Locked Main positions
        // ------------------------------------------------

        var centerX =
            dc.getWidth() / 2;


        // Optical correction already approved for Main.

        var timeCenterX =
            centerX + 6;


        var quoteY = 91;
        var timeY = 115;
        var colonY = 108;
        var timeOffset = 20;


        // ------------------------------------------------
        // Quote
        // ------------------------------------------------

        drawQuote(
            dc,
            centerX,
            quoteY,
            "DESTINY BENDS TO WILL"
        );


        // ------------------------------------------------
        // Hours
        // ------------------------------------------------

        drawMetallicText(
            dc,
            timeCenterX - timeOffset,
            timeY,
            hourText,
            Graphics.TEXT_JUSTIFY_RIGHT
        );


        // ------------------------------------------------
        // Minutes
        // ------------------------------------------------

        drawMetallicText(
            dc,
            timeCenterX + timeOffset,
            timeY,
            minuteText,
            Graphics.TEXT_JUSTIFY_LEFT
        );


        // ------------------------------------------------
        // Blinking green colon
        // ------------------------------------------------

        if ((second % 2) == 0) {

            // Glow

            dc.setColor(
                0x005C24,
                Graphics.COLOR_TRANSPARENT
            );


            dc.drawText(
                timeCenterX - 2,
                colonY,
                timeFont,
                ":",
                Graphics.TEXT_JUSTIFY_CENTER
            );


            dc.drawText(
                timeCenterX + 2,
                colonY,
                timeFont,
                ":",
                Graphics.TEXT_JUSTIFY_CENTER
            );


            dc.drawText(
                timeCenterX,
                colonY - 2,
                timeFont,
                ":",
                Graphics.TEXT_JUSTIFY_CENTER
            );


            dc.drawText(
                timeCenterX,
                colonY + 2,
                timeFont,
                ":",
                Graphics.TEXT_JUSTIFY_CENTER
            );


            // Main colon

            dc.setColor(
                0x00C94F,
                Graphics.COLOR_TRANSPARENT
            );


            dc.drawText(
                timeCenterX,
                colonY,
                timeFont,
                ":",
                Graphics.TEXT_JUSTIFY_CENTER
            );


            // Highlight

            dc.setColor(
                0x62FF91,
                Graphics.COLOR_TRANSPARENT
            );


            dc.drawText(
                timeCenterX,
                colonY - 1,
                timeFont,
                ":",
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }


        // ------------------------------------------------
        // Date
        // ------------------------------------------------

        drawGradientDate(
            dc,
            centerX,
            215,
            getDateText()
        );


        // ------------------------------------------------
        // Main metrics
        // ------------------------------------------------

        drawHeartRate(
            dc,
            106
        );


        drawSteps(
            dc,
            227,
            currentSteps
        );


        drawBattery(
            dc,
            348
        );


        // ------------------------------------------------
        // Step progress
        // ------------------------------------------------

        drawStepProgress(
            dc,
            currentSteps
        );
    }


    // ====================================================
    // DATA HELPERS
    // ====================================================

    function getCurrentSteps() {

        var currentSteps = 0;


        var activityInfo =
            ActivityMonitor.getInfo();


        if (activityInfo != null) {

            if (activityInfo.steps != null) {

                currentSteps =
                    activityInfo.steps;
            }
        }


        return currentSteps;
    }


    function getBatteryText() {

        var batteryText = "--";


        var stats =
            System.getSystemStats();


        if (stats != null) {

            batteryText =
                stats.battery.format("%.0f");
        }


        return batteryText;
    }


    // ====================================================
    // STEP FORMATTER
    //
    // 0 - 999      -> 999
    // 1,000-9,999  -> 5,000
    // 10,000+      -> 10.0K
    // ====================================================

    function formatSteps(steps) {

        if (steps >= 10000) {

            var whole =
                steps / 1000;


            var decimal =
                (steps % 1000) / 100;


            return
                whole.format("%d") +
                "." +
                decimal.format("%d") +
                "K";
        }


        if (steps >= 1000) {

            var thousands =
                steps / 1000;


            var remainder =
                steps % 1000;


            return
                thousands.format("%d") +
                "," +
                remainder.format("%03d");
        }


        return steps.format("%d");
    }


    // ====================================================
    // DATE FORMATTER
    // ====================================================

    function getDateText() {

        var dateInfo =
            Gregorian.info(
                Time.now(),
                Time.FORMAT_SHORT
            );


        var dayNames = [
            "SUN",
            "MON",
            "TUE",
            "WED",
            "THU",
            "FRI",
            "SAT"
        ];


        var monthNames = [
            "JAN",
            "FEB",
            "MAR",
            "APR",
            "MAY",
            "JUN",
            "JUL",
            "AUG",
            "SEP",
            "OCT",
            "NOV",
            "DEC"
        ];


        var dayName =
            dayNames[
                dateInfo.day_of_week - 1
            ];


        var monthName =
            monthNames[
                dateInfo.month - 1
            ];


        return
            dayName +
            "  " +
            dateInfo.day.format("%02d") +
            "  " +
            monthName;
    }


    // ====================================================
    // TIME FORMAT
    // ====================================================

    function getDisplayHour(hour) {

        // ------------------------------------------------
        // System Default
        // ------------------------------------------------

        if (cachedTimeFormat == 0) {

            var clockSettings =
                System.getDeviceSettings();


            if (clockSettings != null) {

                if (!clockSettings.is24Hour) {

                    return convertTo12Hour(
                        hour
                    );
                }
            }


            return hour;
        }


        // ------------------------------------------------
        // Force 12 Hour
        // ------------------------------------------------

        if (cachedTimeFormat == 1) {

            return convertTo12Hour(
                hour
            );
        }


        // ------------------------------------------------
        // Force 24 Hour
        // ------------------------------------------------

        return hour;
    }


    function convertTo12Hour(hour) {

        var displayHour =
            hour % 12;


        if (displayHour == 0) {

            displayHour = 12;
        }


        return displayHour;
    }


    // ====================================================
    // HEART RATE
    // ====================================================

    function drawHeartRate(dc, x) {

        var hrText = "--";


        var options = {
            :period => 1
        };


        var heartRateIterator =
            SensorHistory.getHeartRateHistory(
                options
            );


        if (heartRateIterator != null) {

            var sample =
                heartRateIterator.next();


            if (sample != null) {

                if (sample.data != null) {

                    hrText =
                        sample.data.format("%d");
                }
            }
        }


        var dataY = 301;
        var dataGap = 2;


        // HR value

        dc.setColor(
            0xD7DCDA,
            Graphics.COLOR_TRANSPARENT
        );


        dc.drawText(
            x - dataGap,
            dataY,
            headerFont,
            hrText,
            Graphics.TEXT_JUSTIFY_RIGHT
        );


        // BPM

        dc.setColor(
            0x00C94F,
            Graphics.COLOR_TRANSPARENT
        );


        dc.drawText(
            x + dataGap,
            dataY,
            headerFont,
            "BPM",
            Graphics.TEXT_JUSTIFY_LEFT
        );
    }


    // ====================================================
    // STEPS
    // ====================================================

    function drawSteps(
        dc,
        x,
        currentSteps
    ) {

        var stepsText =
            formatSteps(
                currentSteps
            );


        var dataY = 301;


        dc.setColor(
            0xD7DCDA,
            Graphics.COLOR_TRANSPARENT
        );


        dc.drawText(
            x,
            dataY,
            headerFont,
            stepsText,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }


    // ====================================================
    // BATTERY
    // ====================================================

    function drawBattery(dc, x) {

        var batteryText =
            getBatteryText();


        var dataY = 301;
        var dataGap = 3;


        // Battery value

        dc.setColor(
            0xD7DCDA,
            Graphics.COLOR_TRANSPARENT
        );


        dc.drawText(
            x - dataGap,
            dataY,
            headerFont,
            batteryText,
            Graphics.TEXT_JUSTIFY_RIGHT
        );


        // Percent symbol

        dc.setColor(
            0x00C94F,
            Graphics.COLOR_TRANSPARENT
        );


        dc.drawText(
            x + dataGap,
            dataY,
            headerFont,
            "%",
            Graphics.TEXT_JUSTIFY_LEFT
        );
    }


    // ====================================================
    // STEP GOAL PROGRESS
    //
    // LOCKED FINAL GEOMETRY
    //
    // X      = 118
    // Y      = 354
    // Width  = 216
    // Height = 14
    // ====================================================

    function drawStepProgress(
        dc,
        currentSteps
    ) {

        var stepGoal =
            cachedStepGoal;


        var progressSteps =
            currentSteps;


        if (progressSteps > stepGoal) {

            progressSteps =
                stepGoal;
        }


        if (progressSteps < 0) {

            progressSteps = 0;
        }


        // ------------------------------------------------
        // Locked geometry
        // ------------------------------------------------

        var barX = 118;
        var barY = 354;

        var barWidth = 216;
        var barHeight = 14;


        var fillWidth =
            (progressSteps * barWidth)
            / stepGoal;


        if (fillWidth > 0) {

            // Very small progress:
            // draw a small circle instead of malformed bar.

            if (fillWidth < barHeight) {

                var smallRadius =
                    fillWidth / 2;


                if (smallRadius < 1) {

                    smallRadius = 1;
                }


                dc.setColor(
                    0x00C94F,
                    Graphics.COLOR_TRANSPARENT
                );


                dc.fillCircle(
                    barX + smallRadius,
                    barY + (barHeight / 2),
                    smallRadius
                );

            } else {

                drawRoundedBar(
                    dc,
                    barX,
                    barY,
                    fillWidth,
                    barHeight,
                    0x00C94F
                );
            }
        }
    }


    // ====================================================
    // ROUNDED PROGRESS BAR
    // ====================================================

    function drawRoundedBar(
        dc,
        x,
        y,
        width,
        height,
        color
    ) {

        var radius =
            height / 2;


        var centerY =
            y + radius;


        dc.setColor(
            color,
            Graphics.COLOR_TRANSPARENT
        );


        dc.fillRectangle(
            x + radius,
            y,
            width - (radius * 2),
            height
        );


        dc.fillCircle(
            x + radius,
            centerY,
            radius
        );


        dc.fillCircle(
            x + width - radius,
            centerY,
            radius
        );
    }


    // ====================================================
    // QUOTE
    // ====================================================

    function drawQuote(
        dc,
        x,
        y,
        text
    ) {

        // Shadow

        dc.setColor(
            0x4D5557,
            Graphics.COLOR_TRANSPARENT
        );


        dc.drawText(
            x + 1,
            y + 1,
            headerFont,
            text,
            Graphics.TEXT_JUSTIFY_CENTER
        );


        // Main text

        dc.setColor(
            0xC4CBC9,
            Graphics.COLOR_TRANSPARENT
        );


        dc.drawText(
            x,
            y,
            headerFont,
            text,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }


    // ====================================================
    // METALLIC SILVER TIME
    // ====================================================

    function drawMetallicText(
        dc,
        x,
        y,
        text,
        justify
    ) {

        // Shadow

        dc.setColor(
            0x4D5557,
            Graphics.COLOR_TRANSPARENT
        );


        dc.drawText(
            x + 1,
            y + 2,
            timeFont,
            text,
            justify
        );


        // Mid tone

        dc.setColor(
            0xAEB6B7,
            Graphics.COLOR_TRANSPARENT
        );


        dc.drawText(
            x,
            y + 1,
            timeFont,
            text,
            justify
        );


        // Highlight

        dc.setColor(
            0xE4E8E6,
            Graphics.COLOR_TRANSPARENT
        );


        dc.drawText(
            x,
            y,
            timeFont,
            text,
            justify
        );
    }


    // ====================================================
    // DATE GRADIENT
    // ====================================================

    function drawGradientDate(
        dc,
        x,
        y,
        text
    ) {

        var screenWidth =
            dc.getWidth();


        var screenHeight =
            dc.getHeight();


        var leftX =
            x - 90;


        var totalWidth =
            180;


        var partWidth =
            totalWidth / 4;


        // ------------------------------------------------
        // Emerald
        // ------------------------------------------------

        dc.setClip(
            leftX,
            0,
            partWidth,
            screenHeight
        );


        dc.setColor(
            0x00C94F,
            Graphics.COLOR_TRANSPARENT
        );


        dc.drawText(
            x,
            y,
            dataFont,
            text,
            Graphics.TEXT_JUSTIFY_CENTER
        );


        // ------------------------------------------------
        // Bright Emerald
        // ------------------------------------------------

        dc.setClip(
            leftX + partWidth,
            0,
            partWidth,
            screenHeight
        );


        dc.setColor(
            0x55E879,
            Graphics.COLOR_TRANSPARENT
        );


        dc.drawText(
            x,
            y,
            dataFont,
            text,
            Graphics.TEXT_JUSTIFY_CENTER
        );


        // ------------------------------------------------
        // Pale Metallic Green
        // ------------------------------------------------

        dc.setClip(
            leftX + (partWidth * 2),
            0,
            partWidth,
            screenHeight
        );


        dc.setColor(
            0xA1D9AE,
            Graphics.COLOR_TRANSPARENT
        );


        dc.drawText(
            x,
            y,
            dataFont,
            text,
            Graphics.TEXT_JUSTIFY_CENTER
        );


        // ------------------------------------------------
        // Silver
        // ------------------------------------------------

        dc.setClip(
            leftX + (partWidth * 3),
            0,
            screenWidth - (
                leftX +
                (partWidth * 3)
            ),
            screenHeight
        );


        dc.setColor(
            0xD7DCDA,
            Graphics.COLOR_TRANSPARENT
        );


        dc.drawText(
            x,
            y,
            dataFont,
            text,
            Graphics.TEXT_JUSTIFY_CENTER
        );


        // ------------------------------------------------
        // Restore full clip
        // ------------------------------------------------

        dc.setClip(
            0,
            0,
            screenWidth,
            screenHeight
        );
    }


    // ====================================================
    // AOD EVENTS
    // ====================================================

    function onEnterSleep() {

        isAod = true;

        WatchUi.requestUpdate();
    }


    function onExitSleep() {

        isAod = false;

        WatchUi.requestUpdate();
    }
}