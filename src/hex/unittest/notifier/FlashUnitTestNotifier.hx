package hex.unittest.notifier;

#if flash
import flash.Lib;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.text.TextFormat;
import hex.error.Exception;
import hex.unittest.assertion.Assert;
import hex.unittest.description.ClassDescriptor;
import hex.unittest.error.AssertException;
import hex.unittest.event.ITestClassResultListener;

/**
 * ...
 * @author Francis Bourre
 */
class FlashUnitTestNotifier implements ITestClassResultListener
{
	static var _TRACE 		: Dynamic = haxe.Log.trace;
	
    var _trace  			: Dynamic;
    var _tabs   			: Int = 0;

	var console				: TextField;
	var target				: DisplayObjectContainer;
	var successMarker		: Sprite;
	var styleSheet			: StyleSheet;
	var _styleList			= new Map<String,Bool>();

    public function new( target : DisplayObjectContainer = null )
    {
		this.setConsole( target !=null ? target : Lib.current.stage );
		this.setGlobalResultSuccess( );
    }
	
	function setConsole( target : DisplayObjectContainer ) : Void
	{
		this.target 					= target;
		this.console 					= new TextField();
		this.console.background 		= true;
		this.console.backgroundColor 	= 0x060606;
		this.console.x 					= 50;
		this.console.height 			= target.stage.stageHeight;
		this.console.width 				= target.stage.stageWidth - this.console.x;
		this.console.textColor 			= 0xffffff;
		this.console.wordWrap 			= true;
		this.console.selectable 		= true;
		this.console.multiline 			= true;
		this.console.defaultTextFormat 	= new TextFormat( "Lucida Console", 11 );
		
		target.addChild( this.console );
		
		this.styleSheet 				= new StyleSheet();
		this.console.styleSheet 		= this.styleSheet;
		
		this.successMarker = new Sprite();
		this.target.addChild( this.successMarker );
	}

    function _log( element : String ) : Void
    {
		var buffer = '';

		for ( i in 0...this._tabs * 4 ) 
		{
			buffer += "&nbsp;";
		}
		
		element = buffer + element + "<br/>";
		
		this.console.htmlText = this.console.htmlText + element;
		this.console.scrollV = this.console.maxScrollV;
    }

    function _addTab() : Void
    {
        this._tabs++;
    }

    function _removeTab() : Void
    {
        this._tabs--;
    }

    public function onStartRun( descriptor : ClassDescriptor ) : Void
    {
        this._tabs = 0;
        this._log( this.createElement( "[[[ Start " + descriptor.className + " tests run ]]]", "yellow+bold+h3" ) );
        this._addTab();
    }

    public function onEndRun( descriptor : ClassDescriptor ) : Void
    {
        this._removeTab();
		
		var successfulCount = Assert.getAssertionCount() - Assert.getAssertionFailedCount();
		
		var beginning 		= this.createElement( "[[[ Test runs finished :: ", "yellow+bold+h3" );
		var all 			= this.createElement( Assert.getAssertionCount() + " overall :: ", "white+bold+h3" );
		var successfull 	= this.createElement( successfulCount + " successul :: ", "green+bold+h3" );
		var failed 			= this.createElement( Assert.getAssertionFailedCount() + " failed :: ", "red+bold+h3" );
		var ending 			= this.createElement( "]]]", "yellow+bold+h3" );
		
		var list = new Array<String>();
		list.push( beginning );
		list.push( all );
		
		if ( successfulCount > 0 ) 
		{
			list.push( successfull );
		}
		
		
		if ( Assert.getAssertionFailedCount() > 0 ) 
		{
			list.push( failed );
		}
		
		list.push( ending );
        this._log( this.encapsulateElements( list ) );
		this.addRuler();
    }

    public function onSuiteClassStartRun( descriptor : ClassDescriptor ) : Void
    {
        this._log( this.createElement( "Test suite: '" + descriptor.getName() + "'", "white+bold+h4" ) );
        this._addTab();
    }

    public function onSuiteClassEndRun( descriptor : ClassDescriptor ) : Void
    {
        this._removeTab();
    }

    public function onTestClassStartRun( descriptor : ClassDescriptor ) : Void
    {
        this._log( this.createElement( "Test class: '" + descriptor.className + "'", "darkwhite+h5+bold" ) );
        this._addTab();
    }

    public function onTestClassEndRun( descriptor : ClassDescriptor ) : Void
    {
        this._removeTab();
    }

