package com.lbi.views
{
	import com.greensock.OverwriteManager;
	import com.greensock.TweenLite;
	import com.lbi.controllers.AbstractViewCtrl;
	import com.lbi.events.GenericEvent;
	
	import flash.display.Sprite;
	
	[Event(name="eventStateAnimComplete", type="com.lbi.views.AbstractView")]
	
	
	/**
	 * 
	 * Abstract Views can be extended to be the view class for any page or sub page element.
	 * 
	 * <p><b>Recommended for override:</b></p>
	 * <code>
	 * <li>protected function buildView():void</li>
	 * <li>protected function animIn():void</li>
	 * <li>protected function animOut():void</li>
	 * <li>public function destroy():void</li>
	 * </code>
	 * 
	 * <p><code>AbstractView</code> works hand in hand with <code>AbstractViewCtrl</code>, and has its animIn / animOut methods called from there.</p>
	 * 
	 * All transitions must end by calling <code>notifyViewTransitionComplete()</code>
	 * 
	 * <p><b>Note:</b> <b>When handled by<code>MultiViewCtrl</code></b>, <code>AbstractView</code> is added & removed from the render queue with <code>visible = false</code>, so there is no need to add/remove views to Stage whenever their state is changed from on to off..</p>
	 * 
	 * @see AbstractView.buildView()
	 * @see AbstractView.animIn()
	 * @see AbstractView.animOutComplete()
	 * @see AbstractView.notifyViewTransitionComplete()
	 * 
	 * @see AbstractViewCtrl
	 * 
	 * */
	public class AbstractView extends Sprite
	{
		
		public static const EVENT_STATE_ANIM_COMPLETE:String 	= "AbstractView_stateAnimComplete";
		
		public function AbstractView()
		{
			super();
		}
		
		/**
		 * typically called by AbstractViewCtrl
		 *
		 * @see AbstractViewCtrl
		 **/
		public function buildView():void
		{
			
		}
		
		/**
		 * Pls override this method with your own transition in.
		 * <b>NOTE:</b> This must eventually call <code>notifyViewTransitionComplete</code>
		 * @see notifyViewTransitionComplete
		 **/
		public function animIn():void
		{
			this.alpha = 0;
			TweenLite.to( this, 0.5, { alpha:1, onComplete: animInComplete, overwrite:OverwriteManager.AUTO });
		}
		
		/**
		 * Pls override this method with your own transition out.
		 * <b>NOTE:</b> This must eventually call <code>notifyViewTransitionComplete</code>
		 * @see notifyViewTransitionComplete
		 **/
		public function animOut():void
		{
			trace(this,"animOut");
			TweenLite.to( this, 0.5, { alpha:0, onComplete: animOutComplete });
		}
		
		protected function animInComplete():void
		{
			notifyViewTransitionComplete();
		}
		
		/**
		 * Using <code>visible = false</code> throughout, so there is no need to add/remove Views whenever their state is changed from on to off.
		 **/
		protected function animOutComplete():void
		{
			this.alpha = 1;
			notifyViewTransitionComplete();
		}
		
		/**
		 * All transitions must eventually call this method, 
		 * so that parental controller classes know when the view has finished animation.
		 **/
		protected function notifyViewTransitionComplete():void
		{
			this.dispatchEvent( new GenericEvent( AbstractView.EVENT_STATE_ANIM_COMPLETE ) );
		}
		
		public function destroy():void {}
		
	}
}