package hex.unittest.runner;

import hex.error.Exception;
import hex.util.Stringifier;
import hex.unittest.assertion.Assert;
import hex.unittest.description.ClassDescriptor;
import hex.unittest.event.ITestClassResultListener;
import hex.unittest.metadata.MetadataParser;

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
	
    public var dispatcher ( default, never ) : hex.event.ITrigger<ITestClassResultListener>;

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

    public function addTest( testableClass : Class<Dynamic> ) : Void
    {
        this._classDescriptors.push( this._parser.parse( testableClass ) );
    }
	
	#if genhexunit
	public function addDescriptor( classDescriptor : ClassDescriptor ) : Void
    {
        this._classDescriptors.push( classDescriptor );
    }
	#end
	
	public function addTestCollection( collection : Array<Class<Dynamic>> ) : Void
    {
		for ( testableClass in collection )
		{
			this.addTest( testableClass );
		}
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

    public function onFail( descriptor : ClassDescriptor, timeElapsed : Float, error : Exception ) : Void
    {
        this.dispatcher.onFail( descriptor, timeElapsed, error );
    }

    public function onTimeout( descriptor : ClassDescriptor, timeElapsed : Float, error : Exception ) : Void
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
