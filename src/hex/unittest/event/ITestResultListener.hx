package hex.unittest.event;

using tink.CoreApi;

/**
 * ...
 * @author Francis Bourre
 */
interface ITestResultListener
{
	function onSuccess( timeElapsed : Float ) : Void;
	function onFail( timeElapsed : Float, error : Error ) : Void;
	function onTimeout( timeElapsed : Float ) : Void;
	function onIgnore( timeElapsed : Float ) : Void;
}