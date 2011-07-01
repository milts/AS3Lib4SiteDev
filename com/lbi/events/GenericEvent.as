package com.lbi.events
{
	import flash.events.Event;
	
	/**
	 * <p><code>GenericEvent</code> is the standard Event used in all standard controllers and buttons.</p>
	 * 
	 * <p>Attributes:</p>
	 * <li><code>type:String</code> - should be specified in the Base Controller which will be dispatching the events.</li>
	 * <li><code>bubbles:Boolean</code> - as per normal</li>
	 * <li><code>id:String</code> - id (name) of whatever if firing the event. (Useful especially when dispatched by one of many buttons, for example)</li>
	 * <li><code>data:Object</code> - open <code>Object</code> useful for any other data that may be needed to be passed around.</li>
	 * 
	 * <p><b>NOTE:</b></p>
	 * <p>This is designed (and it is standard practice) to allow for the event's attribute <code>type:String</code> to be declared as a static const within the controller class that dispatches the event.
	 * 
	 * <p>For example, an <code>AbstractButton</code> may dispatch:</p>
	 * <p><code>new GenericEvent( AbstractButton.EVENT_BUTTON_CLICKED, true, id, data )</code></p>  
	 **/
	public class GenericEvent extends Event
	{
		public var data:Object;
		public var id:String;
		
		public function GenericEvent( type:String, bubbles:Boolean = false, id:String = null, data:Object = null ) {
			this.data = data;
			this.id = id;
			super(type, bubbles);
		}
		
		override public function clone():Event
		{
			return new GenericEvent( this.type, this.bubbles, this.id, this.data) as Event;
		}
		
	}
}