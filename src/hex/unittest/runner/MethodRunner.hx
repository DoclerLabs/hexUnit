package hex.unittest.runner;

import haxe.CallStack;
import haxe.Timer;
import hex.error.Exception;
import hex.error.IllegalArgumentException;
import hex.error.IllegalStateException;
import hex.event.BasicEvent;
import hex.event.EventDispatcher;
import hex.unittest.description.TestMethodDescriptor;
import hex.unittest.event.IMethodRunnerListener;
import hex.unittest.event.MethodRunnerEvent;

/**
 * ...
 * @author Francis Bourre
 */
class MethodRunner
{
    var _scope                  : Dynamic;
    var _methodReference        : Dynamic;
    var _methodDescriptor       : TestMethodDescriptor;
    var _dispatcher             : EventDispatcher<IMethodRunnerListener, BasicEvent>;

    var _startTime              : Float;
    var _endTime                : Float;

    public function new( scope : Dynamic, methodDescriptor : TestMethodDescriptor )
    {
        this._scope             = scope;
        this._methodReference   = Reflect.field( this._scope, methodDescriptor.methodName );
        this._methodDescriptor  = methodDescriptor;
        this._dispatcher        = new EventDispatcher<IMethodRunnerListener, BasicEvent>();
    }

    public function run() : Void
    {
        this._startTime = Date.now().getTime();

        if ( !this._methodDescriptor.isAsync )
        {
            try
            {
                Reflect.callMethod( this._scope, this._methodReference, [] );
                this._endTime = Date.now().getTime();
                this._dispatcher.dispatchEvent( new MethodRunnerEvent( MethodRunnerEvent.SUCCESS, this, this._methodDescriptor, this.getTimeElapsed() ) );
            }
            catch ( e : Dynamic )
            {
                this._endTime = Date.now().getTime();
				if ( !Std.is( e, Exception ) )
				{
					var err : Exception = new Exception( e.toString() , e.posInfos );
					this._dispatcher.dispatchEvent( new MethodRunnerEvent( MethodRunnerEvent.FAIL, this, this._methodDescriptor, this.getTimeElapsed(), err ) );
				}
				else
				{
					this._dispatcher.dispatchEvent( new MethodRunnerEvent( MethodRunnerEvent.FAIL, this, this._methodDescriptor, this.getTimeElapsed(), e ) );
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
                this._dispatcher.dispatchEvent( new MethodRunnerEvent( MethodRunnerEvent.FAIL, this, this._methodDescriptor, this.getTimeElapsed(), e ) );
				return;
			}
            
            try
            {
                Reflect.callMethod( this._scope, this._methodReference, [] );
            }
            catch ( e : Dynamic )
            {
                this._endTime = Date.now().getTime();
                this._dispatcher.dispatchEvent( new MethodRunnerEvent( MethodRunnerEvent.FAIL, this, this._methodDescriptor, this.getTimeElapsed(), e ) );
            }
        }
    }

    public function addListener( listener : IMethodRunnerListener ) : Bool
    {
        return this._dispatcher.addListener( listener );
    }

    public function removeListener( listener : IMethodRunnerListener ) : Bool
    {
        return this._dispatcher.removeListener( listener );
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
				methodRunner._dispatcher.dispatchEvent( new MethodRunnerEvent( MethodRunnerEvent.SUCCESS, methodRunner, methodRunner._methodDescriptor, methodRunner.getTimeElapsed() ) );
			}
			catch ( e : Exception )
			{
				MethodRunner._CURRENT_RUNNER = null;
				methodRunner._dispatcher.dispatchEvent( new MethodRunnerEvent( MethodRunnerEvent.FAIL, methodRunner, methodRunner._methodDescriptor, methodRunner.getTimeElapsed(), e ) );
			}
		}
        
		return Reflect.makeVarArgs(f);
    }

    static function _fireTimeout() : Void
    {
		#if (!neko || haxe_ver >= "3.3")
		MethodRunner._CURRENT_RUNNER._timer.stop();
		#end
        var methodRunner : MethodRunner = MethodRunner._CURRENT_RUNNER;
		methodRunner._endTime = Date.now().getTime();
		MethodRunner._CURRENT_RUNNER = null;
        methodRunner._dispatcher.dispatchEvent( new MethodRunnerEvent( MethodRunnerEvent.TIMEOUT, methodRunner, methodRunner._methodDescriptor, methodRunner.getTimeElapsed(), new Exception( "Test timeout" ) ) );
    }
}
