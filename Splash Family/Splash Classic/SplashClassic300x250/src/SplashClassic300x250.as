package
{
	/**
	 * 
	 * @author Ankur
	 * 
	 */	
	import com.glam.SplashClassic;
	
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	
	//[SWF(width='300', height='250', backgroundColor='#000000', frameRate='30')]
	[SWF(widthPercent='100%', heightPercent='100%', backgroundColor='#FFFFFF', frameRate='30')]
	
	public class SplashClassic300x250 extends SplashClassic
	{
		private var _dataxml:String;
		private var _intervalDuration:Number;
		private var _autoplayTime:Number;
		
			
		public function SplashClassic300x250()
		{
			if (Capabilities.playerType == "External") 
			{
				_dataxml = LoaderInfo(root.loaderInfo).parameters["xmlPath"];
				_intervalDuration = LoaderInfo(root.loaderInfo).parameters["intervalDuration"];
				_autoplayTime = LoaderInfo(root.loaderInfo).parameters["autoplayTime"];
			}
			else
			{
				_dataxml = "data.xml";
				_intervalDuration = 1000;
				_autoplayTime = 3000;
			}	
			super(_autoplayTime,_intervalDuration,_dataxml);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;	
			stage.quality = StageQuality.BEST;
		}				
	}
}
