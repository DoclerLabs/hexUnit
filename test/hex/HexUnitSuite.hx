package hex;

import hex.unittest.assertion.AssertionSuite;
import hex.unittest.event.EventSuite;

/**
 * ...
 * @author Francis Bourre
 */
class HexUnitSuite
{
	@Suite( "HexUnit suite" )
    public var list : Array<Class<Dynamic>> = [ AssertionSuite, EventSuite, TestCaseTest, DataProviderTest ];
}