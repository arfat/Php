/**
 * VERSION: 1.0
 * DATE: 2011-05-06
 * AUTHOR: Chenggang Duan
 **/
package com.glam {

    import flash.display.DisplayObject;
    import flash.display.LoaderInfo;
    import flash.external.ExternalInterface;

    /**
     * Metrics is a lightweight API to track engagement events in Flash.
     * 
     * It's built on top of the Javascript version of the glam.metrics API and Flash ExternalInterface.
     * 
     * Samples:
     * 
     *      import com.glam.Metrics;
     * 
     *      // Initialized the Metrics class with current displayObject
     *      Metrics.init(this);
     * 
     *      // Call the following static functions on Metrics class to track events
     *      Metrics.counter("replay");
     *      Metrics.startTimer("waitforclick");
     *      Metrics.stopTimer("waitforclick");
     *      // Or call track() to track generic instantaneous events
     *      // First param of track is one of the predefined event codes:
     *      //      exit
     *      //      tab
     *      //      collapse
     *      //      expand
     *      //      fullscreen
     *      //      mouseover
     *      //      videoplay
     *      //      videostop
     *      //      videopause
     *      //      videounpause
     *      //      videomute
     *      //      videounmute
     *      //      video25
     *      //      video50
     *      //      video75
     *      //      videoend
     *      //      ...
     *      // Second param of track is an arbitrary short name given to the event, or null if no need for it:
     *      Metrics.track("exit", "facebook");
     *      Metrics.track("tab", "1");
     *      
     **/
    public class Metrics {
        private static var reqId:String = null;
		private static var urlprefix:String="";

        public static function init(obj:DisplayObject = null):void {
            if (reqId == null) {
                if (obj != null) {
                    try {
                        trace("Try getting request ID");
                        reqId = obj.root.loaderInfo.parameters["reqId"];		
						urlprefix = obj.root.loaderInfo.parameters["ct_prefix"] as String;
                    } catch (error:Error) {
                        // ignore error
                        trace("Error when getting request ID" + error);
                    }
                }
                if (reqId == null) {
                    reqId = generateRandomString(10);
                    trace("Unable to getting request ID, use random string instead:" + reqId);
                }
            }
        }

        public static function generateRandomString(
            newLength:uint = 1,
            userAlphabet:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        ):String {
            var alphabet:Array = userAlphabet.split("");
            var alphabetLength:int = alphabet.length;
            var randomLetters:String = "";
            for (var i:uint = 0; i < newLength; i++) {
                randomLetters +=  alphabet[int(Math.floor(Math.random() * alphabetLength))];
            }
            return randomLetters;
        }

        public static function track(evt_code:String, evt_name:String = ""):void {
            init();
            ExternalInterface.call("glam.metrics.trackEvent", reqId, evt_code, evt_name);
			if(evt_code == "exit")
			{
				ExternalInterface.call("openurl", urlprefix+String(evt_name));
			}
			trace(evt_code+"<<<<<<<< traking started   "+reqId+"........>>>>>>>"+evt_name);
        }

        public static function counter(evt_name:String):void {
            init();
            ExternalInterface.call("glam.metrics.trackEvent", reqId, "counter", evt_name);
			trace("counter started   "+reqId+"........>>>>>>>"+evt_name)
        }

        public static function startTimer(evt_name:String):void {
            init();
            ExternalInterface.call("glam.metrics.startEvent", reqId, "timer", evt_name);
			trace("Timer start   "+reqId+"........>>>>>>>"+evt_name);
        }

        public static function stopTimer(evt_name:String):void {
            init();
            ExternalInterface.call("glam.metrics.stopEvent", reqId, "timer", evt_name);
			trace("Timer stop   "+reqId+"........>>>>>>>"+evt_name);
        }

    }
}