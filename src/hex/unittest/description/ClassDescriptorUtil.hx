package hex.unittest.description;

using Lambda;
using hex.error.Error;

/**
 * ...
 * @author Francis Bourre
 */
class ClassDescriptorUtil 
{
	/** @private */ function new() throw new PrivateConstructorException();

	static public function hasNextClass( classDescriptor : ClassDescriptor ) : Bool
        return classDescriptor.classIndex < classDescriptor.classDescriptors.length;
	
	static public function nextClass( classDescriptor : ClassDescriptor ) : ClassDescriptor
        return classDescriptor.classDescriptors[ classDescriptor.classIndex++ ];
		
	static public function hasNextMethod( classDescriptor : ClassDescriptor ) : Bool
        return classDescriptor.methodIndex < classDescriptor.methodDescriptors.length;
	
	static public function nextMethod( classDescriptor : ClassDescriptor ) : MethodDescriptor
		return classDescriptor.methodDescriptors[ classDescriptor.methodIndex++ ];
		
	static public function keepOnlyThisMethod( classDescriptor : ClassDescriptor, methodName : String ) : Void
		classDescriptor.methodDescriptors = classDescriptor.methodDescriptors.filter( function( descriptor ) return descriptor.methodName == methodName );
		
	static public function currentMethodDescriptor( classDescriptor : ClassDescriptor ) : MethodDescriptor
		return classDescriptor.methodDescriptors[ classDescriptor.methodIndex == 0 ? 0 : classDescriptor.methodIndex - 1 ];
		
	static public function length( classDescriptor : ClassDescriptor ) : UInt
	{
		var l = 0;
		for ( descriptor in classDescriptor.classDescriptors ) l += length( descriptor );
		return l + classDescriptor.methodDescriptors.length;
	}
		
	public static function toString( classDescriptor : ClassDescriptor ) : String
		return '' + classDescriptor + ':[$classDescriptor.instance, $classDescriptor.type, $classDescriptor.className]';
}