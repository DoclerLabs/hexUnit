package hex.unittest.error;

import haxe.PosInfos;
using tink.CoreApi;

/**
 * ...
 * @author Francis Bourre
 */
class AssertException extends Error
{
    public function new ( message : String, ?posInfos : PosInfos ) super( code, message, pos );
}
