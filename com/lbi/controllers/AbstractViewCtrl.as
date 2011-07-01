package com.lbi.controllers
{
	import com.greensock.OverwriteManager;
	import com.greensock.TweenLite;
	import com.lbi.events.GenericEvent;
	import com.lbi.views.AbstractView;
	
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	
	[Event(name="eventChangeRequest", type="com.lbi.controllers.AbstractViewCtrl")]
	[Event(name="eventStateChangeBegin", type="com.lbi.controllers.AbstractViewCtrl")]
	[Event(name="eventStateChangeComplete", type="com.lbi.controllers.AbstractViewCtrl")]
	
	
	/**
	 * 
	 * This Controller class can instruct its View to show/hide elements etc through the <code>changeState</code> method
	 * 
	 * If your view does more than animate on & off, override the method <code>_callViewTransition</code> (called by <code>changeState</code>).
	 * 
	 * @see AbstractViewCtrl.changeState()  AbstractViewCtrl.changeState(state:String)
	 * @see AbstractViewCtrl._callViewTransition()  AbstractViewCtrl._callViewTransition(state:String)
	 * 
	 * @see AbstractView AbstractView
	 * 
	 **/
	public class AbstractViewCtrl extends EventDispatcher
	{
		public static const EVENT_CHANGE_REQUEST:String 	= "AbstractViewCtrl_changeRequest";
		
		public static const EVENT_STATE_CHANGE_BEGIN:String 	= "AbstractViewCtrl_stateChangeBegin";
		public static const EVENT_STATE_CHANGE_COMPLETE:String 	= "AbstractViewCtrl_stateChangeComplete";
		
		public static const STATE_OFF:String = "viewStateOff";
		public static const STATE_ON:String = "viewStateOn";
		
		protected var _id:String;

		protected var _state:String;
		protected var _viewInTransitionTo:String;
		protected var _stateInQueue:String;
		
		protected var _isViewBuilt:Boolean;
		protected var _isViewInTransition:Boolean;
		
		protected var _view:AbstractView;
	
		public function AbstractViewCtrl( view:AbstractView, id:String = null )
		{
			_id = id;
			_view = view;
		}
		
		/**
		 * <code>changeState</code> is typically called by <code>ViewTransitionCtrl</code>
		 * 
		 * @see ViewTransitionCtrl ViewTransitionCtrl
		 * 
		 **/
		public function changeState( state:String ):void 
		{
			if ( _isViewInTransition )
			{
				_stateInQueue = state;
				return;
			}
			if ( state == _state )
			{
				return;
			}
			buildViewOnlyOnce();
			//
			_isViewInTransition = true;
			_viewInTransitionTo = state;
			//
			_view.addEventListener( AbstractView.EVENT_STATE_ANIM_COMPLETE, _onViewStateChangeComplete );
			this.dispatchEvent( new GenericEvent( AbstractViewCtrl.EVENT_STATE_CHANGE_BEGIN, true, _id ));
			//
			_callViewTransition ( state );
		}
		
		protected function buildViewOnlyOnce():void
		{
			if ( !_isViewBuilt )
			{
				_view.buildView();
				_isViewBuilt = true;
			}
		}
		
		protected function _callViewTransition ( state:String ):void
		{
			switch ( state ) {
				case AbstractViewCtrl.STATE_ON:
					_view.animIn();
					break;
				//
				case AbstractViewCtrl.STATE_OFF:
					_view.animOut();
					break;
				//
			}
		}
		
		protected function _onViewStateChangeComplete( e:GenericEvent ):void
		{
			( e.currentTarget as AbstractView ).removeEventListener( AbstractView.EVENT_STATE_ANIM_COMPLETE, _onViewStateChangeComplete );
			//
			_isViewInTransition = false;
			_state = _viewInTransitionTo;
			_viewInTransitionTo = null;
			//
			if ( _stateInQueue )
			{
				var tempQueuedState:String = _stateInQueue;
				_stateInQueue = null;
				changeState( tempQueuedState );
				return;
			}
			this.dispatchEvent( new GenericEvent( AbstractViewCtrl.EVENT_STATE_CHANGE_COMPLETE, true, _id ));
		}
		
		public function get view():AbstractView
		{
			return _view;
		}
		
		public function get isViewInTransition():Boolean
		{
			return _isViewInTransition;
		}
		
		public function get state():String
		{
			return _state;
		}
		
		public function get id():String
		{
			return _id;
		}
		
		public function destroy():void {}
		
	}
}