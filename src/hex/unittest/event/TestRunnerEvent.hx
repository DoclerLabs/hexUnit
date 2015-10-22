package hex.unittest.event;

import hex.event.BasicEvent;
import hex.error.Exception;
import hex.unittest.runner.TestRunner;
import hex.unittest.description.TestClassDescriptor;

class TestRunnerEvent  extends BasicEvent
{
    public static inline var SUCCESS                : String = "onSuccess";
    public static inline var FAIL                   : String = "onFail";
    public static inline var TIMEOUT                : String = "onTimeout";

    public static inline var START_RUN              : String = "onStartRun";
    public static inline var END_RUN                : String = "onEndRun";
    public static inline var SUITE_CLASS_START_RUN  : String = "onSuiteClassStartRun";
    public static inline var SUITE_CLASS_END_RUN    : String = "onSuiteClassEndRun";
    public static inline var TEST_CLASS_START_RUN   : String = "onTestClassStartRun";
    public static inline var TEST_CLASS_END_RUN     : String = "onTestClassEndRun";

    private var _descriptor                         : TestClassDescriptor;
    private var _error                              : Exception;
    private var _timeElapsed                        : Float;

    public function new ( type : String, target : TestRunner, descriptor : TestClassDescriptor, ?timeElapsed : Float, ?error : Exception )
    {
        super( type, target );

        this._descriptor    = descriptor;
        this._timeElapsed   = timeElapsed;
        this._error         = error;
    }

    public function getRunner() : TestRunner
    {
        return this.target;
    }

    public function getDescriptor() : TestClassDescriptor
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
}
