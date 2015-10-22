package hex.unittest.description;

import hex.log.Stringifier;

/**
 * ...
 * @author Francis Bourre
 */
class TestMethodDescriptor
{
    public var methodName             : String;
    public var isAsync                : Bool;
    public var isIgnored              : Bool;
    public var description            : String;

    public function new (   methodName        : String,
                            isAsync           : Bool,
                            isIgnored         : Bool,
                            ?description      : String )
    {
        this.methodName        = methodName;
        this.isAsync           = isAsync;
        this.isIgnored         = isIgnored;
        this.description       = description != null ? description : "";
    }

    public function toString() : String
    {
        return Stringifier.stringify( this ) + ':[$methodName, $isAsync, $isIgnored, $description]';
    }
}
