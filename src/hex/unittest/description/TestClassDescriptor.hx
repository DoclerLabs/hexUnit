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
    public var beforeClassFieldName : String;

    /**
	 * The life cycle method to be called once, tearDown tests in the class are executed.
	 */
    public var afterClassFieldName : String;

    /**
	 * The life cycle method to be called once, setUp each test in the class is executed.
	 */
    public var setUpFieldName : String;

    /**
	 * The life cycle method to be called once, tearDown each test in the class is executed.
	 */
    public var tearDownFieldName : String;

    var _classDescriptors   : Array<TestClassDescriptor>;
    var _methodDescriptors  : Array<TestMethodDescriptor>;
    var _classIndex         : Int;
    var _methodIndex        : Int;
	
    var _name        		: String;

    public function new( type : Class<Dynamic> )
    {
        this.instance           = Type.createEmptyInstance( type );
        this.type               = type;
        this.className          = Type.getClassName( type );
		this._name 				= "";
		
        this._classDescriptors  = [];
        this._methodDescriptors = [];
        this._classIndex        = 0;
        this._methodIndex       = 0;
    }
	
	public function getName() : String
	{
		return this._name;
	}
	
	public function setName( name : String ) : Void
	{
		this._name = name;
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
	
	public function keepOnlyThisMethod( methodName : String ) : Void
	{
		for ( descriptor in this._methodDescriptors )
		{
			if ( descriptor.methodName == methodName )
			{
				this._methodDescriptors = [];
				this._methodDescriptors.push( descriptor );
				break;
			}
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
