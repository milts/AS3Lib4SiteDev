package com.lbi.utils
{
	import flash.text.AntiAliasType;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	public class TextUtil
	{
		public function TextUtil()
		{
		}
		
		public static function prepText ( txtField:TextField, width:Number = 0, stylesheet:StyleSheet = null, multiline:Boolean = true, isSelectable:Boolean = false, autoSize:String = "left" ):TextField
		{
			var txtToReturn:TextField = txtField ? txtField : new TextField();
			//
			txtToReturn.embedFonts 		= true;
			//
			txtToReturn.styleSheet 		= stylesheet;
			//
			txtToReturn.mouseEnabled 	= isSelectable;
			txtToReturn.selectable 		= isSelectable;
			//
			txtToReturn.multiline 		= multiline;
			txtToReturn.wordWrap 		= multiline;
			//
			if ( width > 0 )
			{
				txtToReturn.width 		= width;
			}
			//
			if ( autoSize != "none" )
			{
				txtToReturn.height 		= 0;
				txtToReturn.autoSize	= autoSize;
			}
			//
			txtToReturn.antiAliasType = AntiAliasType.ADVANCED;
			return txtToReturn;
		}
	}
}