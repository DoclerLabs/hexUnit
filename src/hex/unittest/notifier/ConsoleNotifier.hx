package hex.unittest.notifier;

import hex.error.Exception;
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
class ConsoleNotifier implements ITestRunnerListener
{
    var _trace  			: Dynamic;
    var _tabs   			: String;
    var _errorBubbling   	: Bool;
	
	static var _TRACE : Dynamic = haxe.Log.trace;

    public function new( errorBubbling : Bool = false )
    {
		this._errorBubbling = errorBubbling;
        this._trace = untyped Reflect.field( js.Boot, "__trace" );
    }

    function _log( message : String ) : Void
    {
        Reflect.callMethod( untyped js.Boot, this._trace, [ this._tabs + message] );
    }

    function _addTab() : Void
    {
        this._tabs += "\t";
    }

    function _removeTab() : Void
    {
        this._tabs = this._tabs.substr( 0, this._tabs.length-1 );
    }

    public function onStartRun( e : TestRunnerEvent ) : Void
    {
        this._tabs = "";
        this._log( this.setColor( "<<< Start " + e.getDescriptor().className + " tests run >>>", "blue+bold+underline" ) );
        this._addTab();
    }

    public function onEndRun( e : TestRunnerEvent ) : Void
    {
        this._removeTab();
        this._log( this.setColor( "<<< End tests run >>>", "blue+bold+underline" ) );
        this._log( this.setColor( "Assertions passed: " + Assert.getAssertionCount() + "\n", "bold" )  );
		
		if ( Assert.getAssertionFailedCount() > 0 )
		{
			this._log( this.setColor( "Assertions failed: " + Assert.getAssertionFailedCount() + "\n", "red+bold" )  );
			throw ( new Exception( "Assertions failed: " + Assert.getAssertionFailedCount() ) );
		}
    }

    public function onSuiteClassStartRun( e : TestRunnerEvent ) : Void
    {
        this._log( this.setColor( "Suite class '" + e.getDescriptor().getName() + "'", "green+underline" ) );
        this._addTab();
    }

    public function onSuiteClassEndRun( e : TestRunnerEvent ) : Void
    {
        this._removeTab();
    }

    public function onTestClassStartRun( e : TestRunnerEvent ) : Void
    {
        this._log( this.setColor( "Test class '" + e.getDescriptor().className + "'", "green" ) );
        this._addTab();
    }

    public function onTestClassEndRun( e : TestRunnerEvent ) : Void
    {
        this._removeTab();
    }

    public function onSuccess( e : TestRunnerEvent ) : Void
    {
        var methodDescriptor : TestMethodDescriptor = e.getDescriptor().currentMethodDescriptor();
        var description : String = methodDescriptor.description;
        var timeElapsed : String = this.setColor( " " + e.getTimeElapsed() + "ms", "green+bold" );
        var message : String = "* [" + methodDescriptor.methodName + "] " + ( description.length > 0 ? description : "" ) + timeElapsed;
        this._log( this.setColor( message, "green" ) );
    }

    public function onFail( e : TestRunnerEvent ) : Void
    {
        var methodDescriptor : TestMethodDescriptor = e.getDescriptor().currentMethodDescriptor();
        var description : String = methodDescriptor.description;
        var message : String = "* [" + methodDescriptor.methodName + "] " + ( description.length > 0 ? description : "." );
        this._log( this.setColor( message, "red" ) );
        this._addTab();
        this._log( this.setColor( e.getError().toString(), "red+bold" ) );
        this._log( this.setColor( e.getError().message + ": " + ( Std.is( e.getError(), AssertException ) ? ": " + Assert.getLastAssertionLog() : "" ), "red" ) );
        this._removeTab();
		
		if ( this._errorBubbling )
		{
			throw( e.getError() );
		}
    }

    public function onTimeout( e : TestRunnerEvent ) : Void
    {
        var methodDescriptor : TestMethodDescriptor = e.getDescriptor().currentMethodDescriptor();
        var description : String = methodDescriptor.description;
        var message : String = "* [" + methodDescriptor.methodName + "] " + ( description.length > 0 ? description : "." );
        this._log( this.setColor( message, "red" ) );
        this._addTab();
        this._log( this.setColor( e.getError().message, "red+bold" ) );
        this._removeTab();
    }

    public function setColor( message : String, color : String ) : String
    {
        if ( color == null )
        {
            return message;
        }

        var result : String = "";
        var colorAttributes : Array<String> = color.split( "+" );
        for ( attr in colorAttributes )
        {
            result += "\033[" + this.getAnsiCode( attr ) + "m";
        }

        result += message + "\033[" + this.getAnsiCode( "off" ) + "m";
        return result;
    }

    public function getAnsiCode( id : String ) : Int
    {
        switch( id )
        {
            case "off":
                return 0;

            case "bold":
                return 1;

            case "italic":
                return 3;

            case "underline":
                return 4;

            case "green":
                return 32;

            case "red":
                return 31;

            case "blue":
                return 34;
        }

        return 0;
    }
	
	public function handleEvent( e : IEvent ) : Void
	{
		
	}
}
