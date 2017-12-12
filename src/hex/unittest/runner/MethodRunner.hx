package hex.unittest.runner;

import haxe.Timer;
import hex.error.Exception;
import hex.error.IllegalArgumentException;
import hex.error.IllegalStateException;
import hex.unittest.assertion.Assert;
import hex.unittest.description.MethodDescriptor;
import hex.unittest.event.ITestResultListener;

/**
 * ...
 * @author Francis Bourre
 */
class MethodRunner
{
    public var _scope				: Dynamic;
    public var _methodReference		: Dynamic;
    public var _methodDescriptor	: MethodDescriptor;
	public var _startTime			: Float;
    public var _endTime				: Float;
    public var _classType			: Dynamic;
	
    public var trigger ( default, never ) : Trigger = new Trigger();

    public function new( scope : Dynamic, methodDescriptor : MethodDescriptor, classType : Dynamic )
    {
        this._scope             = scope;
        this._methodReference   = Reflect.field( this._scope, methodDescriptor.methodName );
        this._methodDescriptor  = methodDescriptor;
		this._classType			= classType;
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
		
		var dataProvider = this._methodDescriptor.dataProviderFieldName != "" ? cast(Reflect.field( this._classType, this._methodDescriptor.dataProviderFieldName )) : [];
		
        if ( !this._methodDescriptor.isAsync )
        {
            try
            {
				//
                Reflect.callMethod( this._scope, this._methodReference, dataProvider.length > 0 ? [dataProvider[ this._methodDescriptor.dataProviderIndex ]] : [] );
                this._endTime = Date.now().getTime();
                this.trigger.onSuccess( this.getTimeElapsed() );
			}
            catch ( err : Dynamic )
            {
                this._notifyError( err );
            }
        }
        else
        {
			if ( this._timer != null )
			{
				this._timer.stop();
			}
			this._timer = new Timer( this._methodDescriptor.timeout );
			this._timer.run = MethodRunner._fireTimeout;
		
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
                Reflect.callMethod( this._scope, this._methodReference, dataProvider.length > 0 ? [dataProvider[ this._methodDescriptor.dataProviderIndex ]] : [] );
            }
            catch ( err : Dynamic )
            {
                this._notifyError( err );
            }
        }
    }
	
	function _notifyError( e : Dynamic ) : Void
	{
		this._endTime = Date.now().getTime();
		
		if ( !Std.is( e, Exception ) )
		{
			var err : Exception = null;
			#if php
			err = new Exception( "" + e, e.p );
			#elseif flash
			err = new Exception( cast( e ).message );
			#else
			err = new Exception( e.toString(), e.posInfos );
			#end
			this.trigger.onFail( this.getTimeElapsed(), err );
			Assert._logFailedAssertion();
		}
		else
		{
			this.trigger.onFail( this.getTimeElapsed(), e );
			Assert._logFailedAssertion();
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

    public function getDescriptor() : MethodDescriptor
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
    public static var _CURRENT_RUNNER : MethodRunner;

	#if genhexunit
	macro public static function asyncHandler( methodReference, ?passThroughArgs )
    {
		return macro 
		{
			hex.unittest.runner.MethodRunner._CURRENT_RUNNER._callback          = $methodReference;
			hex.unittest.runner.MethodRunner._CURRENT_RUNNER._passThroughArgs   = $passThroughArgs;
		
			Reflect.makeVarArgs( function( rest:Array<Dynamic> ):Void
			{
				var m = hex.unittest.runner.MethodRunner;
				if ( m._CURRENT_RUNNER == null )
				{
					throw new hex.error.IllegalStateException( "AsyncHandler has been called after '@Async' test was released. Try to remove all your listeners in '@After' method to fix this error" );
				}

				m._CURRENT_RUNNER._timer.stop();
				m._CURRENT_RUNNER._timer = null;
			
				var methodRunner = m._CURRENT_RUNNER;

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
					m._CURRENT_RUNNER = null;
					methodRunner.trigger.onSuccess( methodRunner.getTimeElapsed() );

				}
				catch ( e : hex.error.Exception )
				{
					m._CURRENT_RUNNER = null;
					methodRunner.trigger.onFail( methodRunner.getTimeElapsed(), e );
				}
			});
		}
    }
	#else
    public static function asyncHandler( methodReference : Dynamic, ?passThroughArgs : Array<Dynamic> ) : Dynamic
    {
		try
		{
			MethodRunner._CURRENT_RUNNER.setCallback( methodReference, passThroughArgs );
		}
		catch ( e : Dynamic )
		{
			throw new IllegalStateException( "Asynchronous test failed. Maybe you forgot to add '@Async' metadata to your test?" );
		}
		
        return MethodRunner._createAsyncCallbackHandler();
    }
	#end
	
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

    public var _callback           : Dynamic;
    public var _passThroughArgs    : Array<Dynamic>;
    public var _timeout            : Int;
    public var _timer              : Timer;

    public function setCallback( methodReference : Dynamic, ?passThroughArgs : Array<Dynamic> ) : Void
    {
        this._callback          = methodReference;
        this._passThroughArgs   = passThroughArgs;
    }

    public static function _createAsyncCallbackHandler( ) : Array<Dynamic>->Void
    {
		var f:Array<Dynamic>->Void = function( rest:Array<Dynamic> ):Void
		{
			if ( MethodRunner._CURRENT_RUNNER == null )
			{
				throw new IllegalStateException( "AsyncHandler has been called after '@Async' test was released. Try to remove all your listeners in '@After' method to fix this error" );
			}

			MethodRunner._CURRENT_RUNNER._timer.stop();
			MethodRunner._CURRENT_RUNNER._timer = null;
		
			var methodRunner = MethodRunner._CURRENT_RUNNER;

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
		MethodRunner._CURRENT_RUNNER._timer.stop();
        var methodRunner : MethodRunner = MethodRunner._CURRENT_RUNNER;
		methodRunner._endTime = Date.now().getTime();
		MethodRunner._CURRENT_RUNNER = null;
        methodRunner.trigger.onTimeout( methodRunner.getTimeElapsed() );
    }
}

//Here we create trigger manually to prevent order macro errors
class Trigger implements ITestResultListener
{ 
		var _inputs : Array<ITestResultListener>;

		public function new() 
		{
			this._inputs = [];
		}

		public function connect( input : ITestResultListener ) : Bool
		{
			if ( this._inputs.indexOf( input ) == -1 )
			{
				this._inputs.push( input );
				return true;
			}
			else
			{
				return false;
			}
		}

		public function disconnect( input : ITestResultListener ) : Bool
		{
			var index : Int = this._inputs.indexOf( input );
			
			if ( index > -1 )
			{
				this._inputs.splice( index, 1 );
				return true;
			}
			else
			{
				return false;
			}
		}
		
		public function disconnectAll() : Void
		{
			this._inputs = [];
		}
		
		public function onSuccess( timeElapsed : Float ) : Void 
		{
			var inputs = this._inputs.copy();
			for ( input in inputs ) input.onSuccess( timeElapsed );
		}
		
		public function onFail( timeElapsed : Float, error : Exception ) : Void 
		{
			var inputs = this._inputs.copy();
			for ( input in inputs ) input.onFail( timeElapsed, error );
		}
		
		public function onTimeout( timeElapsed : Float ) : Void 
		{
			var inputs = this._inputs.copy();
			for ( input in inputs ) input.onTimeout( timeElapsed );
		}
		
		public function onIgnore( timeElapsed : Float ) : Void 
		{
			var inputs = this._inputs.copy();
			for ( input in inputs ) input.onIgnore( timeElapsed );
		}
}