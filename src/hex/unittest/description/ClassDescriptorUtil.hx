package hex.unittest.description;

using Lambda;

/**
 * ...
 * @author Francis Bourre
 */
class ClassDescriptorUtil 
{

	function new() throw new hex.error.PrivateConstructorException();

	static public function hasNextClass( classDescriptor : ClassDescriptor ) : Bool
        return classDescriptor.classIndex < classDescriptor.classDescriptors.length;
	
	static public function nextClass( classDescriptor : ClassDescriptor ) : ClassDescriptor
        return classDescriptor.classDescriptors[ classDescriptor.classIndex++ ];
		
	static public function hasNextMethod( classDescriptor : ClassDescriptor ) : Bool
        return classDescriptor.methodIndex < classDescriptor.methodDescriptors.length;
	
	static public function nextMethod( classDescriptor : ClassDescriptor ) : TestMethodDescriptor
		return classDescriptor.methodDescriptors[ classDescriptor.methodIndex++ ];
		
	static public function keepOnlyThisMethod( classDescriptor : ClassDescriptor, methodName : String ) : Void
		classDescriptor.methodDescriptors = classDescriptor.methodDescriptors.filter( function( descriptor ) return descriptor.methodName == methodName );
		
	static public function currentMethodDescriptor( classDescriptor : ClassDescriptor ) : TestMethodDescriptor
		return classDescriptor.methodDescriptors[ classDescriptor.methodIndex == 0 ? 0 : classDescriptor.methodIndex - 1 ];
		
	static public function length( classDescriptor : ClassDescriptor ) : UInt
	{
		var l = 0;
		for ( descriptor in classDescriptor.classDescriptors ) l += length( descriptor );
		l += classDescriptor.methodDescriptors.length;
		return l;
	}
		
	public static function toString( classDescriptor : ClassDescriptor ) : String
		return hex.util.Stringifier.stringify( classDescriptor ) + ':[$classDescriptor.instance, $classDescriptor.type, $classDescriptor.className]';
}