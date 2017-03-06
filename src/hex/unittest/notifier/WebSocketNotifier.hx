package hex.unittest.notifier;

#if js
import haxe.Json;
import hex.data.GUID;
import hex.error.Exception;
import hex.event.ITrigger;
import hex.event.ITriggerOwner;
import hex.unittest.assertion.Assert;
import hex.unittest.description.TestClassDescriptor;
import hex.unittest.event.ITestClassResultListener;
import js.html.CloseEvent;
import js.html.Event;
import js.html.WebSocket;

/**
 * ...
 * @author ...
 */
class WebSocketNotifier 
	implements ITriggerOwner
	implements ITestClassResultListener
{
	static public inline var version : String = "0.1.1";
	
	var _url		: String;
	var _webSocket	: WebSocket;
	var _clientId	: String;

    public var dispatcher ( default, never ) : ITrigger<IWebSocketNotifierListener>;
	
	var _cache 			= new Array<String>();
	var _connected:Bool = false;
	var netTimeElapsed	: Float;

	public function new( url : String ) 
	{
		this._url = url;
		this._clientId = this.generateUUID();
		this._connect();
	}
	
	public function addListener( listener : IWebSocketNotifierListener ):Void
	{
		this.dispatcher.connect( listener );
	}
	
	public function removeListener( listener : IWebSocketNotifierListener ):Void
	{
		this.dispatcher.disconnect( listener );
	}
	
	function _connect() : Void
	{
		trace( "WebSocketServiceJS._connect", this._url );
		this._webSocket = new WebSocket( this._url );
		this._addWebSocketListeners( this._webSocket );
	}
	
	function _close() : Void
	{
		this._webSocket.close(0,"testOver");
		this._removeWebSocketListeners(this._webSocket);
	}
	
	function _addWebSocketListeners( webSocket : WebSocket ) : Void
	{
		webSocket.addEventListener( "open", this.onOpen );
		webSocket.addEventListener( "close", this.onClose );
		webSocket.addEventListener( "error", this.onError );
		webSocket.addEventListener( "message", this.onMessage );
	}
	
	function _removeWebSocketListeners( webSocket : WebSocket ) : Void
	{
		webSocket.removeEventListener( "open", this.onOpen );
		webSocket.removeEventListener( "close", this.onClose );
		webSocket.removeEventListener( "error", this.onError );
		webSocket.removeEventListener( "message", this.onMessage );
	}
	
	function onOpen( e : Event ) : Void 
	{
		trace( "WebSocketServiceJS.onOpen" );
		
		this.dispatcher.onConnect( this );
		this._connected = true;
		
		this.flush( );
	}
	
	function flush() : Void
	{
		var l = this._cache.length;
		for ( i in 0 ... l ) 
		{
			this._webSocket.send( this._cache[i] );
		}
		
		this._cache = new Array<String>();
	}
	
	function onClose( e : CloseEvent ) : Void 
	{
		trace( "WebSocketNotifier.onClose", e.reason, e.code );
		this._connected = false;
	}
	
	function onError( e : Event ) : Void 
	{
		trace( "WebSocketNotifier.onError", e );
	}
	
	function onMessage( e : Event ) : Void 
	{
		trace("WebSocketNotifier.onMessage");
	}
	
	function sendMessage( messageType : String, data : Dynamic ) : Void
	{
		var message = 
		{
			messageId: this.generateUUID(),
			clientType: "webSocketTestNotifier",
			clientVersion: WebSocketNotifier.version,
			clientId: this._clientId,
			messageType: messageType,
			data: data
		};
		
		var stringified = Json.stringify( message );
		
		if ( this._connected )
		{
			this._webSocket.send( stringified );
		}
		else
		{
			this._cache.push( stringified );
		}
	}
	
	public function onStartRun( descriptor : TestClassDescriptor ) : Void
	{
		this.netTimeElapsed = 0;
		this.sendMessage( "startRun", {} );
	}
	
	public function onEndRun( descriptor : TestClassDescriptor ) : Void
	{
		var data = 
		{ 
			successfulAssertionCount: Assert.getAssertionCount() - Assert.getAssertionFailedCount(),
			assertionFailedCount: Assert.getAssertionFailedCount(),
			assertionCount: Assert.getAssertionCount(),
			timeElapsed: this.netTimeElapsed
		}
		
		this.sendMessage( "endRun", data  );
	}
	
	public function onSuccess( descriptor : TestClassDescriptor, timeElapsed : Float ) : Void 
	{
		var methodDescriptor = descriptor.currentMethodDescriptor();
		
		var data = 
		{
			className: descriptor.className,
			methodName: methodDescriptor.methodName,
			description: methodDescriptor.description,
			isAsync: methodDescriptor.isAsync,
			isIgnored: methodDescriptor.isIgnored,
			timeElapsed: timeElapsed,


			fileName: "under_construction",
			lineNumber: 0
		};
		
		this.netTimeElapsed += timeElapsed;
		this.sendMessage( "testCaseRunSuccess", data );
	}
	
	public function onFail( descriptor : TestClassDescriptor, timeElapsed : Float, error : Exception ) : Void
	{
		var methodDescriptor = descriptor.currentMethodDescriptor();
		
		var data = 
		{
			className: descriptor.className,
			methodName: methodDescriptor.methodName,
			description: methodDescriptor.description,
			isAsync: methodDescriptor.isAsync,
			isIgnored: methodDescriptor.isIgnored,
			timeElasped: timeElapsed,


			fileName: error.posInfos != null ? error.posInfos.fileName : "unknown",
			lineNumber: error.posInfos != null ? error.posInfos.lineNumber : 0,

			success: false,
			errorMsg: error.message 
		};
			
		this.netTimeElapsed += timeElapsed;

		this.sendMessage( "testCaseRunFailed", data );
	}
	
	public function onTimeout( descriptor : TestClassDescriptor, timeElapsed : Float, error : Exception ) : Void
	{
		this.onFail( descriptor, timeElapsed, error );
	}
	
	public function onIgnore( descriptor : TestClassDescriptor ) : Void
	{
		this.onSuccess( descriptor, 0 );
	}
	
	public function onSuiteClassStartRun( descriptor : TestClassDescriptor ) : Void
	{
		var data = 
		{
			className: descriptor.className,
			suiteName: descriptor.getName()
		};
		
		this.sendMessage( "testSuiteStartRun", data );
	}
	
	public function onSuiteClassEndRun( descriptor : TestClassDescriptor ) : Void
	{
		this.sendMessage( "testSuiteEndRun", {} );
	}
	
	public function onTestClassStartRun( descriptor : TestClassDescriptor ) : Void 
	{
		var data = 
		{
			className: descriptor.className
		};
		
		this.sendMessage( "testClassStartRun", data );
	}
	
	public function onTestClassEndRun( descriptor : TestClassDescriptor ) : Void
	{
		this.sendMessage( "testClassEndRun", {} );
	}
	
	function generateUUID() : String
	{
		return GUID.uuid();
	}
}
#end