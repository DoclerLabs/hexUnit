package hex.unittest.runner;

import hex.unittest.assertion.Assert;

/**
 * Don't modify this file, order and values
 * are dependent of each other.
 * @author Francis Bourre
 */
class TestRunnerTest 
{
	static var _beforeCalls = 0;
	static var _afterCalls = 0;
	static var _beforeClassCalls = 0;
	
	public static var afterClassCalls = 0;

	public function new() 
	{
		
	}
	
	@BeforeClass
	static public function beforeClass() : Void
	{
		_beforeClassCalls++;
	}
	
	@AfterClass
	static public function afterClass() : Void
	{
		afterClassCalls++;
	}
	
	@Before
	public function setUp() : Void
	{
		_beforeCalls++;
	}
	
	@After
	public function tearDown() : Void
	{
		_afterCalls++;
	}
	
	@Test
	public function testBeforeClass() : Void
	{
		Assert.equals( 1, _beforeClassCalls );
	}
	
	@Test
	public function testBefore() : Void
	{
		Assert.equals( 2, _beforeCalls );
	}
	
	@Test
	public function testAfter() : Void
	{
		Assert.equals( _beforeCalls-1, _afterCalls );
	}
}

class AfterTestRunnerTest 
{
	@Test
	public function testBefore() : Void
	{
		Assert.equals( 1, TestRunnerTest.afterClassCalls );
	}
}