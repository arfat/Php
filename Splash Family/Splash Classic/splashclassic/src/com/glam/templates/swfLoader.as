package com.glam.templates
{
	/**
	 * 
	 * @author Ankur
	 * 
	 */		
	import com.glam.model.Model;
	import com.greensock.*;
	import com.greensock.easing.*;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.*;
	import flash.net.*;
	import flash.system.LoaderContext;
	
	public class swfLoader extends MovieClip
	{
		private var _mymodel:Model;
		public  var loader:Loader;
		private var _req:URLRequest;
		private var _context:LoaderContext;
		private var _swfname:String;
		private var tmpurl:String;
		private var mainMcName:String;
		public var myMc:MovieClip;

		public function swfLoader():void
		{
			_mymodel = Model.getInstance();
		}

		public function loadnit(dataObject:Object):void
		{
			if(_mymodel.apFlg)
			{
				_mymodel.apTimer.stop();
			}
			mainMcName = dataObject.loaderMc.name;
			myMc =  new MovieClip();
			tmpurl = dataObject.url;
			loader = new Loader();
			_context = new LoaderContext()
			_context.checkPolicyFile = true;
			configureListeners(loader.contentLoaderInfo);
			_req = new URLRequest(dataObject.url);
			myMc.name = dataObject.mcinsname;
			myMc.x = dataObject.posX;
			myMc.y = dataObject.posY;
			myMc.dataObj = dataObject; 
			dataObject.loaderMc.addChild(myMc);
			if(mainMcName == "mainContentMc")
			{
				_mymodel.preloadMc.visible = true;
			}
			myMc.addChild(loader);
			loader.load(_req,_context);
		}
		
		private function configureListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(Event.COMPLETE, completeHandler);    
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
		}
		
		private function completeHandler(event:Event):void {
			if(mainMcName == "mainContentMc")
			{
				_mymodel.preloadMc.visible = false;
				myMc.alpha = 0;
				TweenLite.to(myMc,0.5, {alpha:1, ease:Back.easeIn});
				dispatchEvent(new Event("mainContentloadComplete"));
			}
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			//dispatchEvent(new Event("imageNotLoaded"))
		}
		
		private function progressHandler(event:ProgressEvent):void {
			// trace("progressHandler: bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
		}
		
	}
}