package hex.unittest.notifier.junit;

#if sys
import sys.FileSystem;
import sys.io.File;

/**
 * ...
 * @author St3veV
 */
class FileOutputHandler implements IOutputHandler
{
	var _outputFileName:String;
	var _currentFileIndex:Int;

	/**
	 * Writes output to a file
	 * Works only on sys targets
	 * @param	outputFileName	Filename to write the output to. Character '#' will be replaced by index of a number
	 */
	public function new(outputFileName:String) 
	{
		this._outputFileName = outputFileName;
		this._currentFileIndex = 0;
	}
	
	public function handleOutput(output:String):Void 
	{
		var outputName = StringTools.replace(this._outputFileName, "#", this._currentFileIndex + "");
		if (FileSystem.exists(outputName))
		{
			FileSystem.deleteFile(outputName);
		}
		File.saveContent(outputName, output);
		this._currentFileIndex++;
	}
	
}
#end