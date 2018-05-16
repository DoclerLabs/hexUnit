package hex.unittest.runner;

import haxe.Timer;
import hex.error.IllegalArgumentException;
import hex.error.IllegalStateException;
import hex.unittest.assertion.Assert;
import hex.unittest.description.MethodDescriptor;
import hex.unittest.event.ITestResultListener;

using tink.CoreApi;

/**
 * ...
 * @author Francis Bourre
 */
class MethodRunner
{
	var _scope						: Dynamic;
	var _methodDescriptor			: MethodDescriptor;
	var _trigger ( default, never ) : Trigger = new Trigger();
	
	var _functionCall				: Dynamic->Void;
    var _methodReference			: Dynamic;
	
	var _timer              		: Timer;
	var _startTime					: Float;
    var _classType					: Dynamic;
	
    public function new( scope : Dynamic, methodDescriptor : MethodDescriptor, classType : Dynamic )
    {
        this._scope             = scope;
        this._methodReference   = Reflect.field( this._scope, methodDescriptor.methodName );
        this._methodDescriptor  = methodDescriptor;
		this._classType			= classType;
		this._functionCall		= methodDescriptor.functionCall;
    }

    public function run() : Void
    {
        this._startTime = Date.now().getTime();
		
		if ( this._methodDescriptor.isIgnored )
		{
			this._trigger.onIgnore( Date.now().getTime() - this._startTime );
			return;
		}
		
		var dataProvider = this._methodDescriptor.dataProviderFieldName != "" ? cast(Reflect.field( this._classType, this._methodDescriptor.dataProviderFieldName )) : [];
		
        if ( !this._methodDescriptor.isAsync )
        {
			try
            {
                
				if ( this._functionCall != null )
				{
					this._functionCall( this._scope );
					
				}
				else
				{
					Reflect.callMethod( this._scope, this._methodReference, dataProvider.length > 0 ? [dataProvider[ this._methodDescriptor.dataProviderIndex ]] : [] );
				}
				
                this._notifySuccess();
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
                this._trigger.onFail( Date.now().getTime() - this._startTime, e );
				return;
			}
            
            try
            {
				if ( this._functionCall != null )
				{
					this._functionCall( this._scope );
					
				}
				else
				{
					Reflect.callMethod( this._scope, this._methodReference, dataProvider.length > 0 ? [dataProvider[ this._methodDescriptor.dataProviderIndex ]] : [] );
				}
			}
            catch ( err : Dynamic )
            {
				this._timer.stop();
				MethodRunner._CURRENT_RUNNER = null;
                this._notifyError( err );
            }
        }
    }
	
	function _notifySuccess() : Void
	{
		this._trigger.onSuccess( Date.now().getTime() - this._startTime );
	}
	
	function _notifyError( e : Dynamic ) : Void
	{
		if ( !Std.is( e, TypedError ) )
		{
			var err : Error = null;
			#if php
			err = new TypedError( "" + e, e.p );
			#elseif flash
			err = new TypedError( Std.string( cast( e ).message ) );
			#else
			err = new TypedError( e.toString(), e.posInfos );
			#end
			
			Assert._logFailedAssertion();
			this._trigger.onFail( Date.now().getTime() - this._startTime, err );
		}
		else
		{
			Assert._logFailedAssertion();
			this._trigger.onFail( Date.now().getTime() - this._startTime, e );
		}
	}

    public function addListener( listener : ITestResultListener ) : Bool
    {
		return this._trigger.connect( listener );
    }

    public function removeListener( listener : ITestResultListener ) : Bool
    {
		return this._trigger.disconnect( listener );
    }

    public function getDescriptor() : MethodDescriptor
    {
        return this._methodDescriptor;
    }

    /**
     * Async handling
     */
    static var _CURRENT_RUNNER : MethodRunner;

	public static function asyncHandler( closure : Void->Void ) : Void
	{
		var methodRunner = hex.unittest.runner.MethodRunner._CURRENT_RUNNER;
		if ( methodRunner == null )
		{
			throw new hex.error.IllegalStateException( "AsyncHandler has been called after '@Async' test was released. Try to remove all your listeners in '@After' method to fix this error" );
		}
		
		try
		{
			closure();

			methodRunner._timer.stop();
			methodRunner._timer = null;
			hex.unittest.runner.MethodRunner._CURRENT_RUNNER = null;
			methodRunner._notifySuccess();
		}
		catch ( e : Dynamic )
		{
			methodRunner._timer.stop();
			methodRunner._timer = null;
			hex.unittest.runner.MethodRunner._CURRENT_RUNNER = null;
			
			methodRunner._notifyError( e );
		}
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

    static function _fireTimeout() : Void
    {
		var methodRunner = MethodRunner._CURRENT_RUNNER;
		methodRunner._timer.stop();
		MethodRunner._CURRENT_RUNNER = null;
		
		Assert._logFailedAssertion();
        methodRunner._trigger.onTimeout( Date.now().getTime() - methodRunner._startTime );
    }
}

//Here we create trigger manually to prevent macro execution order errors
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
	
	public function onFail( timeElapsed : Float, error : Error ) : Void 
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