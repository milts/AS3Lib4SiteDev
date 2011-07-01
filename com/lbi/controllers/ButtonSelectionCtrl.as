package com.lbi.controllers
{
	import com.lbi.events.GenericEvent;
	import com.lbi.ui.AbstractButton;
	
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	public class ButtonSelectionCtrl extends EventDispatcher
	{
		private var _btns:Dictionary;
		private var _selectedId:String;
		
		/**
		 * 
		 * Each element in 'buttons' must be an AbstractButton with a unique 'id' attribute.
		 * 'defaultId' corresponds to the AbstractButton's 'id' & is optional.
		 * 
		 * */
		public function ButtonSelectionCtrl( buttons:Array, defaultId:String = null )
		{
			super();
			//
			_btns = new Dictionary(true);
			for each ( var btn:AbstractButton in buttons )
			{
				_btns[ btn._id ] = btn;
				btn.selected = ( defaultId == btn._id );
				btn.addEventListener( AbstractButton.EVENT_BUTTON_SELECTED, _onBtnSelected );
			}
			_selectedId = defaultId;
		}
		
		public function get selectedId():String
		{
			return _selectedId;
		}
		
		public function set selectedId( value:String ):void
		{
			var selBtn:AbstractButton = _btns[ value ] as AbstractButton;
			if ( selBtn )
			{
				selBtn.selected = true;
			}
		}
		
		private function _onBtnSelected ( e:GenericEvent ):void
		{
			if ( _selectedId != e.id )
			{
				var oldSelectedBtn:AbstractButton = _btns[ _selectedId ] as AbstractButton;
				var newSelectedBtn:AbstractButton = _btns[ e.id ] as AbstractButton;
				//
				_selectedId = e.id;
				newSelectedBtn.selected = true;
				if ( oldSelectedBtn )
				{
					oldSelectedBtn.selected = false;
				}
			}
		}
		
	}
}