package hex.unittest.runner;

/**
 * Don't modify this file, test execution
 * order dependency ensures results.
 * @author Francis Bourre
 */
class RunnerSuite
{
	@Suite( "Runner" )
    public var list : Array<Class<Dynamic>> = [ClassDescriptorGeneratorTest, TestRunnerTest, TestRunnerTest.AfterTestRunnerTest ];
}