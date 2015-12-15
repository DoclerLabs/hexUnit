package hex.unittest.runner;

import haxe.Timer;
import hex.error.Exception;
import hex.error.IllegalArgumentException;
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
    private var _scope                  : Dynamic;
    private var _methodReference        : Dynamic;
    private var _methodDescriptor       : TestMethodDescriptor;
    private var _dispatcher             : EventDispatcher<IMethodRunnerListener, BasicEvent>;

    private var _startTime              : Float;
    private var _endTime                : Float;

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
                this._dispatcher.dispatchEvent( new MethodRunnerEvent( MethodRunnerEvent.FAIL, this, this._methodDescriptor, this.getTimeElapsed(), e ) );
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
    private static var _CURRENT_RUNNER : MethodRunner;

    public static function asyncHandler( methodReference : Dynamic, ?passThroughArgs : Array<Dynamic>, timeout : Int = 1500 ) : Dynamic
    {
        MethodRunner._CURRENT_RUNNER.setCallback( methodReference, passThroughArgs, timeout );
        return MethodRunner._asyncCallbackHandler;
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

    private var _callback           : Dynamic;
    private var _passThroughArgs    : Array<Dynamic>;
    private var _timeout            : Int;
    private var _timer              : Timer;

    public function setCallback( methodReference : Dynamic, ?passThroughArgs : Array<Dynamic>, timeout : Int = 1500 ) : Void
    {
        this._callback          = methodReference;
        this._passThroughArgs   = passThroughArgs;
        this._timeout           = timeout;

		this._timer = new Timer( timeout );
		this._timer.run = MethodRunner._fireTimeout;
    }

    public static function _asyncCallbackHandler( ?event : BasicEvent ) : Void
    {
		MethodRunner._CURRENT_RUNNER._timer.stop();
		
        var methodRunner : MethodRunner = MethodRunner._CURRENT_RUNNER;

        var args : Array<Dynamic> = [];

        if ( event != null )
        {
            args.push( event );
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

    private static function _fireTimeout() : Void
    {
		MethodRunner._CURRENT_RUNNER._timer.stop();
        var methodRunner : MethodRunner = MethodRunner._CURRENT_RUNNER;
		MethodRunner._CURRENT_RUNNER = null;
        methodRunner._dispatcher.dispatchEvent( new MethodRunnerEvent( MethodRunnerEvent.TIMEOUT, methodRunner, methodRunner._methodDescriptor, methodRunner.getTimeElapsed(), new Exception( "Test timeout" ) ) );
    }
}
