package hex.unittest.runner;

import hex.unittest.event.IMethodRunnerListener;

/**
 * ...
 * @author Francis Bourre
 */
interface ITestClassRunner extends IRunner
{
    function addListener( listener : IMethodRunnerListener ) : Bool;
    function removeListener( listener : IMethodRunnerListener ) : Bool;
}
