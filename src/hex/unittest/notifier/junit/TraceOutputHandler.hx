package hex.unittest.notifier.junit;

/**
 * ...
 * @author St3veV
 */
class TraceOutputHandler implements IOutputHandler
{

	/**
	 * Sends output to the standard trace call
	 */
	public function new() 
	{
		
	}
	
	public function handleOutput(output:String):Void 
	{
		trace(output);
	}
	
}