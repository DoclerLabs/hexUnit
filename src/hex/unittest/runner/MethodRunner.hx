package hex.unittest.runner;

import haxe.Timer;
import hex.error.Exception;
import hex.error.IllegalArgumentException;
import hex.error.IllegalStateException;
import hex.event.ITrigger;
import hex.event.ITriggerOwner;
import hex.unittest.description.TestMethodDescriptor;
import hex.unittest.event.ITestResultListener;

/**
 * ...
 * @author Francis Bourre
 */
class MethodRunner implements ITriggerOwner
{
    var _scope                  : Dynamic;
    var _methodReference        : Dynamic;
    var _methodDescriptor       : TestMethodDescriptor;
	var _startTime              : Float;
    var _endTime                : Float;
	
    public var trigger ( default, never ) : ITrigger<ITestResultListener>;

    public function new( scope : Dynamic, methodDescriptor : TestMethodDescriptor )
    {
        this._scope             = scope;
        this._methodReference   = Reflect.field( this._scope, methodDescriptor.methodName );
        this._methodDescriptor  = methodDescriptor;
    }

    public function run() : Void
    {
        this._startTime = Date.now().getTime();
		
		if ( this._methodDescriptor.isIgnored )
		{
			this._endTime = Date.now().getTime();
			this.trigger.onIgnore( this.getTimeElapsed() );
			return;
		}
		
        if ( !this._methodDescriptor.isAsync )
        {
            try
            {
                Reflect.callMethod( this._scope, this._methodReference, this._methodDescriptor.dataProvider );
                this._endTime = Date.now().getTime();
                this.trigger.onSuccess( this.getTimeElapsed() );
			}
            catch ( e : Dynamic )
            {
                this._endTime = Date.now().getTime();
				if ( !Std.is( e, Exception ) )
				{
					var err : Exception = null;
					#if php
					err = new Exception( "" + e, e.p );
					#else
					err = new Exception( e.toString(), e.posInfos );
					#end
					this.trigger.onFail( this.getTimeElapsed(), err );
				}
				else
				{
					this.trigger.onFail( this.getTimeElapsed(), e );
				}
                
            }
        }
        else
        {
			try
			{
				MethodRunner.registerAsyncMethodRunner( this );
			}
			catch ( e : IllegalArgumentException )
			{
				this._endTime = Date.now().getTime();
                this.trigger.onFail( this.getTimeElapsed(), e );
				return;
			}
            
            try
            {
                Reflect.callMethod( this._scope, this._methodReference, this._methodDescriptor.dataProvider );
            }
            catch ( e : Dynamic )
            {
                this._endTime = Date.now().getTime();
                this.trigger.onFail( this.getTimeElapsed(), e );
            }
        }
    }

    public function addListener( listener : ITestResultListener ) : Bool
    {
		return this.trigger.connect( listener );
    }

    public function removeListener( listener : ITestResultListener ) : Bool
    {
		return this.trigger.disconnect( listener );
    }

    public function getDescriptor() : TestMethodDescriptor
    {
        return this._methodDescriptor;
    }

    public function getTimeElapsed() : Float
    {
        return this._endTime - this._startTime;
    }

    /**
     * Async handling
     */
    static var _CURRENT_RUNNER : MethodRunner;

    public static function asyncHandler( methodReference : Dynamic, ?passThroughArgs : Array<Dynamic>, timeout : Int = 1500 ) : Dynamic
    {
		try
		{
			MethodRunner._CURRENT_RUNNER.setCallback( methodReference, passThroughArgs, timeout );
		}
		catch ( e : Dynamic )
		{
			throw new IllegalStateException( "Asynchronous test failed. Maybe you forgot to add '@Async' metadata to your test ?" );
		}
		
        return MethodRunner._createAsyncCallbackHandler();
    }

    public static function registerAsyncMethodRunner( runner : MethodRunner ) : Void
    {
        if ( MethodRunner._CURRENT_RUNNER == null )
        {
            MethodRunner._CURRENT_RUNNER = runner;
        }
        else
        {
            throw new IllegalArgumentException( "MethodRunner.registerAsyncMethodRunner fails. '"
                                                + MethodRunner._CURRENT_RUNNER + "' was already registered." );
        }
    }

    var _callback           : Dynamic;
    var _passThroughArgs    : Array<Dynamic>;
    var _timeout            : Int;
    var _timer              : Timer;

    public function setCallback( methodReference : Dynamic, ?passThroughArgs : Array<Dynamic>, timeout : Int = 1500 ) : Void
    {
        this._callback          = methodReference;
        this._passThroughArgs   = passThroughArgs;
        this._timeout           = timeout;

		#if (!neko || haxe_ver >= "3.3")
		if ( this._timer != null )
		{
			this._timer.stop();
		}
		this._timer = new Timer( timeout );
		this._timer.run = MethodRunner._fireTimeout;
		#end
    }

    public static function _createAsyncCallbackHandler( ) : Array<Dynamic>->Void
    {
		var f:Array<Dynamic>->Void = function( rest:Array<Dynamic> ):Void
		{
			if ( MethodRunner._CURRENT_RUNNER == null )
			{
				throw new IllegalStateException( "AsyncHandler has been called after '@Async' test was released. Try to remove all your listeners in '@After' method to fix this error" );
			}
			
			#if (!neko || haxe_ver >= "3.3")
			MethodRunner._CURRENT_RUNNER._timer.stop();
			#end
			MethodRunner._CURRENT_RUNNER._timer = null;
		
			var methodRunner : MethodRunner = MethodRunner._CURRENT_RUNNER;

			var args : Array<Dynamic> = [];

			if ( rest != null )
			{
				args = args.concat( rest );
			}

			if ( methodRunner._passThroughArgs != null )
			{
				args = args.concat( methodRunner._passThroughArgs );
			}

			try
			{
				Reflect.callMethod( methodRunner._scope, methodRunner._callback, args );
				methodRunner._endTime = Date.now().getTime();
				MethodRunner._CURRENT_RUNNER = null;
				methodRunner.trigger.onSuccess( methodRunner.getTimeElapsed() );
			
				
			}
			catch ( e : Exception )
			{
				MethodRunner._CURRENT_RUNNER = null;
				methodRunner.trigger.onFail( methodRunner.getTimeElapsed(), e );
			}
		}
        
		return Reflect.makeVarArgs( f );
    }

    static function _fireTimeout() : Void
    {
		#if (!neko || haxe_ver >= "3.3")
		MethodRunner._CURRENT_RUNNER._timer.stop();
		#end
        var methodRunner : MethodRunner = MethodRunner._CURRENT_RUNNER;
		methodRunner._endTime = Date.now().getTime();
		MethodRunner._CURRENT_RUNNER = null;
        methodRunner.trigger.onTimeout( methodRunner.getTimeElapsed() );
    }
}
