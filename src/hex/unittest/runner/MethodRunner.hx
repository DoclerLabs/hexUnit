package hex.unittest.runner;

import haxe.Timer;
import haxe.macro.Context;
import haxe.macro.Expr.ExprOf;
import haxe.macro.Printer;
import hex.error.Exception;
import hex.error.IllegalArgumentException;
import hex.error.IllegalStateException;
import hex.unittest.assertion.Assert;
import hex.unittest.description.MethodDescriptor;
import hex.unittest.event.ITestResultListener;
import hex.util.MacroUtil;

/**
 * ...
 * @author Francis Bourre
 */
class MethodRunner
{
	public var scope						: Dynamic;
	public var callback           			: Dynamic;
    public var passThroughArgs    			: Array<Dynamic>;
    public var timer              			: Timer;
	public var endTime						: Float;
	public var trigger ( default, never ) 	: Trigger = new Trigger();
	
	var _functionCall		: Dynamic->Void;
	
    var _methodReference	: Dynamic;
    var _methodDescriptor	: MethodDescriptor;
	var _startTime			: Float;
    var _classType			: Dynamic;
	
    public function new( scope : Dynamic, methodDescriptor : MethodDescriptor, classType : Dynamic )
    {
        this.scope             	= scope;
        this._methodReference   = Reflect.field( this.scope, methodDescriptor.methodName );
        this._methodDescriptor  = methodDescriptor;
		this._classType			= classType;
		this._functionCall		= methodDescriptor.functionCall;
    }

    public function run() : Void
    {
        this._startTime = Date.now().getTime();
		
		if ( this._methodDescriptor.isIgnored )
		{
			this.endTime = Date.now().getTime();
			this.trigger.onIgnore( this.getTimeElapsed() );
			return;
		}
		
		var dataProvider = this._methodDescriptor.dataProviderFieldName != "" ? cast(Reflect.field( this._classType, this._methodDescriptor.dataProviderFieldName )) : [];
		
        if ( !this._methodDescriptor.isAsync )
        {
			try
            {
                
				if ( this._functionCall != null )
				{
					this._functionCall( this.scope );
					
				}
				else
				{
					Reflect.callMethod( this.scope, this._methodReference, dataProvider.length > 0 ? [dataProvider[ this._methodDescriptor.dataProviderIndex ]] : [] );
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
			if ( this.timer != null )
			{
				this.timer.stop();
			}
			this.timer = new Timer( this._methodDescriptor.timeout );
			this.timer.run = MethodRunner._fireTimeout;
		
			try
			{
				MethodRunner.registerAsyncMethodRunner( this );
			}
			catch ( e : IllegalArgumentException )
			{
				this.endTime = Date.now().getTime();
                this.trigger.onFail( this.getTimeElapsed(), e );
				return;
			}
            
            try
            {
				if ( this._functionCall != null )
				{
					this._functionCall( this.scope );
					
				}
				else
				{
					Reflect.callMethod( this.scope, this._methodReference, dataProvider.length > 0 ? [dataProvider[ this._methodDescriptor.dataProviderIndex ]] : [] );
				}
			}
            catch ( err : Dynamic )
            {
				this.timer.stop();
				MethodRunner._CURRENT_RUNNER = null;
                this._notifyError( err );
            }
        }
    }
	
	public function _notifySuccess() : Void
	{
		this.endTime = Date.now().getTime();
		this.trigger.onSuccess( this.getTimeElapsed() );
	}
	
	public function _notifyError( e : Dynamic ) : Void
	{
		this.endTime = Date.now().getTime();
		
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
        return this.endTime - this._startTime;
    }

    /**
     * Async handling
     */
    public static var _CURRENT_RUNNER : AsyncListener;

	static public function asyncHandler( closure : Void->Void ) : Void
	{
		var methodRunner = hex.unittest.runner.MethodRunner._CURRENT_RUNNER;
		if ( methodRunner == null )
		{
			throw new hex.error.IllegalStateException( "AsyncHandler has been called after '@Async' test was released. Try to remove all your listeners in '@After' method to fix this error" );
		}
		
		try
		{
			closure();

			methodRunner.timer.stop();
			methodRunner.timer = null;
			hex.unittest.runner.MethodRunner._CURRENT_RUNNER = null;
			methodRunner._notifySuccess();
		}
		catch ( e : Dynamic )
		{
			methodRunner.timer.stop();
			methodRunner.timer = null;
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

    public static function _createAsyncCallbackHandler( ) : Array<Dynamic>->Void
    {
		var f:Array<Dynamic>->Void = function( rest:Array<Dynamic> ):Void
		{
			if ( MethodRunner._CURRENT_RUNNER == null )
			{
				return;
				//throw new IllegalStateException( "AsyncHandler has been called after '@Async' test was released. Try to remove all your listeners in '@After' method to fix this error" );
			}

			MethodRunner._CURRENT_RUNNER.timer.stop();
			MethodRunner._CURRENT_RUNNER.timer = null;
		
			var methodRunner = MethodRunner._CURRENT_RUNNER;

			var args : Array<Dynamic> = [];

			if ( rest != null )
			{
				args = args.concat( rest );
			}

			/*if ( methodRunner.passThroughArgs != null )
			{
				args = args.concat( methodRunner.passThroughArgs );
			}*/

			try
			{
				Reflect.callMethod( methodRunner.scope, methodRunner.callback, args );
				methodRunner.endTime = Date.now().getTime();
				MethodRunner._CURRENT_RUNNER = null;
				methodRunner.trigger.onSuccess( methodRunner.getTimeElapsed() );

			}
			catch ( e : Exception )
			{
				//MethodRunner._CURRENT_RUNNER.timer.stop();
				MethodRunner._CURRENT_RUNNER = null;
				methodRunner.trigger.onFail( methodRunner.getTimeElapsed(), e );
			}
		}
        
		return Reflect.makeVarArgs( f );
    }

    static function _fireTimeout() : Void
    {
		MethodRunner._CURRENT_RUNNER.timer.stop();
        var methodRunner = MethodRunner._CURRENT_RUNNER;
		methodRunner.endTime = Date.now().getTime();
		MethodRunner._CURRENT_RUNNER = null;
        methodRunner.trigger.onTimeout( methodRunner.getTimeElapsed() );
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