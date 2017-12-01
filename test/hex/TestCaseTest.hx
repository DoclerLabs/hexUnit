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

	@Async( "Test if async tests can run properly with static Timer.delay" )
	@Timeout( 100 )
	public function asyncStaticTimerTest( )
	{
		Timer.delay( MethodRunner.asyncHandler( this._onAsyncTestComplete ), 50 );
	}
	
	@Async( "Test if async tests can run properly with normal Timer instance" )
	public function asyncTimerInstanceTest( )
	{
		
		this.timer = new Timer( 50 );
		this.timer.run = MethodRunner.asyncHandler( this._onAsyncTestComplete );
	}
	
	function _onAsyncTestComplete() 
	{
		if ( this.timer != null )
		{
			this.timer.stop();
		}
	}
}