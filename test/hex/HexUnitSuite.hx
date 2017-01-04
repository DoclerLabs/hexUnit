package hex;

import hex.unittest.assertion.AssertionSuite;

/**
 * ...
 * @author Francis Bourre
 */
class HexUnitSuite
{
	@Suite( "HexUnit suite" )
    public var list : Array<Class<Dynamic>> = [ AssertionSuite, TestCaseTest, DataProviderTest ];
}