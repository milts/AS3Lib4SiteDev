package com.lbi.ui.buttons
{
	import com.lbi.events.GenericEvent;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	[Event(name="eventButtonClicked", type="com.lbi.ui.buttons.AbstractButton")]
	[Event(name="eventButtonOver", type="com.lbi.ui.buttons.AbstractButton")]
	[Event(name="eventButtonOut", type="com.lbi.ui.buttons.AbstractButton")]
	[Event(name="eventButtonDown", type="com.lbi.ui.buttons.AbstractButton")]
	[Event(name="eventButtonUp", type="com.lbi.ui.buttons.AbstractButton")]
	[Event(name="eventButtonReleaseOutside", type="com.lbi.ui.buttons.AbstractButton")]
	[Event(name="eventButtonDragOutside", type="com.lbi.ui.buttons.AbstractButton")]
	[Event(name="eventButtonSelected", type="com.lbi.ui.buttons.AbstractButton")]
	[Event(name="eventButtonDeselected", type="com.lbi.ui.buttons.AbstractButton")]

	/**
	 * 
	 * Dispatches <code>GenericEvent</code> Events with Strings specified in this class
	 * 
	 * Two noteworthy attributes you can override to alter behavior are: 
	 * 
	 * <p><code>public var behaviorOnSelection:uint</code></p>
	 * 
	 * 	<li><code>AbstractButton.ON_SELECTION_DO_NOTHING:uint = 0;</code></li>
	 * 	<li><code>AbstractButton.ON_SELECTION_HOLD_MOUSEOVER:uint = 1;</code></li>
	 * 	<li><code>AbstractButton.ON_SELECTION_HOLD_MOUSEDOWN:uint = 2;</code></li>
	 * 
	 * <p>And</p>
	 * 
	 * <code>public var behaviorClickableOnSelection:Boolean = false;</code>
	 * 
	 * <p>When extending <code>AbstractButton</code>, most protected methods start with <code>'handle'</code>. Code completion is your friend.
	 * 
	 * @see GenericEvent com.lbi.events.GenericEvent
	 * 
	 **/
	public class AbstractButton extends Sprite 
	{
		
		public static const EVENT_BUTTON_CLICKED:String 	= "AbstractButton_btnClicked";
		public static const EVENT_BUTTON_OVER:String 		= "AbstractButton_btnOver";
		public static const EVENT_BUTTON_OUT:String 		= "AbstractButton_btnOut";
		public static const EVENT_BUTTON_DOWN:String 		= "AbstractButton_btnDown";
		public static const EVENT_BUTTON_UP:String 			= "AbstractButton_btnUp";
		public static const EVENT_BUTTON_RELEASE_OUTSIDE:String= "AbstractButton_btnReleaseOutside";
		public static const EVENT_BUTTON_DRAG_OUTSIDE:String= "AbstractButton_btnDragOutside";
		public static const EVENT_BUTTON_SELECTED:String 	= "AbstractButton_selOn";
		public static const EVENT_BUTTON_DESELECTED:String 	= "AbstractButton_selOff";
		
		public static const ON_SELECTION_DO_NOTHING:uint = 0;
		public static const ON_SELECTION_HOLD_MOUSEOVER:uint = 1;
		public static const ON_SELECTION_HOLD_MOUSEDOWN:uint = 2;
		
		protected var _id:String;
		
		public var behaviorOnSelection:uint = AbstractButton.ON_SELECTION_DO_NOTHING;
		public var behaviorClickableOnSelection:Boolean = false;
		
		protected var _eventBubbles:Boolean = true;
		protected var _isActive:Boolean = true;
		protected var _isSelected:Boolean = false;
		protected var _view:DisplayObjectContainer;
		
		protected var _mcHitArea:MovieClip;
		
		private var _clickListeners:Boolean = false;
		private var _hoverListeners:Boolean = false;
		private var _isMouseDown:Boolean= false;
		private var _isMouseOver:Boolean= false;
		
		public function AbstractButton( view:DisplayObjectContainer = null, id:String = null ) {
			this._id = id;
			//this.view = ( view ) ? view : null;   //	<- disallows graphical clips from extending this class (best practice when loading external gfx)
			this.view = ( view ) ? view : this;		//	<- enables graphical clips to extend this class (acceptable if everything (func & gfx) is compiled in one FLA)
			//
		}
		
		public function set view ( view:DisplayObjectContainer ):void
		{
			if ( view == _view )	return;
			//
			var shouldBeActive:Boolean = _isActive;
			this.active = false; // <- deactivates old view's listeners
			if( _view && this.contains(_view) )
			{
				this.removeChild( _view );
			}
			_view = view;
			_view.mouseChildren = false;
			_view.x = _view.y = 0;
			this.active = shouldBeActive; // <- sets listeners if old view was active
			//
			if ( _view && _view != this )
			{
				this.addChild( _view );
			}
			//
			view.addEventListener( Event.ADDED_TO_STAGE, _onAddedToStage );
			view.addEventListener( Event.REMOVED_FROM_STAGE, _onRemovedFromStage );
		}
		
		public function get view ():DisplayObjectContainer
		{
			return ( _view );
		}
		
		private function _onAddedToStage ( e:Event ):void
		{
		}
		
		private function _onRemovedFromStage ( e:Event ):void
		{
			_removeRelOutsideListener();
		}
		
		public function set active( isActive:Boolean ):void
		{
			if ( _isActive == isActive )	return;
			//
			_isActive = isActive;
			//
			if ( _isActive && !_clickListeners )
			{
				_addClickListeners();
				_addHoverListeners();
				handleActivated();
			} else if ( _clickListeners ) {
				_removeClickListeners();
				_removeHoverListeners();
				_removeRelOutsideListener();
				handleDeactivated();
			}
		}
		
		public function get active():Boolean
		{
			return _isActive;
		}
		
		public function set selected( sel:Boolean ):void
		{
			if ( sel == _isSelected ) return;
			//
			_isSelected = sel;
			if ( _isSelected )
			{
				handleSelected();
			} else {
				handleDeselected();
			}
		}
		
		public function get selected():Boolean
		{
			return _isSelected;
		}
		
		/** 
		 * 	set behaviorOnSelection takes one of three values:
		 * 		AbstractButton.ON_SELECTION_DO_NOTHING ( 0 )
		 * 		AbstractButton.ON_SELECTION_HOLD_MOUSEDOWN ( 1 )
		 * 		AbstractButton.ON_SELECTION_HOLD_MOUSEOVER ( 2 )
		public function set behaviorOnSelection( value:uint ):void
		{
			_behaviorOnSelection = value;
		} 
		 * */
		
		private function _addClickListeners():void
		{
			if( !_clickListeners )
			{
				if ( _mcHitArea )
				{
					_clickListeners = true;
					_mcHitArea.buttonMode = true;
					_mcHitArea.addEventListener( MouseEvent.CLICK, handleClick );
					_mcHitArea.addEventListener( MouseEvent.MOUSE_DOWN, handleDown );
					_mcHitArea.addEventListener( MouseEvent.MOUSE_UP, handleUp );
				} else {
					_clickListeners = true;
					this.buttonMode = true;
					this.addEventListener( MouseEvent.CLICK, handleClick );
					this.addEventListener( MouseEvent.MOUSE_DOWN, handleDown );
					this.addEventListener( MouseEvent.MOUSE_UP, handleUp );
				}
			}
		}
		
		private function _removeClickListeners():void
		{
			if( _clickListeners )
			{
				if ( _mcHitArea )
				{
					_clickListeners = false;
					_mcHitArea.buttonMode = false;
					_mcHitArea.removeEventListener( MouseEvent.CLICK, handleClick);
					_mcHitArea.removeEventListener( MouseEvent.MOUSE_DOWN, handleDown );
					_mcHitArea.removeEventListener( MouseEvent.MOUSE_UP, handleUp );
				} else {
					_clickListeners = false;
					this.buttonMode = false;
					this.removeEventListener( MouseEvent.CLICK, handleClick);
					this.removeEventListener( MouseEvent.MOUSE_DOWN, handleDown );
					this.removeEventListener( MouseEvent.MOUSE_UP, handleUp );
				}
			}
		}
		
		private function _addHoverListeners():void
		{
			if( !_hoverListeners )
			{
				if ( _mcHitArea )
				{
					_hoverListeners = true;
					_mcHitArea.addEventListener( MouseEvent.ROLL_OVER, handleOver );
					_mcHitArea.addEventListener( MouseEvent.ROLL_OUT, handleOut );
				} else {
					_hoverListeners = true;
					this.addEventListener( MouseEvent.ROLL_OVER, handleOver );
					this.addEventListener( MouseEvent.ROLL_OUT, handleOut );
				}
			}
		}
		
		private function _removeHoverListeners():void
		{
			if( _hoverListeners )
			{
				if ( _mcHitArea )
				{
					_hoverListeners = false;
					_mcHitArea.removeEventListener( MouseEvent.ROLL_OVER, handleOver);
					_mcHitArea.removeEventListener( MouseEvent.ROLL_OUT, handleOut);
				} else {
					_hoverListeners = false;
					this.removeEventListener( MouseEvent.ROLL_OVER, handleOver);
					this.removeEventListener( MouseEvent.ROLL_OUT, handleOut);
				}
			}
		}
		
		protected function handleClick( e:MouseEvent ):void
		{
			this.dispatchEvent( new GenericEvent( AbstractButton.EVENT_BUTTON_CLICKED, _eventBubbles, this._id ) );
			//
		}
		
		protected function handleOver( e:MouseEvent ):void
		{
			_isMouseOver = true;
			this.dispatchEvent( new GenericEvent( AbstractButton.EVENT_BUTTON_OVER, _eventBubbles, this._id ) );
		}
		
		protected function handleDown( e:MouseEvent ):void
		{
			_isMouseDown = true;
			this.dispatchEvent( new GenericEvent( AbstractButton.EVENT_BUTTON_DOWN, _eventBubbles, this._id ) );
			//
			_view.stage.addEventListener(MouseEvent.MOUSE_UP, handleReleaseOutside)
		}
		
		protected function handleReleaseOutside( e:MouseEvent ):void
		{
			_isMouseDown = false;
			_removeRelOutsideListener();
			this.dispatchEvent( new GenericEvent( AbstractButton.EVENT_BUTTON_RELEASE_OUTSIDE, _eventBubbles, this._id ) );
		}
		
		protected function handleUp( e:MouseEvent ):void
		{
			_isMouseDown = false;
			_removeRelOutsideListener();
			this.dispatchEvent( new GenericEvent( AbstractButton.EVENT_BUTTON_UP, _eventBubbles, this._id ) );
		}
		
		private function _removeRelOutsideListener():void
		{
			if( _view.stage && _view.stage.hasEventListener( MouseEvent.MOUSE_UP ) )
			{
				_view.stage.removeEventListener( MouseEvent.MOUSE_UP, handleReleaseOutside);
			}
		}
		
		protected function handleOut( e:MouseEvent ):void
		{
			_isMouseOver = false;
			this.dispatchEvent( new GenericEvent( AbstractButton.EVENT_BUTTON_OUT, _eventBubbles, this._id ) );
			//
			if ( _isMouseDown )
			{
				this.dispatchEvent( new GenericEvent( AbstractButton.EVENT_BUTTON_DRAG_OUTSIDE, _eventBubbles, this._id ) );
			}
		}
		
		protected function handleActivated():void {}
		
		protected function handleDeactivated():void {}
		
		protected function handleSelected():void
		{
			this.dispatchEvent( new GenericEvent( AbstractButton.EVENT_BUTTON_SELECTED, _eventBubbles, this._id ) );
			//
			switch ( behaviorOnSelection )
			{
				case AbstractButton.ON_SELECTION_HOLD_MOUSEOVER:
					if ( _isMouseDown )
					{
						handleUp( null );
					}
					if ( !_isMouseOver )
					{
						handleOver( null );
					}
				break;
				
				case AbstractButton.ON_SELECTION_HOLD_MOUSEDOWN:
					if ( !_isMouseDown )
					{
						handleDown( null );
					}
				break;
			} 
			if ( !behaviorClickableOnSelection )
			{
				_removeClickListeners();
			}
			_removeHoverListeners();
			
		}
		
		protected function handleDeselected():void
		{
			this.dispatchEvent( new GenericEvent( AbstractButton.EVENT_BUTTON_DESELECTED, _eventBubbles, this._id ) );
			//
			_isMouseOver = false;
			handleOut( null );
			
			_addHoverListeners();
			
			if ( !behaviorClickableOnSelection )
			{
				_addClickListeners();
			}
			
		}
		
		public function get id():String
		{
			return _id;
		}
		
		override public function toString():String
		{
			return ( super.toString()+"(id='"+ _id +"')" );
		}
	}
	
}
