package hex;
import haxe.Timer;
import hex.unittest.runner.MethodRunner;

/**
 * ...
 * @author duke
 */
class TestCaseTest
{
	var timer:Timer;

	public function new() 
	{
		
	}
	
	#if (!neko || haxe_ver >= "3.3")
	@Async( "Test if async tests can run properly with static Timer.delay" )
	public function asyncStaticTimerTest( )
	{
		trace("aaaaa");
		Timer.delay( MethodRunner.asyncHandler( this._onAsyncTestComplete, 100 ), 50 );
	}
	
	@Async( "Test if async tests can run properly with normal Timer instance" )
	public function asyncTimerInstanceTest( )
	{
		
		this.timer = new Timer( 50 );
		this.timer.run = MethodRunner.asyncHandler( this._onAsyncTestComplete );
	}
	
	function _onAsyncTestComplete() 
	{
		this.timer.stop();
	}
	
	#end
}