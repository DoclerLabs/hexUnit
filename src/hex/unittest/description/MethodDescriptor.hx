package hex.unittest.description;

/**
 * ...
 * @author Francis Bourre
 */
typedef MethodDescriptor =
{
    var methodName             : String;
    var isAsync                : Bool;
    var isIgnored              : Bool;
    var description            : String;
    var dataProvider           : Array<Dynamic>;
}