using Toybox.Lang;
using Toybox.WatchUi;
using Toybox.Time;

//big number smart formatter like 2.378M instead of 2378422
function smartFormatter(num){
	
	//System.println(num);

	var origNumStr = num; 

	if(num instanceof Lang.String){
		var chArr = num.toCharArray();
		var resStr = "";
		for(var i = 0; i < chArr.size(); i++){
			if(chArr[i] >= '0' && chArr[i] <= '9'){
				resStr += chArr[i];
			}
		}
		//System.println(resStr);
		
		num = resStr.toLong();
		
		//System.println("num: :" + num);
	}
	//System.println(num);
	if(num instanceof Lang.Number || num instanceof Lang.Long || num instanceof Lang.Float || num instanceof Lang.Double){ 
		if(num > 999999 || num < -999999){
			num = (num / 1000000.0).format("%3.3f") + "M";
			return num;
		}
	}
	return origNumStr;
}    


(:debug)
// displays human redable last update like 2 mins ago OR 3 hours ago //updatedStringFromatter
function lastUpdFormatter(lastUpdated){
	var updString = null;
	
	if(lastUpdated != null){
        	
        	var lastUpdatedMoment = new Time.Moment(lastUpdated);
        	var sinceUpdate = Time.now().subtract(lastUpdatedMoment);
			
			var sinceUpdateMins = (sinceUpdate.value() / 60).toNumber();
			
			updString = WatchUi.loadResource(Rez.Strings.justNow) ;
			
			if (sinceUpdateMins > 120){
				var sinceUpdateHours = (sinceUpdateMins / 60).toNumber();
				updString = Lang.format(WatchUi.loadResource(Rez.Strings.hoursAgo) , [sinceUpdateHours]);
			}else if(sinceUpdateMins > 1){
				updString = Lang.format(WatchUi.loadResource(Rez.Strings.minutesAgo) , [sinceUpdateMins]);
			}
	}		
	return "~" + updString;
}

(:release)
function lastUpdFormatter(lastUpdated){
	var updString = null;
	
	if(lastUpdated != null){
        	
        	var lastUpdatedMoment = new Time.Moment(lastUpdated);
        	var sinceUpdate = Time.now().subtract(lastUpdatedMoment);
			
			var sinceUpdateMins = (sinceUpdate.value() / 60).toNumber();
			
			updString = WatchUi.loadResource(Rez.Strings.justNow) ;
			
			if (sinceUpdateMins > 120){
				var sinceUpdateHours = (sinceUpdateMins / 60).toNumber();
				updString = Lang.format(WatchUi.loadResource(Rez.Strings.hoursAgo) , [sinceUpdateHours]);
			}else if(sinceUpdateMins > 1){
				updString = Lang.format(WatchUi.loadResource(Rez.Strings.minutesAgo) , [sinceUpdateMins]);
			}
	}		
	return "·" + updString;
}