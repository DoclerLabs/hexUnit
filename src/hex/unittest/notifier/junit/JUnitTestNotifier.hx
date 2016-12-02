package hex.unittest.notifier.junit;

import hex.event.IEvent;
import hex.unittest.assertion.Assert;
import hex.unittest.description.TestClassDescriptor;
import hex.unittest.description.TestMethodDescriptor;
import hex.unittest.error.AssertException;
import hex.unittest.event.ITestRunnerListener;
import hex.unittest.event.TestRunnerEvent;

using StringTools;

/**
 * ...
 * @author St3veV
 */

typedef TestSuiteSummary = {
	var success:Int;
	var failed:Int;
	var errored:Int;
	var skipped:Int;
	var output:String;
	var time:Float;
	var tests:Int;
	var pack:String;
	var timestamp:String;
	var suiteName:String;
}

class JUnitTestNotifier implements ITestRunnerListener
{

	var _testSuiteSummaries:List<TestSuiteSummary>;
	var _testSuitesInExecution:List<TestSuiteSummary>;
	var _hostname:String;
	var _outputHandler:IOutputHandler;
	
	public function new(outputHandler:IOutputHandler, hostname:String = "localhost") 
	{
		this._outputHandler = outputHandler;
		this._hostname = hostname;
	}
	
	public function onStartRun(event:TestRunnerEvent):Void 
	{
		this._testSuiteSummaries = new List();
		this._testSuitesInExecution = new List();
		
		//push global suite to catch orphaned tests and functions
		this._testSuitesInExecution.push(getSuiteSummary("-", ""));
	}
	
	public function onEndRun(event:TestRunnerEvent):Void 
	{
		//pop the global suite
		this._testSuiteSummaries.add(this._testSuitesInExecution.pop());
		
		this._outputHandler.handleOutput(getOutput());
	}
	
	public function onSuccess(event:TestRunnerEvent):Void 
	{
		var summary = this._testSuitesInExecution.first();
		updateSummary(summary, event);
		summary.output += getTestCaseStart(event);
		summary.output += getTestCaseEnd();
	}
	
	public function onFail(event:TestRunnerEvent):Void 
	{
		var summary = this._testSuitesInExecution.first();
		updateSummary(summary, event);
		summary.output += getTestCaseStart(event);
		summary.output += "<failure type=\"" + event.getError().name + "\" message=\"" + event.getError().message.htmlEscape(true) + "\"><![CDATA[" + event.getError() + "]]></failure>";
		summary.output += getTestCaseEnd();
	}
	
	public function onTimeout(event:TestRunnerEvent):Void 
	{
		var summary = this._testSuitesInExecution.first();
		updateSummary(summary, event);
		summary.output += getTestCaseStart(event);
		summary.output += "<error type=\"" + event.getError().name + "\" message=\"" + event.getError().message.htmlEscape(true) + "\"><![CDATA[" + event.getError() + "]]></error>";
		summary.output += getTestCaseEnd();
	}
	
	public function onIgnore(event:TestRunnerEvent):Void 
	{
		var summary = this._testSuitesInExecution.first();
		updateSummary(summary, event);
		summary.output += getTestCaseStart(event);
		summary.output += "<skipped />";
		summary.output += getTestCaseEnd();
	}
	
	public function onSuiteClassStartRun(event:TestRunnerEvent):Void 
	{
		this._testSuitesInExecution.push(getSuiteSummary(event.getDescriptor().getName(), event.getDescriptor().className));
	}
	
	public function onSuiteClassEndRun(event:TestRunnerEvent):Void 
	{
		this._testSuiteSummaries.add(_testSuitesInExecution.pop());
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
	
	//----------------------------------------- Helper functions
	
	function getSuiteSummary(name:String, className:String):TestSuiteSummary
	{
		var suiteName = name;
		if (suiteName == "")
		{
			suiteName = className.substring(className.lastIndexOf(".") + 1);
		}
		
		var now = Date.now();
		var formattedTime = now.toString().split(" ").join("T");
		
		var testSuiteSummary:TestSuiteSummary = {
			errored: 0,
			failed: 0,
			skipped: 0,
			success: 0,
			output: "",
			time:0,
			tests: 0,
			pack: (className.length > 0)?className.substring(0, className.lastIndexOf(".")):"",
			suiteName: suiteName,
			timestamp: formattedTime
		};
		return testSuiteSummary;
	}
	
	function updateSummary(summary:TestSuiteSummary, event:TestRunnerEvent):Void
	{
		summary.time += event.getTimeElapsed();
		summary.tests++;
		switch(event.type)
		{
			case TestRunnerEvent.TIMEOUT:	summary.errored++;
			case TestRunnerEvent.FAIL:		summary.failed++;
			case TestRunnerEvent.IGNORE:	summary.skipped++;
			default:
		}
	}
	
	function getTestCaseStart(event:TestRunnerEvent):String
	{
		var methodDescriptor : TestMethodDescriptor = event.getDescriptor().currentMethodDescriptor();
		return "<testcase classname=\"" + event.getDescriptor().className + "\" name=\"" + methodDescriptor.methodName + "\" time=\"" + event.getTimeElapsed() / 1000 + "\">";
	}
	
	function getTestCaseEnd():String
	{
		return "</testcase>";
	}
	
	function getSuiteNode(summary:TestSuiteSummary, id:Int, host:String):String
	{
		var out = "";
		out += getTestSuiteStart(summary, id, host);
		out += "<properties />";
		out += summary.output;
		out += getTestSuiteEnd();
		return out;
	}
	
	function getTestSuiteStart(summary:TestSuiteSummary, id:Int, host:String):String
	{
		return "<testsuite name=\"" + summary.suiteName + "\" " +
							"package=\"" + summary.pack + "\" " +
							"id=\"" + id + "\" " +
							"hostname=\"" + host + "\" " +
							"timestamp=\"" + summary.timestamp + "\" " +
							"failures=\"" + summary.failed + "\" " +
							"errors=\"" + summary.errored + "\" " +
							"skips=\"" + summary.skipped + "\" " +
							"tests=\"" + summary.tests + "\" " +
							"time=\"" + (summary.time / 1000.0) + "\">";
	}
	
	function getTestSuiteEnd():String
	{
		return "<system-out /><system-err /></testsuite>";
	}
	
	function getOutput():String
	{
		var id:Int = 0;
		var output = "";
		output += "<testsuites>";
		for (summary in this._testSuiteSummaries)
		{
			if (summary.tests == 0) continue;
			output += getSuiteNode(summary, id++, _hostname);
		}
		output += "</testsuites>";
		
		return output;
	}
}