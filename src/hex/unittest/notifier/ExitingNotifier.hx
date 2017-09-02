package hex.unittest.notifier;

import hex.error.Exception;
import hex.unittest.assertion.Assert;
import hex.unittest.description.TestClassDescriptor;
import hex.unittest.event.ITestClassResultListener;

class ExitingNotifier implements ITestClassResultListener
{
    public function new() {}

    public function onStartRun( descriptor : TestClassDescriptor ) : Void {}

    public function onEndRun( descriptor : TestClassDescriptor ) : Void
    {
		if ( Assert.getAssertionFailedCount() > 0 )
		{
			#if flash
			flash.system.System.exit( 1 );
			#elseif ( php || neko )
			Sys.exit(1);
			#else
			throw ( new Exception( "Assertions failed: " + Assert.getAssertionFailedCount() ) );
			#end
		}

		#if flash
		flash.system.System.exit( 0 );
		#end
    }

    public function onSuiteClassStartRun( descriptor : TestClassDescriptor ) : Void {}

    public function onSuiteClassEndRun( descriptor : TestClassDescriptor ) : Void {}

    public function onTestClassStartRun( descriptor : TestClassDescriptor ) : Void {}

    public function onTestClassEndRun( descriptor : TestClassDescriptor ) : Void {}

    public function onSuccess( descriptor : TestClassDescriptor, timeElapsed : Float ) : Void {}

    public function onFail( descriptor : TestClassDescriptor, timeElapsed : Float, error : Exception ) : Void {}

    public function onTimeout( descriptor : TestClassDescriptor, timeElapsed : Float, error : Exception ) : Void {}

	public function onIgnore( descriptor : TestClassDescriptor ) : Void {}
}
