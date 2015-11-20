package hex.unittest.notifier;

import hex.event.IEvent;
import hex.unittest.assertion.Assert;
import hex.unittest.description.TestMethodDescriptor;
import hex.unittest.event.ITestRunnerListener;
import hex.unittest.event.TestRunnerEvent;
import js.Browser;
import js.html.Element;
import js.html.HRElement;
import js.html.HtmlElement;
import js.html.SpanElement;
import js.html.Text;
import js.Lib;

/**
 * ...
 * @author Francis Bourre
 */
class BrowserUnitTestNotifier implements ITestRunnerListener
{
    private var _trace  : Dynamic;
    private var _tabs   : String;
	
	private static var _TRACE : Dynamic = haxe.Log.trace;
	private var console:Element;

    public function new( targetId:String )
    {
		this.setConsole( targetId );
		
		this.setGlobalResultSuccess( );
    }
	
	private function setConsole( targetId:String ) : Void
	{
		this.console = Browser.document.getElementById( targetId );
		this.console.style.backgroundColor = "#060606";
		this.console.style.whiteSpace = "pre";
		this.console.style.fontFamily = "Lucida Console";
		this.console.style.position = "relative";
		this.console.style.fontSize = "11px";
	}

    private function _log( element : Element ) : Void
    {
        //Reflect.callMethod( untyped js.Boot, this._trace, [ this._tabs + message] );
		/*var span:SpanElement = Browser.document.createSpanElement(this._tabs + message + "\n");
		span.innerText = message;*/
		
		element.style.marginLeft = (this._tabs.length * 30) + "px";
		element.appendChild( Browser.document.createTextNode("\n") );
		this.console.appendChild( element );
		
		this.console.scrollTop = this.console.scrollHeight;
    }

    private function _addTab() : Void
    {
        this._tabs += "\t";
    }

    private function _removeTab() : Void
    {
        this._tabs = this._tabs.substr( 0, this._tabs.length-1 );
    }

    public function onStartRun( e : TestRunnerEvent ) : Void
    {
        this._tabs = "";
        this._log( this.createElement( "<<< Start " + e.getDescriptor().className + " tests run >>>", "yellow+bold+h3" ) );
        this._addTab();
    }

    public function onEndRun( e : TestRunnerEvent ) : Void
    {
        this._removeTab();
		
		Browser.console.log( Assert.getAssertionFailedCount() );
		
		var successfulCount:Int = Assert.getAssertionCount() - Assert.getAssertionFailedCount();
		
		var beginning:Element = this.createElement( "<<< Test runs finished :: ", "yellow+bold+h3" );
		var all:Element = this.createElement( Assert.getAssertionCount() + " overall :: ", "white+bold+h3" );
		var successfull:Element = this.createElement( successfulCount + " successul :: ", "green+bold+h3" );
		var failed:Element = this.createElement( Assert.getAssertionFailedCount() + " failed :: ", "red+bold+h3" );
		var ending:Element = this.createElement( ">>>", "yellow+bold+h3" );
		
		var list:Array<Element> = new Array<Element>();
		list.push( beginning );
		list.push( all );
		if ( successfulCount > 0 ) 
			list.push( successfull );
		if ( Assert.getAssertionFailedCount() > 0 ) 
			list.push( failed );
		list.push( ending );
		
		
        this._log( this.encapsulateElements( list ) );
		
		this.addRuler();
		
        //this._log( this.createElement( "Assertions count: " + Assert.getAssertionCount() + "\n", "bold" )  );
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
		var success: Element = this.createElement( "✔ ", "green" );
		
		var methodDescriptor : TestMethodDescriptor = e.getDescriptor().currentMethodDescriptor();
		var func : Element = this.createElement( methodDescriptor.methodName + "() ", "lightgrey" );
        
        this.generateMessage( success, func, e );
    }
	

    public function onFail( e : TestRunnerEvent ) : Void
    {
        var methodDescriptor : TestMethodDescriptor = e.getDescriptor().currentMethodDescriptor();
		var func : Element = this.createElement( methodDescriptor.methodName + "() ", "red" );
		
		var fail: Element = this.createElement( "✘ ", "red" );
		
        this.generateMessage( fail, func, e );
		
        this._addTab();
        this._addTab();
        this._log( this.createElement( e.getError().toString(), "red+bold" ) );
        this._log( this.createElement( e.getError().message + ": " + Assert.getLastAssertionLog(), "red" ) );
        this._removeTab();
        this._removeTab();
		
		this.setGlobalResultFailed( );
    }

    public function onTimeout( e : TestRunnerEvent ) : Void
    {
        /*var methodDescriptor : TestMethodDescriptor = e.getDescriptor().currentMethodDescriptor();
        var description : String = methodDescriptor.description;
        var message : String = "[" + methodDescriptor.methodName + "] " + ( description.length > 0 ? description : "." );
		
		var fail: Element = this.createElement( "✘ ", "red" );
		
        this._log( this.encapsulateElements( [fail, this.createElement( message, "red" ) ] ) );
        this._addTab();
        this._addTab();
        this._log( this.createElement( e.getError().message, "red+bold" ) );
        this._removeTab();
        this._removeTab();*/
		
		this.onFail( e );
    }
	
	private function generateMessage( icon:Element, func:Element, e : TestRunnerEvent ) : Void
	{
        var description : String = e.getDescriptor().currentMethodDescriptor().description;
		
        var message : Element = this.createElement( (description.length > 0 ? description : "") + " [" + e.getTimeElapsed() + "ms]", "darkgrey" );
		
        this._log( this.encapsulateElements( [icon, func, message] ) );
	}

    public function createElement( message : String, color : String ) : Element
    {
        var result : String = "";
		
		//message = StringTools.htmlEscape( message );
		var span:SpanElement = Browser.document.createSpanElement();
		span.innerText = message;
		
        this.setAttributes( span, color );

        return span;
    }
	
	private function encapsulateElements( elementList:Array<Element> ):Element
	{
		var container:SpanElement = Browser.document.createSpanElement();
		
		for ( element in elementList )
		{
			container.appendChild( element );
		}
		
		return container;
	}
	
	private function setAttributes( element:Element, color: String ) : Void
	{
		var colorAttributes : Array<String> = color.split( "+" );
        for ( attr in colorAttributes )
        {
            this.setAttribute( element, attr );
        }
	}
	
	private function setAttribute( element:Element, attr:String ) : Void
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
	
	private function setGlobalResultSuccess( ) : Void
	{
		this.console.style.borderLeft = "50px solid #2f8a11";
	}
	
	private function setGlobalResultFailed( ) : Void
	{
		this.console.style.borderLeft = "50px solid #e62323";
	}
	
	private function addRuler() : Void
	{
		var ruler:HRElement = Browser.document.createHRElement();
		ruler.style.border = "0";
		ruler.style.height = "10px";
		ruler.style.borderTop = "1px solid #555";
		ruler.style.margin = "15px 0px 15px 0px";
		
		this.console.appendChild(ruler);
	}
	
	public function handleEvent( e : IEvent ) : Void
		
	{
	}
}