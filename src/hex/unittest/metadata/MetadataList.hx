package hex.unittest.metadata;

/**
 * ...
 * @author Francis Bourre
 */
class MetadataList
{
    /**
	 * Metadata marking method to be called setUp all tests in a class.
	 */
    public inline static var BEFORE_CLASS : String = "beforeClass";

    /**
	 * Metadata marking method to be called tearDown all tests in a class.
	 */
    public inline static var AFTER_CLASS : String = "afterClass";

    /**
	 * Metadata marking method to be called setUp each test in a class.
	 */
    public inline static var SETUP : String = "setUp";

    /**
	 * Metadata marking method to be called tearDown each test in a class.
	 */
    public inline static var TEARDOWN : String = "tearDown";

    /**
	 * Metadata marking test method in class.
	 */
    public inline static var TEST : String = "test";

    /**
     * Metadata marking asynchronous test method in class.
     */
    public inline static var ASYNC : String = "async";

    /**
     * Metadata marking a test method to ignore.
     */
    public inline static var IGNORE : String = "ignore";

    /**
     * Metadata marking a test method to ignore.
     */
    public inline static var SUITE : String = "suite";

    /**
	 * Array of valid metadatas for instance methods.
	 */
    public static var INSTANCE_METADATA = [ SETUP, TEARDOWN, TEST, ASYNC ];

    /**
	 * Array of valid metadatas for instance methods.
	 */
    public static var STATIC_METADATA = [ BEFORE_CLASS, AFTER_CLASS ];
}
