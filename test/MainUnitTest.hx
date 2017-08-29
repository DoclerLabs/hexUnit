package;

import hex.HexUnitSuite;
import hex.unittest.runner.ExMachinaUnitCore;

/**
 * ...
 * @author Francis Bourre
 */
class MainUnitTest
{
	static public function main() : Void
	{
		var emu = new ExMachinaUnitCore();
        
		#if flash
		emu.addListener( new hex.unittest.notifier.TraceNotifier( flash.Lib.current.loaderInfo, false, true ) );
		#else
		emu.addListener( new hex.unittest.notifier.ConsoleNotifier( ) );
		#end
		
        emu.addTest( HexUnitSuite );
        emu.run();
	}
}
