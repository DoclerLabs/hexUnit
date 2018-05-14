package hex.unittest.notifier;

#if js
import hex.error.IllegalArgumentException;
import hex.unittest.assertion.Assert;
import hex.unittest.description.ClassDescriptor;
import hex.unittest.description.MethodDescriptor;
import hex.unittest.error.AssertException;
import hex.unittest.event.ITestClassResultListener;
import js.Browser;
import js.html.Element;
import js.html.HRElement;
import js.html.SpanElement;

using tink.CoreApi;
using hex.unittest.description.ClassDescriptorUtil;

/**
 * ...
 * @author Francis Bourre
 */
class BrowserUnitTestNotifier implements ITestClassResultListener
{
	
    var _trace  		: Dynamic;
    var _tabs   		: Int = 0;
	var console 		: Element;
	var netTimeElapsed	: Float;
	
	var _assertionStartCount	: UInt = 0;
	var _successfulCount		: UInt = 0;
	var _failedCount 			: UInt = 0;
	
	static var _TRACE 	: Dynamic = haxe.Log.trace;

    public function new( ?targetId : String )
    {
		this.setConsole( targetId );
		this.setGlobalResultSuccess( );
    }
	
	function setConsole( ?targetId : String ) : Void
	{
		if ( targetId != null )
		{
			this.console = Browser.document.getElementById( targetId );
			if ( this.console == null )
			{
				throw new IllegalArgumentException( "'" + targetId + "' div not found" );
			}
		}
		else
		{
			this.console = Browser.document.createDivElement();
			Browser.document.body.appendChild( this.console );
		}
		
		this.console.style.backgroundColor = "#060606";
		this.console.style.whiteSpace = "pre";
		this.console.style.fontFamily = "Lucida Console";
		this.console.style.position = "relative";
		this.console.style.fontSize = "11px";
		this.console.style.overflowY = "scroll";
		this.console.style.height = "100vh";
		this.console.style.padding = "15px";
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

    public function onStartRun( descriptor : ClassDescriptor ) : Void
    {
		this._assertionStartCount = Assert.getAssertionCount();
		this._successfulCount = 0;
		this._failedCount = 0;
        this._tabs = 0;
        this._log( this.createElement( "[[[ Start " + descriptor.className + " tests run ]]]", "yellow+bold+h3" ) );
        this._addTab();
		this.netTimeElapsed = 0;
    }

    public function onEndRun( descriptor : ClassDescriptor ) : Void
    {
		this._removeTab();
		
		var assertionCount = Assert.getAssertionCount() - this._assertionStartCount;
		var assertionMessage = assertionCount > 1 ?  assertionCount + " assertions runned" : assertionCount + " assertions runned";

		var beginning 	= this.createElement( "[[[ Test runs finished :: ", "yellow+bold+h3" );
		var all 		= this.createElement( this._successfulCount + this._failedCount + " overall :: ", "white+bold+h3" );
		var successfull = this.createElement( this._successfulCount + " successul :: ", "green+bold+h3" );
		var failed 		= this.createElement( this._failedCount + " failed :: ", "red+bold+h3" );
		var assertion 	= this.createElement( assertionMessage + "  :: ", "white+bold+h3" );
		var ending 		= this.createElement( " in " + this.netTimeElapsed + "ms :: ]]]", "yellow+bold+h3" );
		
		var list = new Array<Element>();
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
		
		list.push( assertion );
		list.push( ending );
        this._log( this.encapsulateElements( list ) );
		this.addRuler();
    }

    public function onSuiteClassStartRun( descriptor : ClassDescriptor ) : Void
    {
        this._log( this.createElement( descriptor.name + ": '" + descriptor.className + "'", "white+bold+h4" ) );
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
		this._successfulCount++;
		var success = this.createElement( "✔ ", "green" );
		var methodDescriptor = descriptor.currentMethodDescriptor();
		var func = this.createElement( methodDescriptor.methodName + "() ", "lightgrey" );
        this.generateMessage( success, func, descriptor, timeElapsed );
    }
	

    public function onFail( descriptor : ClassDescriptor, timeElapsed : Float, error : Error ) : Void
    {
		this._failedCount++;
        var methodDescriptor = descriptor.currentMethodDescriptor();
		var func = this.createElement( methodDescriptor.methodName + "() ", "red" );
		var fail = this.createElement( "✘ ", "red" );
		
        this.generateMessage( fail, func, descriptor, timeElapsed );
		
        this._addTab();
        this._addTab();
        this._log( this.createElement( error.toString(), "red+bold" ) );
        this._log( this.createElement( error.message + ( Std.is( error, AssertException ) ? ": " + Assert.getLastAssertionLog() : "" ), "red" ) );
        this._removeTab();
        this._removeTab();
		
		this.setGlobalResultFailed( );
    }

    public function onTimeout( descriptor : ClassDescriptor, timeElapsed : Float, error : Error ) : Void
    {
		this.onFail( descriptor, timeElapsed, error );
    }
	
	public function onIgnore( descriptor : ClassDescriptor ):Void 
	{
		this._successfulCount++;
		var ignore = this.createElement( "- ", "yellow" );
		var methodDescriptor : MethodDescriptor = descriptor.currentMethodDescriptor();
		var func = this.createElement( methodDescriptor.methodName + "() ", "lightgrey" );
        this.generateMessage( ignore, func, descriptor, 0 );
	}
	
	function generateMessage( icon:Element, func:Element, descriptor : ClassDescriptor, timeElapsed : Float ) : Void
	{
        var description = descriptor.currentMethodDescriptor().description;
        var message = this.createElement( (description.length > 0 ? description : "") + " [" + timeElapsed + "ms]", "darkgrey" );
		this.netTimeElapsed += timeElapsed;
        this._log( this.encapsulateElements( [icon, func, message] ) );
	}

    public function createElement( message : String, color : String ) : Element
    {
        var result = "";
		var span = Browser.document.createSpanElement();
		span.textContent = message;
        this.setAttributes( span, color );
        return span;
    }
	
	function encapsulateElements( elementList:Array<Element> ):Element
	{
		var container = Browser.document.createSpanElement();
		
		for ( element in elementList )
		{
			container.appendChild( element );
		}
		
		return container;
	}
	
	function setAttributes( element:Element, color: String ) : Void
	{
		var colorAttributes = color.split( "+" );
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
		var ruler = Browser.document.createHRElement();
		ruler.style.border = "0";
		ruler.style.height = "10px";
		ruler.style.borderTop = "1px solid #555";
		ruler.style.margin = "15px 0px 15px 0px";
		
		this.console.appendChild( ruler );
	}
}
#end