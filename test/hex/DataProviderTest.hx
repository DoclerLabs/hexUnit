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
	public function new(){}

	public static var testDataProvider = [
		{ stringValue:"string0", intValue:0 },
		{ stringValue:"string1", intValue:1 },
		{ stringValue:"string2", intValue:2 },
		{ stringValue:"string3", intValue:3 },
		{ stringValue:"string4", intValue:4 }
	];
	
	@Test("Data provider test")
	@DataProvider( "testDataProvider" )
	public function testWithProvider(o:{stringValue:String, intValue:Int})
	{
		Assert.equals( o.stringValue, "string" + o.intValue, "Values must be equal" );
	}
	
	@Async( "Async test with data provider" )
	@DataProvider( "testDataProvider" )
	public function testAsyncWithDataProvider(o:{stringValue:String, intValue:Int})
	{
		Assert.equals(o.stringValue, "string" + o.intValue, "Values must be equal");
		Timer.delay( 

			MethodRunner.asyncHandler.bind(

				function() 
				{
					this._onAsyncTestEnd( o.intValue, o.stringValue ); 
				} 
			)
			
		,  500 );
	
	}
	
	function _onAsyncTestEnd( intValue : Int, stringValue : String )
	{
		Assert.equals( testDataProvider[ intValue ].stringValue, stringValue );
	}
	
	@Async
	public function testAsyncWithArgument() : Void
	{
		var callback = DataProviderTest._registerCallback( 
			function( s : String ) 
			{
				MethodRunner.asyncHandler( function() { this._onStringCallback( s, ' world' ); } );
			}
		);
		callback( 'hello' );
	}
	
	static function _registerCallback( callback : String->Void ) return callback;
	function _onStringCallback( hello : String, world : String ) Assert.equals( 'hello world', hello + world );
}