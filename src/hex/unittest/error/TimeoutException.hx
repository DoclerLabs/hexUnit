package hex.unittest.error;

import haxe.PosInfos;
import hex.error.Exception;

/**
 * ...
 * @author Francis Bourre
 */
class TimeoutException extends Exception
{
    public function new ( ?message : String = 'Async test timeout', ?posInfos : PosInfos )
    {
        super( message, posInfos );
    }
}
