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

import haxe.PosInfos;

/**
 * ...
 * @author Francis Bourre
 */
class TraceNotifier implements ITestClassResultListener
{
	public static var TAB_CHARACTER:String = "  ";
	
    var _tabs   			: String;
    var _errorBubbling   	: Bool;
    var _hideSuccessTest   	: Bool;

	#if flash
    public function new( loaderInfo : LoaderInfo, errorBubbling : Bool = false, hideSuccessTest : Bool = false )
    {
		this._errorBubbling = errorBubbling;
		this._hideSuccessTest = hideSuccessTest;
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
	public function new( errorBubbling : Bool = false, hideSuccessTest : Bool = false )
    {
		this._errorBubbling = errorBubbling;
		this._hideSuccessTest = hideSuccessTest;
		Log.init();
    }
	#end

    function _log( message : String ) : Void
    {
		Log.debug( this._tabs + message );
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
        Log.pass( "Assertions passed: " + Assert.getAssertionCount() );
		
		if ( Assert.getAssertionFailedCount() > 0 )
		{
			Log.fail( "Assertions failed: " + Assert.getAssertionFailedCount() + "\n" );
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

    public function onSuccess( descriptor : TestClassDescriptor, timeElapsed : Float ) : Void
    {
		if( !this._hideSuccessTest )
		{
			var methodDescriptor = descriptor.currentMethodDescriptor();
			var description = methodDescriptor.description;
			var time = " " + timeElapsed + "ms";
			var message = "* [" + methodDescriptor.methodName + "] " + ( description.length > 0 ? description : "" ) + time;
			Log.pass( message );
		}
    }

    public function onFail( descriptor : TestClassDescriptor, timeElapsed : Float, error : Exception ) : Void
    {
		if ( descriptor != null )
		{
			var methodDescriptor = descriptor.currentMethodDescriptor();
			var description = methodDescriptor.description;
			var message = "FAILURE!!!	* [" + methodDescriptor.methodName + "] " + ( description.length > 0 ? description : "." );
			Log.fail( message );
			this._addTab();
			#if php
			Log.fail( "" + error + ": " + ( Std.is( error, AssertException ) ? ": " + Assert.getLastAssertionLog() : "" ) );
			#else
			Log.fail( error.toString() );
			Log.fail( error.message + ": " + ( Std.is( error, AssertException ) ? ": " + Assert.getLastAssertionLog() : "" ) );
			#end
			
			this._removeTab();
			
			if ( this._errorBubbling )
			{
				throw( error );
			}
		}
		
    }

    public function onTimeout( descriptor : TestClassDescriptor, timeElapsed : Float, error : Exception ) : Void
    {
        var methodDescriptor = descriptor.currentMethodDescriptor();
        var description = methodDescriptor.description;
        var message = "* [" + methodDescriptor.methodName + "] " + ( description.length > 0 ? description : "." );
        Log.warn( message );
        this._addTab();
        this._removeTab();
    }
	
	public function onIgnore( descriptor : TestClassDescriptor ) : Void 
	{
		var methodDescriptor = descriptor.currentMethodDescriptor();
        var description = methodDescriptor.description;
		var timeElapsed = " " + 0 + "ms";
        var message = "IGNORE	* [" + methodDescriptor.methodName + "] " + ( description.length > 0 ? description : "" );
        Log.warn( message );
	}
}

// from https://gist.github.com/martinwells/5980517
class Log
{
	private static var ansiColors:Map<String,String> = new Map();

	private static var origTrace:Dynamic->?PosInfos->Void;

	public static function init()
	{
		ansiColors['black'] = '\033[0;30m';
		ansiColors['red'] = '\033[31m';
		ansiColors['green'] = '\033[32m';
		ansiColors['yellow'] = '\033[33m';
		ansiColors['blue'] = '\033[1;34m';
		ansiColors['magenta'] = '\033[1;35m';
		ansiColors['cyan'] = '\033[0;36m';
		ansiColors['grey'] = '\033[0;37m';
		ansiColors['white'] = '\033[1;37m';
		ansiColors['default'] = '\033[1;39m';

		// reuse it for quick lookups of colors to log levels
		ansiColors['debug'] = ansiColors['default'];
		ansiColors['warn'] = ansiColors['yellow'];
		ansiColors['error'] = ansiColors['red'];
		ansiColors['fail'] = ansiColors['red'];
		ansiColors['pass'] = ansiColors['green'];
		ansiColors['default'] = ansiColors['default'];

		// overload trace so we get access to funky stuff
		origTrace = haxe.Log.trace;
		haxe.Log.trace = haxeTrace;
	}

	inline public static function debug(message:Dynamic, ?pos:PosInfos):Void
	{
		print('debug', [message], pos);
	}

	inline public static function warn(message:Dynamic, ?pos:PosInfos):Void
	{
		print('warn', [message], pos);
	}

	inline public static function error(message:Dynamic, ?pos:PosInfos):Void
	{
		print('error', [message], pos);
	}

	inline public static function fail(message:Dynamic, ?pos:PosInfos):Void
	{
		print('fail', [message], pos);
	}

	inline public static function pass(message:Dynamic, ?pos:PosInfos):Void
	{
		print('pass', [message], pos);
	}

	static function haxeTrace(value:Dynamic, ?pos:PosInfos)
	{
		var params = pos.customParams;
		if (params == null)
			params = [];
		else
			pos.customParams = null;

		print(value, params, pos);
	}

	static public function print(level:String, params:Array<Dynamic>, pos:PosInfos):Void
	{
		params = params.copy();

		// prepare message
		for (i in 0...params.length)
			params[i] = Std.string(params[i]);
		var message = params.join(", ");

		origTrace(ansiColors[level] + message + ansiColors['default'], pos);
	}
}
