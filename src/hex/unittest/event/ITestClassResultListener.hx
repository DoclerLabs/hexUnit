package hex.unittest.event;

import hex.unittest.description.ClassDescriptor;
using tink.CoreApi;

/**
 * ...
 * @author Francis Bourre
 */
interface ITestClassResultListener
{
	function onStartRun( descriptor : ClassDescriptor ) : Void;
    function onEndRun( descriptor : ClassDescriptor ) : Void;
	
    function onSuiteClassStartRun( descriptor : ClassDescriptor ) : Void;
    function onSuiteClassEndRun( descriptor : ClassDescriptor ) : Void;
    function onTestClassStartRun( descriptor : ClassDescriptor ) : Void;
    function onTestClassEndRun( descriptor : ClassDescriptor ) : Void;
	
	function onSuccess( descriptor : ClassDescriptor, timeElapsed : Float ) : Void;
    function onFail( descriptor : ClassDescriptor, timeElapsed : Float, error : Error ) : Void;
    function onTimeout( descriptor : ClassDescriptor, timeElapsed : Float, error : Error ) : Void;
    function onIgnore( descriptor : ClassDescriptor ) : Void;
}