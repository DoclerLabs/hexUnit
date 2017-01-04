package hex.unittest.runner;

import hex.unittest.event.ITestClassResult;

/**
 * ...
 * @author Francis Bourre
 */
interface ITestRunner extends IRunner
{
    function addListener( listener : ITestClassResult ) : Bool;
    function removeListener( listener : ITestClassResult ) : Bool;
}