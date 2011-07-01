package com.lbi.events
{
	import flash.events.Event;

	public class TimelineEvent extends GenericEvent
	{
		public static const TIMELINE_ANIMATION_START:String = "animationStart";
		public static const TIMELINE_ANIMATION_AT_FRAME:String = "animationAtFrame";
		public static const TIMELINE_ANIMATION_COMPLETE:String = "timelineAnimationComplete";
			
		public var currentFrame:int;
		
		/**
		 * inherited:
		 * public var data:Object;
		 * */
		 
		public function TimelineEvent(type:String, currentFrame:int, bubbles:Boolean = false, id:String= null, data:Object = null)
		{
			this.currentFrame = currentFrame;
			super( type, bubbles, id, data );
		}
		
		override public function clone():Event
		{
			return new TimelineEvent( this.type, this.currentFrame, this.bubbles, this.id, this.data) as Event;
		}
		
	}
}