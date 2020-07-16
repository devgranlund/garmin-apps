using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;

class IntervalDataFieldView extends WatchUi.DataField {

	const DEBUG_MODE = true;

    hidden var batteryStatus;
    hidden var currentTime;
    hidden var timePassed;
    hidden var currentHr;
    hidden var currentSpeed;
    hidden var distance;
    
    const CURRENT_TIME_LABEL = "current_time_label";
    const CURRENT_TIME_VALUE = "current_time_value";
    
    const TIME_PASSED_LABEL = "time_passed_label";
    const TIME_PASSED_VALUE = "time_passed_value";
    
    const HR_LABEL = "hr_label";
    const HR_VALUE = "hr_value";
    
    const CURRENT_SPEED_LABEL = "current_speed_label";
    const CURRENT_SPEED_VALUE = "current_speed_value";
    
    const BATTERY_STATUS_LABEL = "battery_status_label";
    const BATTERY_STATUS_VALUE = "battery_status_value";
    
    const DISTANCE_LABEL = "distance_label";
    const DISTANCE_VALUE = "distance_value";

    function initialize() {
        DataField.initialize();
        timePassed = 0;
        currentHr = 0;
        currentSpeed = 0;
        distance = 0;
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc) {
        var obscurityFlags = DataField.getObscurityFlags();

        // Top left quadrant so we'll use the top left layout
        if (obscurityFlags == (OBSCURE_TOP | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.TopLeftLayout(dc));

        // Top right quadrant so we'll use the top right layout
        } else if (obscurityFlags == (OBSCURE_TOP | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.TopRightLayout(dc));

        // Bottom left quadrant so we'll use the bottom left layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.BottomLeftLayout(dc));

        // Bottom right quadrant so we'll use the bottom right layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.BottomRightLayout(dc));

        // Use the generic, centered layout
        } else {
            View.setLayout(Rez.Layouts.MainLayout(dc));
            
            var batteryLabel = View.findDrawableById(BATTERY_STATUS_LABEL);
            var batteryValue = View.findDrawableById(BATTERY_STATUS_VALUE);
            batteryValue.locY = batteryLabel.locY + 17;
            
            var timeLabel = View.findDrawableById(CURRENT_TIME_LABEL);
            var timeValue = View.findDrawableById(CURRENT_TIME_VALUE);
            timeValue.locY = timeLabel.locY + 17;
            
            var passedLabel = View.findDrawableById(TIME_PASSED_LABEL);
            var passedValue = View.findDrawableById(TIME_PASSED_VALUE);
            passedValue.locY = passedLabel.locY + 17;
            
            var hrLabel = View.findDrawableById(HR_LABEL);
            var hrValue = View.findDrawableById(HR_VALUE);
            hrValue.locY = hrLabel.locY + 17;
            
            var speedLabel = View.findDrawableById(CURRENT_SPEED_LABEL);
            var speedValue = View.findDrawableById(CURRENT_SPEED_VALUE);
            speedValue.locY = speedLabel.locY + 17;
            
            var distanceLabel = View.findDrawableById(DISTANCE_LABEL);
            var distanceValue = View.findDrawableById(DISTANCE_VALUE);
            distanceValue.locY = distanceLabel.locY + 17;
        }

        View.findDrawableById(BATTERY_STATUS_LABEL).setText(Rez.Strings.battery_status);
        View.findDrawableById(CURRENT_TIME_LABEL).setText(Rez.Strings.current_time);
        View.findDrawableById(TIME_PASSED_LABEL).setText(Rez.Strings.time_passed);
        View.findDrawableById(HR_LABEL).setText(Rez.Strings.heart_rate);
        View.findDrawableById(CURRENT_SPEED_LABEL).setText(Rez.Strings.current_speed);
        View.findDrawableById(DISTANCE_LABEL).setText(Rez.Strings.distance);
        
        return true;
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    // TODO : ajanotto, nopeus, syke
    function compute(info) {
        
        // Current time
        currentTime = getTime();
        
        // Time passed
        if(info has :timerTime){
            if(info.timerTime != null){
                timePassed = info.timerTime;
                //$.log(DEBUG_MODE, "timerTime " + info.timerTime);
            } else {
                timePassed = 0;
                $.log(DEBUG_MODE, "elapsedTime = null");
            } 
        } else {
        	$.log(DEBUG_MODE, "elapsedTime not in info");
        }
        
        // Current hr
        if(info has :currentHeartRate){
        	if(info.currentHeartRate != null){
        		currentHr = info.currentHeartRate;
        		//$.log(DEBUG_MODE, "currentHr " + timePassed);
        	}
        }
        
        // Current speed
        if(info has :currentSpeed){
        	if(info.currentSpeed != null){
        		currentSpeed = info.currentSpeed * 3.6;
        		//$.log(DEBUG_MODE, "currentSpeed " + currentSpeed);
        	}
        }
        
        // Battery status
        var deviceStats = System.getSystemStats();
        batteryStatus = deviceStats.battery;
        
        // Distance
        if(info has :elapsedDistance){
        	if(info.elapsedDistance != null){
        		distance = info.elapsedDistance / 1000;
        		$.log(DEBUG_MODE, "distance " + distance + " (raakadata) " +info.elapsedDistance);
        	}
        }

    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
        // Set the background color
        View.findDrawableById("Background").setColor(getBackgroundColor());

		// TODO layout
		var time = View.findDrawableById(CURRENT_TIME_VALUE);
		time.setColor(Graphics.COLOR_BLACK);
		time.setText(currentTime);

        // Set the foreground color and value
        var battery = View.findDrawableById(BATTERY_STATUS_VALUE);
        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
            battery.setColor(Graphics.COLOR_WHITE);
        } else {
            battery.setColor(Graphics.COLOR_BLACK);
        }
        battery.setText(batteryStatus.format("%02d") + "%");

		var passed = View.findDrawableById(TIME_PASSED_VALUE);
		passed.setColor(Graphics.COLOR_BLACK);
		var seconds = (timePassed / 1000) %60;
		var minutes = ((timePassed / (1000*60)) % 60); 
		var hours = ((timePassed / (1000*60*60)) % 24);
		passed.setText(Lang.format("$1$:$2$:$3$",
    		[hours.format("%02d"), minutes.format("%02d"), seconds.format("%02d")]));

		var hr = View.findDrawableById(HR_VALUE);
		hr.setColor(Graphics.COLOR_BLACK);
		hr.setText(currentHr.format("%02d"));
		
		var speed = View.findDrawableById(CURRENT_SPEED_VALUE);
		speed.setColor(Graphics.COLOR_BLACK);
		speed.setText(currentSpeed.format("%3.2f"));
		
		var dist = View.findDrawableById(DISTANCE_VALUE);
		dist.setColor(Graphics.COLOR_BLACK);
		dist.setText(distance.format("%3.2f"));
		
        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }
    
    function getTime() {
    	var timeFormat = "$1$:$2$";
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        } else {
            if (Application.getApp().getProperty("UseMilitaryFormat")) {
                timeFormat = "$1$$2$";
                hours = hours.format("%02d");
            }
        }
        return Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]);
    }

}

function log(debugMode, message) {
	if (debugMode == true) {
		System.println(message);
	}
}
