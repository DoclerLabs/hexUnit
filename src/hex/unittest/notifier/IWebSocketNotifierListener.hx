package hex.unittest.notifier;

#if js
/**
 * @author Francis Bourre
 */
interface IWebSocketNotifierListener 
{
	function onConnect( notifier: WebSocketNotifier ) : Void;
}
#end
