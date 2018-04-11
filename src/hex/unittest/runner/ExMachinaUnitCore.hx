package hex.unittest.runner;

import hex.unittest.assertion.Assert;
import hex.unittest.description.ClassDescriptor;
import hex.unittest.event.ITestClassResultListener;
import hex.unittest.metadata.MetadataParser;
import hex.util.Stringifier;

using tink.CoreApi;
using hex.unittest.description.ClassDescriptorUtil;

/**
 * ...
 * @author Francis Bourre
 */
class ExMachinaUnitCore 
	implements hex.event.ITriggerOwner
	implements ITestClassResultListener
{
    var _parser                     : MetadataParser;
    var _classDescriptors           : Array<ClassDescriptor>;
    var _runner                     : TestRunner;
    var _currentClassDescriptor     : Int;
	
    public var dispatcher ( default, never ) = new UnitCoreTrigger();
    public function new()
    {
        this._parser            = new MetadataParser();
        this._classDescriptors  = [];
    }

    public function run() : Void
    {
        this._currentClassDescriptor = 0;
        Assert.resetAssertionLog();
        this._runNext();
    }
	
	public function getTestLength() : UInt
	{
		var length = 0;
		for ( classDescriptor in this._classDescriptors ) length += classDescriptor.length();
		return length;
	}

    public function addRuntimeTest( testableClass : Class<Dynamic> ) : Void
    {
        this._classDescriptors.push( this._parser.parse( testableClass ) );
    }
	
	macro public function addTest( ethis : haxe.macro.Expr, testableClass : ExprOf<Class<Dynamic>> )
    {
		var descriptor = ClassDescriptorGenerator.doGeneration( testableClass );
		return macro @:pos( ethis.pos ) $ethis.addDescriptor( $descriptor );
    }
	
	public function addDescriptor( classDescriptor : ClassDescriptor ) : Void
    {
        this._classDescriptors.push( classDescriptor );
    }

	public function addTestMethod( testableClass : Class<Dynamic>, methodName : String ) : Void
    {
		this._classDescriptors.push( this._parser.parseMethod( testableClass, methodName ) );
	}

    public function toString() return hex.util.Stringifier.stringify( this );

    /**
     * Event handling
     **/
	public function addListener( listener : ITestClassResultListener ) : Bool
    {
        return this.dispatcher.connect( listener );
    }

    public function removeListener( listener : ITestClassResultListener ) : Bool
    {
        return this.dispatcher.disconnect( listener );
    }

    public function onStartRun( descriptor : ClassDescriptor ): Void
    {
        this.dispatcher.onStartRun( descriptor );
    }

    public function onEndRun( descriptor : ClassDescriptor ) : Void
    {
		this.dispatcher.onEndRun( descriptor );
		
        if ( this._hasNextClassDescriptor() )
        {
			Assert.resetAssertionLog();
			
            this._runner.removeListener( this );
            this._runNext();
        }
        else
        {
            Assert.resetAssertionLog();
        }
    }

    public function onSuiteClassStartRun( descriptor : ClassDescriptor ) : Void
    {
       this.dispatcher.onSuiteClassStartRun( descriptor );
    }

    public function onSuiteClassEndRun( descriptor : ClassDescriptor ) : Void
    {
        this.dispatcher.onSuiteClassEndRun( descriptor );
    }

    public function onTestClassStartRun( descriptor : ClassDescriptor ) : Void
    {
        this.dispatcher.onTestClassStartRun( descriptor );
    }

    public function onTestClassEndRun( descriptor : ClassDescriptor ) : Void
    {
        this.dispatcher.onTestClassEndRun( descriptor );
    }

    public function onSuccess( descriptor : ClassDescriptor, timeElapsed : Float ) : Void
    {
        this.dispatcher.onSuccess( descriptor, timeElapsed );
    }

    public function onFail( descriptor : ClassDescriptor, timeElapsed : Float, error : Error ) : Void
    {
        this.dispatcher.onFail( descriptor, timeElapsed, error );
    }

    public function onTimeout( descriptor : ClassDescriptor, timeElapsed : Float, error : Error ) : Void
    {
        this.dispatcher.onTimeout( descriptor, timeElapsed, error );
    }

	public function onIgnore( descriptor : ClassDescriptor ) : Void 
	{
		this.dispatcher.onIgnore( descriptor );
	}

    /**
     *
     **/
    function _runNext() : Void
    {
        this._runner = new TestRunner( this._nextClassDescriptor() );
        this._runner.addListener( this );
        this._runner.run();
    }

    function _nextClassDescriptor() : ClassDescriptor
    {
        return this._classDescriptors[ this._currentClassDescriptor++ ];
    }

    function _hasNextClassDescriptor() : Bool
    {
        return this._currentClassDescriptor < this._classDescriptors.length;
    }
}

class UnitCoreTrigger implements ITestClassResultListener
{ 
	var _inputs : Array<ITestClassResultListener>;

	public function new() 
	{
		this._inputs = [];
	}

	public function connect( input : ITestClassResultListener ) : Bool
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

	public function disconnect( input : ITestClassResultListener ) : Bool
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
	
	public function onStartRun( descriptor : ClassDescriptor ) : Void
	{
		var inputs = this._inputs.copy();
		for ( input in inputs ) input.onStartRun( descriptor );
	}
	public function onEndRun( descriptor : ClassDescriptor ) : Void
	{
		var inputs = this._inputs.copy();
		for ( input in inputs ) input.onEndRun( descriptor );
	}

	public function onSuiteClassStartRun( descriptor : ClassDescriptor ) : Void
	{
		var inputs = this._inputs.copy();
		for ( input in inputs ) input.onSuiteClassStartRun( descriptor );
	}

	public function onSuiteClassEndRun( descriptor : ClassDescriptor ) : Void
	{
		var inputs = this._inputs.copy();
		for ( input in inputs ) input.onSuiteClassEndRun( descriptor );
	}

	public function onTestClassStartRun( descriptor : ClassDescriptor ) : Void
	{
		var inputs = this._inputs.copy();
		for ( input in inputs ) input.onTestClassStartRun( descriptor );
	}

	public function onTestClassEndRun( descriptor : ClassDescriptor ) : Void
	{
		var inputs = this._inputs.copy();
		for ( input in inputs ) input.onTestClassEndRun( descriptor );
	}
	
	public function onSuccess( descriptor : ClassDescriptor, timeElapsed : Float ) : Void
	{
		var inputs = this._inputs.copy();
		for ( input in inputs ) input.onSuccess( descriptor, timeElapsed );
	}
	
	public function onFail( descriptor : ClassDescriptor, timeElapsed : Float, error : Error ) : Void
	{
		var inputs = this._inputs.copy();
		for ( input in inputs ) input.onFail( descriptor, timeElapsed, error );
	}
	
	public function onTimeout( descriptor : ClassDescriptor, timeElapsed : Float, error : Error ) : Void
	{
		var inputs = this._inputs.copy();
		for ( input in inputs ) input.onTimeout( descriptor, timeElapsed, error );
	}
	
	public function onIgnore( descriptor : ClassDescriptor ) : Void 
	{
		var inputs = this._inputs.copy();
		for ( input in inputs ) input.onIgnore( descriptor );
	}
}