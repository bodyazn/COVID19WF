using Toybox.Background;
using Toybox.System as Sys;
using Toybox.Application.Storage;
using Toybox.Time;
using Toybox.Communications;
using Toybox.Activity;

// The Service Delegate is the main entry point for background processes
// our onTemporalEvent() method will get run each time our periodic event
// is triggered by the system.

(:background)
class BgDataProvider extends Toybox.System.ServiceDelegate {

	hidden var reqCounter = 0;
	hidden var bgData = {};
	
	function enterReq(){
		reqCounter ++;
		$.logMessage("enterReq: " + reqCounter);
	}
	
	function exitReq(){
		reqCounter --;
		$.logMessage("exitReq: " + reqCounter);
		return (reqCounter == 0);
	}
		
	function initialize() {
		//$.logMessage(" *** Printed by BgbgServiceDelegate initialize() first line ***");
		Sys.ServiceDelegate.initialize();
		inBackground=true;
	}
	
    function onTemporalEvent() {
    	
    	makeRequest();
    	
		var curLoc = Activity.getActivityInfo().currentLocation; 
		if(curLoc != null){
	    	makeRequest_rGeo(curLoc);
	    }else if(Storage.getValue("countryId2") != null){
	    	makeRequest_countryId2(Storage.getValue("countryId2"));
	    }
	            
    }
    
	function onReceive(responseCode, data) {
		//Sys.println("onReceive: " + responseCode + " " + data);

/*		
		bgData = {
			"responseCode" => responseCode,
			"data" => data,
			"lastUpdated" => Time.now().value()
				};
*/
		bgData["responseCode"] = responseCode;
		bgData["data"] = data;
		bgData["lastUpdated"] = Time.now().value();
				
       	//Sys.println(bgData);
   		if(exitReq()){
			$.logMessage("onReceive EXIT");
			Background.exit(bgData);
		}
	}
   

	function makeRequest() {
		//Sys.println("makeRequest()");
		/*
       var options = {                                             // set the options
           :method => Communications.HTTP_REQUEST_METHOD_GET,      // set HTTP method
           :headers => {                                           // set headers
           			"Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED,
           			"x-rapidapi-host" => $.api_host,
              		"x-rapidapi-key" => $.api_key
                   },
                                                                   // set response type
                   :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON//Communications.HTTP_RESPONSE_CONTENT_TYPE_TEXT_PLAIN                                                
           };
           */
       Communications.makeWebRequest(Application.Properties.getValue("ww_url"), null, getOpts(), method(:onReceive));
       enterReq();
       //Sys.println("end of makeRequest()");      
	} 

	function onReceive_country(responseCode, data) {	
       if (responseCode == 200) {
           //System.println("onReceive_country: " +data);
           $.logMessage("onReceive_country: " +data); 
           // ***  Array Out Of Bounds Error & Unhandled Exception
			try{
	           if(data["latest_stat_by_country"] instanceof Array && data["latest_stat_by_country"].size() > 0){
		           var clearData = data["latest_stat_by_country"][0]; // [0] this should reduce mem usage for display specific country *** also this line was reported by ERA Unhandled excaption covid19stats.onReceive_country:159
		           
		           bgData["country_data"] = clearData;
		           /*
		           var lastUpdated = Time.now();
		           Storage.setValue($.cl_by_country + $.LST_UPD_SFX + cname, lastUpdated.value());
		           */
	           }
			}catch(e){
				System.println("e: " + e.getErrorMessage() + " data: " + data);
			} 
       }
       else {
           System.println("onReceive_country !!! Response Code: " + responseCode);
           System.println("onReceive_country !!! Response: " + data);          
       }
       
       	//System.println(bgData);
		if(exitReq()){
			$.logMessage("onReceive_country EXIT");
			Background.exit(bgData);
		}
	}

/*	
	//by country name like USA, but reverse geocoding can return United States of America what requires translation	
	function makeRequest_country(cname) {
      	var params = {"country" => cname};
       	Communications.makeWebRequest(Application.Properties.getValue("cl_country_url"), params, getOpts(), method(:onReceive_country));
       	enterReq();
  	}
*/  	
  	//by ISO ALPHA-2 code like US
  	function makeRequest_countryId2(cId2) {
      	var params = {"alpha2" => cId2};
       	Communications.makeWebRequest(Application.Properties.getValue("cl_countryId2_url"), params, getOpts(), method(:onReceive_country));
       	enterReq();
  	} 

	function getOpts(){
       var options = {                                             // set the options
           :method => Communications.HTTP_REQUEST_METHOD_GET,      // set HTTP method
           :headers => {                                           // set headers
           			"Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED,
           			"x-rapidapi-host" => Application.Properties.getValue("api_host"), //$.api_host,
              		"x-rapidapi-key" => Application.Properties.getValue("api_key") //$.api_key
                   },                                                                   // set response type
                   :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON//Communications.HTTP_RESPONSE_CONTENT_TYPE_TEXT_PLAIN                                                
           };
		return options;
	}
		
