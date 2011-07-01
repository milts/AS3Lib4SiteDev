package com.lbi.controllers
{
	import com.lbi.events.GenericEvent;
	import com.lbi.ui.buttons.AbstractButton;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	[Event(name="eventNewScrollPosition", type="com.lbi.controllers.ScrollPanelCtrl")]
	
	public class ScrollPanelCtrl extends EventDispatcher
	{
		/**
		 * Fires event with no id, but with data object { pos: new Point() }
		 */
		public static const EVENT_NEW_SCROLL_POSITION:String = "evtNewScrollPosition";
		
		private var _mask:Sprite;
		private var _target:Sprite;
		private var _scrubber:AbstractButton;
		private var _positionIndicator:Sprite;
		private var _targetY:Number;
		private var _wholePixels:Boolean;
		private var _scrollOnMouseOver:Boolean;
		private var _dragCoefficient:Number;
		private var _extraMaskPadding:Number;
		private var _mouseAreaPadding:Number;
		private var _preciseMouseYPercent:Number = 0;
		private var _fluidMouseYPercent:Number = 0;
		
		private var _isPlaying:Boolean;
		private var _isScrubberDragging:Boolean;
		
		/**
		 * 
		 * <p><code>mask:Sprite</code> & <code>target:Sprite</code> both need to be added to some stage, before calling this constructor.</p>
		 * 
		 * <p><code>scrubber:AbstractButton = null</code> is a click and dragable AbstractButton</p>
		 * <p><code>positionIndicator:Sprite = null</code> is a non-interactive version of the scrubber.</p>
		 * <p>Typically, you'd use <b>either</b> <code>scrubber</code> or <code>positionIndicator</code>, and both should have their 0,0 position on the top left, not center</p>
		 * 
		 * <p><code>dragCoefficient:Number = 1</code> is a percentage calue stating how fast/slow it scrolls ( 0 to 1 )</p>
		 * <p><code>mouseAreaPadding:Number = 0</code> is the amount the user can move their cursor in from the edge of the edge of the mask before it moves the scrollable target</p>
		 * <p><code>extraMaskPadding:Number = 0</code> for if you want the mask to 'overhang' the target area</p>
		 * 
		 **/
		public function ScrollPanelCtrl( mask:Sprite, target:Sprite, scrubber:AbstractButton = null, positionIndicator:Sprite = null, wholePixels:Boolean = false, scrollOnMouseOver:Boolean = true, dragCoefficient:Number = 1, mouseAreaPadding:Number = 0, extraMaskPadding:Number = 0 )
		{
			_mask = mask;
			_target = target;
			_scrubber = scrubber ? scrubber : new AbstractButton(new Sprite() as DisplayObjectContainer);
			_positionIndicator = positionIndicator;
			_wholePixels = wholePixels;
			_scrollOnMouseOver = scrollOnMouseOver;
			_dragCoefficient = dragCoefficient;
			_mouseAreaPadding = mouseAreaPadding;
			_extraMaskPadding = extraMaskPadding;
			//
			_mask.cacheAsBitmap = _target.cacheAsBitmap = true;
			_target.mask = _mask;
			//
			_targetY = _mask.y + _extraMaskPadding;
			//
			_isPlaying = true;
			_mask.addEventListener( Event.ENTER_FRAME, _renderFrame );
			//
			_scrubber.addEventListener( AbstractButton.EVENT_BUTTON_DOWN, _scrubberMouseDown );
			_scrubber.addEventListener( AbstractButton.EVENT_BUTTON_UP, _scrubberMouseUp );
			_scrubber.addEventListener( AbstractButton.EVENT_BUTTON_RELEASE_OUTSIDE, _scrubberMouseUp );
		}
		
		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}
		
		public function pause():void
		{
			if ( !_isPlaying ) return;
			//
			_isPlaying = false;
			_mask.removeEventListener( Event.ENTER_FRAME, _renderFrame );
		}
		
		public function unpause():void
		{
			if ( _isPlaying ) return;
			//
			_isPlaying = true;
			_mask.addEventListener( Event.ENTER_FRAME, _renderFrame );
		}
		
		private function _scrubberMouseDown ( e:GenericEvent ):void
		{
			_isScrubberDragging = true;
			_scrubber.startDrag( false, new Rectangle( _scrubber.x, _mask.y + _extraMaskPadding, 0, _mask.height - _extraMaskPadding*2 - _scrubber.height ) );
		}
		
		private function _scrubberMouseUp ( e:GenericEvent ):void
		{
			_isScrubberDragging = false;
			_scrubber.stopDrag();
		}
		
		private function _renderFrame ( e:Event ):void
		{
			if ( _target.height < (_mask.height - _extraMaskPadding*2) )
			{
				_target.y = _mask.y+_extraMaskPadding;
				return;
			}
			var oldYPercent:Number = _fluidMouseYPercent;
			//
			if ( _isScrubberDragging )
			{
				_preciseMouseYPercent = ( _scrubber.y - ( _mask.y + _extraMaskPadding ) ) / ( _mask.height - _extraMaskPadding*2 - _scrubber.height );
			} 
			else if ( _isMouseInMask() && _scrollOnMouseOver )
			{
				_preciseMouseYPercent = Math.min( 1, Math.max( 0, ( _mask.mouseY - _mouseAreaPadding ) / ( _mask.height - _extraMaskPadding*2 - _mouseAreaPadding*2 ) ) );
			}
			var newYPercent:Number = oldYPercent + ( ( _preciseMouseYPercent - oldYPercent ) * _dragCoefficient );
			var newYPos:Number = _mask.y + _extraMaskPadding - ( _target.height - (_mask.height - _extraMaskPadding*2) ) * newYPercent;
			var autoScrubberPos:Number = _mask.y + _extraMaskPadding + ( _mask.height - (_extraMaskPadding*2) - _scrubber.height ) *  newYPercent;
			if ( _wholePixels )
			{
				newYPos = Math.round( newYPos );
				autoScrubberPos = Math.round( autoScrubberPos );
			}
			//
			if ( _target.y != newYPos )
			{
				_target.y = newYPos;
				if ( _scrubber && !_isScrubberDragging ) _scrubber.y = autoScrubberPos;
				//
				this.dispatchEvent( new GenericEvent( ScrollPanelCtrl.EVENT_NEW_SCROLL_POSITION, false, null, { pos: new Point( 0, newYPercent ) } ) );
			}
			_fluidMouseYPercent = newYPercent;
		}
		
		private function _isMouseInMask():Boolean
		{
			return Boolean( _mask.mouseX > 0 && _mask.mouseX < _mask.width && _mask.mouseY > 0 && _mask.mouseY < _mask.height );
		}
		
	}
}