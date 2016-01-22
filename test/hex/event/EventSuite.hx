package hex.event;

/**
 * ...
 * @author Francis Bourre
 */
class EventSuite
{
	@Suite( "Event suite" )
    public var list : Array<Class<Dynamic>> = [MethodRunnerEventTest, TestRunnerEventTest];
}