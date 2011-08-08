package com.glam
{	
	/**
	 * 
	 * @author Ankur
	 * 
	 */	
	import com.glam.Metrics;
	import com.glam.model.Model;
	import com.glam.templates.imgLoader;
	import com.glam.templates.swfLoader;
	import com.greensock.*;
	import com.greensock.easing.*;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.*;
	
	
	public class SplashClassic extends Sprite
	{
		private var baseSp:Sprite;
		private var _mymodel:Model;	
		private var il:imgLoader;
		private var sl:swfLoader;
		private var myloader:*;
		private var tmppos:Number;
		private var _unexpd:MovieClip;
		private var _expd:MovieClip;
		private var _intervalDuration:Number;
		private var _autoplayTime:Number;
		private var posx:Number;
		private var posy:Number;
		private var bgMc:MovieClip
		private var mainContentMc:MovieClip;
		private var thumbMc:MovieClip
		private var headerMc:MovieClip
		private var closeMc:MovieClip
		private var fsMc:MovieClip
		private var rtaMc:MovieClip
		private var ltaMc:MovieClip
		private var preloadMc:MovieClip;
		private var preloadSp:Sprite;
		private var firstFlg:Boolean = false;
		private var closeFlg:Boolean = false;
		private var setExpFlg:Boolean = false;
		private var apFlg:Boolean = false;
		private var expClickedFlg:Boolean = false;
		private var expadedFlg:Boolean = false;
		private var dataObject:Object;
		private var expTimer:Timer;
		private var fsTimer:Timer;
		private var apTimer:Timer;
		private static var _cnt:int = 0;
		private var animTime:Number = 0.5;
		private var tmpFSx:Number = 0;
		
		public function SplashClassic (autoplayTime:Number,intervalDuration:Number,myXML:String):void
			
		{
			Metrics.init(this);
			// main Sprite
			baseSp =  new Sprite();
			addChild(baseSp);
			
			// unexpanded MovieClip
			_unexpd = new MovieClip();
			_unexpd.buttonMode = true;
			baseSp.addChild(_unexpd);
			
			//expanded MovieClip
			_expd = new MovieClip();
			//_expd.x= - stage.stageWidth;
			baseSp.addChild(_expd);
			
		
			// All model instance
			_mymodel = Model.getInstance();
			_mymodel.currentSp = baseSp;
			_mymodel.expd = _expd;
			_mymodel.unexpd = _unexpd;

			// Assinging timer duration
			_intervalDuration = intervalDuration;
			_autoplayTime = autoplayTime;
		
			//bgmc in Expanded
			bgMc = new MovieClip();
			_expd.addChild(bgMc);	
			
			// Main center content MovieClip in Expanded
			mainContentMc = new MovieClip();
			mainContentMc.buttonMode = true
			mainContentMc.name = "mainContentMc";
			_expd.addChild(mainContentMc);	
			
			// header banner MovieClip in Expanded
			headerMc = new MovieClip();
			headerMc.buttonMode = true;
			_expd.addChild(headerMc);	
			
			// Close MovieClip in Expanded
			closeMc = new MovieClip();
			closeMc.buttonMode = true;
			_expd.addChild(closeMc);	
			
			// Fullscreen MovieClip in Expanded
			fsMc = new MovieClip();
			fsMc.buttonMode = true;
			_expd.addChild(fsMc);	
			
			// Left Arrow MovieClip in Expanded
			ltaMc = new MovieClip();
			ltaMc.buttonMode = true;
			ltaMc.name = "ltaMc";
			_expd.addChild(ltaMc);	

			// Right Arrow MovieClip in Expanded
			rtaMc= new MovieClip();
			rtaMc.buttonMode = true;
			rtaMc.name = "rtaMc"
			_expd.addChild(rtaMc);	

			//preloadMc in expanded
			preloadMc = new MovieClip();
			preloadMc.name = "preloadMc";
			_expd.addChild(preloadMc);			
			_mymodel.preloadMc= preloadMc;
			_mymodel.preloadMc.visible = false;

			// thumbnail MovieClip in Expanded
			thumbMc = new MovieClip();
			thumbMc.buttonMode = true
			thumbMc.x = stage.stageWidth/2;
			_expd.addChild(thumbMc);
			
			// XML loading
			var request:URLRequest = new URLRequest(myXML)
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, xmlprocessing);
			loader.load(request);			
			stage.addEventListener(Event.RESIZE, setScreen);
			stage.addEventListener(Event.FULLSCREEN, onFullscreen);
			
			// Expanded Timer initialize
			expTimer = new Timer(_intervalDuration,1);
			expTimer.addEventListener(TimerEvent.TIMER_COMPLETE,setExpand);
			
			// AutoPlay Timer Initialize
			apTimer =  new Timer(_autoplayTime,1);
			apTimer.addEventListener(TimerEvent.TIMER_COMPLETE,autoPlayFunc);
			_mymodel.apFlg = apFlg;
			_mymodel.apTimer = apTimer;
		
			//Fullscreen timer 
			fsTimer =  new Timer(_intervalDuration,1);
			fsTimer.addEventListener(TimerEvent.TIMER_COMPLETE,fsTimeComplete);
			
			//stage listerner
			stage.addEventListener(MouseEvent.CLICK,stageClicked);
 		}
		
		private function stageClicked(e:MouseEvent):void
		{
			if(_mymodel.apFlg)
			{
				Metrics.counter("Autoplay Stop");
				_mymodel.apFlg = false;
				_mymodel.apTimer.stop();
			}
		}
		
		private function autoPlayFunc(e:TimerEvent):void
		{
			if(_mymodel.apFlg)
			{
				rtaClicked();
			}
		}
		
		private function xmlprocessing(e:Event):void
		{
			_mymodel.xmlObj = XML(e.target.data);
			loadunexpanded();
		}
		
		// unexpanded loading
		private function loadunexpanded():void
		{			
			var cnt:int = _mymodel.xmlObj.data.assets.asset.length();
			for(var i:int=0;i<cnt;i++)
			{
				if(_mymodel.xmlObj.data.assets.asset[i].@name == "start_ani")
				{
					if(_mymodel.xmlObj.data.assets.asset[i].@type == "swf")
					{
						myloader =  new swfLoader();
					}else{
						myloader =  new imgLoader();
					}
					dataObject = new Object();
					dataObject.url =String(_mymodel.xmlObj.data.global.imagePath)+String(_mymodel.xmlObj.data.assets.asset[i].@src);
					dataObject.mcinsname = "unexpadedmc";
					dataObject.loaderMc = _mymodel.unexpd;
					dataObject.posX  =0;
					dataObject.posY = 0;
					myloader.loadnit(dataObject);
					myloader.loader.addEventListener(MouseEvent.MOUSE_OVER,showTimer);
					myloader.loader.addEventListener(MouseEvent.MOUSE_OUT,removeTimer);
					myloader.loader.addEventListener(MouseEvent.CLICK,expandedClicked);
					break;
				}
			}
			for(i=0;i<cnt;i++)
			{
				if(_mymodel.xmlObj.data.assets.asset[i].@name == "timer")
				{
					if(_mymodel.xmlObj.data.assets.asset[i].@type == "swf")
					{
						myloader =  new swfLoader();
						_mymodel.temp = myloader;

					}else{
						myloader =  new imgLoader();
						_mymodel.temp = myloader;

					}
					dataObject = new Object();
					dataObject.url =String(_mymodel.xmlObj.data.global.imagePath)+String(_mymodel.xmlObj.data.assets.asset[i].@src);
					dataObject.mcinsname = "timermc";
					dataObject.loaderMc = _mymodel.unexpd;
					dataObject.posX  =0;
					dataObject.posY = 0;
					myloader.loadnit(dataObject);	
					myloader.loader.visible = false;
					break;
				}
			}
		}
		
		private function showTimer(e:MouseEvent):void
		{
			expClickedFlg = false;
			setExpFlg = true;
			stage.addEventListener(Event.ENTER_FRAME,onEnterFrame);
			_mymodel.temp.loader.visible = true;
			TweenLite.to(_mymodel.temp.loader,animTime/2,{alpha:1, ease:Back.easeIn});
			_cnt =0;
			expTimer.start();			
		}
		
		private function removeTimer(e:MouseEvent):void
		{
			setExpFlg = false;
			_mymodel.temp.loader.visible = false;
			expTimer.stop();
		}
		
		private function expandedClicked(e:MouseEvent):void
		{
			expClickedFlg = true;
			setExpFlg = true;
			_mymodel.temp.loader.visible = false;
			setExpand();
		}
		// Tween alpha goes to Zero and That instance visiblility is False
		private function onFinishAlphatoZero(obj:Object):void
		{
			obj.visible = false;
		}
		private function  setExpand(e:TimerEvent = null):void
		{ 
				if(!expClickedFlg)
				{
					Metrics.counter("Autoplay Start");
					_mymodel.apFlg  = true;
				}else{
					_mymodel.apFlg  = false;
				}
				Metrics.track("expand", "Expand Expanded");
				TweenLite.to(_mymodel.unexpd, animTime, {alpha:0, ease:Back.easeOut, onComplete:onFinishAlphatoZero, onCompleteParams:[_mymodel.unexpd]});
				TweenLite.to(_mymodel.temp.loader, animTime, {alpha:0, ease:Back.easeOut, onComplete:onFinishAlphatoZero, onCompleteParams:[_mymodel.temp.loader]});
				_mymodel.expd.visible = true;
				TweenLite.to(_mymodel.expd,animTime/2,{alpha:1, ease:Back.easeIn});
				expTimer.stop();
				if(closeFlg)
				{
					thumbClicked();
					arrangeScreen();
					_mymodel.unexpd.getChildAt(0).removeEventListener(MouseEvent.MOUSE_OVER,showTimer);
					_mymodel.unexpd.getChildAt(0).removeEventListener(MouseEvent.MOUSE_OUT,removeTimer);
					_mymodel.unexpd.getChildAt(0).removeEventListener(MouseEvent.CLICK,expandedClicked);
				}else{
					firstFlg = true;
					loadAllThumbnails();
					//headerMc
					var cnt:int = _mymodel.xmlObj.data.assets.asset.length();
					for(var i:int=0;i<cnt;i++)
					{
						if(_mymodel.xmlObj.data.assets.asset[i].@name == "header")
						{
							if(_mymodel.xmlObj.data.assets.asset[i].@type == "swf")
							{
								myloader =  new swfLoader();
							}else{
								myloader =  new imgLoader();
							}
							dataObject = new Object();
							dataObject.url =String(_mymodel.xmlObj.data.global.imagePath)+String(_mymodel.xmlObj.data.assets.asset[i].@src);
							dataObject.mcinsname = "headermc";
							dataObject.loaderMc = headerMc;
							dataObject.posX  =0;
							dataObject.posY = 0;
							dataObject.u = String(_mymodel.xmlObj.data.assets.asset[i].@u);
							myloader.loadnit(dataObject);				
							myloader.myMc.addEventListener(MouseEvent.CLICK,headerClicked);
							break;
						}
					}
					// bgMc
					dataObject = new Object();
					if(_mymodel.xmlObj.data.interfaceSettings.theme.@type== "swf")
					{
						myloader =  new swfLoader();
						dataObject.url =String(_mymodel.xmlObj.data.global.imagePath)+String(_mymodel.xmlObj.data.interfaceSettings.theme.@name+"_bg.swf");			
					}else if(_mymodel.xmlObj.data.interfaceSettings.theme.@type == "image"){
						myloader =  new imgLoader();
						dataObject.url =String(_mymodel.xmlObj.data.global.imagePath)+String(_mymodel.xmlObj.data.interfaceSettings.theme.@name+"_bg.jpg");
					}else{
						if(_mymodel.xmlObj.data.interfaceSettings.theme.content.@type== "swf")
						{
							myloader =  new swfLoader();
						}else {
							myloader =  new imgLoader();
						}
						dataObject.url =String(_mymodel.xmlObj.data.global.imagePath)+String(_mymodel.xmlObj.data.interfaceSettings.theme.content.@src);
					}
					dataObject.mcinsname = "bgmc";
					dataObject.loaderMc = bgMc;
					dataObject.posX  =0;
					dataObject.posY = 0;
					myloader.loadnit(dataObject);	
					
					
					//closeMc
					dataObject = new Object();
					if(_mymodel.xmlObj.data.interfaceSettings.theme.@type == "swf")
					{
						myloader =  new swfLoader();
						dataObject.url =String(_mymodel.xmlObj.data.global.imagePath)+String(_mymodel.xmlObj.data.interfaceSettings.theme.@name+"_cl.swf");
					}else if(_mymodel.xmlObj.data.interfaceSettings.theme.@type == "image"){
						myloader =  new imgLoader();
						dataObject.url =String(_mymodel.xmlObj.data.global.imagePath)+String(_mymodel.xmlObj.data.interfaceSettings.theme.@name+"_cl.jpg");
					}else{
						if(_mymodel.xmlObj.data.interfaceSettings.theme.content.@type== "swf")
						{
							myloader =  new swfLoader();
						}else{
							myloader =  new imgLoader();
						}
						dataObject.url =String(_mymodel.xmlObj.data.global.imagePath)+String(_mymodel.xmlObj.data.interfaceSettings.theme.content.@src);
					}
					dataObject.mcinsname = "closemc";
					dataObject.loaderMc = closeMc;
					dataObject.posX  =_mymodel.stagewd-45;
					dataObject.posY = 5;
					myloader.loadnit(dataObject);
					closeMc.addEventListener(MouseEvent.CLICK,closeExpand);
					
					//fsMc
					dataObject = new Object();
					if(_mymodel.xmlObj.data.interfaceSettings.theme.@type == "swf")
					{
						myloader =  new swfLoader();			
						dataObject.url =String(_mymodel.xmlObj.data.global.imagePath)+String(_mymodel.xmlObj.data.interfaceSettings.theme.@name+"_fs.swf");
					}else if(_mymodel.xmlObj.data.interfaceSettings.theme.@type == "image"){
						myloader =  new imgLoader();
						dataObject.url =String(_mymodel.xmlObj.data.global.imagePath)+String(_mymodel.xmlObj.data.interfaceSettings.theme.@name+"_fs.jpg");
					}else{
						if(_mymodel.xmlObj.data.interfaceSettings.theme.content.@type== "swf")
						{
							myloader =  new swfLoader();
						}else{
							myloader =  new imgLoader();
						}
						dataObject.url =String(_mymodel.xmlObj.data.global.imagePath)+String(_mymodel.xmlObj.data.interfaceSettings.theme.content.@src);
					}
					dataObject.mcinsname = "flscreenmc";
					dataObject.loaderMc = fsMc;
					dataObject.posX  =_mymodel.stagewd-80;
					dataObject.posY = 5;
					myloader.loadnit(dataObject);
					fsMc.addEventListener(MouseEvent.CLICK,setFullScreenOnOff);
					
					//ltaMc
					dataObject = new Object();
					if(_mymodel.xmlObj.data.interfaceSettings.theme.@type == "swf")
					{
						myloader =  new swfLoader();
						dataObject.url =String(_mymodel.xmlObj.data.global.imagePath)+String(_mymodel.xmlObj.data.interfaceSettings.theme.@name+"_lta.swf");
					}else if(_mymodel.xmlObj.data.interfaceSettings.theme.@type == "image"){
						myloader =  new imgLoader();
						dataObject.url =String(_mymodel.xmlObj.data.global.imagePath)+String(_mymodel.xmlObj.data.interfaceSettings.theme.@name+"_lta.jpg");
					}else{
						if(_mymodel.xmlObj.data.interfaceSettings.theme.content.@type== "swf")
						{
							myloader =  new swfLoader();
						}else{
							myloader =  new imgLoader();
						}
						dataObject.url =String(_mymodel.xmlObj.data.global.imagePath)+String(_mymodel.xmlObj.data.interfaceSettings.theme.content.@src);
					}
					dataObject.mcinsname = "leftarrowmc";
					dataObject.loaderMc = ltaMc;
					dataObject.posX  =15;
					dataObject.posY = _mymodel.stageht/2;
					myloader.loadnit(dataObject);
					ltaMc.addEventListener(MouseEvent.CLICK,ltaClicked);
					
					//rtaMc
					dataObject = new Object();
					if(_mymodel.xmlObj.data.interfaceSettings.theme.@type == "swf")
					{
						myloader =  new swfLoader();
	
						dataObject.url =String(_mymodel.xmlObj.data.global.imagePath)+String(_mymodel.xmlObj.data.interfaceSettings.theme.@name+"_rta.swf");
					}else if(_mymodel.xmlObj.data.interfaceSettings.theme.@type == "image"){
						myloader =  new imgLoader();
						dataObject.url =String(_mymodel.xmlObj.data.global.imagePath)+String(_mymodel.xmlObj.data.interfaceSettings.theme.@name+"_rta.jpg");
					}else{
						if(_mymodel.xmlObj.data.interfaceSettings.theme.content.@type== "swf")
						{
							myloader =  new swfLoader();
						}else{
							myloader =  new imgLoader();
						}
						dataObject.url =String(_mymodel.xmlObj.data.global.imagePath)+String(_mymodel.xmlObj.data.interfaceSettings.theme.content.@src);
					}		
					dataObject.mcinsname = "rightarrowmc";
					dataObject.loaderMc = rtaMc;
					dataObject.posX  =_mymodel.stagewd-50;
					dataObject.posY = _mymodel.stageht/2;
					myloader.loadnit(dataObject);
					rtaMc.addEventListener(MouseEvent.CLICK,rtaClicked);
				}
				
				// preloadMc
				dataObject = new Object();
				if(_mymodel.xmlObj.data.interfaceSettings.theme.@type== "swf")
				{
					myloader =  new swfLoader();
					dataObject.url =String(_mymodel.xmlObj.data.global.imagePath)+String(_mymodel.xmlObj.data.interfaceSettings.theme.@name+"_preloader.swf");			
				}else if(_mymodel.xmlObj.data.interfaceSettings.theme.@type == "image"){
					myloader =  new imgLoader();
					dataObject.url =String(_mymodel.xmlObj.data.global.imagePath)+String(_mymodel.xmlObj.data.interfaceSettings.theme.@name+"_preloader.gif");
				}else{
					if(_mymodel.xmlObj.data.interfaceSettings.theme.content.@type== "swf")
					{
						myloader =  new swfLoader();
					}else {
						myloader =  new imgLoader();
					}
					dataObject.url =String(_mymodel.xmlObj.data.global.imagePath)+String(_mymodel.xmlObj.data.interfaceSettings.theme.content.@src);
				}
				dataObject.mcinsname = "preloadermc";
				dataObject.loaderMc = preloadMc;
				dataObject.posX  =0;
				dataObject.posY = 0;
				myloader.loadnit(dataObject);	
		}
		
		//Left Arrow Clicked
		private function ltaClicked(e:MouseEvent = null):void
		{
			Metrics.counter("Previous Button Clicked");
			dataObject = new Object();
			var tmpNo:int;
			for(var no:int=0; no< thumbMc.numChildren;no++)
			{
				if(int(_mymodel.currentObj.no) == no)
				{
					tmpNo =no-1;
					if(tmpNo < 0)
					{
						tmpNo = int(_mymodel.xmlObj.data.tot.@n)-1;
					}
					var tmpMc:MovieClip = thumbMc.getChildAt(tmpNo) as  MovieClip;
					dataObject = tmpMc.dataObj;
					break;
				}
			}
			loadMainContainer(dataObject);
		}
		//Right Arrow Clicked
		private function rtaClicked(e:MouseEvent = null):void
		{
			if(!_mymodel.apFlg)
			{
				Metrics.counter("Next Button Clicked");
			}
			dataObject = new Object();
			var tmpNo:int;
			for(var no:int=0; no< thumbMc.numChildren;no++)
			{
				if(int(_mymodel.currentObj.no) == no)
				{
					tmpNo =no+1;
					if(tmpNo == int(_mymodel.xmlObj.data.tot.@n))
					{
						tmpNo = 0;
					}
					var tmpMc:MovieClip = thumbMc.getChildAt(tmpNo) as  MovieClip;
					dataObject = tmpMc.dataObj;
					break;
				}
			}
			
			loadMainContainer(dataObject);
		}

		
		// used for unexpanded timer attached to mouse position when it rollovered on unexpanded movieclip 
		private function onEnterFrame(e:Event):void
		{	

			_mymodel.temp.loader.x = stage.mouseX;
			_mymodel.temp.loader.y = stage.mouseY;
			if(_mymodel.currentTypeOfObj == "video")
			{
				dimentionSetFunc();
			}
		}
		
		//Loading maincontent in Center Area 
		private function loadMainContainer(dataObj:Object):void
		{
			var no:int=0;
			dataObject = new Object();

			if(_mymodel.currentTypeOfObj == "video")
			{
				myloader.loader.unloadAndStop();
			}
			_mymodel.currentTypeOfObj = dataObj.type;
			
			dataObject.src =dataObj.src;
			dataObject.mcinsname = "mainmc";
			dataObject.loaderMc = mainContentMc;
			dataObject.posX  = 0;
			dataObject.posY = 0;
			dataObject.type  = dataObj.type;
			dataObject.u = dataObj.u;
			dataObject.no = dataObj.no;
			
			if(dataObj.type== "video")
			{
				myloader =  new swfLoader();
				dataObject.url = String(_mymodel.xmlObj.data.global.imagePath)+   String(_mymodel.xmlObj.data.interfaceSettings.templates.template[1].@path);
			}else {
				if(dataObj.type== "swf")
				{
					myloader =  new swfLoader();
				}else if(dataObj.type== "image"){
					myloader =  new imgLoader();
				}
				dataObject.url = String(_mymodel.xmlObj.data.global.imagePath)+  dataObject.src;
			}
			
		
			try
			{
				for(no=0; no< thumbMc.numChildren;no++)
				{
					TweenLite.to(thumbMc.getChildAt(no),animTime/2, {alpha:0.5, ease:Back.easeIn});
				}
				while(mainContentMc.numChildren >0)
				{
					mainContentMc.removeChildAt(0);
				}
			}catch(e:Error)
			{
			}
			try
			{
				if(dataObject.no != _mymodel.currentObj.no)
				{
					Metrics.stopTimer("tab"+(_mymodel.currentObj.no+1));
				}
			}catch(e:Error)
			{		
			}
			_mymodel.currentObj = dataObject;
			Metrics.startTimer("tab"+(dataObject.no+1));
			myloader.loadnit(dataObject);
			TweenLite.to(thumbMc.getChildAt(dataObject.no),animTime/2, {alpha:1, ease:Back.easeIn});
			myloader.addEventListener("mainContentloadComplete",mainContentloadingComplete);
		}
		
		private function mainContentloadingComplete(e:Event):void
		{
			if(_mymodel.currentTypeOfObj == "video")
			{
				if(_mymodel.apFlg)
				{
					e.target.myMc.getChildAt(0).content.initVideoplayer(String(_mymodel.xmlObj.data.global.imagePath)+ e.target.myMc.dataObj.src,e.target.myMc.dataObj.u,0)
				}else{
					e.target.myMc.getChildAt(0).content.initVideoplayer(String(_mymodel.xmlObj.data.global.imagePath)+ e.target.myMc.dataObj.src,e.target.myMc.dataObj.u,1)
				}
			}else{
				if(_mymodel.apFlg)
				{
					_mymodel.apTimer.start();
				}
				e.target.myMc.addEventListener(MouseEvent.CLICK,mainContentClicked);
			}
			arrangeScreen();
		}
		
		private function videoPlayComplete(e:Event):void
		{
			if(_mymodel.apFlg)
			{
				_mymodel.apTimer.start();
			}
		}
		
		//	main Content clicked
		private function mainContentClicked(e:MouseEvent):void
		{
			Metrics.counter("Main Content Clicked");
			Metrics.track("exit", e.currentTarget.dataObj.u as String);
			if(stage.displayState == StageDisplayState.FULL_SCREEN)
			{
				setFullScreenOnOff(false);
			}
		}
		
		// Load all thumbnails one by one
		private function loadAllThumbnails():void
		{
				if(_cnt < int(_mymodel.xmlObj.data.tot.@n))
				{				
					var url:String;
				
					posx = 0;
					posy = 0;
					if(_cnt == 0)
					{
						posx= 0;
					}else{
						posx = _mymodel.thwd*_cnt*1.05;
					}
					// For Thumbnail loading
					il = new imgLoader();
					var thumbName:String = String(_mymodel.xmlObj.data.slides.slide[_cnt].@src);
					thumbName = thumbName.substring(0,thumbName.lastIndexOf("."))+"_th.jpg";
				 	url= String(_mymodel.xmlObj.data.global.imagePath+thumbName);
					var dataObject:Object = new Object();
					dataObject.src = String(_mymodel.xmlObj.data.slides.slide[_cnt].@src);
					dataObject.url = url;
					dataObject.mcinsname = "dataContainer"+_cnt+"mc";
					dataObject.loaderMc = thumbMc;
					dataObject.posX  =posx;
					dataObject.posY = posy;
					dataObject.no = _cnt;
					dataObject.u = String(_mymodel.xmlObj.data.slides.slide[_cnt].@u);
					dataObject.type = String(_mymodel.xmlObj.data.slides.slide[_cnt].@type);
					il.loadnit(dataObject);
					il.myMc.addEventListener(MouseEvent.CLICK,thumbClicked);
					il.addEventListener("thumbImageloadComplete", thLoadComplete);
				}
		}
		
		// Thumb movie clip clicked
		private function thumbClicked(e:MouseEvent=null):void
		{
			if(!setExpFlg)
			{
				if(_mymodel.currentObj.no != e.currentTarget.dataObj.no)
				{
					Metrics.counter("tab "+e.currentTarget.dataObj.no + " Clicked");
					loadMainContainer(e.currentTarget.dataObj);
				}
			}else{
				setExpFlg = false;
				dataObject = new Object();
				dataObject.no = 0;
				dataObject.url = String(_mymodel.xmlObj.data.global.imagePath)+String(_mymodel.xmlObj.data.slides.slide[0].@src);
				dataObject.src = String(_mymodel.xmlObj.data.slides.slide[0].@src);
				dataObject.mcinsname = "mainmc";
				dataObject.loaderMc = mainContentMc;
				dataObject.posX  = 0;
				dataObject.posY = 0;
				dataObject.type  = String(_mymodel.xmlObj.data.slides.slide[0].@type);
				dataObject.u = String(_mymodel.xmlObj.data.slides.slide[0].@u);
				loadMainContainer(dataObject);
			}
		}
		
		// Header movieclip clicked 
		private function headerClicked(e:MouseEvent):void
		{
			Metrics.counter("Header Clicked");
			Metrics.track("exit", e.currentTarget.dataObj.u as String);
			if(stage.displayState == StageDisplayState.FULL_SCREEN)
			{
				setFullScreenOnOff(false);
			};
		}
		
		
		//Thumbnail loading Finished
		private function thLoadingFinished():void
		{
			stage.removeEventListener(Event.ENTER_FRAME,onEnterFrame);
			loadFistMainContent();
		}
		
		// intially loading first main Content
		private function loadFistMainContent():void
		{
			dataObject = new Object();
			dataObject.no = 0;
			dataObject.url = String(_mymodel.xmlObj.data.global.imagePath)+String(_mymodel.xmlObj.data.slides.slide[0].@src);
			dataObject.src = String(_mymodel.xmlObj.data.slides.slide[0].@src);
			dataObject.mcinsname = "mainmc";
			dataObject.loaderMc = mainContentMc;
			dataObject.posX  = 0;
			dataObject.posY = 0;
			dataObject.type  = String(_mymodel.xmlObj.data.slides.slide[0].@type);
			dataObject.u = String(_mymodel.xmlObj.data.slides.slide[0].@u);
			loadMainContainer(dataObject);
		}
		
		// this function  is called when one image load complete
		private function thLoadComplete(e:Event):void
		{	
			if(_cnt == (int(_mymodel.xmlObj.data.tot.@n)-1))
			{
				arrangeScreen();
				_mymodel.unexpd.visible = false;
				_mymodel.unexpd.getChildAt(0).removeEventListener(MouseEvent.MOUSE_OVER,showTimer);
				_mymodel.unexpd.getChildAt(0).removeEventListener(MouseEvent.MOUSE_OUT,removeTimer);
				_mymodel.unexpd.getChildAt(0).removeEventListener(MouseEvent.CLICK,expandedClicked);
				thLoadingFinished();
			}else{
				arrangeScreen();
				_cnt+=1;
				loadAllThumbnails();
			}
		}
		
		// Close Expand
		private function  closeExpand(e:MouseEvent):void
		{
			if(_mymodel.currentTypeOfObj == "video")
			{
				myloader.loader.unloadAndStop();
			}
			Metrics.counter("Close Button Clicked");
			Metrics.track("collpase", "Expand Closed");
			if(stage.displayState == StageDisplayState.FULL_SCREEN)
			{
				setFullScreenOnOff(false);
			}
			closeFlg = true;
			TweenLite.to(_mymodel.expd, animTime, {alpha:0, ease:Back.easeOut, onComplete:onFinishAlphatoZero, onCompleteParams:[_mymodel.expd]});
			_mymodel.unexpd.visible = true;
			TweenLite.to(_mymodel.unexpd,animTime/2, {alpha:1, ease:Back.easeIn});
			_mymodel.unexpd.getChildAt(0).addEventListener(MouseEvent.MOUSE_OVER,showTimer);
			_mymodel.unexpd.getChildAt(0).addEventListener(MouseEvent.MOUSE_OUT,removeTimer);
			_mymodel.unexpd.getChildAt(0).addEventListener(MouseEvent.CLICK,expandedClicked);

		}
		
		// Used for adjustment in screen when stage size / browser resizes
		private function setScreen(e:Event):void
		{
			arrangeScreen();
		}
		private function arrangeScreen():void
		{

			try
			{
				//applying stagewidth and stage height in to model class
				_mymodel.stagewd = stage.stageWidth;
				_mymodel.stageht = stage.stageHeight;	
				
				// preloadMc position 
				_mymodel.preloadMc.x = _mymodel.stagewd/2 - _mymodel.preloadMc.width/2;
				_mymodel.preloadMc.y = _mymodel.stageht/2 - _mymodel.preloadMc.height/2;
				
			}catch(e:Error){	
			}

			if (firstFlg)
			{
				try
				{
					// setting bg position in expanded Mc
					bgMc.getChildAt(0).width = _mymodel.stagewd;
					bgMc.getChildAt(0).height = _mymodel.stageht;
					
					// setting close  button position
					closeMc.getChildAt(0).x  = _mymodel.stagewd-45;

					//setting fullscreen button position
					fsMc.getChildAt(0).x  = _mymodel.stagewd-80;

					//setting left arrow button position
					ltaMc.getChildAt(0).y  = _mymodel.stageht/2- ltaMc.getChildAt(0).height/2;

					//setting right arrow button position
					rtaMc.getChildAt(0).x  = _mymodel.stagewd-45;
					rtaMc.getChildAt(0).y  = _mymodel.stageht/2- rtaMc.getChildAt(0).height/2;

					//setting header movieclip position
					//headerMc.getChildAt(0).x  = stage.stageWidth/2 - headerMc.width/2;
					//headerMc.getChildAt(0).y  = 0;
					TweenLite.to(headerMc.getChildAt(0),animTime/2, {x:(stage.stageWidth/2 - headerMc.width/2),y:0});
				}catch(e:Error){
				}

			}
			
			try
			{
				// Footer Thumnail setting
				var tmpX:Number
				if(thumbMc.width == 0){
					tmpX = stage.stageWidth/2;
				}else{
					tmpX = stage.stageWidth/2 - thumbMc.width/2;	
				}
				thumbMc.x = tmpX;
				thumbMc.y = stage.stageHeight - 80;

				// Main image container for center part				
				if(_mymodel.currentTypeOfObj == "video")
				{
					myloader.loader.content.resizePlayer((thumbMc.y-5) - (headerMc.y+headerMc.height+5));
					myloader.loader.content.vidComponent.addEventListener("dimentionSet",dimentionSetFunc);
					myloader.loader.content.vidComponent.addEventListener("videoEnd",videoPlayComplete);
				}else{					
					mainContentMc.getChildAt(0).height = (thumbMc.y-5) - (headerMc.y+headerMc.height+5);
					mainContentMc.getChildAt(0).scaleX = mainContentMc.getChildAt(0).scaleY;
				}
				mainContentMc.getChildAt(0).x = stage.stageWidth/2 - 	mainContentMc.width/2;
				mainContentMc.getChildAt(0).y =headerMc.y+headerMc.height+5;
			}catch(e:Error){
			}
		}
		
		// This function called after setting dimention of videocontent 
		private function dimentionSetFunc(e:* = null):void
		{
			mainContentMc.getChildAt(0).x = stage.stageWidth/2 - 	mainContentMc.width/2;
			mainContentMc.getChildAt(0).y =headerMc.y+headerMc.height+5;			
		}
		
		
		private function onFullscreen(e:Event):void
		{
			if(stage.displayState == StageDisplayState.NORMAL)
			{
				// Require to set video content position after Stage Fullscreen to Normal position
				if(_mymodel.currentTypeOfObj == "video")
				{
					stage.addEventListener(Event.ENTER_FRAME,onEnterFrame);
					fsTimer.start();
				}
				Metrics.track("fullscreen", "OFF");
				Metrics.stopTimer("fullscreen");
			}else{
				Metrics.track("fullscreen", "ON");
				Metrics.startTimer("fullscreen");
			}
		}
		// Fullscreen On/Off
		private function setFullScreenOnOff(fsButtonClicked:Boolean = true,e:MouseEvent = null):void
		{
			if (fsButtonClicked)
			{
			 	Metrics.counter("Fullscreen Button Clicked");
			}	
			if(stage.displayState == StageDisplayState.NORMAL)
			{
				stage.displayState = StageDisplayState.FULL_SCREEN;
			}
			else
			{	
				stage.displayState = StageDisplayState.NORMAL;
			}
		}

		// stop fullscreen timer
		private function fsTimeComplete(e:TimerEvent):void
		{
			stage.removeEventListener(Event.ENTER_FRAME,onEnterFrame);
			fsTimer.stop()
		}

	} // Class
}// Package
