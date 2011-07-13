package 
{
	//DISPLAY
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	//CLICK THROUGH
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	//EVENTS
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.AsyncErrorEvent
	import flash.events.TimerEvent;
	//STAGE
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	//TWEEN
	import com.external.greensock.*;
	import com.external.greensock.easing.*;
	//VIDEO
	import fl.video.VideoEvent;
	import fl.video.FLVPlayback;
	import fl.video.SoundEvent;
	import flash.media.Video;
	import flash.media.SoundTransform;
	import flash.net.NetStream;
	import flash.net.NetConnection;
	//EXTERNAL INTERFACE
	import flash.external.ExternalInterface;
	//TIMER
	import flash.utils.Timer;
	//GLAM TRACKING
	import com.glam.Metrics;
	//SECURITY
	import flash.system.Security;
	
	
	/**
	 * ...
	 * @author Tushar Vaghela
	 * 
	 * Tween
	 * http://www.greensock.com/as/docs/tween/
	 * 
	 */
	public class Main extends Sprite 
	{
		public var _xml:XML;
		public var total_items:int = 0;
		public var tn:int = 0;
		public var _asset_list = new Array();
		
		public var tn_border_size:int = 2;
		public var tn_border_color:Number = 0xd2232a;
		public var thumbnail_group:MovieClip = new MovieClip();
		public var mcPlayer:MovieClip = new MovieClip();
		public var mcController:MovieClip = new MovieClip();
		public var mc:MovieClip = new MovieClip();
		public var show_tooltip:Boolean = false;	// true OR false
        public var tween_duration:Number = 0.6;
		public var speed:Number = 5;
		public var spacing:Number = 10;
		public var _pic:MovieClip = new MovieClip();
		public var current_tab_no:Number = 0;
		public var last_tab_no:Number = 0;
		public var i:int;
		
		public var videoRatio:Number = 1.777777777777778;
		public var played = {'25':false, '50':false, '75':false};
		
		public var videoURL:String = "Video.flv";
        public var connection:NetConnection;
        public var stream:NetStream;
		public var video:Video;
		public var soundT:SoundTransform;
		
		public var objInfo:Object;
		public var oParam:Object;
		
		public var bVideo:Boolean = false;
		public var bVideoTimer:Boolean = false;
		public var bFSMode:Boolean = false;
		
		public var autoplay:Boolean = true;
		public var autoplayTimer:Timer;
		public var autoplayDelay:Number = 3000;
		
		public var videoTimer:Timer;
		public var nRatio:Number;
		
		private var bHuman:Boolean = false
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			Security.allowDomain("*");
			
			oParam = LoaderInfo(this.root.loaderInfo).parameters;
			
			Metrics.init(this);
			
			stage.scaleMode = "noScale";
			stage.align = StageAlign.TOP_LEFT;
			
			oParam.ctPrefix = (oParam.ctPrefix || "");
			oParam.assetPrefix = (oParam.assetPrefix || "");
			oParam.videoAssetPrefix = (oParam.videoAssetPrefix || "http://www10.glam.com/widgets/ev3/jeep/assets/");
			//oParam.videoAssetPrefix = (oParam.videoAssetPrefix || "");
			
			load_gallery(oParam.dataXML || "data.xml");
			
			_pic.mask = _pic_mask;
			_pic_info.x = _pic.x = _pic_mask.x;
			_pic_info.y = _pic.y = _pic_mask.y;
			_pic_info.visible = false;
			
			thumbnail_group.mask = _tn_group_mask;
			thumbnail_group.alpha = .6;
			thumbnail_group.x = _tn_group_mask.x;
			thumbnail_group.y = _tn_group_mask.y;
			
			thumbnail_group.scaleX = thumbnail_group.scaleY = .6;
			
			mcPlayer.visible = false;
			
			this.addChild(thumbnail_group);
			
			if( show_tooltip == false )
			{
				this.removeChild(_tooltip);
			}
			else
			{
				_tooltip.visible = false;
				_tooltip.addEventListener( Event.ENTER_FRAME, tooltip );
			}
			
			stage.addEventListener(Event.RESIZE, arrangeStage);
			on_fs_mc.addEventListener(MouseEvent.CLICK, changeMode);
			on_close.addEventListener(MouseEvent.CLICK, closeIFrame);
			
			btnNext.addEventListener(MouseEvent.CLICK, navNext);
			btnPrev.addEventListener(MouseEvent.CLICK, navPrev);
			
			bClick.addEventListener(MouseEvent.CLICK, openURL);
			
			mcHeader.addEventListener(MouseEvent.CLICK, openTitleURL);
			mcBG.addEventListener(MouseEvent.CLICK, openBGURL);
			
			mcHeader.buttonMode = true;
			mcBG.buttonMode = true;
			
			mcCT.visible = false;
			mcCT.addEventListener(MouseEvent.CLICK,openURL);
		
			loadHeader();
		
			arrangeStage();
			
		}
		
		private function loadHeader() {
			
			try{
				var pic_request:URLRequest = new URLRequest(oParam.splashHeader || "Header.swf");
				var pic_loader:Loader = new Loader();
				
				pic_loader.addEventListener(Event.COMPLETE,arrangeStage);
				
				pic_loader.load(pic_request);
				
				mcHeader.addChild(pic_loader);
			}catch(e:Error){
				
			}
			
		}

		
		private function closeIFrame(e:MouseEvent=null):void 
		{
			if (stage.displayState == StageDisplayState.FULL_SCREEN) {
				stage.displayState = StageDisplayState.NORMAL;
			}
			
			if (bVideo) {
				pauseVideo();
			}
			
			Metrics.stopTimer("tab"+(current_tab_no+1));
			
			//glamEvent("close", 1);
			Metrics.stopTimer("expand");
			Metrics.track("collapse","");
			
			
			var sCloseFunc:String = (oParam.jsHide || "hideSite")
			
			ExternalInterface.call("top."+sCloseFunc+"("+1+")");
		}
		
		private function playHeadUpdate(e:VideoEvent):void {
			
			trace("playHeadUpdate called with " + e );
			
			
			mcController.txtTimeCurrent.text = formatTime(stream.time);
			//mcController.txtTimeTotal.text = formatTime(video.totalTime);
			
			//mcPlayer.mcController.mcProgress.scaleX = Math.round(mcPlayer.video_player.playheadPercentage) / 100;
			
		}
		
		
		private function playStateEnter(e:VideoEvent):void 
		{
			allvideoevents('videoplay');
			
		}
		
		private function pausedStateEnter(e:VideoEvent):void 
		{
			allvideoevents('videopause');
			
		}
		
		
		private function formatTime(t:int):String {
			
			// returns the minutes and seconds with leading zeros
			// for example: 70 returns 01:10
			var s:int=Math.round(t);
			var m:int=0;
			if (s>0) {
				while (s > 59) {
					m++;
					s-=60;
				}
				return String((m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s);
			} else {
				return "00:00";
			}			
		}
		
		private function changeMode(e:MouseEvent=null):void 
		{
			//stage.displayState = (stage.displayState == "fullscreen")?"normal":"fullscreen";
			stage.displayState = (stage.displayState == StageDisplayState.FULL_SCREEN)?StageDisplayState.NORMAL:StageDisplayState.FULL_SCREEN;
			
			if(stage.displayState == "fullScreen"){
				//Metrics.track("fullscreen");
				Metrics.startTimer("fullscreen");
				bFSMode = true;
			}
		}
		
		private function arrangeStage(e:Event = null):void {
			
			if(bFSMode == true && stage.displayState == "normal"){
				Metrics.stopTimer("fullscreen");
				bFSMode = false;
			}
			
			try{
			
				var nStageWidth:Number = stage.stageWidth;
				var nStageWidthHalf:Number = nStageWidth / 2;
				var nStageHeight:Number = stage.stageHeight;
				var nStageHeightHalf:Number = nStageHeight / 2;
	
				//Heading
				mcHeader.y = 0;
				mcHeader.x = (nStageWidthHalf) - (mcHeader.width / 2);
				
				//Thumbnails			
				if (thumbnail_group.width < nStageWidth) {
					thumbnail_group.x = _tn_group_mask.x = (nStageWidthHalf)-(thumbnail_group.width/2);
				}else {
					thumbnail_group.x = _tn_group_mask.x = 0;
				}
							
				thumbnail_group.y = _tn_group_mask.y =  stage.stageHeight - (thumbnail_group.height+spacing);
				_tn_group_mask.width = nStageWidth;	
				
				
				//Image 
				if (stage.stageHeight < (155 + _pic.height + thumbnail_group.height + spacing + 20)) {
					_pic.height = stage.stageHeight - 155 - thumbnail_group.height - (spacing* 2);
					_pic.scaleX = _pic.scaleY;
				}else {
					_pic.scaleX = _pic.scaleY = 1;
				}
				
				if (nStageWidth < ((btnNext.width + spacing) * 2) + _pic.width) {
					_pic.width = nStageWidth - ((btnNext.width + spacing) * 2) - spacing;
					_pic.scaleY = _pic.scaleX;
				}
				
				_pic_mask.width = _pic_bg.width = _pic.width;
				_pic_mask.height = _pic_bg.height = _pic.height;
				
				if (_pic.width != 0) {
					var nY:Number = ((stage.stageHeight - (thumbnail_group.height + spacing) - 75) / 2) - (_pic.height / 2);
					
					if (nY < 170) {
						nY = 170;
					}
						
					_pic.x = _pic_mask.x = _pic_bg.x = (nStageWidthHalf) - (_pic.width / 2);
					_pic.y = _pic_mask.y = _pic_bg.y = nY;
					bClick.visible = true;
				}else {
					_pic_bg.x = (nStageWidthHalf) - (_pic_bg.width / 2);
					_pic_bg.y = ((stage.stageHeight - (thumbnail_group.height + spacing)) / 2) - (_pic_bg.height / 2);
					bClick.visible = false;
				}
				
				//Loading Information
				loading_info.x = (nStageWidthHalf) - (loading_info.width / 2);
				loading_info.y = (stage.stageHeight / 2) - (loading_info.height / 2);
				
				//Fullscreen button	/ Close Button
				on_close.x = nStageWidth - (on_close.width) - spacing;
				on_close.y = spacing;
				
				on_fs_mc.x = on_close.x - (on_fs_mc.width) - spacing;
				on_fs_mc.y = spacing;
				
				if (stage.displayState == StageDisplayState.FULL_SCREEN) {
					on_fs_mc.gotoAndStop("off");
				}else {
					on_fs_mc.gotoAndStop("on");
				}
				
				//Clickout Button			
				bClick.x = _pic_bg.x + _pic_bg.width - bClick.width;
				bClick.y = _pic_bg.y - bClick.height;
				
				btnNext.x = nStageWidth - (btnNext.width / 2)-spacing;
				btnNext.y = nStageHeightHalf;
				
				btnPrev.x = (btnPrev.width / 2) + spacing;
				btnPrev.y = nStageHeightHalf;
				
				if (mcPlayer.visible) {
					mcPlayer.x = nStageWidthHalf - (mcPlayer.width / 2);
					mcPlayer.y = nStageHeightHalf = (mcPlayer.height/2)
				}
				
				mcBG.x = 0;
				mcBG.y = 0;
				mcBG.width = stage.stageWidth;
				mcBG.height = stage.stageHeight;
				
				
				if (bVideo) {
					
					//_pic.width = video.width;
					//_pic.height = video.height;
					
					if (stage.stageHeight < (mcHeader.height + video.height + mcController.height + thumbnail_group.height + spacing + 20)) {
						video.height = stage.stageHeight - mcHeader.height - thumbnail_group.height - (spacing* 2) - mcController.height;
						if (video.height< 300) {
							video.height = 300;
						}

						
						video.width = video.height * nRatio;
					}else {
						video.height = (objInfo.height || 864);
						video.width  = (objInfo.width || 483);
					}
					
					if (nStageWidth < ((btnNext.width + spacing) * 2) + video.width) {
						video.width = nStageWidth - ((btnNext.width + spacing) * 2) - spacing;
						
						if(video.width < 300){
							video.width = 300;
						}
						video.height = video.width / nRatio;
					}
					
					video.x = _pic.x = nStageWidthHalf - (video.width/ 2);
					video.y = _pic.y = nStageHeightHalf - (video.height/ 2);
					
					mcCT.x = video.x;
					mcCT.y = video.y;
					mcCT.width = video.width;
					mcCT.height = video.height;
					
					bClick.x = video.x + video.width - bClick.width;
					bClick.y = video.y - (bClick.height);
					
					bClick.visible = true;
					
					video.visible = true;
					mcController.visible = true;
					mcController.x = video.x;
					mcController.y = video.y + video.height;
					mcController.mcBg.width =  video.width;
					
					mcController.bPlayPause.x = 5 + (mcController.bPlayPause.width / 2);
					mcController.bMute.x = mcController.mcBg.width - 5  - (mcController.bMute.on_mc.width / 2);
					
					mcController.txtTimeCurrent.x = mcController.bPlayPause.x + (mcController.bPlayPause.width / 2) + 5;
					mcController.txtTimeTotal.x = mcController.bMute.x - (mcController.bMute.on_mc.width / 2) - 10 - mcController.txtTimeTotal.width;
					
					mcController.mcProgress.x = mcController.mcTotal.x = mcController.txtTimeCurrent.x + mcController.txtTimeCurrent.width  + 10;
					mcController.mcProgress.mcP.width = mcController.mcTotal.width = mcController.txtTimeTotal.x - (mcController.txtTimeCurrent.x + mcController.txtTimeCurrent.width+ 20)  ;
					
					
					
				}else {
					mcController.visible = false;
				}
			}catch(e:Error){
			
			}
			//glamEvent("stageresize", 1);
			
		}
		
		
		private function load_gallery(xml_file:String):void
		{
			//trace("load_gallery called with (" + arguments + ")");
			
			var xml_loader:URLLoader = new URLLoader();
			xml_loader.load( new URLRequest( xml_file ) );
			xml_loader.addEventListener(Event.COMPLETE, create_gallery);
		}
		
		private function create_gallery(e:Event):void
		{
			_xml = new XML(e.target.data);
			total_items = _xml.photo.length();

			for( i= 0; i < total_items; i++ )
			{
				_asset_list.push( {
					filename: _xml.photo[i].filename.toString(), 
					thumbnail: _xml.photo[i].thumbnail.toString(), 
					title: _xml.photo[i].title.toString(), 
					description: _xml.photo[i].description.toString(),
					url: _xml.photo[i].url.toString()
				} );
			}
			//css_loader.load( new URLRequest(css_file) );
			//css_loader.addEventListener(Event.COMPLETE, css_complete);
			
			load_tn();
		}
		
		private function load_tn():void
		{
			var pic_request:URLRequest = new URLRequest(oParam.assetPrefix +  _asset_list[tn].thumbnail );
			var pic_loader:Loader = new Loader();
			
			pic_loader.load(pic_request);
			pic_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, tn_progress);
			pic_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, tn_loaded);
			tn++;
		}
		
		private function tn_progress(e:ProgressEvent):void
		{
			loading_info.text = "Loading Thumbnail " + tn + " of " + total_items;
		}
		
		private function tn_loaded(e:Event=null):void
		{
			try{
			
				var tnBitmap:Bitmap = new Bitmap();
				var tnBitmap_2:MovieClip = new MovieClip();
				var tnMovieClip:MovieClip = new MovieClip();
				
				tnBitmap = Bitmap(e.target.content);
				tnBitmap.smoothing = true;
				tnBitmap.x = tn_border_size;
				tnBitmap.y = tn_border_size;
	
				var bg_width:Number = tnBitmap.width + tn_border_size * 2;
				var bg_height:Number = tnBitmap.height + tn_border_size * 2;
				
				if( tn_border_size > 0 )
				{
					tnMovieClip.graphics.beginFill(tn_border_color);
					tnMovieClip.graphics.drawRect( 0, 0, bg_width, bg_height );
					tnMovieClip.graphics.endFill();
				}
	
				tnMovieClip.addChild(tnBitmap);
	
				tnMovieClip.name = "_tn_" + thumbnail_group.numChildren;
				tnMovieClip.x = thumbnail_group.numChildren * ( bg_width + spacing );
				
				thumbnail_group.addChild( tnMovieClip );
	
				if( tn < total_items )
					load_tn();
				else
				{
					load_photo();
					loading_info.text = "";
					//dragger.visible = true;
					//drag_area.visible = true;
				}
			}catch(e:Error){
			
			}
			arrangeStage();
		}
		
		private function load_photo():void
		{
			Metrics.startTimer("tab"+(current_tab_no + 1));
			
			if (checkType(_asset_list[current_tab_no].filename) == "image") {
				
				mcCT.visible = false;
				
				//trace("Loading image : " + _folder + _asset_list[current_tab_no].filename);
				
				mcPlayer.visible = false;
				
				var pic_request:URLRequest = new URLRequest(oParam.assetPrefix + _asset_list[current_tab_no].filename );
				var pic_loader:Loader = new Loader();
				pic_loader.load(pic_request);
				pic_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, on_photo_progress);
				pic_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, on_photo_loaded);

				if( _pic.numChildren > 0 ) 
					_pic.removeChildAt(0);
					
				this.addChild(_pic);
				this.addChild(_pic_info);
				this.addChild(_tooltip);
				//_pic_info.photo_title.text = _asset_list[current_tab_no].title;
				//_pic_info.photo_description.htmlText = _asset_list[current_tab_no].description;
				loading_info.text = "Loading Image...";
				
				_pic.addEventListener(MouseEvent.CLICK, openURL);
				_pic.buttonMode = true;
				
				
			}else {
				
				bVideo = true;
				mcCT.visible = true;
				
				connection = new NetConnection();
				//connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
				connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
				connection.connect(null);
				
				
				videoURL = oParam.videoAssetPrefix +_asset_list[current_tab_no].filename;
				
				connectStream();
				
				activate_horizon();
				loading_info.text = "";
				
				if( _pic.numChildren > 0 ) 
					_pic.removeChildAt(0);
				
					
				this.addChild(_pic);
				this.addChild(_pic_info);
				this.addChild(_tooltip);
				
				//this.addChild(mcPlayer);
				//this.swapChildren(mcPlayer,_pic);
				_pic_info.photo_title.text = _asset_list[current_tab_no].title;
				_pic_info.photo_description.htmlText = _asset_list[current_tab_no].description;
				loading_info.text = "Loading Video...";
				
				
				video.visible = false;
				mcController.visible = false;
				
				video.addEventListener(MouseEvent.CLICK, openURL);
				//video.buttonMode = true;
				
			}
		}
		
		private function checkType(sInput):String
		{
			var aList:Array = sInput.split(".");
			var sType:String = "";
			
			if (aList[aList.length - 1] == "jpg") {
				sType = "image";
			}else {
				sType = "video"
			}
			
			return sType;
		}
		
		private function openURL(e:MouseEvent):void 
		{
			//trace(e.target.name + " clicked - open " + _asset_list[current_tab_no].url);
			
			Metrics.track("exit","tab" + (current_tab_no+1));
			
			var request:URLRequest = new URLRequest(oParam.ctPrefix + _asset_list[current_tab_no].url || "http://ad.doubleclick.net/clk;237696968;61023395;y");
			try { 
				if (stage.displayState == StageDisplayState.FULL_SCREEN) {
					stage.displayState = StageDisplayState.NORMAL;
				}
				navigateToURL(request, '_blank'); 
			}
			catch (e:Error) { 
				trace("Cannot clickout to " + _asset_list[current_tab_no].url); 
			}
			
			if (bVideo && bVideoTimer) {
				pauseVideo();
			}
			
		}
		
		private function openBGURL(e:MouseEvent):void 
		{	
			 Metrics.track("exit","expanded");
			
			var request:URLRequest = new URLRequest(oParam.ctPrefix  + _asset_list[current_tab_no].url || "http://ad.doubleclick.net/clk;237696968;61023395;y");
			try { 
				if (stage.displayState == StageDisplayState.FULL_SCREEN) {
					stage.displayState = StageDisplayState.NORMAL;
				}
				navigateToURL(request, '_blank'); 
			}
			catch (e:Error) { 
				trace("Cannot clickout to " + _asset_list[current_tab_no].url); 
			}
			
			if (bVideo && bVideoTimer) {
				pauseVideo();
			}
			
		}
		
		private function openTitleURL(e:MouseEvent):void 
		{	
			//glamEvent("titleexit", current_tab_no);
			 Metrics.track("exit","brand");
			
			var request:URLRequest = new URLRequest(oParam.ctPrefix + _asset_list[current_tab_no].url || "http://ad.doubleclick.net/clk;237696968;61023395;y");
			try { 
				if (stage.displayState == StageDisplayState.FULL_SCREEN) {
					stage.displayState = StageDisplayState.NORMAL;
				}
				navigateToURL(request, '_blank'); 
			}
			catch (e:Error) { 
				trace("Cannot clickout to " + _asset_list[current_tab_no].url); 
			}
			
			if (bVideo && bVideoTimer) {
				pauseVideo();
			}
			
		}
		
		private function unload_photo():void
		{
			
			if (bVideo) {
				stream.close();
				video.visible = false;
				bVideo = false;
				mcController.visible = false;
				
				if(bVideoTimer){
					Metrics.stopTimer("videoplay_tab"+(last_tab_no+1));
				}
				
				videoTimer.removeEventListener(TimerEvent.TIMER,timerUpdate)
			}
			
			Metrics.stopTimer("tab"+(last_tab_no+1));
			
			this.removeChild(_pic);
			this.removeChild(_pic_info);
			load_photo();
		}

		private function on_photo_progress(e:ProgressEvent):void
		{
			var percent:Number = Math.round(e.bytesLoaded / e.bytesTotal * 100);
			var filesize:Number = Math.round(e.bytesTotal / 1024);
			loading_info.text = "Loading Image... " + percent + "% (" + filesize + "KB)";
		}

		private function on_photo_loaded(e:Event):void
		{
			activate_horizon();
			loading_info.text = "";
			_pic.alpha = 0;
			_pic.addChild( Bitmap(e.target.content) );
			
			TweenLite.to(_pic, tween_duration, {alpha:1, ease:Circ.easeIn});
			
			arrangeStage();
			
			if (autoplay) {
				autoplayTimer = new Timer(autoplayDelay, 1);
				autoplayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, navNextAuto);
				autoplayTimer.start();
			}
		}
		
		private function tooltip(e:Event):void
		{
			_tooltip.x = mouseX;
			_tooltip.y = mouseY - 5;
		}
		
		private function activate_horizon():void
		{
			for( i = 0; i < total_items; i++ )
			{
				mc = MovieClip( thumbnail_group.getChildByName("_tn_" + i) );
				mc.addEventListener( MouseEvent.MOUSE_OVER, tn_over );
				mc.addEventListener( MouseEvent.MOUSE_OUT, tn_out );
				mc.addEventListener( MouseEvent.CLICK, tn_click );
				mc.buttonMode = true;
				
				if (i == current_tab_no) {
					mc.alpha = 1;
				}else {
					mc.alpha = .5;
				}
				
			}
			thumbnail_group.alpha = 1;
		}

		private function deactivate_horizon():void
		{
			for( i = 0; i < total_items; i++ )
			{
				mc = MovieClip( thumbnail_group.getChildByName("_tn_" + i) );
				mc.removeEventListener( MouseEvent.MOUSE_OVER, tn_over );
				mc.removeEventListener( MouseEvent.MOUSE_OUT, tn_out );
				mc.removeEventListener( MouseEvent.CLICK, tn_click );
				mc.buttonMode = false;
			}
			thumbnail_group.alpha = 0.5;
		}

		private function tn_over(e:MouseEvent):void
		{
			mc = MovieClip(e.target);
			//_tooltip.visible = true;
			_tooltip.pic_title.text = _asset_list[ parseInt( mc.name.slice(4, 7) ) ].title;
		}

		private function tn_out(e:MouseEvent):void
		{	
			_tooltip.visible = false;
		}

		private function tn_click(e:MouseEvent):void
		{
			mc = MovieClip(e.target);
			last_tab_no = current_tab_no;
			current_tab_no = parseInt(mc.name.slice(4,6));
			
			deactivate_horizon();
			//_tooltip.visible = false;
			//_pic_info.visible = false;
			_pic.removeEventListener( Event.ENTER_FRAME, detect_mouse );
			//Tweener.addTween( _pic, { alpha: 0, time: tween_duration, transition: "easeIn", onComplete: unload_photo } );
			
			TweenMax.to(_pic, tween_duration, { alpha:0, ease:Circ.easeIn, onComplete :unload_photo } );
			
			autoplay = false;
			
			if(autoplay) autoplayTimer.stop();
			Metrics.track("navigate", "thumbnail");
		}
		
		private function navNextAuto(e:TimerEvent=null):void 
		{
			navNext(e);
			autoplayTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, navNextAuto);
			//glamEvent("autonext", 1);
			Metrics.track("navigate", "right");
		}
		
		private function navNext(e:Event=null):void 
		{
			trace("navNext called with " + current_tab_no)
			
			if(e){
				if (e.type == "click") {
					autoplay = false;
					
					//glamEvent("next", 1);
					Metrics.track("navigate", "right")
				}
				
			}else {
				//trace("navNext callled by timer ");
			}
			
			last_tab_no = current_tab_no;
			
			if(current_tab_no<(total_items-1)){
				current_tab_no++;
			}else {
				current_tab_no = 0;
			}
			
			deactivate_horizon();
			//_tooltip.visible = false;
			//_pic_info.visible = false;
			_pic.removeEventListener( Event.ENTER_FRAME, detect_mouse );
			//Tweener.addTween( _pic, { alpha: 0, time: tween_duration, transition: "easeIn", onComplete: unload_photo } );
			
			TweenMax.to(_pic, tween_duration, { alpha:0, ease:Circ.easeIn, onComplete :unload_photo } );
			
		}
		
		private function navPrev(e:MouseEvent):void 
		{
			last_tab_no = current_tab_no;
			
			if(current_tab_no!=0){
				current_tab_no--;
			}else {
				current_tab_no = total_items-1;
			}
			
			Metrics.track("navigate", "left");
			
			deactivate_horizon();
			//_tooltip.visible = false;
			//_pic_info.visible = false;
			_pic.removeEventListener( Event.ENTER_FRAME, detect_mouse );
			//Tweener.addTween( _pic, { alpha: 0, time: tween_duration, transition: "easeIn", onComplete: unload_photo } );
			
			TweenMax.to(_pic, tween_duration, { alpha:0, ease:Circ.easeIn, onComplete :unload_photo } );
			
		}
		
		private function detect_mouse(e:Event):void
		{
			if( this.mouseX > _pic_info.x && this.mouseX < _pic_info.x + _pic_info.width &&
				this.mouseY > _pic_info.y && this.mouseY < _pic_info.y + _pic_info.height )
				_pic_info.visible = true;
			else
				_pic_info.visible = false;
		}
		
		private function allvideoevents(events) {
			//ExternalInterface.call("eclipseTrackEvent", events, 1);
			//glamEvent(events, 1);
			//Metrics.track("videoplay", "tab"+current_tab_no);
			
			if(events == "videoplay"){
				if(bVideoTimer == false){
					bVideoTimer = true;
					Metrics.startTimer("videoplay_tab"+(current_tab_no + 1));
					//Metrics.track(events,"tab" + (current_tab_no + 1));
				}
			}else if(events == "videopause"){
				if(bVideoTimer){
					Metrics.track(events,"tab" + (current_tab_no + 1));
					Metrics.stopTimer("videoplay_tab"+(current_tab_no + 1));
					bVideoTimer = false;
				}
			}else if(events == "videoend"){
				Metrics.track(events,"tab" + (current_tab_no + 1));
				Metrics.stopTimer("videoplay_tab"+(current_tab_no + 1));
				bVideoTimer = false;
			}else if(events == "videounmute" || events == "videomute"){
				Metrics.track(events,"tab" + (current_tab_no + 1));
			}else{
				Metrics.track(events,"tab" + (current_tab_no + 1));
			}
		}
		
		private function netStatusHandler(event:NetStatusEvent):void {
			//trace("netStatusHandler called with " + event.info.code);
            switch (event.info.code) {
                case "NetConnection.Connect.Success":
                    connectStream();
                    break;
                case "NetStream.Play.StreamNotFound":
                    trace("Unable to locate video: " + videoURL);
					connectStream();
                    break;
            }
        }

        private function connectStream():void {
			stream = new NetStream(connection);
            stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			//stream.addEventListener(NetStreamEvent.METADATA_RECEIVED, onMetaData);
			
			stream.client = { };
			stream.client.onMetaData = onMetaData;
			
            video = new Video(320,240)
            video.attachNetStream(stream);
			
			if(mcController){
				mcController = new video_control();
				
				mcController.bPlayPause.play_mc.addEventListener(MouseEvent.CLICK, pauseVideo);
				mcController.bPlayPause.pause_mc.addEventListener(MouseEvent.CLICK, playVideo);
				
				mcController.bMute.on_mc.addEventListener(MouseEvent.CLICK, stopAudio);
				mcController.bMute.off_mc.addEventListener(MouseEvent.CLICK, startAudio);
				
				//video.addEventListener(VideoEvent.PLAYHEAD_UPDATE, playHeadUpdate);
				
				videoTimer = new Timer(10);
				videoTimer.addEventListener(TimerEvent.TIMER, timerUpdate);
				
				videoTimer.start();
				
				soundT = stream.soundTransform;
				
				if (autoplay) {
					if (!bHuman)
					{
						soundT.volume = 0;
						mcController.bMute.on_mc.visible = false;
						//mcController.bMute.off_mc.mcSoundMessage.visible = true;
						mcController.bMute.off_mc.mcSoundMessage.gotoAndPlay("message");
						//mcController.bMute.off_mc.mcSoundMessage.gotoandPlay(10);
					}
				}else{
					soundT.volume = 1;
					mcController.bMute.on_mc.visible = true;
					//mcController.bMute.off_mc.mcSoundMessage.visible = false;
				}
				
				stream.soundTransform = soundT;
				
			}
			
            stream.play(videoURL);
			
			Metrics.startTimer("videoplay_tab"+(current_tab_no+1));
			//Metrics.track("videoplay","tab"+(current_tab_no+1));
			played = {'25':false, '50':false, '75':false};
			bVideoTimer = true;
			
			video.visible = true;
            this.addChild(video);  
			this.addChild(mcController);
        }
		
		private function timerUpdate(e:TimerEvent=null) {
			//trace("timerUpdate called with " + stream.time);
			
			try{
				var nTotal:Number = objInfo.duration;
				var nCurrent:Number = stream.time;
				var nPre:Number = Math.round((nCurrent / nTotal) * 100);
				
				nPre = nPre / 100;
				
				mcController.txtTimeCurrent.text = formatTime(nCurrent);
				
				mcController.mcProgress.scaleX = nPre;
				
				if (nPre == 1) {
					stream.seek(0);
					
					mcController.bPlayPause.play_mc.visible = false;
					mcController.bPlayPause.pause_mc.visible = true;
					stream.pause();
					
					allvideoevents('videoend');
					if (autoplay) {
						autoplayTimer = new Timer(1000, 1);
						autoplayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, navNextAuto);
						autoplayTimer.start();
					}
					
				}
				
				for (var key in played) 
				{
					//trace("played["+key+"] : " + played[key]);
					if (!played[key])
					{
						//trace("mcPlayer.video_player.playheadPercentage : " + mcPlayer.video_player.playheadPercentage);
						//trace("nPre : " + nPre + " key " + key);
						if ((nPre*100) >= key) 
						{
							allvideoevents('video'+key);
							played[key] = true;
							
						}
						return;
					}
				}
				
			}catch (err:Error)
			{
				//trace(err.name + " : " + err.message);
			}
			
			
			
			
		}
		
		private function pauseVideo(e:MouseEvent=null):void 
		{
			mcController.bPlayPause.play_mc.visible = false;
			mcController.bPlayPause.pause_mc.visible = true;
			stream.pause();
			
			allvideoevents('videopause');
			
		}
		
		private function playVideo(e:MouseEvent=null):void 
		{
			mcController.bPlayPause.play_mc.visible = true;
			mcController.bPlayPause.pause_mc.visible = false;
			
			stream.resume();
			
			allvideoevents('videoplay');
			
		}
		
		private function stopAudio(e:MouseEvent=null):void 
		{
			mcController.bMute.on_mc.visible = false;
			mcController.bMute.off_mc.visible = true;
			soundT.volume = 0;
			
			stream.soundTransform = soundT;
			
			allvideoevents('videomute');
			
		}
		
		private function startAudio(e:MouseEvent=null):void 
		{
			mcController.bMute.on_mc.visible = true;
			mcController.bMute.off_mc.visible = false;
			soundT.volume = 1;
			
			stream.soundTransform = soundT;
			bHuman = true
			allvideoevents('videounmute');
			
		}
		

        private function securityErrorHandler(event:SecurityErrorEvent):void {
            trace("securityErrorHandler: " + event);
        }
        
        private function asyncErrorHandler(event:AsyncErrorEvent):void {
            // ignore AsyncErrorEvent events.
        }
		
		private function onMetaData(info:Object):void {
			//trace("onMetaData called with " + info);
			// stores meta data in a object
			objInfo = new Object();
			objInfo = info;
			
			
			/*
			for each( var prop in info) {
				trace(prop + " : " + info[prop]);
			}
			*/
			
			
			video.width = _pic.width = info.width;
			video.height = _pic.height = info.height;
			
			nRatio = video.width / video.height;
			
			mcController.txtTimeTotal.text = formatTime(info.duration);
			
			//trace(formatTime(info.duration));
			// Center video instance on Stage.
			
			arrangeStage();

			// now we can start the timer because
			// we have all the neccesary data
		}
		
		private function glamEvent (events:String, no:Number) {
			trace("glamEvent called with " + events + "," + no);
			ExternalInterface.call("top.splashTrackEvent", events.toLowerCase(), no);
		}


	}
	
}