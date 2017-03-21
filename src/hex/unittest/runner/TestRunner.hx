package hex.unittest.runner;

import haxe.Timer;
import haxe.ds.GenericStack;
import hex.error.Exception;
import hex.event.ITrigger;
import hex.event.ITriggerOwner;
import hex.unittest.description.TestClassDescriptor;
import hex.unittest.error.TimeoutException;
import hex.unittest.event.ITestClassResultListener;
import hex.unittest.event.ITestResultListener;

/**
 * ...
 * @author Francis Bourre
 */
class TestRunner implements ITestRunner 
	implements ITriggerOwner
	implements ITestResultListener 
{
    var _classDescriptors           : GenericStack<TestClassDescriptor>;
    var _executedDescriptors        : Map<TestClassDescriptor, Bool>;
	var _lastRender					: Float = 0;

    public var dispatcher ( default, never ) : ITrigger<ITestClassResultListener>;
	
	#if flash
	static public var RENDER_DELAY 			: Int = 150;
	#else
	static public var RENDER_DELAY			: Int = 0;
	#end

    public function new( classDescriptor : TestClassDescriptor )
    {
        this._classDescriptors          = new GenericStack<TestClassDescriptor>();
        this._executedDescriptors       = new Map<TestClassDescriptor, Bool>();
        this._classDescriptors.add( classDescriptor );
    }

    public function run() : Void
    {
        var classDescriptor : TestClassDescriptor = this._classDescriptors.first();
		this.dispatcher.onStartRun( classDescriptor );
        this._runClassDescriptor( this._classDescriptors.first() );
    }

    function _runClassDescriptor( classDescriptor : TestClassDescriptor ) : Void
    {
        if ( classDescriptor != null )
        {
            if ( classDescriptor.isSuiteClass )
            {
                if ( !this._executedDescriptors.exists( classDescriptor ) )
                {
                    this.dispatcher.onSuiteClassStartRun( classDescriptor );
                    this._executedDescriptors.set( classDescriptor, true );
                }

                this._runSuiteClass( classDescriptor );
            }
            else
            {
                if ( !this._executedDescriptors.exists( classDescriptor ) )
                {
                    this.dispatcher.onTestClassStartRun( classDescriptor );
                    classDescriptor.instance = Type.createEmptyInstance( classDescriptor.type );
                    this._executedDescriptors.set( classDescriptor, true );
                }

                this._tryToRunBeforeClass( classDescriptor );
                this._runTestClass( classDescriptor );
            }
        }
        else
        {
            this.dispatcher.onEndRun( classDescriptor  );
        }
    }

    function _runSuiteClass( classDescriptor : TestClassDescriptor ) : Void
    {
        if ( classDescriptor.hasNextClass() )
        {
            classDescriptor = classDescriptor.nextClass();
            this._classDescriptors.add( classDescriptor );
            this._runClassDescriptor( classDescriptor );
        }
        else
        {
            this.dispatcher.onSuiteClassEndRun( classDescriptor );
            this._classDescriptors.pop();
            this._runClassDescriptor( this._classDescriptors.first() );
        }
    }

    function _runTestClass( classDescriptor : TestClassDescriptor ) : Void
    {
        if ( classDescriptor.hasNextMethod() )
        {
            this._tryToRunSetUp( classDescriptor );
            var methodRunner = new MethodRunner( classDescriptor.instance, classDescriptor.nextMethod() );
            methodRunner.addListener( this );
            methodRunner.run();
        }
        else
        {
            this.dispatcher.onTestClassEndRun( classDescriptor );
            this._tryToRunAfterClass( classDescriptor );
            this._classDescriptors.pop();
            this._runClassDescriptor( this._classDescriptors.first() );
        }
    }

    function _tryToRunSetUp( classDescriptor : TestClassDescriptor ) : Void
    {
        if ( classDescriptor.setUpFieldName != null )
        {
            Reflect.callMethod( classDescriptor.instance, Reflect.field( classDescriptor.instance, classDescriptor.setUpFieldName ), [] );
        }
    }

    function _tryToRunTearDown( classDescriptor : TestClassDescriptor ) : Void
    {
        if ( classDescriptor.tearDownFieldName != null )
        {
            Reflect.callMethod( classDescriptor.instance, Reflect.field( classDescriptor.instance, classDescriptor.tearDownFieldName ), [] );
        }
    }

    function _tryToRunBeforeClass( classDescriptor : TestClassDescriptor ) : Void
    {
        if ( classDescriptor.beforeClassFieldName != null )
        {
           Reflect.callMethod( classDescriptor.type, Reflect.field( classDescriptor.type, classDescriptor.beforeClassFieldName ), [] );
        }
    }

    function _tryToRunAfterClass( classDescriptor : TestClassDescriptor ) : Void
    {
        if ( classDescriptor.afterClassFieldName != null )
        {
            Reflect.callMethod( classDescriptor.type, Reflect.field( classDescriptor.type, classDescriptor.afterClassFieldName ), [] );
        }
    }

    public function addListener( listener : ITestClassResultListener ) : Bool
    {
        return this.dispatcher.connect( listener );
    }

    public function removeListener( listener : ITestClassResultListener ) : Bool
    {
        return this.dispatcher.disconnect( listener );
    }

    /**
     *
     **/
    public function onSuccess( timeElapsed : Float ) : Void
    {
		var classDescriptor = this._classDescriptors.first();
		this.dispatcher.onSuccess( classDescriptor, timeElapsed );
        this._endTestMethodCall( classDescriptor );
    }

    public function onFail( timeElapsed : Float, error : Exception ) : Void
    {
		var classDescriptor = this._classDescriptors.first();
		this.dispatcher.onFail( classDescriptor, timeElapsed, error );
        this._endTestMethodCall( classDescriptor );
    }

    public function onTimeout( timeElapsed : Float ) : Void
    {
		var classDescriptor = this._classDescriptors.first();
		this.dispatcher.onTimeout( classDescriptor, timeElapsed, new TimeoutException() );
        this._endTestMethodCall( classDescriptor );
    }
	
	public function onIgnore( timeElapsed : Float) : Void
	{
		var classDescriptor = this._classDescriptors.first();
		this.dispatcher.onIgnore( classDescriptor );
		this._endTestMethodCall( classDescriptor );
	}

    function _endTestMethodCall( classDescriptor: TestClassDescriptor ) : Void
    {
        this._tryToRunTearDown( classDescriptor );

		if ( TestRunner.RENDER_DELAY > 0 && Date.now().getTime() - this._lastRender > TestRunner.RENDER_DELAY )
		{
			this._lastRender = Date.now().getTime() + 1;
			Timer.delay( function( ) { _runTestClass( classDescriptor ); }, 1 );
		}
		else
		{
			this._lastRender = Date.now().getTime() + TestRunner.RENDER_DELAY;
			Timer.delay( function( ) { _runTestClass( classDescriptor ); }, TestRunner.RENDER_DELAY );
		}
    }
}
