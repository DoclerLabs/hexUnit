package hex;
import haxe.Timer;
import hex.unittest.assertion.Assert;
import hex.unittest.runner.MethodRunner;

/**
 * ...
 * @author Stepan Vyterna
 */
class DataProviderTest
{

	public static var testDataProvider:Array<Array<Dynamic>> = [
		["string0", 0],
		["string1", 1],
		["string2", 2],
		["string3", 3],
		["string4", 4]
	];
	
	@Test("Data provider test")
	@DataProvider("testDataProvider")
	public function testWithProvider(stringValue:String, intValue:Int)
	{
		Assert.equals(stringValue, "string" + intValue, "Values must be equal");
	}
	
	@Async("Async test with data provider")
	@DataProvider("testDataProvider")
	public function testAsyncWithDataProvider(stringValue:String, intValue:Int)
	{
		Assert.equals(stringValue, "string" + intValue, "Values must be equal");
		Timer.delay(MethodRunner.asyncHandler(this._onAsyncTestEnd), 10);
	}
	
	function _onAsyncTestEnd()
	{
		Assert.isTrue(true, "true is true");
	}
}