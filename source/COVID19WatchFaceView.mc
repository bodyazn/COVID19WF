using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Activity;
using Toybox.ActivityMonitor;
using Toybox.Time.Gregorian;
using Toybox.Math;

class COVID19WatchFaceView extends WatchUi.WatchFace {

	const rk = 0.7;
	
	var width;
	var height;
	var maxGw;
	var maxGh;
	var gX;
	var gY;
	var gXmax;
	var gYmax;
	var gXcenter;
	var gYcenter;

	var country_data = null;
	
    var bX;
    var bY;
    	
    var bW = 8;
    var bH = 16;
    	
    var fBl = (bH * 0.65).toNumber();	
	
    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
    	//System.println("onLayout");
        if(bgData != null){
        	country_data = bgData["country_data"];
        }
        if(country_data != null){
        		setLayout(Rez.Layouts.WatchFaceD(dc));
        }else{
        		setLayout(Rez.Layouts.WatchFaceS(dc));
        }
        setScreenParams(dc);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    	
    }

    // Update the view
    function onUpdate(dc) {
    
       	if(bgData != null){
        	country_data = bgData["country_data"];
        }
    	
    	if(country_data != null){	 
			if(View.findDrawableById("CnLbl") == null){
				//System.println("setLayout(Rez.Layouts.WatchFaceD(dc)) - DUAL");
				setLayout(Rez.Layouts.WatchFaceD(dc));
			}
		}else{
			if(View.findDrawableById("CnLbl") != null){
				//System.println("setLayout(Rez.Layouts.WatchFaceS(dc))");
				setLayout(Rez.Layouts.WatchFaceS(dc));
			}
		}
    	//doExperiment();
        // Get and show the current time
        var clockTime = System.getClockTime();
        //var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
        var hView = View.findDrawableById("HoursLabel");
        hView.setText(clockTime.hour.format("%02d"));
        
		var mView = View.findDrawableById("MinutesLabel");
        mView.setText(clockTime.min.format("%02d"));
        
        //date
        var gregorianToday = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM); 
        var dateString = Lang.format("$1$, $2$ $3$ $4$", 
        	[gregorianToday.day_of_week, gregorianToday.day, gregorianToday.month, gregorianToday.year]);
        
        var dateLbl = View.findDrawableById("DateLbl");
        dateLbl.setText(dateString);
        
        var hRLbl = View.findDrawableById("HRLbl");
        hRLbl.setText(getHR());
        
        var dataToShow = null;//Storage.getValue($.ww_covid19data);
        if(bgData != null){
        	dataToShow = bgData["data"];
        	if(bgData["responseCode"] != 200){
        		var UpdLbl = View.findDrawableById("UpdLbl");
        		UpdLbl.setText(WatchUi.loadResource(Rez.Strings.chckPConnect) + bgData["responseCode"]);
        	} 
        }
        
        if(country_data != null && dataToShow != null){
        	var cnCaption = View.findDrawableById("CnLbl");
	        cnCaption.setText("   " + country_data["country_name"]);	        
	        
 	        var newCasesCaption = View.findDrawableById("NCLbl");
	        newCasesCaption.setText(WatchUi.loadResource(Rez.Strings.newCases) + dataToShow["new_cases"] + " ");	        
	        
	        var totalCasesCaption = View.findDrawableById("TCLbl");
	        totalCasesCaption.setText($.smartFormatter(dataToShow["total_cases"]) + " ");	        
	        
	        var totalRecoveredCaption = View.findDrawableById("TRLbl");
	        totalRecoveredCaption.setText($.smartFormatter(dataToShow["total_recovered"]) + " ");
	        
			var newCasesCaption_c = View.findDrawableById("NCLbl_c");
	        newCasesCaption_c.setText(" " + WatchUi.loadResource(Rez.Strings.newCases) + country_data["new_cases"]);	        
	        
	        var totalCasesCaption_c = View.findDrawableById("TCLbl_c");
	        totalCasesCaption_c.setText(" " + $.smartFormatter(country_data["total_cases"]));	        
	        
	        var totalRecoveredCaption_c = View.findDrawableById("TRLbl_c");
	        totalRecoveredCaption_c.setText(" " + $.smartFormatter(country_data["total_recovered"]));
	        
	        var updString = $.lastUpdFormatter(bgData["lastUpdated"]);
	        //System.println("updString: " +updString);
	        
	        if(updString != null){
	        	var UpdLbl = View.findDrawableById("UpdLbl");
	        	UpdLbl.setText(updString);//dataToShow["statistic_taken_at"]);
	        }       
        }else if(dataToShow != null){
        
	        var newCasesCaption = View.findDrawableById("NCLbl");
	        newCasesCaption.setText(WatchUi.loadResource(Rez.Strings.newCases) + dataToShow["new_cases"]);	        
	        
	        var totalCasesCaption = View.findDrawableById("TCLbl");
	        totalCasesCaption.setText(WatchUi.loadResource(Rez.Strings.totalCases) + dataToShow["total_cases"]);	        
	        
	        var totalRecoveredCaption = View.findDrawableById("TRLbl");
	        totalRecoveredCaption.setText(WatchUi.loadResource(Rez.Strings.totalRecovered) + dataToShow["total_recovered"]);
	        
	        var updString = $.lastUpdFormatter(bgData["lastUpdated"]);
	        //System.println("updString: " +updString);
	        
	        if(updString != null){
	        	var UpdLbl = View.findDrawableById("UpdLbl");
	        	UpdLbl.setText(WatchUi.loadResource(Rez.Strings.updated)  +  updString);//dataToShow["statistic_taken_at"]);
	        }
        }

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        
		dc.setColor(Graphics.COLOR_DK_RED, Graphics.COLOR_BLACK);
		dc.drawLine(4, gYcenter - 5, width - 4, gYcenter - 5);
		if(country_data != null){
			dc.drawLine(gXcenter, gYcenter, gXcenter, gYmax + 10);
		}
		
		drawBattery(dc);
        
    }
    
    //find drawable and update text by formatted rez and value *** NOT TESTED YET !!!
    function updLbl(lblId, frmtTmplt, rezId, val){
    	var dtu = View.findDrawableById(lblId);
    	var rezVal = "";
    	try{
    		rezVal = WatchUi.loadResource(rezId);
    	}catch(e){}
    	var frmtStr = Lang.format(frmtTmplt, [rezVal, val]);
	    dtu.setText(frmtStr);	
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }
    
	function setScreenParams(dc){
		width = dc.getWidth();
		height = dc.getHeight();
	
		maxGw = (width * rk).toNumber();
		maxGh = (height * rk).toNumber();
		gX = ((width - maxGw) / 2).toNumber();
		gY = ((height - maxGh) / 2).toNumber();
		
		gXmax = width - gX;
		gYmax = width - gY;
		
		gXcenter = gX + (maxGw / 2);
		gYcenter = gY + (maxGh / 2);
		
		bX = gX - 18; 
		bY = gY +  (38 * height / 280.0).toNumber();
		
		//System.println("bX = " + bX + ", bY = " + bY);
		
		/*
		System.println(Lang.format("width, height x: $1$, y: $2$", [width, height]));
		System.println(Lang.format("maxGw, maxGh rx: $1$, ry: $2$", [maxGw, maxGh]));
		System.println(Lang.format("gX gY rx: $1$, ry: $2$", [gX, gY]));
		System.println(Lang.format("gXmax, gYmax rx: $1$, ry: $2$", [gXmax, gYmax]));
		System.println(Lang.format("gXcenter, gYcenter rx: $1$, ry: $2$", [gXcenter, gYcenter]));
		*/
	}

    function drawBattery(dc){
  		var batt = System.getSystemStats().battery;
  		
		var battLbl = View.findDrawableById("BattLbl");
    	if(battLbl != null){
    		var bStr = Math.round(batt).toNumber().toString();
    		if(width > 240){
    			bStr += "%";
    		}
    		battLbl.setText(bStr);
    	} 		
  		
  		if(batt <=10){
  		    	dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
  		}else{
    		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    	}
    	dc.setPenWidth(2);
    	dc.drawRectangle(bX, bY, bW, bH);
    	dc.drawRectangle(bX + bW / 2 - 2, bY - 2, 4, 2);
    	
    	var battBarL = (fBl * batt / 100).toNumber();
    	//System.println(battBarL);
    	
    	if(batt <= 20){
    		dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
    	}
    	
    	dc.drawRectangle(bX + bW / 2 -1, bY + fBl + 3 - battBarL, 2, battBarL);
    }	   
	
	function getHR(){
		var act = Activity.getActivityInfo();
		if(act != null && act has :currentHeartRate && act.currentHeartRate != null){
			
			//System.println("Activity.getActivityInfo().currentHeartRate " + act.currentHeartRate);
			return act.currentHeartRate.toString();
		}
		if ((Toybox has :ActivityMonitor) && (ActivityMonitor has :getHeartRateHistory)) {
			var iter = ActivityMonitor.getHeartRateHistory(1, true);
			if(iter != null){
				var measure = iter.next().heartRate;
				if(measure != ActivityMonitor.INVALID_HR_SAMPLE){
					//System.println("ActivityMonitor.getHeartRateHistory " + measure);
					return measure.toString();
				}
			}
		}
		return "--";
	}
}