	function getOpts_noggle(){
     	var options = getOpts();
       	options[:headers]["x-rapidapi-host"] = Application.Properties.getValue("api_host_noggle");
       //System.println(options);
		return options;
	}
	
//Not used any more cos of ISO ALPHA-2 code implementation
/*	
	function translateCountry(cname){
		cname = trimStr(cname); //some countries can be returned by reverse GeoCoding with trailing or leading space(s)
		var countriesDic = Application.getApp().loadResource(Rez.JsonData.countriesDic);
		//System.println(countriesDic);
		//System.println("countriesDic[cname] :" + cname + " -> " + countriesDic[cname]);
		if(countriesDic[cname] != null){
			cname = countriesDic[cname];
		}
		return cname;
	}

	//dumb trim implementation
	function trimStr(str){
		if(str != null && str instanceof Toybox.Lang.String){
			var isChanged = false;
			var startInd = 0;
			var endInd = str.length() - 1;
			do{
				isChanged = false;
				//System.println("startInd : " + startInd + " -> " +str.substring(startInd, startInd+1));
				//System.println("endInd : " + endInd + " -> " +str.substring(endInd, endInd+1));
				if(str.substring(startInd, startInd + 1).equals(" ")){
					startInd ++;
					isChanged = true;
				}
				if(str.substring(endInd, endInd + 1).equals(" ")){
					endInd --;
					isChanged = true;
				}
			}while(isChanged);
			return str.substring(startInd, endInd + 1);
		}
		return null; // or it can be str in case we are don't care for input / output types
	}
*/	

	function onReceive_rGeo(responseCode, data) {			
		$.logMessage("onReceive_rGeo: " + responseCode + " " + data);	
		if(data != null){
			try{
				//var res = data["results"];
				var fitem = data[0];
				var country = fitem["Country"];
				var countryId2 = fitem["CountryId"];
				if(country != null){
					bgData["country"] = country; //translateCountry(country); //not used any more as ISO ALPHA-2 code is more relaible 
					bgData["countryId2"] = countryId2;
					$.logMessage("bgData Country Name and ISO2 were added: " + bgData);
				}
			}catch(e){}
		}
		if(bgData["country"] != null){
			//makeRequest_country(bgData["country"]);
			makeRequest_countryId2(bgData["countryId2"]);
		}
		
		if(exitReq()){
			$.logMessage("onReceive_rGeo EXIT");
			Background.exit(bgData);
		}
	}
	function makeRequest_rGeo(curLoc){
		if(curLoc != null){
		
			var lat= curLoc.toDegrees()[0].toFloat();
			var long = curLoc.toDegrees()[1].toFloat();
			
			var params = {
				"latitude" => 	lat,
				"longitude" => long,
				"range" => "0"
			};
			
			//System.println(params);
			
			Communications.makeWebRequest(Application.Properties.getValue("rgeo_url_noggle"), params, getOpts_noggle(), method(:onReceive_rGeo));
			enterReq();
		}
	} 

/*	
	function getOpts_trueway(){
     	var options = getOpts();
       	options[:headers]["x-rapidapi-host"] = Application.Properties.getValue("api_host_trueway");
       //System.println(options);
		return options;
	}

	function getOpts_sports(){
     	var options = getOpts();
       	options[:headers]["x-rapidapi-host"] = Application.getApp().getProperty("api_host_sports");
       //System.println(options);
		return options;
	}
*/


//trueway
/*
	function onReceive_rGeo(responseCode, data) {		
		Sys.println("onReceive: " + responseCode + " " + data);
		if(data != null){
			try{
				var res = data["results"];
				var fitem = res[0];
				var country = fitem["country"];
				if(country != null){
					bgData["country"] = translateCountry(country);
					System.println(bgData);
				}
			}catch(e){}
		}
		if(bgData["country"] != null){
			makeRequest_country(bgData["country"]);
		}
		
		if(exitReq()){
			System.println("onReceive_rGeo EXIT");
			Background.exit(bgData);
		}
	}
*/

//trueway Reverse Geocoding service - fremium %(
/*
	function makeRequest_rGeo(curLoc){
		if(curLoc != null){
		
			var lat= curLoc.toDegrees()[0].toFloat();
			var long = curLoc.toDegrees()[1].toFloat();
			
			var params = {
				"location" => 	lat +"," + long,
				"language" => "en"
			};
			
			System.println(params);
			
			Communications.makeWebRequest(Application.Properties.getValue("rgeo_url"), params, getOpts_trueway(), method(:onReceive_rGeo));
			enterReq();
		}
	} 
*/	  
}