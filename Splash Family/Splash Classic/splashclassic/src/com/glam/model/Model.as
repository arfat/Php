package com.glam.model
{
	/**
	 * 
	 * @author Ankur
	 * 
	 */	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.utils.Timer;
	
	public class Model
	{
		private static var _instance:Model;
		
		private var _wd:int;
		private var _ht:int;
		private var _exwd:int;
		private var _exht:int;
		private var _thwd:int = 0;
		private var _thht:int = 0;
		private var _stagewd:int;
		private var _stageht:int;
		private var _currentSp:Sprite
		private var _xmlObj:Object;
		private var _temp:Object;
		private var _unexp:MovieClip;
		private var _exp:MovieClip;
		private var _currentObj:Object;
		private var _currentTypeOfObj:String;
		private var _apFlg:Boolean;
		private var _apTimer:Timer;
		
		public function Model(obj:MyIntClass) 
		{
		}
		
		public static function getInstance():Model
		{
			if(!Model._instance)
			{
				 Model._instance = new Model(new MyIntClass());
			}
			else
			{
				 //trace('instance already initiated');
			}
			
			return Model._instance;
		}		
		
		//stores current Sprite
		public function set currentSp(value:Sprite):void
		{
			_currentSp = value;
		}
		public function get currentSp():Sprite
		{
			return _currentSp;
		}
		
		//stores current object type in main container
		public function set currentTypeOfObj(value:String):void
		{
			_currentTypeOfObj = value;
		}
		public function get currentTypeOfObj():String
		{
			return _currentTypeOfObj;
		}
		
		//stores auto play flag true/false value
		public function set apFlg(value:Boolean):void
		{
			_apFlg = value;
		}
		public function get apFlg():Boolean
		{
			return _apFlg;
		}
		//stores autoPlayTimer instance
		public function set apTimer(value:Timer):void
		{
			_apTimer = value;
		}
		public function get apTimer():Timer
		{
			return _apTimer;
		}
		
		//stores current Main Object
		public function set currentObj(value:Object):void
		{
			_currentObj = value;
		}
		public function get currentObj():Object
		{
			return _currentObj;
		}
		
		//stores unexpanded movie ref
		public function set unexpd(value:MovieClip):void
		{
			_unexp = value;
		}
		public function get unexpd():MovieClip
		{
			return _unexp;
		}
		
		//stores expanded movie ref
		public function set expd(value:MovieClip):void
		{
			_exp = value;
		}
		public function get expd():MovieClip
		{
			return _exp;
		}
		
		//stores normal(unexapnded) Width
		public function set wd(value:int):void
		{
			_wd = value;
		}
		public function get wd():int
		{
			return _wd;
		}
		
		//stores normal(unexapnded) Height
		public function set ht(value:int):void
		{
			_ht = value;
		}
		public function get ht():int
		{
			return _ht;
		}
		
		//stores exapnded width but inside of browser Width
		public function set exwd(value:int):void
		{
			_exwd = value;
		}
		public function get exwd():int
		{
			return _exwd;
		}
		
		//stores exapnded height but inside of browser Height
		public function set exht(value:int):void
		{
			_exht = value;
		}
		public function get exht():int
		{
			return _exht;
		}
		
		
		
		//stores thumbnail width
		public function set thwd(value:int):void
		{
			if(_thwd == 0)
			{
			_thwd = value;
			}
		}
		public function get thwd():int
		{
			return _thwd;
		}
		
		//stores thumbnail height
		public function set thht(value:int):void
		{
			if(_thht == 0)
			{
				_thht = value;
			}
		}
		public function get thht():int
		{
			return _thht;
		}
		
		//stores current resolution Width
		public function set stagewd(value:int):void
		{
			_stagewd = value;
		}
		public function get stagewd():int
		{
			return _stagewd;
		}
		
		//stores current resolution Height
		public function set stageht(value:int):void
		{
			_stageht = value;
		}
		public function get stageht():int
		{
			return _stageht;
		}
		
		//stores temp variable
		public function set temp(value:Object):void
		{
			_temp = value;
		}
		public function get temp():Object
		{
			return _temp;
		}
		
		// stores parsed xml data
		public function set xmlObj(value:Object):void
		{
			if(_xmlObj ==null)
			{
				_xmlObj = value;	
			}
		}
		public function get xmlObj():Object
		{
			return _xmlObj;
		}
	}
}

// used for singleton to create private constructor of Model Class
internal class MyIntClass{}