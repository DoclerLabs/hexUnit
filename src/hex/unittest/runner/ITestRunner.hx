package hex.unittest.runner;

import hex.unittest.event.ITestRunnerListener;

/**
 * ...
 * @author Francis Bourre
 */
interface ITestRunner extends IRunner
{
    function addListener( listener : ITestRunnerListener ) : Bool;
    function removeListener( listener : ITestRunnerListener ) : Bool;
}