package com.lbi.ui
{
	import com.lbi.events.GenericEvent;
	import com.lbi.ui.buttons.AbstractButton;
	
	import flash.events.EventDispatcher;
	
	import gs.util.ArrayUtils;

	public class RadioBtnCtrl extends EventDispatcher
	{
		private var _radioBtns:Array;
		private var _selectedBtn:AbstractButton;
		
		public function RadioBtnCtrl( abstractButtons:Array )
		{
			_radioBtns = [];
			for each ( var btn:AbstractButton in abstractButtons )
			{
				if (! ArrayUtils.contains( _radioBtns, btn ) )
				{
					_radioBtns.push( btn );
					btn.addEventListener( AbstractButton.EVENT_BUTTON_CLICKED, handleBtnClicked );
					btn.addEventListener( AbstractButton.EVENT_BUTTON_SELECTED, handleBtnSelection );
				}
			}
		}
		
		public function get selectedBtnId():String
		{
			return _selectedBtn.id;
		}
		
		public function selectFirst():void
		{
			selectBtn( _radioBtns[ 0 ] as AbstractButton );
		}
		
		private function handleBtnClicked ( e:GenericEvent ):void
		{
			selectBtn( e.currentTarget as AbstractButton );
		}
		
		private function handleBtnSelection ( e:GenericEvent ):void
		{
			this.dispatchEvent( e.clone() );
		}
		
		private function selectBtn (btn:AbstractButton):void
		{
			if ( _selectedBtn == btn ) return;
			//
			if ( _selectedBtn )
			{
				_selectedBtn.selected = false;
			}
			_selectedBtn = btn;
			_selectedBtn.selected = true;
		}
		
	}
}