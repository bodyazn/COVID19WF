using Toybox.Application;
using Toybox.System;
using Toybox.Time;
using Toybox.Application.Storage;
using Toybox.WatchUi as Ui;
	
	const LST_UPD_SFX = "_LUPD_";
	
	const ww_covid19data = "ww_covid19data";

	var canDoBG = false;
	var inBackground = false;
	
	var bgData;


class COVID19WatchFaceApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    	bgData = Storage.getValue($.ww_covid19data);
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    	Background.deleteTemporalEvent();
    }

    // Return the initial view of your application here
    function getInitialView() {
    	if(Toybox.System has :ServiceDelegate) {
    		canDoBG=true;
    		try{
    			Background.registerForTemporalEvent(new Time.Moment(Time.now().value() + 3));
    			//System.println("registerForTemporalEvent +3 sec !!!");
    		}catch(e){
    			Background.registerForTemporalEvent(new Time.Duration(60 * 5));
    			//System.println("registerForTemporalEvent 60 * 5 ...");
    		}
    	} else {
    		System.println("****background not available on this device****");
    	}
    	    
        return [ new COVID19WatchFaceView() ];
    }
    
    
    function getServiceDelegate(){
    	var now=System.getClockTime();
    	var ts=now.hour+":"+now.min.format("%02d");    
    	System.println("getServiceDelegate: "+ts);
        return [new BgDataProvider()];
    }
    
    function onBackgroundData(data) {
    
    	if(data["responseCode"] != 200){
    		Background.registerForTemporalEvent(new Time.Duration(60 * 5));
    		if(bgData != null){
    			bgData["responseCode"] = data["responseCode"];
    		}else{  	
    			bgData = data;
    		}
    	}else{
    		Background.registerForTemporalEvent(new Time.Duration(60 * 30));
    		if(data["country_data"] == null && bgData != null){
    			
    			System.println(bgData);
    			System.println(data);
    			
    			bgData["data"] = data["data"];
    			bgData["responseCode"] = data["responseCode"];
				bgData["lastUpdated"] = data["lastUpdated"];
			}else{
    			bgData = data;
    		}
    	}
		    	
    	Storage.setValue($.ww_covid19data, bgData);
        
        if(data != null){
        	if(data["country"] != null){
        		Storage.setValue("country", data["country"]);
        	}
        }
        
        Ui.requestUpdate();
    }    

}