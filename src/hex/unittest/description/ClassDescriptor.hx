package hex.unittest.description;

/**
 * @author Francis Bourre
 */
typedef ClassDescriptor =
{
	/**
	 * The instance of the test class.
	 */
    @:optional 
	var instance : Dynamic;

    /**
	 * The type of the test class.
	 */
    @:optional 
	var type : Dynamic;

    /**
	 * The class name of the test class.
	 */
    var className : String;

    /**
	 * Specifies is the class descripted is a suite.
	 */
    var isSuiteClass : Bool;

    /**
	 * The life cycle method to be called once, setUp tests in the class are executed.
	 */
    var beforeClassFieldName : String;

    /**
	 * The life cycle method to be called once, tearDown tests in the class are executed.
	 */
    var afterClassFieldName : String;

    /**
	 * The life cycle method to be called once, setUp each test in the class is executed.
	 */
    var setUpFieldName : String;

    /**
	 * The life cycle method to be called once, tearDown each test in the class is executed.
	 */
    var tearDownFieldName 	: String;

    var classDescriptors   	: Array<ClassDescriptor>;
    var methodDescriptors  	: Array<MethodDescriptor>;
    var classIndex 			: Int;
    var methodIndex 		: Int;
    var name				: String;
	
	@:optional 
	var setUpCall 			: Dynamic->Void;
	
	@:optional 
	var tearDownCall 		: Dynamic->Void;
	
	@:optional 
	var beforeCall 			: Void->Void;
	
	@:optional 
	var afterCall 			: Void->Void;
	
	@:optional 
	var instanceCall 		: Void->Dynamic;
}