package hex.unittest.notifier;

import hex.unittest.assertion.Assert;
import hex.unittest.description.ClassDescriptor;
import hex.unittest.event.ITestClassResultListener;
using tink.CoreApi;

class ExitingNotifier implements ITestClassResultListener
{
    public function new() {}

    public function onStartRun( descriptor : ClassDescriptor ) : Void {}

    public function onEndRun( descriptor : ClassDescriptor ) : Void
    {
		if ( Assert.getAssertionFailedCount() > 0 )
		{
			#if travix
			travix.Logger.exit( 1 );
			#elseif flash
			flash.system.System.exit( 1 );
			#elseif ( php || neko )
			Sys.exit(1);
			#else
			throw ( new Error( "Assertions failed: " + Assert.getAssertionFailedCount() ) );
			#end
		}

		#if flash
		flash.system.System.exit( 0 );
		#elseif travix
		travix.Logger.exit( 0 );
		#end
    }

    public function onSuiteClassStartRun( descriptor : ClassDescriptor ) : Void {}

    public function onSuiteClassEndRun( descriptor : ClassDescriptor ) : Void {}

    public function onTestClassStartRun( descriptor : ClassDescriptor ) : Void {}

    public function onTestClassEndRun( descriptor : ClassDescriptor ) : Void {}

    public function onSuccess( descriptor : ClassDescriptor, timeElapsed : Float ) : Void {}

    public function onFail( descriptor : ClassDescriptor, timeElapsed : Float, error : Error ) : Void {}

    public function onTimeout( descriptor : ClassDescriptor, timeElapsed : Float, error : Error ) : Void {}

	public function onIgnore( descriptor : ClassDescriptor ) : Void {}
}
