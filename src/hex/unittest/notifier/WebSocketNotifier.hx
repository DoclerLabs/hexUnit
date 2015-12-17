package hex.unittest.notifier;

import haxe.Json;
import hex.event.IEvent;
import hex.event.LightweightClosureDispatcher;
import hex.unittest.description.TestMethodDescriptor;
import hex.unittest.event.ITestRunnerListener;
import hex.unittest.event.TestRunnerEvent;
import js.html.CloseEvent;
import js.html.Event;
import js.html.WebSocket;

/**
 * ...
 * @author ...
 */
class WebSocketNotifier implements ITestRunnerListener
{
	private var _url:String;
	private var _webSocket:WebSocket;
	private var _clientId:String;
	
	private var _dispatcher:LightweightClosureDispatcher<WebSocketNotifierEvent>;

	public function new(url:String) 
	{
		this._url = url;
		this._clientId = this.generateUUID();
		this._connect( );
	}
	
	public function addEventListener( eventType:String, callback:WebSocketNotifierEvent->Void ):Void
	{
		this._dispatcher.addEventListener( eventType, callback );
	}
	
	private function _connect():Void
	{
		this._webSocket = new WebSocket(this._url);
		this._addWebSocketListeners( this._webSocket );
	}
	
	private function _close():Void
	{
		this._webSocket.close(0,"testOver");
		this._removeWebSocketListeners(this._webSocket);
	}
	
	private function _addWebSocketListeners( webSocket:WebSocket ):Void
	{
		webSocket.addEventListener( "open", this.onOpen );
		webSocket.addEventListener( "close", this.onClose );
		webSocket.addEventListener( "error", this.onError );
		webSocket.addEventListener( "message", this.onMessage );
	}
	
	private function _removeWebSocketListeners( webSocket:WebSocket ):Void
	{
		webSocket.removeEventListener( "open", this.onOpen );
		webSocket.removeEventListener( "close", this.onClose );
		webSocket.removeEventListener( "error", this.onError );
		webSocket.removeEventListener( "message", this.onMessage );
	}
	
	private function onOpen(e:Event):Void 
	{
		trace("WebSocketServiceJS.onOpen");
		
		this._dispatcher.dispatchEvent(new WebSocketNotifierEvent(WebSocketNotifierEvent.CONNECTED, this));
		//TODO: dispatch when it'c ready
	}
	
	private function onClose(e:CloseEvent):Void 
	{
		trace("WebSocketNotifier.onClose", e.reason, e.code);
	}
	
	private function onError(e:Event):Void 
	{
		trace("WebSocketNotifier.onError", e);
	}
	
	private function onMessage(e:Event):Void 
	{
		trace("WebSocketNotifier.onMessage");
	}
	
	private function sendMessage( messageType:String, data:Dynamic ):Void
	{
		var message:Dynamic = {
			messageId: this.generateUUID(),
			clientType: "webSocketTestNotifier",
			clientId: this._clientId,
			messageType: messageType,
			data: data
		};
		
		this._webSocket.send( Json.stringify(message) );
	}
	
	/* INTERFACE hex.unittest.event.ITestRunnerListener */
	
	public function onStartRun(event:TestRunnerEvent):Void 
	{
		this.sendMessage( "startRun", {} );
	}
	
	public function onEndRun(event:TestRunnerEvent):Void 
	{
		this.sendMessage( "endRun", {} );
	}
	
	public function onSuccess(event:TestRunnerEvent):Void 
	{
		var methodDescriptor : TestMethodDescriptor = event.getDescriptor().currentMethodDescriptor();
		
		var data:Dynamic = {
			className: event.getDescriptor().className,
			methodName: methodDescriptor.methodName,
			description: methodDescriptor.description,
			isAsync: methodDescriptor.isAsync,
			isIgnored: methodDescriptor.isIgnored,


			fileName: "under_construction",
			lineNumber:0
		};

		this.sendMessage( "testCaseRunSuccess", data );
	}
	
	public function onFail(event:TestRunnerEvent):Void 
	{
		var methodDescriptor : TestMethodDescriptor = event.getDescriptor().currentMethodDescriptor();
		
		var data:Dynamic = {
			className: event.getDescriptor().className,
			methodName: methodDescriptor.methodName,
			description: methodDescriptor.description,
			isAsync: methodDescriptor.isAsync,
			isIgnored: methodDescriptor.isIgnored,


			fileName: event.getError().posInfos.fileName,
			lineNumber: event.getError().posInfos.lineNumber,

			success: false,
			errorMsg: event.getError().message };

		this.sendMessage( "testCaseRunFailed", data );
	}
	
	public function onTimeout(event:TestRunnerEvent):Void 
	{
		
	}
	
	public function onSuiteClassStartRun(event:TestRunnerEvent):Void 
	{
		
	}
	
	public function onSuiteClassEndRun(event:TestRunnerEvent):Void 
	{
		
	}
	
	public function onTestClassStartRun(event:TestRunnerEvent):Void 
	{
		
	}
	
	public function onTestClassEndRun(event:TestRunnerEvent):Void 
	{
		
	}
	
	public function handleEvent(e:IEvent):Void 
	{
		
	}
	
	private function generateUUID():String
	{
		var text:String = "";
		var possible:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

		for (i in 0...10) 
		{		
			text += possible.charAt(Math.floor(Math.random() * possible.length));
		}

		return text;
	}
}