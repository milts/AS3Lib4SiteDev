package com.lbi.ui
{
	import com.lbi.events.GenericEvent;
	import com.lbi.ui.buttons.AbstractButton;
	
	import flash.events.EventDispatcher;
	
	import gs.util.ArrayUtils;
	

	public class CheckBoxBtnCtrl extends EventDispatcher
	{
		private var _checkBoxBtns:Array;
		private var _selectedBtns:Array;
		
		public function CheckBoxBtnCtrl( abstractButtons:Array )
		{
			_checkBoxBtns = [];
			_selectedBtns = [];
			//
			for each ( var btn:AbstractButton in abstractButtons )
			{
				if (! ArrayUtils.contains( _checkBoxBtns, btn ) )
				{
					_checkBoxBtns.push( btn );
					btn.addEventListener( AbstractButton.EVENT_BUTTON_CLICKED, handleBtnClicked );
					btn.addEventListener( AbstractButton.EVENT_BUTTON_SELECTED, handleBtnSelection );
					btn.addEventListener( AbstractButton.EVENT_BUTTON_DESELECTED, handleBtnSelection );
				}
			}
		}
		
		public function deselectById(id:String):void
		{
			for each ( var btn:AbstractButton in _checkBoxBtns )
			{
				if ( btn.id == id && btn.selected )
				{
					toggleSelectBtn( btn );
				}
			}
		}
		
		public function selectById(id:String):void
		{
			for each ( var btn:AbstractButton in _checkBoxBtns )
			{
				if ( btn.id == id && !btn.selected )
				{
					toggleSelectBtn( btn );
				}
			}
		}
		
		public function get selectedBtns():Array
		{
			return _selectedBtns;
		}
		
		public function get selectedBtnsIds():Array
		{
			var idArray:Array=[];
			for each ( var btn:AbstractButton in _selectedBtns )
			{
				idArray.push( btn.id );
			}
			return idArray;
		}
		
		private function handleBtnClicked ( e:GenericEvent ):void
		{
			toggleSelectBtn( e.currentTarget as AbstractButton );
		}
		
		private function handleBtnSelection ( e:GenericEvent ):void
		{
			this.dispatchEvent( e.clone() );
		}
		
		private function toggleSelectBtn (btn:AbstractButton):void
		{
			btn.selected = !btn.selected;
			
			if( ArrayUtils.contains( _selectedBtns, btn ) )
			{
				ArrayUtils.remove( _selectedBtns, btn );
			} else {
				_selectedBtns.push( btn );
			}
		}
		
	}
}