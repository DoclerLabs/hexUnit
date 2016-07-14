package hex.unittest.event;

/**
 * ...
 * @author Francis Bourre
 */
class EventSuite
{
	@Suite( "Event" )
    public var list : Array<Class<Dynamic>> = [ MethodRunnerEventTest, TestRunnerEventTest ];
}