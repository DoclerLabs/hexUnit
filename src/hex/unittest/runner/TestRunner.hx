package hex.unittest.runner;

import haxe.Timer;
import hex.event.BasicEvent;
import hex.event.IEvent;
import hex.event.LightweightListenerDispatcher;
import hex.unittest.description.TestMethodDescriptor;
import haxe.ds.GenericStack;
import hex.unittest.event.MethodRunnerEvent;
import hex.unittest.event.IMethodRunnerListener;
import hex.unittest.event.TestRunnerEvent;
import hex.unittest.description.TestClassDescriptor;

import hex.unittest.event.ITestRunnerListener;

/**
 * ...
 * @author Francis Bourre
 */
class TestRunner implements ITestRunner implements IMethodRunnerListener
{
    private var _dispatcher                 : LightweightListenerDispatcher<ITestRunnerListener, TestRunnerEvent>;
    private var _classDescriptors           : GenericStack<TestClassDescriptor>;
    private var _executedDescriptors        : Map<TestClassDescriptor, Bool>;

    public function new( classDescriptor : TestClassDescriptor )
    {
        this._classDescriptors          = new GenericStack<TestClassDescriptor>();
        this._dispatcher                = new LightweightListenerDispatcher<ITestRunnerListener, TestRunnerEvent>();
        this._executedDescriptors       = new Map<TestClassDescriptor, Bool>();

        this._classDescriptors.add( classDescriptor );
    }

    public function run() : Void
    {
        var classDescriptor : TestClassDescriptor = this._classDescriptors.first();
        this._dispatcher.dispatchEvent( new TestRunnerEvent( TestRunnerEvent.START_RUN, this, classDescriptor ) );
        this._runClassDescriptor( this._classDescriptors.first() );
    }

    private function _runClassDescriptor( classDescriptor : TestClassDescriptor ) : Void
    {
        if ( classDescriptor != null )
        {
            if ( classDescriptor.isSuiteClass )
            {
                if ( !this._executedDescriptors.exists( classDescriptor ) )
                {
                    this._dispatcher.dispatchEvent( new TestRunnerEvent( TestRunnerEvent.SUITE_CLASS_START_RUN, this, classDescriptor ) );
                    this._executedDescriptors.set( classDescriptor, true );
                }

                this._runSuiteClass( classDescriptor );
            }
            else
            {
                if ( !this._executedDescriptors.exists( classDescriptor ) )
                {
                    this._dispatcher.dispatchEvent( new TestRunnerEvent( TestRunnerEvent.TEST_CLASS_START_RUN, this, classDescriptor ) );
                    classDescriptor.instance = Type.createInstance( classDescriptor.type, [] );
                    this._executedDescriptors.set( classDescriptor, true );
                }

                this._tryToRunBeforeClass( classDescriptor );
                this._runTestClass( classDescriptor );
            }
        }
        else
        {
            this._dispatcher.dispatchEvent( new TestRunnerEvent( TestRunnerEvent.END_RUN, this, classDescriptor ) );
        }
    }

    private function _runSuiteClass( classDescriptor : TestClassDescriptor ) : Void
    {
        if ( classDescriptor.hasNextClass() )
        {
            classDescriptor = classDescriptor.nextClass();
            this._classDescriptors.add( classDescriptor );
            this._runClassDescriptor( classDescriptor );
        }
        else
        {
            this._dispatcher.dispatchEvent( new TestRunnerEvent( TestRunnerEvent.SUITE_CLASS_END_RUN, this, classDescriptor ) );
            this._classDescriptors.pop();
            this._runClassDescriptor( this._classDescriptors.first() );
        }
    }

    private function _runTestClass( classDescriptor : TestClassDescriptor ) : Void
    {
        if ( classDescriptor.hasNextMethod() )
        {
            this._tryToRunSetUp( classDescriptor );
            var methodRunner : MethodRunner = new MethodRunner( classDescriptor.instance, classDescriptor.nextMethod() );
            methodRunner.addListener( this );
            methodRunner.run();
        }
        else
        {
            this._dispatcher.dispatchEvent( new TestRunnerEvent( TestRunnerEvent.TEST_CLASS_END_RUN, this, classDescriptor ) );
            this._tryToRunAfterClass( classDescriptor );
            this._classDescriptors.pop();
            this._runClassDescriptor( this._classDescriptors.first() );
        }
    }

    private function _tryToRunSetUp( classDescriptor : TestClassDescriptor ) : Void
    {
        if ( classDescriptor.setUp )
        {
            Reflect.callMethod( classDescriptor.instance, classDescriptor.setUp, [] );
        }
    }

    private function _tryToRunTearDown( classDescriptor : TestClassDescriptor ) : Void
    {
        if ( classDescriptor.tearDown )
        {
            Reflect.callMethod( classDescriptor.instance, classDescriptor.tearDown, [] );
        }
    }

    private function _tryToRunBeforeClass( classDescriptor : TestClassDescriptor ) : Void
    {
        if ( classDescriptor.beforeClass )
        {
            Reflect.callMethod( classDescriptor.type, classDescriptor.beforeClass, [] );
        }
    }

    private function _tryToRunAfterClass( classDescriptor : TestClassDescriptor ) : Void
    {
        if ( classDescriptor.afterClass )
        {
            Reflect.callMethod( classDescriptor.type, classDescriptor.afterClass, [] );
        }
    }

    public function addListener( listener : ITestRunnerListener ) : Bool
    {
        return this._dispatcher.addListener( listener );
    }

    public function removeListener( listener : ITestRunnerListener ) : Bool
    {
        return this._dispatcher.removeListener( listener );
    }

    /**
     *
     **/
	public function handleEvent( e : IEvent ) : Void
	{
		
	}
	
    public function onSuccess( e : MethodRunnerEvent ) : Void
    {
        this._endTestMethodCall( e, TestRunnerEvent.SUCCESS );
    }

    public function onFail( e : MethodRunnerEvent ) : Void
    {
        this._endTestMethodCall( e, TestRunnerEvent.FAIL );
    }

    public function onTimeout( e : MethodRunnerEvent ) : Void
    {
        this._endTestMethodCall( e, TestRunnerEvent.TIMEOUT );
    }

    private function _endTestMethodCall( e : MethodRunnerEvent, eventType : String ) : Void
    {
        var classDescriptor : TestClassDescriptor = this._classDescriptors.first();
        this._dispatcher.dispatchEvent( new TestRunnerEvent( eventType, this, classDescriptor, e.getTimeElapsed(), e.getError() ) );
        this._tryToRunTearDown( classDescriptor );
		
		Timer.delay( function( ) { _runTestClass( classDescriptor ); }, 1 );
    }
}
