package;

import hex.HexUnitSuite;
import hex.unittest.notifier.ConsoleNotifier;
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
        emu.addListener( new ConsoleNotifier() );
        emu.addTest( HexUnitSuite );
        emu.run();
	}
}