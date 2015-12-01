package hex.unittest.event;

import hex.unittest.description.TestMethodDescriptor;
import hex.unittest.runner.MethodRunner;
import hex.error.Exception;
import hex.event.BasicEvent;

/**
 * ...
 * @author Francis Bourre
 */
class MethodRunnerEvent extends BasicEvent
{
    public static inline var SUCCESS    : String = "onSuccess";
    public static inline var FAIL       : String = "onFail";
    public static inline var TIMEOUT    : String = "onTimeout";
    public static inline var START_RUN  : String = "onStartRun";
    public static inline var END_RUN    : String = "onEndRun";

    private var _descriptor             : TestMethodDescriptor;
    private var _timeElapsed            : Float;
    private var _error                  : Exception;

    public function new ( type : String, target : MethodRunner, descriptor : TestMethodDescriptor, timeElapsed : Float, ?error : Exception )
    {
        super( type, target );

        this._descriptor    = descriptor;
        this._timeElapsed   = timeElapsed;
        this._error         = error;
    }

    public function getRunner() : MethodRunner
    {
        return this.target;
    }

    public function getDescriptor() : TestMethodDescriptor
    {
        return this._descriptor;
    }

    public function getError() : Exception
    {
        return this._error;
    }

    public function getTimeElapsed() : Float
    {
        return this._timeElapsed;
    }
	
	override public function clone() : BasicEvent
    {
        return new MethodRunnerEvent( this.type, this.target, this._descriptor, this._timeElapsed, this._error );
    }
}
