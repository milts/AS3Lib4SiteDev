package com.lbi.controllers
{
	import com.greensock.OverwriteManager;
	import com.lbi.events.GenericEvent;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	[Event(name="eventAnimOutBegin", type="com.lbi.controllers.MultiViewCtrl")]
	[Event(name="eventAnimOutComplete", type="com.lbi.controllers.MultiViewCtrl")]
	[Event(name="eventAnimInBegin", type="com.lbi.controllers.MultiViewCtrl")]
	[Event(name="eventAnimInComplete", type="com.lbi.controllers.MultiViewCtrl")]
	
	public class MultiViewCtrl extends EventDispatcher
	{
		public static const EVENT_ANIM_OUT_BEGIN:String 	= "EVENT_ANIM_OUT_BEGIN";
		public static const EVENT_ANIM_OUT_COMPLETE:String 	= "EVENT_ANIM_OUT_COMPLETE";
		public static const EVENT_ANIM_IN_BEGIN:String 		= "EVENT_ANIM_IN_BEGIN";
		public static const EVENT_ANIM_IN_COMPLETE:String 	= "EVENT_ANIM_IN_COMPLETE";
		
		protected var _viewCtrlsById:Dictionary;
		
		protected var _activeViewId:String;
		protected var _upcomingViewId:String;
		protected var _isAnimating:Boolean
		
		protected var _useSingleViewHolder:Boolean
		protected var _viewHolder:Sprite;
		
		/**
		 * <p>The constructor's attribute <code>useSingleViewHolder</code> specifies whether to add all Ctrls' views to one parent, 
		 * which is accessible through instance.view, so that you can just addChild( _myMultiViewCtrl.view ).</p>
		 * 
		 * <p><b>Note 1:</b> By default, all AbstractViews set their visibility on & off (in _changeState), so adding everything to one parent generally works well.</p>
		 * 
		 * <p><b>Note 2:</b> Setting <code>useSingleViewHolder = false</code> will simply <b>not</b> add the ctrls' views to anything, which enables/requires to to do it yourself.
		 * 
		 * <p><code>_viewCtrlsById</code> is a Dictionary which uses a <code>String id</code> as the key and an <code>AbtractViewCtrl</code> as the value.
		 * 
		 * <p>Use method <code>changeToViewWithId(id:String)</code> to switch between views.</p>
		 * 
		 * @see com.lbi.controllers.AbtractViewCtrl AbtractViewCtrl
		 * 
		 **/
		public function MultiViewCtrl( useSingleViewHolder:Boolean = true )
		{
			super();
			_viewCtrlsById = new Dictionary();
			_useSingleViewHolder = useSingleViewHolder;
			if ( _useSingleViewHolder )
				_viewHolder = new Sprite();
		}
		
		public function addViewCtrl( viewCtrl:AbstractViewCtrl ):void
		{
			_viewCtrlsById[ viewCtrl.id ] = viewCtrl;
			viewCtrl.addEventListener( AbstractViewCtrl.EVENT_CHANGE_REQUEST, _onChangeRequest );
			if ( _useSingleViewHolder )
				_viewHolder.addChild( viewCtrl.view );
		}
		
		private function _onChangeRequest ( e:GenericEvent ):void
		{
			changeToViewWithId( e.id );
		}
		
		public function changeToViewWithId(id:String):void
		{
			//
			//	No views, or requested view doesnt exist
			if ( !_viewCtrlsById || !Boolean( _viewCtrlsById[ id ] ) ) 
			{
				trace("No views, or requested view doesnt exist");
				trace("	-	_activeViewId :		", _activeViewId );
				trace("	-	_upcomingViewId :	", _upcomingViewId );
				trace("	-	changeToViewWithId(id :	", id );
				return;
			}
			//
			//	Requested view is already on.
			if ( _activeViewId == id ) 
			{
				trace("Requested view is already on.");
				trace("	-	_activeViewId :		", _activeViewId );
				trace("	-	_upcomingViewId :	", _upcomingViewId );
				trace("	-	changeToViewWithId(id :	", id );
				return;
			}
			//
			_upcomingViewId = id;
			//
			//	Something is already animating
			if ( _isAnimating )
			{
				trace("Something is already animating");
				trace("	-	_activeViewId :		", _activeViewId );
				trace("	-	_upcomingViewId :	", _upcomingViewId );
				trace("	-	changeToViewWithId(id :	", id );
				return;
			}
			// 
			if ( _viewCtrlsById[ _activeViewId ] )
			{
				oldViewOut();
			} else {
				newViewIn();
			}
		}
		
		public function get view():DisplayObjectContainer
		{
			return _viewHolder;
		}
		
		protected function oldViewOut():void
		{
			_isAnimating = true;
			//
			this.dispatchEvent( new GenericEvent( MultiViewCtrl.EVENT_ANIM_OUT_BEGIN, false, _activeViewId ) );
			//
			var oldViewCtrl:AbstractViewCtrl = _viewCtrlsById[ _activeViewId ] as AbstractViewCtrl;
			oldViewCtrl.addEventListener( AbstractViewCtrl.EVENT_STATE_CHANGE_COMPLETE, onOldViewOutComplete );
			oldViewCtrl.changeState( AbstractViewCtrl.STATE_OFF );
		}
		
		protected function onOldViewOutComplete (e:GenericEvent):void
		{
			this.dispatchEvent( new GenericEvent( MultiViewCtrl.EVENT_ANIM_OUT_COMPLETE, false, _activeViewId ) );
			//
			var oldViewCtrl:AbstractViewCtrl = _viewCtrlsById[ _activeViewId ] as AbstractViewCtrl;
			oldViewCtrl.view.visible = false;
			oldViewCtrl.removeEventListener( AbstractViewCtrl.EVENT_STATE_CHANGE_COMPLETE, onOldViewOutComplete );
			//
			newViewIn();
		}
		
		protected function newViewIn():void
		{
			_activeViewId = _upcomingViewId;
			_upcomingViewId = null;
			//
			this.dispatchEvent( new GenericEvent( MultiViewCtrl.EVENT_ANIM_IN_BEGIN, false, _activeViewId ) );
			//
			var newViewCtrl:AbstractViewCtrl = _viewCtrlsById[ _activeViewId ];
			newViewCtrl.view.visible = true;
			newViewCtrl.addEventListener( AbstractViewCtrl.EVENT_STATE_CHANGE_COMPLETE, onNewViewInComplete );
			newViewCtrl.changeState( AbstractViewCtrl.STATE_ON );
		}
		
		protected function onNewViewInComplete (e:GenericEvent):void
		{
			_isAnimating = false;
			//
			this.dispatchEvent( new GenericEvent( MultiViewCtrl.EVENT_ANIM_IN_COMPLETE, false, _activeViewId ) );
		}
		
	}
}