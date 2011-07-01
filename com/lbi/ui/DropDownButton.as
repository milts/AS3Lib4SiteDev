package com.lbi.ui
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;
	import com.lbi.controllers.AbstractViewCtrl;
	import com.lbi.controllers.MultiViewCtrl;
	import com.lbi.events.GenericEvent;
	import com.lbi.ui.buttons.AbstractButton;
	import com.lbi.utils.SpriteMaker;
	import com.lbi.views.AbstractView;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;


	[Event(name="eventNewSelection", type="com.lbi.ui.DropDownButton")]
	
	public class DropDownButton extends EventDispatcher
	{
		
		public static const EVENT_NEW_SELECTION:String = "DropDownBtnCtrl_newSelection";
		
		public static const STATE_OPEN:String = "viewStateOpen";
		public static const STATE_CLOSED:String = "viewStateClosed";
		
		protected const TWEEN_OPEN_DURATION:Number = 0.25;
		protected const TWEEN_CLOSE_DURATION:Number = 0.25;
		protected const TWEEN_OPEN_EASE:Function = Strong.easeOut;
		protected const TWEEN_CLOSE_EASE:Function = Strong.easeOut;
		
		protected var _view:Sprite;
		protected var _state:String;
		//
		private var _dropDownButtons:Array;
		private var _selectedLabelButtons:Array;
		//
		private var _length:uint;
		private var _numIdToStringId:Dictionary;
		//
		private var _mcDropDowns:Sprite;
		private var _mcSelected:Sprite;
		private var _maskDropDowns:Sprite;
		private var _maskSelected:Sprite;
		//
		private var _selectedId:uint = 0;
		
		/**
		 * There are a few things you need to know about using this class:
		 * 
		 * 1) Both Arrays must contain only AbstractButtons (com.lbi.ui.AbstractButtons) or something else extending that.
		 * 
		 * 2) Both Arrays must have same length, and each AbstractButton's 'id' attribute should identically correlate.
		 * 
		 * */
		public function DropDownButton( dropDownButtons:Array, selectedLabelButtons:Array )
		{
			//
			_view = new Sprite();
			_dropDownButtons = dropDownButtons;
			_selectedLabelButtons = selectedLabelButtons;
			//
			_length = dropDownButtons.length;
			_mcDropDowns = new Sprite();
			_mcSelected = new Sprite();
			_view.addChild( _mcDropDowns );
			_view.addChild( _mcSelected );
			//
			_maskDropDowns = SpriteMaker.makeSprite( 10, 10 );
			_maskSelected = SpriteMaker.makeSprite( 10, 10 );
			_view.addChild( _maskDropDowns );
			_view.addChild( _maskSelected );
			_mcDropDowns.mask = _maskDropDowns;
			_mcSelected.mask = _maskSelected;
			//
			_state = DropDownButton.STATE_CLOSED;
			_initElements();
			//
			// create numeric keys for each string 'id'
			_numIdToStringId = new Dictionary();
			for ( var i:uint=0; i< _dropDownButtons.length; i++ )
			{
				_numIdToStringId[ ( _dropDownButtons[i] as AbstractButton ).id ] = i;
			}
		}
		
		protected function _open():void
		{
			TweenLite.to( _mcDropDowns, this.TWEEN_OPEN_DURATION, { y: _mcSelected.height, ease:this.TWEEN_OPEN_EASE } );
			TweenLite.to( _maskDropDowns, this.TWEEN_OPEN_DURATION, { height: _mcDropDowns.height, ease:this.TWEEN_OPEN_EASE } );
		}
		
		protected function _close():void
		{
			TweenLite.to( _mcDropDowns, this.TWEEN_CLOSE_DURATION, { y: _mcSelected.height - _mcDropDowns.height, ease:this.TWEEN_CLOSE_EASE } );
			TweenLite.to( _maskDropDowns, this.TWEEN_CLOSE_DURATION, { height: 1, ease:this.TWEEN_CLOSE_EASE } );
		}
		
		private function _onStageRelease( e:GenericEvent ):void
		{
			changeState( DropDownButton.STATE_CLOSED );
		}
		
		protected function _onTransitionComplete():void
		{
			
		}
		
		public function changeState( state:String ):void 
		{
//			super.changeState( state );
			/**
			 *  don't forget: eventually SOMETHING in this process needs to call notifyStateChangeComplete();
			 * */
			//
			if ( state == _state ) return;	// quit if already in requested state
			
			switch ( state )
			{
				case DropDownButton.STATE_OPEN :
					_open();
					_addStageListener();
					break;
					
				case DropDownButton.STATE_CLOSED :
					_close();
					_removeStageListener();
					break;
			}
			_state = state;
		}
		
		public function changeSelectionById( id:String ):void
		{
			changeSelectionByNumber( _numIdToStringId[ id ] );
		}
		
		public function changeSelectionByNumber( num:uint ):void
		{
			if ( num == _selectedId )
			{
				return;
			}
			_mcSelected.addChild( _selectedLabelButtons[num] );
			_mcSelected.removeChild( _selectedLabelButtons[_selectedId] );
			_selectedId = num;
		}
		
		private function _initElements():void
		{
			var selectedBtn:AbstractButton = _selectedLabelButtons[ _selectedId ] as AbstractButton;
			selectedBtn.active = true;
			_mcSelected.addChild( selectedBtn );
			selectedBtn.x = selectedBtn.y = 0;
			//
			var thisSelect:AbstractButton;
			var thisDropDn:AbstractButton;
			var totalHeight:Number = 0;
			//
			for ( var i:uint=0; i<_length; i++ )
			{
				thisSelect = _selectedLabelButtons[i] as AbstractButton;
				thisDropDn = _dropDownButtons[i] as AbstractButton;
				thisDropDn.x = 0;
				thisDropDn.y = totalHeight;
				_mcDropDowns.addChild( thisDropDn );
				//
				totalHeight += thisDropDn.height;
				//
				thisSelect.addEventListener( AbstractButton.EVENT_BUTTON_DOWN, _onSelectMouseDn );
				thisSelect.addEventListener( AbstractButton.EVENT_BUTTON_CLICKED, _onSelectClick );
				thisSelect.addEventListener( AbstractButton.EVENT_BUTTON_DRAG_OUTSIDE, _onSelectClick );
				
				thisDropDn.addEventListener( AbstractButton.EVENT_BUTTON_UP, _onButtonClick );
			}
			_mcDropDowns.x = 0; 
			_mcDropDowns.y = _mcSelected.height - _mcDropDowns.height;
			_maskDropDowns.width = _mcDropDowns.width;
			_maskDropDowns.height = 1;
			_maskDropDowns.x = 0;
			_maskDropDowns.y = selectedBtn.y + selectedBtn.height;
			//
			_maskSelected.width = selectedBtn.width;
			_maskSelected.height = selectedBtn.height;
		}
		
		private function _onSelectMouseDn ( e:Event ):void
		{
			if ( _state == DropDownButton.STATE_OPEN )
			{
				changeState( DropDownButton.STATE_CLOSED );
			} else {
				changeState( DropDownButton.STATE_OPEN );
			}
		}
		
		private function _onSelectClick ( e:Event ):void
		{
			if ( _state == DropDownButton.STATE_OPEN )
			{
				_addStageListener();
			}
		}
		
		private function _onButtonClick ( e:GenericEvent ):void
		{
			this.dispatchEvent( new GenericEvent( DropDownButton.EVENT_NEW_SELECTION, false, (e.currentTarget as AbstractButton).id ) );
			changeSelectionById( e.id );
			changeState( DropDownButton.STATE_CLOSED );
		}
		
		private function _addStageListener():void
		{
			if ( _view.stage && !_view.stage.hasEventListener(MouseEvent.MOUSE_UP) )
			{
				_view.stage.addEventListener(MouseEvent.MOUSE_UP, _onStageClick );
			}
		}
		
		private function _removeStageListener():void
		{
			if ( _view.stage && _view.stage.hasEventListener(MouseEvent.MOUSE_UP) )
			{
				this._view.stage.removeEventListener(MouseEvent.MOUSE_UP, _onStageClick );
			}
		}
		
		private function _onStageClick( e:MouseEvent ):void
		{
			changeState( DropDownButton.STATE_CLOSED );
		}
		
		public function get view():Sprite
		{
			return _view;
		}
		
		public function get state():String
		{
			return _state;
		}
		
		
	}
}