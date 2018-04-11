package hex.unittest.error;

import haxe.PosInfos;
using tink.CoreApi;

/**
 * ...
 * @author Francis Bourre
 */
class TimeoutException extends Error
{
    public function new ( ?message : String = 'Async test timeout', ?posInfos : PosInfos ) super( code, message, pos );
}