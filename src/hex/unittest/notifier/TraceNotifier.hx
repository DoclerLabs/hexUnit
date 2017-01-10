package hex.unittest.notifier;

#if flash
import flash.display.LoaderInfo;
import flash.errors.Error;
import flash.events.ErrorEvent;
import flash.events.UncaughtErrorEvent;
#end

import hex.error.Exception;
import hex.unittest.assertion.Assert;
import hex.unittest.description.TestClassDescriptor;
import hex.unittest.error.AssertException;
import hex.unittest.event.ITestClassResultListener;

/**
 * ...
 * @author Francis Bourre
 */
class TraceNotifier implements ITestClassResultListener
{
	public static var TAB_CHARACTER:String = "  ";
	
    var _tabs   			: String;
    var _errorBubbling   	: Bool;

	#if flash
    public function new( loaderInfo : LoaderInfo, errorBubbling : Bool = false )
    {
		this._errorBubbling = errorBubbling;
		loaderInfo.uncaughtErrorEvents.addEventListener( UncaughtErrorEvent.UNCAUGHT_ERROR, this._uncaughtErrorHandler );
    }
	
	function _uncaughtErrorHandler( event : UncaughtErrorEvent ) : Void
	{
		event.preventDefault();
		if ( Std.is( event.error, Error ) )
		{
			var error : Error = cast event.error;
			// do something with the error
			trace( "UNCAUGHT ERROR: " + error.message + ":" + error.getStackTrace() );
		}
		else if ( Std.is( event.error, ErrorEvent ) )
		{
			var errorEvent : ErrorEvent = cast event.error;
			// do something with the error
			trace( "UNCAUGHT ERROR: " + errorEvent.text );
		}
		else
		{
			// a non-Error, non-ErrorEvent type was thrown and uncaught
			trace( "UNCAUGHT ERROR: " + event.text );
		}
		
	}
	#else
	public function new( errorBubbling : Bool = false )
    {
		this._errorBubbling = errorBubbling;
    }
	#end

    function _log( message : String ) : Void
    {
		#if neko
        Sys.println( this._tabs + message );
		#else
		trace( this._tabs + message );
		#end
    }

    function _addTab() : Void
    {
        this._tabs += TAB_CHARACTER;
    }

    function _removeTab() : Void
    {
        this._tabs = this._tabs.substr( 0, this._tabs.length - (TAB_CHARACTER.length) );
    }

    public function onStartRun( descriptor : TestClassDescriptor ) : Void
    {
        this._tabs = "";
        this._log( "<<< Start " + descriptor.className + " tests run >>>" );
        this._addTab();
    }

    public function onEndRun( descriptor : TestClassDescriptor ) : Void
    {
        this._removeTab();
        this._log( "<<< End tests run >>>" );
        this._log( "Assertions passed: " + Assert.getAssertionCount() );
		
		if ( Assert.getAssertionFailedCount() > 0 )
		{
			this._log( "Assertions failed: " + Assert.getAssertionFailedCount() + "\n" );
			#if flash
			flash.system.System.exit( 1 );
			#elseif ( php || neko )
			Sys.exit(1);
			#end
		}
		
		#if flash
		flash.system.System.exit( 0 );
		#end
    }

    public function onSuiteClassStartRun( descriptor : TestClassDescriptor ) : Void
    {
        this._log( "Suite class '" + descriptor.getName() + "'" );
        this._addTab();
    }

    public function onSuiteClassEndRun( descriptor : TestClassDescriptor ) : Void
    {
        this._removeTab();
    }

    public function onTestClassStartRun( descriptor : TestClassDescriptor ) : Void
    {
        this._log( "Test class '" + descriptor.className + "'" );
        this._addTab();
    }

    public function onTestClassEndRun( descriptor : TestClassDescriptor ) : Void
    {
        this._removeTab();
    }

    public function onSuccess( descriptor : TestClassDescriptor, ?timeElapsed : Float, ?error : Exception ) : Void
    {
        var methodDescriptor = descriptor.currentMethodDescriptor();
        var description = methodDescriptor.description;
        var time = " " + timeElapsed + "ms";
        var message = "* [" + methodDescriptor.methodName + "] " + ( description.length > 0 ? description : "" ) + time;
        this._log( message );
    }

    public function onFail( descriptor : TestClassDescriptor, ?timeElapsed : Float, ?error : Exception ) : Void
    {
		if ( descriptor != null )
		{
			var methodDescriptor = descriptor.currentMethodDescriptor();
			var description = methodDescriptor.description;
			var message = "FAILURE!!!	* [" + methodDescriptor.methodName + "] " + ( description.length > 0 ? description : "." );
			this._log( message );
			this._addTab();
			#if php
			this._log( "" + error + ": " + ( Std.is( error, AssertException ) ? ": " + Assert.getLastAssertionLog() : "" ) );
			#else
			this._log( error.toString() );
			this._log( error.message + ": " + ( Std.is( error, AssertException ) ? ": " + Assert.getLastAssertionLog() : "" ) );
			#end
			
			this._removeTab();
			
			if ( this._errorBubbling )
			{
				throw( error );
			}
		}
		
    }

    public function onTimeout( descriptor : TestClassDescriptor, ?timeElapsed : Float, ?error : Exception ) : Void
    {
        var methodDescriptor = descriptor.currentMethodDescriptor();
        var description = methodDescriptor.description;
        var message = "* [" + methodDescriptor.methodName + "] " + ( description.length > 0 ? description : "." );
        this._log( message );
        this._addTab();
        this._log( error.message );
        this._removeTab();
    }
	
	public function onIgnore( descriptor : TestClassDescriptor, ?timeElapsed : Float, ?error : Exception ) : Void 
	{
		var methodDescriptor = descriptor.currentMethodDescriptor();
        var description = methodDescriptor.description;
        var timeElapsed = " " + timeElapsed + "ms";
        var message = "IGNORE	* [" + methodDescriptor.methodName + "] " + ( description.length > 0 ? description : "" ) + timeElapsed;
        this._log( message );
	}
}
