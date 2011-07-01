package com.lbi.ui.buttons
{
	import com.greensock.TweenLite;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	/**
	 * The StandardButton class it a basic button implementing generic events.
	 * Please see this as a usable example of how to implement AbstractButton's extension.
	 * 
	 * This class assumes the 'mc' MovieClip contains several child MovieClips:
	 * <ul>
	 * 	<li>mc.btnOn</li>
	 * 	<li>mc.btnOver</li>
	 * 	<li>mc.btnDown</li>
	 * 	<li>mc.btnOff</li>
	 * </ul>
	 * 
	 * When the user rolls over the button, btnOver fades over the top of btnOn.
	 * Toggling 'set active( isActive:Boolean )' will switch between btnOn and btnOff (without animation)
	 * 
	 * @see com.lbi.ui.StandardButtonFrameBased StandardButtonFrameBased
	 * 
	 */
	public class StandardButton extends AbstractButton
	{
		protected var _mouseOverDuration:Number;
		protected var _mouseOutDuration:Number;
		protected var _mouseDownDuration:Number;
		protected var _mouseUpDuration:Number;
		
		protected var _mcOver:MovieClip;
		protected var _mcOn:MovieClip;
		protected var _mcDown:MovieClip;
		protected var _mcOff:MovieClip;
		
		public function StandardButton( mc:DisplayObjectContainer = null, id:String = null )
		{
			super(mc, id);
			//
			_mouseOverDuration 	= 0.25;
			_mouseOutDuration 	= 0.5;
			_mouseDownDuration 	= 0.1;
			_mouseUpDuration 	= 0.1;
		}
		
		override public function set view ( movieClip:DisplayObjectContainer ):void
		{
			if ( movieClip == _view || !(movieClip as MovieClip) )	return;
			//
			var mc:MovieClip = movieClip as MovieClip;
			if ( mc.btnOn )		_mcOn = mc.btnOn;
			if ( mc.btnOver )	_mcOver = mc.btnOver;
			if ( mc.btnDown )	_mcDown = mc.btnDown;
			if ( mc.btnOff )	_mcOff = mc.btnOff;
			
			if ( mc.btnHitArea )	_mcHitArea = mc.btnHitArea;
			//
			if ( _mcOver )	_mcOver.alpha = 0;
			if ( _mcDown )	_mcDown.alpha = 0;
			if ( _mcOff )	_mcOff.visible = false;
			if ( _mcHitArea )	_mcHitArea.alpha = 0;
			//
			super.view = movieClip;
			//
		}
		
		override protected function handleOver (e:MouseEvent):void
		{
			super.handleOver(e);
			//
			if ( _mcOver )
			{
				TweenLite.killTweensOf( _mcOver );
				TweenLite.to( _mcOver, _mouseOverDuration, {alpha:1} );
			}
		}
		
		override protected function handleOut (e:MouseEvent):void
		{
			super.handleOut(e);
			//
			if ( _mcOver )
			{
				TweenLite.killTweensOf( _mcOver );
				TweenLite.to( _mcOver, _mouseOutDuration, {alpha:0} );
			}
			if ( _mcDown )
			{
				_mcDown.alpha = 0;
			}
		}
		
		override protected function handleDown (e:MouseEvent):void
		{
			super.handleDown(e);
			//
			if ( _mcDown )
			{
				TweenLite.killTweensOf( _mcDown );
				TweenLite.to( _mcDown, _mouseDownDuration, {alpha:1} );
			}
			if ( _mcDown && _mcOver )
			{
				TweenLite.killTweensOf( _mcOver );
				TweenLite.to( _mcOver, _mouseDownDuration, {alpha:0} );
			}
		}
		
		override protected function handleUp (e:MouseEvent):void
		{
			super.handleUp(e);
			//
			if ( _mcDown )
			{
				TweenLite.killTweensOf( _mcOver );
				TweenLite.to( _mcOver, _mouseUpDuration, {alpha:0} );
			}
			if ( _mcDown && _mcOver )
			{
				TweenLite.killTweensOf( _mcOver );
				TweenLite.to( _mcOver, _mouseDownDuration, {alpha:1} );
			}
		}
		
		override protected function handleActivated():void
		{
			super.handleActivated();
			//
			if ( _mcOn && _mcOff )
			{
				_mcOn.visible = true;
				_mcOff.visible = false;
			}
			if ( _mcDown )
			{
				_mcDown.visible = true;
				_mcDown.alpha = 0;
			}
			if ( _mcOver )
			{
				_mcOver.visible = true;
				_mcOver.alpha = 0;
			}	
		}
		
		override protected function handleDeactivated():void
		{
			super.handleDeactivated();
			if ( _mcOn && _mcOff )
			{
				_mcOn.visible = false;
				_mcOff.visible = true;
			}
			if ( _mcDown )	_mcDown.visible = false;
			if ( _mcOver )	_mcOver.visible = false;
			
		}
		
	}
}