package hex.unittest.notifier;

import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.Lib;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.text.TextFormat;
import hex.event.IEvent;
import hex.unittest.assertion.Assert;
import hex.unittest.description.TestMethodDescriptor;
import hex.unittest.error.AssertException;
import hex.unittest.event.ITestRunnerListener;
import hex.unittest.event.TestRunnerEvent;

/**
 * ...
 * @author Francis Bourre
 */
class FlashUnitTestNotifier implements ITestRunnerListener
{
	private static var _TRACE 		: Dynamic = haxe.Log.trace;
	
    private var _trace  			: Dynamic;
    private var _tabs   			: Int = 0;

	private var console				: TextField;
	private var target				: DisplayObjectContainer;
	private var successMarker		: Sprite;
	private var styleSheet			: StyleSheet;
	private var _styleList			: Map<String,Bool> = new Map<String,Bool>();

    public function new( target : DisplayObjectContainer = null )
    {
		this.setConsole( target !=null ? target : Lib.current.stage );
		this.setGlobalResultSuccess( );
    }
	
	private function setConsole( target : DisplayObjectContainer ) : Void
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

    private function _log( element : String ) : Void
    {
		var buffer:String = '';

		for ( i in 0...this._tabs * 4 ) 
		{
			buffer += "&nbsp;";
		}
		
		element = buffer + element + "<br/>";
		
		this.console.htmlText = this.console.htmlText + element;
		this.console.scrollV = this.console.maxScrollV;
    }

    private function _addTab() : Void
    {
        this._tabs++;
    }

    private function _removeTab() : Void
    {
        this._tabs--;
    }

    public function onStartRun( e : TestRunnerEvent ) : Void
    {
        this._tabs = 0;
        this._log( this.createElement( "[[[ Start " + e.getDescriptor().className + " tests run ]]]", "yellow+bold+h3" ) );
        this._addTab();
    }

    public function onEndRun( e : TestRunnerEvent ) : Void
    {
        this._removeTab();
		
		var successfulCount:Int = Assert.getAssertionCount() - Assert.getAssertionFailedCount();
		
		var beginning : String 		= this.createElement( "[[[ Test runs finished :: ", "yellow+bold+h3" );
		var all : String 			= this.createElement( Assert.getAssertionCount() + " overall :: ", "white+bold+h3" );
		var successfull : String 	= this.createElement( successfulCount + " successul :: ", "green+bold+h3" );
		var failed : String 		= this.createElement( Assert.getAssertionFailedCount() + " failed :: ", "red+bold+h3" );
		var ending : String 		= this.createElement( "]]]", "yellow+bold+h3" );
		
		var list : Array<String> = new Array<String>();
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

    public function onSuiteClassStartRun( e : TestRunnerEvent ) : Void
    {
        this._log( this.createElement( "Test suite: '" + e.getDescriptor().className + "'", "white+bold+h4" ) );
        this._addTab();
    }

    public function onSuiteClassEndRun( e : TestRunnerEvent ) : Void
    {
        this._removeTab();
    }

    public function onTestClassStartRun( e : TestRunnerEvent ) : Void
    {
        this._log( this.createElement( "Test class: '" + e.getDescriptor().className + "'", "darkwhite+h5+bold" ) );
        this._addTab();
    }

    public function onTestClassEndRun( e : TestRunnerEvent ) : Void
    {
        this._removeTab();
    }

    public function onSuccess( e : TestRunnerEvent ) : Void
    {
		var success: String = this.createElement( "✔ ", "green" );
		var methodDescriptor : TestMethodDescriptor = e.getDescriptor().currentMethodDescriptor();
		var func : String = this.createElement( methodDescriptor.methodName + "() ", "lightgrey" );
        this.generateMessage( success, func, e );
    }
	

    public function onFail( e : TestRunnerEvent ) : Void
    {
        var methodDescriptor : TestMethodDescriptor = e.getDescriptor().currentMethodDescriptor();
		var func : String = this.createElement( methodDescriptor.methodName + "() ", "red" );
		
		var fail: String = this.createElement( "✘ ", "red" );
		
        this.generateMessage( fail, func, e );
		
        this._addTab();
        this._addTab();
        this._log( this.createElement( e.getError().toString(), "red+bold" ) );
        this._log( this.createElement( e.getError().message + ": " + ( Std.is( e.getError(), AssertException ) ? ": " + Assert.getLastAssertionLog() : "" ), "red" ) );
        this._removeTab();
        this._removeTab();
		
		this.setGlobalResultFailed( );
    }

    public function onTimeout( e : TestRunnerEvent ) : Void
    {
		this.onFail( e );
    }
	
	private function generateMessage( icon:String, func:String, e : TestRunnerEvent ) : Void
	{
        var description : String = e.getDescriptor().currentMethodDescriptor().description;
		
        var message : String = this.createElement( (description.length > 0 ? description : "") + " [" + e.getTimeElapsed() + "ms]", "darkgrey" );
		
        this._log( this.encapsulateElements( [icon, func, message] ) );
	}

    public function createElement( message : String, color : String ) : String
    {
        var result : String = "";
		var colorId:String = color.split("+").join("_");
		var span:String = "<span class=\"" + colorId + "\">" + message + "</span>";
		
		if ( this._styleList[ "." + colorId ] == null )
		{
			var style:Dynamic = { };
			this.setAttributes( style, color );
			this.styleSheet.setStyle( "." + colorId, style );
			this._styleList["." + colorId] = true;
		}
		

        return span;
    }
	
	private function encapsulateElements( elementList : Array<String> ) : String
	{
		return elementList.join( "" );
	}
	
	private function setAttributes( style:Dynamic, color: String ) : Void
	{
		var colorAttributes : Array<String> = color.split( "+" );
		
        for ( attr in colorAttributes )
        {
            this.setAttribute( style, attr );
        }
	}
	
	private function setAttribute( style : Dynamic, attr : String ) : Void
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
	
	private function setGlobalResultSuccess( ) : Void
	{
		this.successMarker.graphics.clear();
		this.successMarker.graphics.beginFill( 0x2f8a11 );
		this.successMarker.graphics.drawRect( 0, 0, this.console.x, target.stage.stageHeight );
	}
	
	private function setGlobalResultFailed( ) : Void
	{
		this.successMarker.graphics.clear();
		this.successMarker.graphics.beginFill( 0xe62323 );
		this.successMarker.graphics.drawRect( 0, 0, this.console.x, target.stage.stageHeight );
	}
	
	private function addRuler() : Void
	{
		this.console.htmlText += "----------------------<br/>";
	}
	
	public function handleEvent( e : IEvent ) : Void {}
}
