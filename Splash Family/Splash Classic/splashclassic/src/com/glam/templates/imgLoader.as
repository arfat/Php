package com.glam.templates
{
	/**
	 * 
	 * @author Ankur
	 * 
	 */	
	import com.glam.model.Model;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.events.EventDispatcher;
	import flash.net.*;
	import flash.system.LoaderContext;
	import com.greensock.*;
	import com.greensock.easing.*;	
	
	public class imgLoader extends MovieClip
	{
		private var _mymodel:Model;
		private var loader:Loader;
		private var _req:URLRequest;
		private var _context:LoaderContext;
		private  var imageData:Bitmap;
		private var tmpurl:String;
		private var mainMcName:String;
		public var myMc:MovieClip;
		
		public function imgLoader()
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
			myMc.name = dataObject.imgname;
			myMc.x = dataObject.posX;
			myMc.y = dataObject.posY;
			myMc.dataObj = dataObject; 
			dataObject.loaderMc.addChild(myMc);
			myMc.addChild(loader);
			loader.load(_req,_context);	
			
		}
		
		private function configureListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(Event.COMPLETE, completeHandler);    
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
		}
		
		private function completeHandler(event:Event):void {			
			imageData = new Bitmap();
			imageData = event.target.content as Bitmap;
			imageData.smoothing = true;


			if (tmpurl.lastIndexOf("_th") != -1)
			{
				_mymodel.thht = loader.height;
				_mymodel.thwd = loader.width;
				dispatchEvent(new Event("thumbImageloadComplete"));
			}
			if(mainMcName == "mainContentMc")
			{
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