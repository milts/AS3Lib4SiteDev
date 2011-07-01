package com.lbi.ui
{
	
	import com.lbi.events.GenericEvent;
	import com.lbi.ui.buttons.AbstractButton;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	[Event(name="eventToggle", type="com.lbi.ui.ToggleButton")]
	
	public class ToggleButton extends Sprite
	{
		public static const EVENT_TOGGLE:String 	= "ToggleBtnCtrl_toggle";
		
		private var _selectedBtn:AbstractButton;
		private var _selectedNum:uint;
		private var _buttons:Array;
		private var _buttonIds:Array;
		private var _buttonsById:Dictionary;
		
		/**
		 * 
		 * All AbstractButtons must have different 'id' attributes in order to properly function.
		 * 
		 * @see AbstractButton
		 **/
		
		public function ToggleButton( abstractButtons:Array )
		{
			super();
			_buttons = abstractButtons;
			_buttonIds = [];
			_buttonsById = new Dictionary();
			_selectedNum = 0;
			//
			var btn:AbstractButton;
			for each ( btn in abstractButtons )
			{
				btn.addEventListener( AbstractButton.EVENT_BUTTON_CLICKED, handleButtonClicked );
				this.addChild( btn );
				btn.x = btn.y = 0;
				_buttonIds.push( btn.id );
				_buttonsById[ btn.id ] = btn;
			}
			//
			selectBtnByNum();
			//
		}
		
		private function handleButtonClicked ( e:GenericEvent ):void
		{
			this.dispatchEvent( new GenericEvent( ToggleButton.EVENT_TOGGLE, false, e.id ) );
			//
			_selectedNum ++ % _buttons.length-1;
			var newBtnId:String = _selectedBtn.id;
			selectBtnByNum( _selectedNum );
		}
		
		public function selectBtnByNum( selectedNum:uint = 0 ):void
		{
			var btn:AbstractButton;
			for each ( btn in _buttons )
			{
				btn.visible = btn.id == _buttonIds[ selectedNum ];
			}
		}
		
		
		
	}
}