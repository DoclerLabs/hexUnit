package hex.unittest.notifier;

import hex.error.Exception;
import hex.unittest.assertion.Assert;
import hex.unittest.description.ClassDescriptor;
import hex.unittest.error.AssertException;
import hex.unittest.event.ITestClassResultListener;

using hex.unittest.description.ClassDescriptorUtil;

/**
 * ...
 * @author Francis Bourre
 */
class ConsoleNotifier implements ITestClassResultListener
{
    var _tabs   			: String;
    var _errorBubbling   	: Bool;
	var _hideSuccessTest   	: Bool;
	
	static var _TRACE : Dynamic = haxe.Log.trace;

    public function new( errorBubbling : Bool = false, hideSuccessTest : Bool = false )
    {
		this._errorBubbling = errorBubbling;
		this._hideSuccessTest = hideSuccessTest;
    }

    function _log( message : String, ?infos : haxe.PosInfos ) : Void
    {
		_TRACE(this._tabs + message, infos);
    }

    function _addTab() : Void
    {
        this._tabs += "\t";
    }

    function _removeTab() : Void
    {
        this._tabs = this._tabs.substr( 0, this._tabs.length-1 );
    }

    public function onStartRun( descriptor : ClassDescriptor ) : Void
    {
        this._tabs = "";
        this._log( this.setColor( "<<< Start " + descriptor.className + " tests run >>>", "blue+bold+underline" ) );
        this._addTab();
    }

    public function onEndRun( descriptor : ClassDescriptor ) : Void
    {
        this._removeTab();
        this._log( this.setColor( "<<< End tests run >>>", "blue+bold+underline" ) );
        this._log( this.setColor( "Assertions passed: " + Assert.getAssertionCount() + "\n", "bold" )  );
		
		if ( Assert.getAssertionFailedCount() > 0 )
		{
			this._log( this.setColor( "Assertions failed: " + Assert.getAssertionFailedCount() + "\n", "red+bold" )  );
		}
    }

    public function onSuiteClassStartRun( descriptor : ClassDescriptor ) : Void
    {
        this._log( this.setColor( "Suite class '" + descriptor.name + "'", "green+underline" ) );
        this._addTab();
    }

    public function onSuiteClassEndRun( descriptor : ClassDescriptor ) : Void
    {
        this._removeTab();
    }

    public function onTestClassStartRun( descriptor : ClassDescriptor ) : Void
    {
        this._log( this.setColor( "Test class '" + descriptor.className + "'", "green" ) );
        this._addTab();
    }

    public function onTestClassEndRun( descriptor : ClassDescriptor ) : Void
    {
        this._removeTab();
    }

    public function onSuccess( descriptor : ClassDescriptor, timeElapsed : Float ) : Void
    {
		if( !this._hideSuccessTest )
		{
			var methodDescriptor = descriptor.currentMethodDescriptor();
			var description = methodDescriptor.description;
			var time = this.setColor( " " + timeElapsed + "ms", "green+bold" );
			var message = "* [" + methodDescriptor.methodName + "] " + ( description.length > 0 ? description : "" ) + time;
			this._log( this.setColor( message, "green" ) );
		}
    }

    public function onFail( descriptor : ClassDescriptor, timeElapsed : Float, error : Exception ) : Void
    {
        var methodDescriptor = descriptor.currentMethodDescriptor();
        var description = methodDescriptor.description;
        var message = "* [" + methodDescriptor.methodName + "] " + ( description.length > 0 ? description : "." );
        this._log( this.setColor( message, "red" ) );
        this._addTab();
        this._log( this.setColor( error.toString(), "red+bold" ) );
        this._log( this.setColor( error.message + ": " + ( Std.is( error, AssertException ) ? ": " + Assert.getLastAssertionLog() : "" ), "red" ) );
        this._removeTab();
		
		if ( this._errorBubbling )
		{
			throw( error );
		}
    }

    public function onTimeout( descriptor : ClassDescriptor, timeElapsed : Float, error : Exception ) : Void
    {
        var methodDescriptor = descriptor.currentMethodDescriptor();
        var description = methodDescriptor.description;
        var message = "* [" + methodDescriptor.methodName + "] " + ( description.length > 0 ? description : "." );
        this._log( this.setColor( message, "red" ) );
        this._addTab();
        this._log( this.setColor( error.message, "red+bold" ) );
        this._removeTab();
    }

	public function onIgnore( descriptor : ClassDescriptor ) : Void
	{
		var methodDescriptor = descriptor.currentMethodDescriptor();
        var description = methodDescriptor.description;
        var time = this.setColor( " " + 0 + "ms", "yellow+bold" );
        var message = "* [" + methodDescriptor.methodName + "] " + ( description.length > 0 ? description : "" ) + time;
        this._log( this.setColor( message, "yellow" ) );
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

			case "yellow":
				return 33;

            case "blue":
                return 34;
        }

        return 0;
    }
}
