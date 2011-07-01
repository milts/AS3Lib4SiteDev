package com.lbi.ui.buttons
{
	import flash.display.DisplayObjectContainer;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import gs.util.ArrayUtils;

	/**
	 * The <code>StandardButtonFrameBased</code> class extends <code>AbstractButton</code> and dispatches a <code>GenericEvent</code>.
	 * Please see this as a usable example of how to implement AbstractButton's extension.
	 * 
	 * This class assumes the view MovieClip contains several keyframes:
	 * <ul>
	 * 	<li><code>initialOn</code></li>
	 * 	<li><code>onToOver</code></li>
	 * 	<li><code>overToOn</code></li>
	 * 	<li><code>onToOff</code></li>
	 * 	<li><code>offToOn</code></li>
	 * 	<li><code>overToDown</code></li>
	 * 	<li><code>downToOver</code></li>
	 * </ul>
	 * 
	 * 'mc' is told to gotoAndPlay required frames, so 'mc' is responsible for its own stop() calls.
	 * 
	 * @see com.lbi.ui.AbstractButton
	 * @see com.lbi.ui.StandardButton
	 * @see com.lbi.events.GenericEvent
	 */
	
	public class StandardButtonFrameBased extends AbstractButton
	{
		
		public static const FRAME_INITIAL_ON:String = "initialOn";
		public static const FRAME_ON_TO_OVER:String = "onToOver";
		public static const FRAME_OVER_TO_ON:String = "overToOn";
		public static const FRAME_OFF_TO_ON:String = "offToOn";
		public static const FRAME_ON_TO_OFF:String = "onToOff";
		public static const FRAME_OVER_TO_DOWN:String = "overToDown";
		public static const FRAME_DOWN_TO_OVER:String = "downToOver";
		
		private var _labels:Array;
		private var _mc:MovieClip;
		 
		public function StandardButtonFrameBased( mc:MovieClip = null, id:String = null )
		{
			super(mc, id);
			//
		}
		
		override public function set view ( movieClip:DisplayObjectContainer ):void
		{
			if ( movieClip as MovieClip == null ) return;
			//
			_mc = movieClip as MovieClip;
			_labels = getFrameLabels( _mc );
			super.view = movieClip;
			//
			if ( _labels.indexOf( FRAME_INITIAL_ON ) != -1 )
			{
				_mc.gotoAndPlay( FRAME_INITIAL_ON );
			} else {
				_mc.stop();
			}
		}
		
		override protected function handleOver (e:MouseEvent):void
		{
			super.handleOver(e);
			//
			if ( ArrayUtils.contains( _labels, FRAME_ON_TO_OVER ) )
			{
				_mc.gotoAndPlay( FRAME_ON_TO_OVER );
			}
		}
		
		override protected function handleOut (e:MouseEvent):void
		{
			super.handleOut(e);
			//
			if ( ArrayUtils.contains( _labels, FRAME_OVER_TO_ON ) )
			{
				_mc.gotoAndPlay( FRAME_OVER_TO_ON );
			}
		}
		
		override protected function handleActivated():void
		{
			super.handleActivated();
			//
			if ( ArrayUtils.contains( _labels, FRAME_OFF_TO_ON ) )
			{
				_mc.gotoAndPlay( FRAME_OFF_TO_ON );
			}
		}
		
		override protected function handleDeactivated():void
		{
			super.handleDeactivated();
			//
			if ( ArrayUtils.contains( _labels, FRAME_ON_TO_OFF ) )
			{
				_mc.gotoAndPlay( FRAME_ON_TO_OFF );
			}
		}
		
		
		
		override protected function handleDown( e:MouseEvent ):void
		{
			super.handleDown(e);
			//
			if ( ArrayUtils.contains( _labels, FRAME_OVER_TO_DOWN ) )
			{
				_mc.gotoAndPlay( FRAME_OVER_TO_DOWN );
			}
		}
		
		override protected function handleUp( e:MouseEvent ):void
		{
			super.handleUp(e);
			//
			if ( ArrayUtils.contains( _labels, FRAME_DOWN_TO_OVER ) )
			{
				_mc.gotoAndPlay( FRAME_DOWN_TO_OVER );
			}
		}
		
		private function getFrameLabels( mc:MovieClip ):Array
		{
			var labelObjects:Array = mc.currentLabels;
			var labelNames:Array = [];
			for each ( var labelObject:FrameLabel in labelObjects )
			{
				labelNames.push( labelObject.name );
			}
			return labelNames;
		}
		
	}
}