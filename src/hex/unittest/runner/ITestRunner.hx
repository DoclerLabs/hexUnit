package hex.unittest.runner;

import hex.unittest.event.ITestClassResultListener;

/**
 * ...
 * @author Francis Bourre
 */
interface ITestRunner extends IRunner
{
    function addListener( listener : ITestClassResultListener ) : Bool;
    function removeListener( listener : ITestClassResultListener ) : Bool;
}