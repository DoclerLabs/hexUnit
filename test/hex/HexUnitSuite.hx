package hex;

import hex.event.EventSuite;

/**
 * ...
 * @author Francis Bourre
 */
class HexUnitSuite
{
	@suite( "HexUnit suite" )
    public var list : Array<Class<Dynamic>> = [EventSuite];
}