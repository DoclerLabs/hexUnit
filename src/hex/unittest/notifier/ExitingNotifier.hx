package hex.unittest.notifier;

import hex.error.Exception;
import hex.unittest.assertion.Assert;
import hex.unittest.description.ClassDescriptor;
import hex.unittest.event.ITestClassResultListener;

class ExitingNotifier implements ITestClassResultListener
{
    public function new() {}

    public function onStartRun( descriptor : ClassDescriptor ) : Void {}

    public function onEndRun( descriptor : ClassDescriptor ) : Void
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

    public function onSuiteClassStartRun( descriptor : ClassDescriptor ) : Void {}

    public function onSuiteClassEndRun( descriptor : ClassDescriptor ) : Void {}

    public function onTestClassStartRun( descriptor : ClassDescriptor ) : Void {}

    public function onTestClassEndRun( descriptor : ClassDescriptor ) : Void {}

    public function onSuccess( descriptor : ClassDescriptor, timeElapsed : Float ) : Void {}

    public function onFail( descriptor : ClassDescriptor, timeElapsed : Float, error : Exception ) : Void {}

    public function onTimeout( descriptor : ClassDescriptor, timeElapsed : Float, error : Exception ) : Void {}

	public function onIgnore( descriptor : ClassDescriptor ) : Void {}
}
