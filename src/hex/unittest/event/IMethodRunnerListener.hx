package hex.unittest.event;

import hex.event.IEventListener;

/**
 * ...
 * @author Francis Bourre
 */
interface IMethodRunnerListener extends IEventListener
{
    function onSuccess( event : MethodRunnerEvent ) : Void;
    function onFail( event : MethodRunnerEvent ) : Void;
    function onTimeout( event : MethodRunnerEvent ) : Void;
    function onIgnore( event : MethodRunnerEvent ) : Void;
}