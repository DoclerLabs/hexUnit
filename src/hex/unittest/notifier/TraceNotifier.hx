package hex.unittest.notifier;

import hex.error.Exception;
import hex.event.IEvent;
import hex.unittest.assertion.Assert;
import hex.unittest.description.TestMethodDescriptor;
import hex.unittest.error.AssertException;
import hex.unittest.event.ITestRunnerListener;
import hex.unittest.event.TestRunnerEvent;

/**
 * ...
 * @author Francis Bourre
 */
class TraceNotifier implements ITestRunnerListener
{
    private var _tabs   			: String;
    private var _errorBubbling   	: Bool;

    public function new( errorBubbling : Bool = false )
    {
		this._errorBubbling = errorBubbling;
    }

    private function _log( message : String ) : Void
    {
        trace( this._tabs + message );
    }

    private function _addTab() : Void
    {
        this._tabs += "\t";
    }

    private function _removeTab() : Void
    {
        this._tabs = this._tabs.substr( 0, this._tabs.length-1 );
    }

    public function onStartRun( e : TestRunnerEvent ) : Void
    {
        this._tabs = "";
        this._log( "<<< Start " + e.getDescriptor().className + " tests run >>>" );
        this._addTab();
    }

    public function onEndRun( e : TestRunnerEvent ) : Void
    {
        this._removeTab();
        this._log( "<<< End tests run >>>" );
        this._log( "Assertions passed: " + Assert.getAssertionCount() + "\n" );
		
		if ( Assert.getAssertionFailedCount() > 0 )
		{
			this._log( "Assertions failed: " + Assert.getAssertionFailedCount() + "\n" );
			throw ( new Exception( "Assertions failed: " + Assert.getAssertionFailedCount() ) );
		}
		
		#if flash
		flash.system.System.exit( 0 );
		#end
    }

    public function onSuiteClassStartRun( e : TestRunnerEvent ) : Void
    {
        this._log( "Suite class '" + e.getDescriptor().getName() + "'" );
        this._addTab();
    }

    public function onSuiteClassEndRun( e : TestRunnerEvent ) : Void
    {
        this._removeTab();
    }

    public function onTestClassStartRun( e : TestRunnerEvent ) : Void
    {
        this._log( "Test class '" + e.getDescriptor().className + "'" );
        this._addTab();
    }

    public function onTestClassEndRun( e : TestRunnerEvent ) : Void
    {
        this._removeTab();
    }

    public function onSuccess( e : TestRunnerEvent ) : Void
    {
        var methodDescriptor : TestMethodDescriptor = e.getDescriptor().currentMethodDescriptor();
        var description : String = methodDescriptor.description;
        var timeElapsed : String = e.getTimeElapsed() + "ms";
        var message : String = "* [" + methodDescriptor.methodName + "] " + ( description.length > 0 ? description : "" ) + timeElapsed;
        this._log( message );
    }

    public function onFail( e : TestRunnerEvent ) : Void
    {
        var methodDescriptor : TestMethodDescriptor = e.getDescriptor().currentMethodDescriptor();
        var description : String = methodDescriptor.description;
        var message : String = "* [" + methodDescriptor.methodName + "] " + ( description.length > 0 ? description : "." );
        this._log( message );
        this._addTab();
        this._log( e.getError().toString() );
        this._log( e.getError().message + ": " + ( Std.is( e.getError(), AssertException ) ? ": " + Assert.getLastAssertionLog() : "" ) );
        this._removeTab();
		
		if ( this._errorBubbling )
		{
			throw( e.getError() );
		}
    }

    public function onTimeout( e : TestRunnerEvent ) : Void
    {
        var methodDescriptor : TestMethodDescriptor = e.getDescriptor().currentMethodDescriptor();
        var description : String = methodDescriptor.description;
        var message : String = "* [" + methodDescriptor.methodName + "] " + ( description.length > 0 ? description : "." );
        this._log( message );
        this._addTab();
        this._log( e.getError().message );
        this._removeTab();
    }
	
	public function handleEvent( e : IEvent ) : Void
	{
		
	}
}
