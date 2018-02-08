package hex.unittest.runner;

import haxe.Timer;
import hex.unittest.runner.MethodRunner.Trigger;

/**
 * @author Francis Bourre
 */
typedef AsyncListener =
{
	function getTimeElapsed() 		: Float;

	var scope						: Dynamic;
	var callback           			: Dynamic;
    var passThroughArgs    			: Array<Dynamic>;
    var timer              			: Timer;
	var endTime						: Float;
	var trigger ( default, never ) 	: Trigger;
}