package hex.unittest.event;
import hex.event.IEventListener;

/**
 * ...
 * @author Francis Bourre
 */
interface ITestRunnerListener extends IEventListener
{
    function onStartRun( event : TestRunnerEvent ) : Void;
    function onEndRun( event : TestRunnerEvent ) : Void;

    function onSuccess( event : TestRunnerEvent ) : Void;
    function onFail( event : TestRunnerEvent ) : Void;
    function onTimeout( event : TestRunnerEvent ) : Void;
    function onIgnore( event : TestRunnerEvent ) : Void;

    function onSuiteClassStartRun( event : TestRunnerEvent ) : Void;
    function onSuiteClassEndRun( event : TestRunnerEvent ) : Void;
    function onTestClassStartRun( event : TestRunnerEvent ) : Void;
    function onTestClassEndRun( event : TestRunnerEvent ) : Void;
}
