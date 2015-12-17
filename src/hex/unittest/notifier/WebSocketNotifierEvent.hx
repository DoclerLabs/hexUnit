package hex.unittest.notifier;

import hex.event.BasicEvent;

/**
 * ...
 * @author ...
 */
class WebSocketNotifierEvent extends BasicEvent
{
	public static inline var CONNECTED:String = "connected";

	public function new(type:String, target:Dynamic) 
	{
		super(type, target);
		
	}
	
}