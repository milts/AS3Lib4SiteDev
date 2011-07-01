package com.lbi.utils
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	public class AlignController{
		
		//nine positions for pinning objects
		public static const TL:uint = 1;
		public static const TC:uint = 2;
		public static const TR:uint = 3;
		public static const ML:uint = 4;
		public static const MC:uint = 5;
		public static const MR:uint = 6;
		public static const BL:uint = 7;
		public static const BC:uint = 8;
		public static const BR:uint = 9;
		
		private static var _active:Boolean;
		private static var _stage:Stage;
		private static var _stageW:uint;
		private static var _stageH:uint;
		private static var _minW:uint;
		private static var _minH:uint;
		private static var _registeredObjects:Dictionary;
		
		//
		// inital call, sets stage and minimum stage size
		//
		public static function init($stage:Stage, $minW:uint = 1024, $minH:uint = 768):void
		{
			_stage = $stage;
			_minW = $minW;
			_minH = $minH;
			_stage.scaleMode = StageScaleMode.NO_SCALE;
			_stage.align = StageAlign.TOP_LEFT;
			
			_registeredObjects = new Dictionary(true);
			
			_stage.addEventListener(Event.RESIZE, _onStageResize);
			_active = true;
		}
		
		//
		// if you need to stop positioning objects for some reason
		//
		public static function pause():void
		{
			if ( _active )
			{
				_stage.removeEventListener(Event.RESIZE, _onStageResize);
				_active = false;
			}
		}
		
		public static function unpause():void
		{
			if ( !_active )
			{
				_stage.addEventListener(Event.RESIZE, _onStageResize);
				_active = true;
			}
		}
		
		//
		// used to add a display object to the list of objects that will be laid out
		//
		public static function registerMC($disp:DisplayObject, $loc:uint, $padX:Number = 0, $padY:Number = 0):void{
			
			if (_stage){
				_registeredObjects[$disp] = {location:$loc, padX:$padX, padY:$padY};
				_onStageResize(null);
			}
		}
		
		public static function unregisterMC($disp:DisplayObject):void{
			
			if (_stage){
				_registeredObjects[$disp] = null;
				delete(_registeredObjects[$disp]);
				_onStageResize(null);
			}
		}
		
		public static function forceResize():void
		{
			_onStageResize( null );
		}
		
		private static function _onStageResize(e:Event = null):void{
			var sw:uint = (_stage.stageWidth >= _minW) ? _stage.stageWidth : _minW;
			var sh:uint = (_stage.stageHeight >= _minH) ? _stage.stageHeight : _minH;
			
			for (var $disp:* in _registeredObjects){
				
				switch (_registeredObjects[$disp].location){
					
					case TL:
						$disp.x = $disp.y = 0;
						break;
					case TC:
						$disp.x = (sw / 2);
						$disp.y = 0;
						break;
					case TR:
						$disp.x = (sw);
						$disp.y = 0;
						break;
					case ML:
						$disp.x = 0;
						$disp.y = (sh / 2);
						break;
					case MC:
						$disp.x = (sw / 2);
						$disp.y = (sh / 2);
						break;
					case MR:
						$disp.x = (sw);
						$disp.y = (sh / 2);
						break;
					case BL:
						$disp.x = 0;
						$disp.y = (sh);
						break;
					case BC:
						$disp.x = (sw / 2);
						$disp.y = (sh);
						break;
					case BR:
						$disp.x = (sw);
						$disp.y = (sh);
						break;
				}
				$disp.x += _registeredObjects[$disp].padX;
				$disp.y += _registeredObjects[$disp].padY;
				trace("_mc=",$disp, $disp.y );
			}
		}
	}
}