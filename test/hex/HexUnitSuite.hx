package hex;

import hex.unittest.assertion.AssertionSuite;
import hex.unittest.runner.RunnerSuite;

/**
 * ...
 * @author Francis Bourre
 */
class HexUnitSuite
{
	@Suite( "HexUnit suite" )
    public var list : Array<Class<Dynamic>> = [ AssertionSuite, TestCaseTest, DataProviderTest, RunnerSuite ];
}