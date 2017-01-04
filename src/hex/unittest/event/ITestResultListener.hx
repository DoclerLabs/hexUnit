package hex.unittest.event;

import hex.error.Exception;

/**
 * ...
 * @author Francis Bourre
 */
interface ITestResultListener
{
	function onSuccess( timeElapsed : Float ) : Void;
	function onFail( timeElapsed : Float, error : Exception ) : Void;
	function onTimeout( timeElapsed : Float ) : Void;
	function onIgnore( timeElapsed : Float ) : Void;
}