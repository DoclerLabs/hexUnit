package hex.unittest.notifier;

/**
 * @author Francis Bourre
 */
interface IWebSocketNotifierListener 
{
	function onConnect( notifier: WebSocketNotifier ) : Void;
}