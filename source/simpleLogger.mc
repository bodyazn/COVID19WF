using Toybox.System;

(:background, :debug)
function logMessage(msg){
	System.println(msg);
}

(:background, :release)
function logMessage(msg){
	//do nothing :)
	//System.println(msg);
}