    public function onSuccess( descriptor : ClassDescriptor, timeElapsed : Float ) : Void
    {
		var success = this.createElement( "✔ ", "green" );
		var methodDescriptor = descriptor.currentMethodDescriptor();
		var func = this.createElement( methodDescriptor.methodName + "() ", "lightgrey" );
        this.generateMessage( success, func, descriptor, timeElapsed );
    }
	

    public function onFail( descriptor : ClassDescriptor, timeElapsed : Float, error : Exception ) : Void
    {
        var methodDescriptor = descriptor.currentMethodDescriptor();
		var func = this.createElement( methodDescriptor.methodName + "() ", "red" );
		var fail = this.createElement( "✘ ", "red" );
		
        this.generateMessage( fail, func, descriptor, timeElapsed );
		
        this._addTab();
        this._addTab();
        this._log( this.createElement( error.toString(), "red+bold" ) );
        this._log( this.createElement( error.message + ": " + ( Std.is( error, AssertException ) ? ": " + Assert.getLastAssertionLog() : "" ), "red" ) );
        this._removeTab();
        this._removeTab();
		
		this.setGlobalResultFailed( );
    }

    public function onTimeout( descriptor : ClassDescriptor, timeElapsed : Float, error : Exception ) : Void
    {
		this.onFail( descriptor, timeElapsed, error );
    }
	
	public function onIgnore( descriptor : ClassDescriptor ) : Void
	{
		var success 			= this.createElement( "- ", "yellow" );
		var methodDescriptor 	= descriptor.currentMethodDescriptor();
		var func 				= this.createElement( methodDescriptor.methodName + "() ", "lightgrey" );
        this.generateMessage( success, func, descriptor, 0 );
	}
	
	function generateMessage( icon : String, func:String, descriptor : ClassDescriptor, timeElapsed : Float ) : Void
	{
        var description 	= descriptor.currentMethodDescriptor().description;
        var message 		= this.createElement( ( description.length > 0 ? description : "" ) + " [" + timeElapsed + "ms]", "darkgrey" );
        this._log( this.encapsulateElements( [icon, func, message] ) );
	}

    public function createElement( message : String, color : String ) : String
    {
        var result 		= "";
		var colorId 	= color.split("+").join("_");
		var span 		= "<span class=\"" + colorId + "\">" + message + "</span>";
		
		if ( this._styleList[ "." + colorId ] == null )
		{
			var style : Dynamic = {};
			this.setAttributes( style, color );
			this.styleSheet.setStyle( "." + colorId, style );
			this._styleList["." + colorId] = true;
		}
		

        return span;
    }
	
	function encapsulateElements( elementList : Array<String> ) : String
	{
		return elementList.join( "" );
	}
	
	function setAttributes( style : Dynamic, color : String ) : Void
	{
		var colorAttributes : Array<String> = color.split( "+" );
		
        for ( attr in colorAttributes )
        {
            this.setAttribute( style, attr );
        }
	}
	
	function setAttribute( style : Dynamic, attr : String ) : Void
	{
        switch( attr )
        {
            case "bold":
                style.fontWeight = "bold";

            case "italic":
                style.fontStyle = "italic";

            case "underline":
                style.textDecoration = "underline";

            case "green":
                style.color = "#27fe11";

            case "red":
                style.color = "#e62323";

            case "blue":
                style.color = "#4999d4";
				
			case "yellow":
                style.color = "#ffcf18";
				
			case "darkgrey":
                style.color = "#727272";
				
			case "lightgrey":
				style.color = "#d9d9d9";
				
			case "darkwhite":
				style.color = "#e6e6e6";
				
			case "white":
				style.color = "#e2e2e2";
				
			case "h3":
				style.fontSize = "14px";
				style.leading = 30;
				
			case "h4":
				style.fontSize = "13px";
				style.leading = "30px";
				
			case "h5":
				style.leading = "25px";
        }
		
    }
	
	function setGlobalResultSuccess() : Void
	{
		this.successMarker.graphics.clear();
		this.successMarker.graphics.beginFill( 0x2f8a11 );
		this.successMarker.graphics.drawRect( 0, 0, this.console.x, target.stage.stageHeight );
	}
	
	function setGlobalResultFailed() : Void
	{
		this.successMarker.graphics.clear();
		this.successMarker.graphics.beginFill( 0xe62323 );
		this.successMarker.graphics.drawRect( 0, 0, this.console.x, target.stage.stageHeight );
	}
	
	function addRuler() : Void
	{
		this.console.htmlText += "----------------------<br/>";
	}
}
#end