package hex.unittest.description;

import hex.error.NoSuchElementException;
import hex.log.Stringifier;

/**
 * ...
 * @author Francis Bourre
 */
class TestClassDescriptor
{
    /**
	 * The instance of the test class.
	 */
    public var instance : Dynamic;

    /**
	 * The type of the test class.
	 */
    public var type : Class<Dynamic>;

    /**
	 * The class name of the test class.
	 */
    public var className : String;

    /**
	 * Specifies is the class descripted is a suite.
	 */
    public var isSuiteClass : Bool;

    /**
	 * The life cycle method to be called once, setUp tests in the class are executed.
	 */
    public var beforeClass : Dynamic;

    /**
	 * The life cycle method to be called once, tearDown tests in the class are executed.
	 */
    public var afterClass : Dynamic;

    /**
	 * The life cycle method to be called once, setUp each test in the class is executed.
	 */
    public var setUp : Dynamic;

    /**
	 * The life cycle method to be called once, tearDown each test in the class is executed.
	 */
    public var tearDown : Dynamic;

    private var _classDescriptors   : Array<TestClassDescriptor>;
    private var _methodDescriptors  : Array<TestMethodDescriptor>;
    private var _classIndex         : Int;
    private var _methodIndex        : Int;

    public function new( type : Class<Dynamic> )
    {
        this.instance           = Type.createEmptyInstance( type );
        this.type               = type;
        this.className          = Type.getClassName( type );

        this._classDescriptors  = [];
        this._methodDescriptors = [];
        this._classIndex        = 0;
        this._methodIndex       = 0;
    }

    public function addTestMethodDescriptor( methodDescriptor : TestMethodDescriptor ) : Void
    {
        this._methodDescriptors.push( methodDescriptor );
    }

    public function addTestClassDescriptor( classDescriptor : TestClassDescriptor ) : Void
    {
        this._classDescriptors.push( classDescriptor );
    }

    public function hasNextClass() : Bool
    {
        return this._classIndex < this._classDescriptors.length;
    }

    public function nextClass() : TestClassDescriptor
    {
        if ( this.hasNextClass()  )
        {
            return this._classDescriptors[ this._classIndex++ ];
        }
        else
        {
            throw new NoSuchElementException( "nextClass() call on '" + this.toString() + "' failed." );
        }
    }

    public function hasNextMethod() : Bool
    {
        return this._methodIndex < this._methodDescriptors.length;
    }

    public function nextMethod() : TestMethodDescriptor
    {
        if ( this.hasNextMethod()  )
        {
            return this._methodDescriptors[ this._methodIndex++ ];
        }
        else
        {
            throw new NoSuchElementException( "nextMethod call on '" + this.toString() + "' failed." );
        }
    }

    public function currentClassDescriptor() : TestClassDescriptor
    {
        return this._classDescriptors[ this._classIndex == 0 ? 0 : this._classIndex-1 ];
    }

    public function currentMethodDescriptor() : TestMethodDescriptor
    {
        return this._methodDescriptors[ this._methodIndex == 0 ? 0 : this._methodIndex-1 ];
    }

    public function toString() : String
    {
        return Stringifier.stringify( this ) + ':[$instance, $type, $className]';
    }
}
