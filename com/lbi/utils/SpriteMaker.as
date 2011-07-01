package com.lbi.utils
{
    import flash.display.Sprite;
   
    public class SpriteMaker
    {
		public function SpriteMaker() {}
   
		public static function makeSprite(w:Number, h:Number, hex:uint = 0x000000, alpha:Number = 1 ):Sprite {
			var sp:Sprite = new Sprite();
		    sp.graphics.beginFill(hex, 1);
			sp.graphics.drawRoundRect(0, 0, w, h, 0);
		    sp.graphics.endFill();
			sp.alpha = alpha;
		    return sp;
		}
		
		public static function getRoundedSprite(w:Number, h:Number, x:Number = 0, y:Number = 0, hex:uint=0, curve:Number = 10):Sprite {
			var sp:Sprite = new Sprite();
			sp.graphics.beginFill(hex, 1);
			sp.graphics.drawRoundRect(x, y, w, h, curve);
			sp.graphics.endFill();
			return sp;
		}
		
		public static function makeSpriteCircle(r:Number, hex:uint = undefined):Sprite {
			var sp:Sprite = new Sprite();
			sp.graphics.beginFill(hex, 1);
			sp.graphics.drawCircle(0, 0, r);
			sp.graphics.endFill();
			return sp;
		}
	}
}
