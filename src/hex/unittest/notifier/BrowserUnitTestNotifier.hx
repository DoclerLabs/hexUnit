package hex.unittest.notifier;

import hex.event.IEvent;
import hex.unittest.assertion.Assert;
import hex.unittest.description.TestMethodDescriptor;
import hex.unittest.error.AssertException;
import hex.unittest.event.ITestRunnerListener;
import hex.unittest.event.TestRunnerEvent;
import js.Browser;
import js.html.Element;
import js.html.HRElement;
import js.html.SpanElement;

/**
 * ...
 * @author Francis Bourre
 */
class BrowserUnitTestNotifier implements ITestRunnerListener
{
    var _trace  		: Dynamic;
    var _tabs   		: Int = 0;
	var console 		: Element;
	var netTimeElapsed	: Float;
	
	var _successfulCount	: UInt = 0;
	var _failedCount 	: UInt = 0;
	
	static var _TRACE 	: Dynamic = haxe.Log.trace;

    public function new( targetId : String )
    {
		this.setConsole( targetId );
		this.setGlobalResultSuccess( );
    }
	
	function setConsole( targetId : String ) : Void
	{
		this.console = Browser.document.getElementById( targetId );
		this.console.style.backgroundColor = "#060606";
		this.console.style.whiteSpace = "pre";
		this.console.style.fontFamily = "Lucida Console";
		this.console.style.position = "relative";
		this.console.style.fontSize = "11px";
	}

    function _log( element : Element ) : Void
    {
        element.style.marginLeft = (this._tabs * 30) + "px";
		element.appendChild( Browser.document.createTextNode("\n") );
		this.console.appendChild( element );
		
		this.console.scrollTop = this.console.scrollHeight;
    }

    function _addTab() : Void
    {
        this._tabs++;
    }

    function _removeTab() : Void
    {
        this._tabs--;
    }

    public function onStartRun( e : TestRunnerEvent ) : Void
    {
		this._successfulCount = 0;
		this._failedCount = 0;
        this._tabs = 0;
        this._log( this.createElement( "[[[ Start " + e.getDescriptor().className + " tests run ]]]", "yellow+bold+h3" ) );
        this._addTab();
		this.netTimeElapsed = 0;
    }

    public function onEndRun( e : TestRunnerEvent ) : Void
    {
        this._removeTab();

		var beginning : Element 	= this.createElement( "[[[ Test runs finished :: ", "yellow+bold+h3" );
		var all : Element 			= this.createElement( this._successfulCount + this._failedCount + " overall :: ", "white+bold+h3" );
		var successfull : Element 	= this.createElement( this._successfulCount + " successul :: ", "green+bold+h3" );
		var failed : Element 		= this.createElement( this._failedCount + " failed :: ", "red+bold+h3" );
		var ending : Element 		= this.createElement( " in " + this.netTimeElapsed + "ms :: ]]]", "yellow+bold+h3" );
		
		var list= new Array<Element>();
		list.push( beginning );
		list.push( all );
		
		if ( this._successfulCount > 0 ) 
		{
			list.push( successfull );
		}
		
		if ( this._failedCount > 0 ) 
		{
			list.push( failed );
		}
		
		list.push( ending );
        this._log( this.encapsulateElements( list ) );
		this.addRuler();
    }

    public function onSuiteClassStartRun( e : TestRunnerEvent ) : Void
    {
        this._log( this.createElement( e.getDescriptor().getName() + ": '" + e.getDescriptor().className + "'", "white+bold+h4" ) );
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
		this._successfulCount++;
		var success: Element = this.createElement( "✔ ", "green" );
		var methodDescriptor : TestMethodDescriptor = e.getDescriptor().currentMethodDescriptor();
		var func : Element = this.createElement( methodDescriptor.methodName + "() ", "lightgrey" );
        this.generateMessage( success, func, e );
    }
	

    public function onFail( e : TestRunnerEvent ) : Void
    {
		this._failedCount++;
        var methodDescriptor : TestMethodDescriptor = e.getDescriptor().currentMethodDescriptor();
		var func : Element = this.createElement( methodDescriptor.methodName + "() ", "red" );
		var fail: Element = this.createElement( "✘ ", "red" );
		
        this.generateMessage( fail, func, e );
		
        this._addTab();
        this._addTab();
        this._log( this.createElement( e.getError().toString(), "red+bold" ) );
        this._log( this.createElement( e.getError().message + ( Std.is( e.getError(), AssertException ) ? ": " + Assert.getLastAssertionLog() : "" ), "red" ) );
        this._removeTab();
        this._removeTab();
		
		this.setGlobalResultFailed( );
    }

    public function onTimeout( e : TestRunnerEvent ) : Void
    {
		this.onFail( e );
    }
	
	function generateMessage( icon:Element, func:Element, e : TestRunnerEvent ) : Void
	{
        var description : String = e.getDescriptor().currentMethodDescriptor().description;
        var message : Element = this.createElement( (description.length > 0 ? description : "") + " [" + e.getTimeElapsed() + "ms]", "darkgrey" );
		this.netTimeElapsed += e.getTimeElapsed();
        this._log( this.encapsulateElements( [icon, func, message] ) );
	}

    public function createElement( message : String, color : String ) : Element
    {
        var result : String = "";
		var span : SpanElement = Browser.document.createSpanElement();
		span.textContent = message;
        this.setAttributes( span, color );
        return span;
    }
	
	function encapsulateElements( elementList:Array<Element> ):Element
	{
		var container:SpanElement = Browser.document.createSpanElement();
		
		for ( element in elementList )
		{
			container.appendChild( element );
		}
		
		return container;
	}
	
	function setAttributes( element:Element, color: String ) : Void
	{
		var colorAttributes : Array<String> = color.split( "+" );
        for ( attr in colorAttributes )
        {
            this.setAttribute( element, attr );
        }
	}
	
	function setAttribute( element:Element, attr:String ) : Void
	{
        switch( attr )
        {
            case "bold":
                element.style.fontWeight = "bold";

            case "italic":
                element.style.fontStyle = "italic";

            case "underline":
                element.style.textDecoration = "underline";

            case "green":
                element.style.color = "#27fe11";

            case "red":
                element.style.color = "#e62323";

            case "blue":
                element.style.color = "#4999d4";
				
			case "yellow":
                element.style.color = "#ffcf18";
				
			case "darkgrey":
                element.style.color = "#727272";
				
			case "lightgrey":
				element.style.color = "#d9d9d9";
				
			case "darkwhite":
				element.style.color = "#e6e6e6";
				
			case "white":
				element.style.color = "#e2e2e2";
				
			case "h3":
				element.style.fontSize = "14px";
				element.style.lineHeight = "30px";
				
			case "h4":
				element.style.fontSize = "13px";
				element.style.lineHeight = "30px";
				
			case "h5":
				element.style.lineHeight = "25px";
        }
    }
	
	function setGlobalResultSuccess() : Void
	{
		this.console.style.borderLeft = "50px solid #2f8a11";
	}
	
	function setGlobalResultFailed( ) : Void
	{
		this.console.style.borderLeft = "50px solid #e62323";
	}
	
	function addRuler() : Void
	{
		var ruler:HRElement = Browser.document.createHRElement();
		ruler.style.border = "0";
		ruler.style.height = "10px";
		ruler.style.borderTop = "1px solid #555";
		ruler.style.margin = "15px 0px 15px 0px";
		
		this.console.appendChild( ruler );
	}
	
	public function handleEvent( e : IEvent ) : Void {}
}
