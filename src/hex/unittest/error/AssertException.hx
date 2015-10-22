package hex.unittest.error;

import haxe.PosInfos;
import hex.error.Exception;

/**
 * ...
 * @author Francis Bourre
 */
class AssertException extends Exception
{
    public function new ( message : String, ?posInfos : PosInfos )
    {
        super( message, posInfos );
    }
}
