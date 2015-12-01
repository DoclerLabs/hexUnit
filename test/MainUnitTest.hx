package;

import hex.HexUnitSuite;
import hex.unittest.notifier.ConsoleNotifier;
import hex.unittest.notifier.TraceNotifier;
import hex.unittest.runner.ExMachinaUnitCore;

/**
 * ...
 * @author Francis Bourre
 */
class MainUnitTest
{
	static public function main() : Void
	{
		var emu : ExMachinaUnitCore = new ExMachinaUnitCore();
        
		#if flash
		TestRunner.RENDER_DELAY = 0;
		emu.addListener( new TraceNotifier( false ) );
		#else
		emu.addListener( new ConsoleNotifier( false ) );
		#end
		
        emu.addTest( HexUnitSuite );
        emu.run();
	}
}