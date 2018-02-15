package hex.unittest.description;

/**
 * ...
 * @author Francis Bourre
 */
typedef MethodDescriptor =
{
    var methodName             	: String;
    var isAsync                	: Bool;
    var isIgnored              	: Bool;
    var description            	: String;
    var timeout 				: UInt;
	
	@:optional 
	var dataProviderFieldName 	: String;
	
	@:optional 
	var dataProviderIndex 		: UInt;
	
	@:optional 
	var functionCall 	: Dynamic->Void;
}