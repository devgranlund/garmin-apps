using Toybox.System;

class Timer {

	var timerStatus;
	var currentPhase;
	var workDuration;
	var restDuration;
	var phaseSecondsLeft;
	
	// for timer status
    hidden enum {
    	RUNNING,
    	PAUSED,
    	NOT_STARTED
    }
    
    // for timer phase
	public enum {
	    WORK,
    	REST
	} 
	
	// Parameters: seconds, seconds, boolean
	function initialize( workDuration, restDuration, startWithWorkPhase ) {
		
		self.workDuration = workDuration;
		self.restDuration = restDuration;
		
		if ( startWithWorkPhase ) {
			currentPhase = WORK;
			phaseSecondsLeft = workDuration;
		} else {
			currentPhase = REST;
			phaseSecondsLeft = restDuration; 
		}
		
		timerStatus = NOT_STARTED;
	}
	
	function start() {
		timerStatus = RUNNING; 
	}
	
	function stop() {
		timerStatus = PAUSED;
	}
	
	// The operating system guarantees that this method gets called once per second
	function onCompute() {
		calculateTimer();
	}
	
	function onUpdate() {
		return getTimerText();
	}
	
	function calculateTimer() {
		if ( timerStatus == RUNNING ){
			phaseSecondsLeft = phaseSecondsLeft - 1;
			if (phaseSecondsLeft == 1) {
				// TODO inform datafield that phase turn is coming
			}
		}
		if (phaseSecondsLeft == 0) {
			turnPhase();
		}
    }

	function getTimerText() {
		var minutes = (phaseSecondsLeft / 60).toNumber().format("%02d");
		var seconds = (phaseSecondsLeft % 60).format("%02d");
		return minutes + ":" + seconds;
	}
	
	hidden function turnPhase() {
		if (currentPhase == WORK) {
			currentPhase = REST;
			phaseSecondsLeft = restDuration;
		} else {
			currentPhase = WORK;
			phaseSecondsLeft = workDuration;
		}
	}
	
	function getCurrentPhase() {
		return currentPhase;
	}
}