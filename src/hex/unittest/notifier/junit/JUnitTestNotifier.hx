package hex.unittest.notifier.junit;

import hex.unittest.description.ClassDescriptor;
import hex.unittest.event.ITestClassResultListener;

using StringTools;
using tink.CoreApi;
using hex.unittest.description.ClassDescriptorUtil;

/**
 * ...
 * @author St3veV
 */

typedef TestSuiteSummary = 
{
	var success		: Int;
	var failed		: Int;
	var errored		: Int;
	var skipped		: Int;
	var output		: String;
	var time		: Float;
	var tests		: Int;
	var pack		: String;
	var timestamp	: String;
	var suiteName	: String;
}

class JUnitTestNotifier implements ITestClassResultListener
{

	var _testSuiteSummaries		: List<TestSuiteSummary>;
	var _testSuitesInExecution	: List<TestSuiteSummary>;
	var _hostname				: String;
	var _outputHandler			: IOutputHandler;
	
	public function new( outputHandler : IOutputHandler, hostname : String = "localhost" ) 
	{
		this._outputHandler = outputHandler;
		this._hostname = hostname;
	}
	
	public function onStartRun( descriptor : ClassDescriptor ) : Void 
	{
		this._testSuiteSummaries = new List();
		this._testSuitesInExecution = new List();
		
		//push global suite to catch orphaned tests and functions
		this._testSuitesInExecution.push( this.getSuiteSummary("-", "") );
	}
	
	public function onEndRun( descriptor : ClassDescriptor ) : Void 
	{
		//pop the global suite
		this._testSuiteSummaries.add( this._testSuitesInExecution.pop() );
		
		this._outputHandler.handleOutput( this.getOutput() );
	}
	
	public function onSuccess( descriptor : ClassDescriptor, timeElapsed : Float ) : Void
	{
		var summary = this._testSuitesInExecution.first();
		this.updateSummary( summary, timeElapsed );
		
		summary.output += this.getTestCaseStart( descriptor, timeElapsed );
		summary.output += this.getTestCaseEnd();
	}
	
	public function onFail( descriptor : ClassDescriptor, timeElapsed : Float, error : Error ) : Void
	{
		var summary = this._testSuitesInExecution.first();
		
		this.updateSummary( summary, timeElapsed );
		summary.failed++;
		
		summary.output += this.getTestCaseStart( descriptor, timeElapsed );
		summary.output += "<failure type=\"" + error.name + "\" message=\"" + error.message.htmlEscape(true) + "\"><![CDATA[" + error + "]]></failure>";
		summary.output += this.getTestCaseEnd();
	}
	
	public function onTimeout( descriptor : ClassDescriptor, timeElapsed : Float, error : Error ) : Void
	{
		var summary = this._testSuitesInExecution.first();
		
		this.updateSummary( summary, timeElapsed );
		summary.errored++;
		
		summary.output += this.getTestCaseStart( descriptor, timeElapsed );
		summary.output += "<error type=\"" + error.name + "\" message=\"" + error.message.htmlEscape(true) + "\"><![CDATA[" + error + "]]></error>";
		summary.output += this.getTestCaseEnd();
	}
	
	public function onIgnore( descriptor : ClassDescriptor ) : Void
	{
		var summary = this._testSuitesInExecution.first();
		
		this.updateSummary( summary, 0 );
		summary.skipped++;
		
		summary.output += this.getTestCaseStart( descriptor, 0 );
		summary.output += "<skipped />";
		summary.output += this.getTestCaseEnd();
	}
	
	public function onSuiteClassStartRun( descriptor : ClassDescriptor ) : Void  
	{
		this._testSuitesInExecution.push( this.getSuiteSummary( descriptor.name, descriptor.className ) );
	}
	
	public function onSuiteClassEndRun( descriptor : ClassDescriptor ) : Void 
	{
		this._testSuiteSummaries.add(_testSuitesInExecution.pop());
	}
	
	public function onTestClassStartRun( descriptor : ClassDescriptor ) : Void  
	{
	}
	
	public function onTestClassEndRun( descriptor : ClassDescriptor ) : Void 
	{
	}
	
	//----------------------------------------- Helper functions
	
	function getSuiteSummary( name : String, className : String ) : TestSuiteSummary
	{
		var suiteName = name;
		if ( suiteName == "" )
		{
			suiteName = className.substring( className.lastIndexOf(".") + 1 );
		}
		
		var now = Date.now();
		var formattedTime = now.toString().split(" ").join("T");
		
		var testSuiteSummary : TestSuiteSummary = 
		{
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
	
	function updateSummary( summary : TestSuiteSummary, timeElapsed : Float ) : Void
	{
		summary.time += timeElapsed;
		summary.tests++;
	}
	
	function getTestCaseStart( descriptor : ClassDescriptor, timeElapsed : Float ) : String
	{
		var methodDescriptor = descriptor.currentMethodDescriptor();
		return "<testcase classname=\"" + descriptor.className + "\" name=\"" + methodDescriptor.methodName + "\" time=\"" + timeElapsed / 1000 + "\">";
	}
	
	function getTestCaseEnd() : String
	{
		return "</testcase>";
	}
	
	function getSuiteNode( summary : TestSuiteSummary, id : Int, host : String ) : String
	{
		var out = "";
		out += getTestSuiteStart(summary, id, host);
		out += "<properties />";
		out += summary.output;
		out += getTestSuiteEnd();
		return out;
	}
	
	function getTestSuiteStart( summary : TestSuiteSummary, id : Int, host : String ) : String
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
	
	function getTestSuiteEnd() : String
	{
		return "<system-out /><system-err /></testsuite>";
	}
	
	function getOutput() : String
	{
		var id : Int = 0;
		var output = "";
		output += "<testsuites>";
		for ( summary in this._testSuiteSummaries )
		{
			if ( summary.tests == 0 ) continue;
			output += this.getSuiteNode( summary, id++, _hostname );
		}
		output += "</testsuites>";
		
		return output;
	}
}