package hex.unittest.metadata;

/**
 * ...
 * @author Francis Bourre
 */
class MetadataList
{
    /**
	 * Metadata marking method to be called setUp all tests in a class
	 */
    public inline static var BEFORE_CLASS : String = "BeforeClass";

    /**
	 * Metadata marking method to be called tearDown all tests in a class
	 */
    public inline static var AFTER_CLASS : String = "AfterClass";

    /**
	 * Metadata marking method to be called setUp each test in a class
	 */
    public inline static var BEFORE : String = "Before";

    /**
	 * Metadata marking method to be called tearDown each test in a class
	 */
    public inline static var AFTER : String = "After";

    /**
	 * Metadata marking test method in class
	 */
    public inline static var TEST : String = "Test";

    /**
     * Metadata marking asynchronous test method in class
     */
    public inline static var ASYNC : String = "Async";
	
	/**
     * Metadata for specifying asynchronous test timeout in ms
     */
    public inline static var TIMEOUT : String = "Timeout";

    /**
     * Metadata marking a test method to ignore
     */
    public inline static var IGNORE : String = "Ignore";

    /**
     * Metadata marking a test method to ignore
     */
    public inline static var SUITE : String = "Suite";

    /**
     * Metadata marking test as parametrized with input parameters
     */
    public inline static var DATA_PROVIDER : String = "DataProvider";
    
    /**
	 * Array of valid metadatas for instance methods
	 */
    public static var INSTANCE_METADATA = [ BEFORE, AFTER, TEST, ASYNC, TIMEOUT ];

    /**
	 * Array of valid metadatas for static methods
	 */
    public static var STATIC_METADATA = [ BEFORE_CLASS, AFTER_CLASS ];
}
