package hex.unittest.event;

import hex.error.Exception;
import hex.unittest.description.TestClassDescriptor;

/**
 * ...
 * @author Francis Bourre
 */
interface ITestClassResultListener
{
	function onStartRun( descriptor : TestClassDescriptor ) : Void;
    function onEndRun( descriptor : TestClassDescriptor ) : Void;
	
    function onSuiteClassStartRun( descriptor : TestClassDescriptor ) : Void;
    function onSuiteClassEndRun( descriptor : TestClassDescriptor ) : Void;
    function onTestClassStartRun( descriptor : TestClassDescriptor ) : Void;
    function onTestClassEndRun( descriptor : TestClassDescriptor ) : Void;
	
	function onSuccess( descriptor : TestClassDescriptor, ?timeElapsed : Float, ?error : Exception ) : Void;
    function onFail( descriptor : TestClassDescriptor, ?timeElapsed : Float, ?error : Exception ) : Void;
    function onTimeout( descriptor : TestClassDescriptor, ?timeElapsed : Float, ?error : Exception ) : Void;
    function onIgnore( descriptor : TestClassDescriptor, ?timeElapsed : Float, ?error : Exception ) : Void;
}