package hex.event;

/**
 * ...
 * @author Francis Bourre
 */
class EventSuite
{
	@suite( "Event suite" )
    public var list : Array<Class<Dynamic>> = [MethodRunnerEventTest, TestRunnerEventTest];
}