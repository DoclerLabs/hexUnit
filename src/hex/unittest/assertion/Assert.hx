package hex.unittest.assertion;

import haxe.PosInfos;
import hex.error.Exception;
import hex.error.PrivateConstructorException;
import hex.util.ArrayUtil;
import hex.util.Stringifier;
import hex.unittest.error.AssertException;

/**
 * ...
 * @author Francis Bourre
 */
class Assert
{
    static var _assertCount             : Int = 0;
    static var _assertFailedCount       : Int = 0;
    static var _lastAssertionLog        : String = "";
    static var _assertionLogs           : Array<String> = [];

    static function _LOG_ASSERT( userMessage : String ) : Void
    {
        Assert._assertCount++;
        Assert._lastAssertionLog = userMessage;
        Assert._assertionLogs.push( userMessage );
    }

    /**
     * Returns the number of assertions that have been made
     */
    public static function getAssertionCount() : Int
    {
        return Assert._assertCount;
    }
	
	/**
     * Returns the number of assertions that have been made
     */
    public static function getAssertionFailedCount() : Int
    {
        return Assert._assertFailedCount;
    }

    /**
     * Returns the last assertion message logged
     */
    public static function getLastAssertionLog() : String
    {
        return Assert._lastAssertionLog;
    }

    /**
     * Returns all the assertion messages logged
     */
    public static function getAssertionLogs() : Array<String>
    {
        return Assert._assertionLogs;
    }

    /**
     * Resets the number of assertions made back to zero
     */
    public static function resetAssertionLog() : Void
    {
        Assert._assertCount         = 0;
        Assert._assertFailedCount   = 0;
        Assert._lastAssertionLog    = "";
        Assert._assertionLogs       = [];
    }

    /**
     * Asserts that 'value' is true
     */
    public static function isTrue( value : Bool, userMessage : String = "", ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );

        if ( value != true )
        {
            Assert._fail( "Expected true but was '" + value + "'", userMessage, posInfos );
        }
    }

    /**
     * Asserts that 'value' is false
     */
    public static function isFalse( value : Bool, userMessage : String = "", ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );

        if ( value != false )
        {
            Assert._fail( "Expected false but was '" + value + "'", userMessage, posInfos );
        }
    }

    /**
     * Asserts that 'value' is null
     */
    public static function isNull<T>( value : Null<T>, userMessage : String = "", ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );

        if ( value != null )
        {
            Assert._fail( "Expected null but was '" + Stringifier.stringify( value ) + "'", userMessage, posInfos );
        }
    }

    /**
     * Asserts that 'value' is not null
     */
    public static function isNotNull<T>( value : Null<T>, userMessage : String = "", ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );

        if ( value == null )
        {
            Assert._fail( "Expected not null but was 'null'", userMessage, posInfos );
        }
    }

    /**
     * Asserts that 'value' is type of 'type'
     */
    public static function isInstanceOf( value : Dynamic, type : Dynamic, userMessage : String = "", ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );

        if ( !Std.is( value, type ) )
        {
            Assert._fail( "Expected '" + Type.getClassName( type ) + "' but was '" + Stringifier.stringify( value ) + "'", userMessage, posInfos );
        }
    }

    /**
     * Asserts that 'value' is not type of 'type'
     */
    public static function isNotInstanceOf( value : Dynamic, type : Dynamic, userMessage : String = "", ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );

        if ( Std.is( value, type ) )
        {
            Assert._fail( "Value '" + Stringifier.stringify( value ) + "' was not of type '" + Type.getClassName( type ) + "'", userMessage, posInfos );
        }
    }

    /**
     * Asserts that 'expected' and 'actual' are equal
     */
    public static function equals( expected : Dynamic, value : Dynamic, userMessage : String = "", ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );
		
		#if (neko || php)
		if ( Reflect.isFunction( expected ) )
		{
			if ( !Reflect.compareMethods( expected, value ) )
			{
				Assert._fail( "Expected '" + expected +"' but was '" + value + "'", userMessage, posInfos );
			}
		} else 
		#end

        if ( expected != value )
        {
            Assert._fail( "Expected '" + expected +"' but was '" + value + "'", userMessage, posInfos );
        }
    }
	
	/**
     * Asserts that 'expected' and 'actual' are not equal
     */
    public static function notEquals( expected : Dynamic, value : Dynamic, userMessage : String = "", ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );
		
		#if (neko || php)
		if ( Reflect.isFunction( expected ) )
		{
			if ( Reflect.compareMethods( expected, value ) )
			{
				Assert._fail( "Expected '" + expected +"' was not equal to '" + value + "'", userMessage, posInfos );
			}
		} else 
		#end

        if ( expected == value )
        {
            Assert._fail( "Expected '" + expected +"' was not equal to '" + value + "'", userMessage, posInfos );
        }
    }
	
	/**
     * Asserts that 'expected' and 'actual' are deep equal
     */
	public static function deepEquals( expected : Dynamic, value : Dynamic, userMessage : String = "", ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );

        if ( !jsonStream.testUtil.JsonEquality.deepEquals( expected, value ) )
        {
            Assert._fail( "Expected '" + expected +"' but was '" + value + "'", userMessage, posInfos );
        }
    }
	
	/**
     * Asserts that 'expected' and 'actual' are not deep equal
     */
	public static function notDeepEquals( expected : Dynamic, value : Dynamic, userMessage : String = "", ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );

        if ( jsonStream.testUtil.JsonEquality.deepEquals( expected, value ) )
        {
            Assert._fail( "Expected '" + expected +"' was not deep equal to '" + value + "'", userMessage, posInfos );
        }
    }

	/**
     * Asserts that array contains this element
     */
	public static function arrayContainsElement<T>( a : Array<T>, value : T, userMessage : String = "", ?posInfos : PosInfos ) : Void
    {
		if ( a.indexOf( value ) == -1 )
		{
			Assert._fail( "Array '" + a +"' should contain '" + value + "'", userMessage, posInfos );
		}
	}
	
	/**
     * Asserts that array contains this element using deepEquals
     */
	public static function arrayDeepContainsElement<T>( a : Array<T>, value : T, userMessage : String = "", ?posInfos : PosInfos ) : Void
    {
		var contains = false;
		for (e in a)
		{
			if (jsonStream.testUtil.JsonEquality.deepEquals( e, value ))
			{
				contains = true;
				break;
			}
		}
		
		if ( !contains )
		{
			Assert._fail( "Array '" + a +"' should contain '" + value + "'", userMessage, posInfos );
		}
	}
	
	
	
	/**
     * Asserts that array does not contain this element
     */
	public static function arrayNotContainsElement<T>( a : Array<T>, value : T, userMessage : String = "", ?posInfos : PosInfos ) : Void
    {
		if ( ArrayUtil.indexOf( a, value ) != -1 )
		{
			Assert._fail( "Array '" + a +"' should not contain '" + value + "'", userMessage, posInfos );
		}
	}
	
	/**
     * Asserts this array contains every elements from another array
     */
	public static function arrayContainsElementsFrom<T>( expected : Array<T>, value : Array<T>, userMessage : String = "", ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );

		for ( element in value )
		{
			if ( ArrayUtil.indexOf( expected, element ) == -1 )
			{
				Assert._fail( "Array '" + expected +"' should contain '" + element + "'", userMessage, posInfos );
			}
		}
    }
	
	/**
     * Asserts this array contains every elements from another array using deep equals
     */
	public static function arrayDeepContainsElementsFrom<T>( expected : Array<T>, value : Array<T>, userMessage : String = "", ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );

		for ( element in value )
		{
			var contains = false;
			for (e in expected)
			{
				if (jsonStream.testUtil.JsonEquality.deepEquals( e, element ))
				{
					contains = true;
					break;
				}
			}
			
			if ( !contains )
			{
				Assert._fail( "Array '" + expected +"' should contain '" + element + "'", userMessage, posInfos );
			}
		}
    }

    /**
     * Asserts this array does not contain any element from another array
     */
	public static function arrayNotContainsElementsFrom<T>( expected : Array<T>, value : Array<T>, userMessage : String = "", ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );

		for ( element in value )
		{
			if ( expected.indexOf( element ) != -1 )
			{
				Assert._fail( "Array '" + expected +"' should not contain '" + element + "'", userMessage, posInfos );
			}
		}
    }
	
	/**
     * Asserts constructor call throws 'expectedException'
     */
    public static function constructorCallThrows<T>( expectedException : Class<Exception>, type : Class<T>, args : Array<Dynamic>, userMessage : String = "", ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );

        var expectedExceptionType : String      = Type.getClassName( expectedException );
        var exceptionCaught : Exception         = null;

        try
        {
            Type.createInstance( type, args );
        }
        catch ( e : Exception )
        {
            exceptionCaught = e;
        }

        if ( exceptionCaught == null || ( exceptionCaught != null && ( Type.getClass( exceptionCaught ) != expectedException ) ) )
        {
            Assert._fail( "Expected '" + expectedExceptionType +"' but was '" + Stringifier.stringify( exceptionCaught ) + "'", userMessage, posInfos );
        }
    }
	
	/**
     * Asserts constructor call throws 'PrivateConstructorException'
     */
	public static function constructorIsPrivate<T>( type : Class<T>, userMessage : String = "", ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );
		
		var exceptionCaught : Exception  = null;
		
		try
        {
            Type.createInstance( type, [] );
        }
        catch ( e : Exception )
        {
            exceptionCaught = e;
        }
		
		if ( exceptionCaught == null || ( exceptionCaught != null && ( Type.getClass( exceptionCaught ) != PrivateConstructorException ) ) )
        {
            Assert._fail( "Expected 'PrivateConstructorException' but was '" + Stringifier.stringify( exceptionCaught ) + "'", userMessage, posInfos );
        }
	}

    /**
     * Asserts method call throws 'expectedException'
     */
    public static function methodCallThrows( expectedException : Class<Exception>, scope : Dynamic, methodReference : Dynamic, args : Array<Dynamic>, userMessage : String = "", ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );

        var expectedExceptionType : String      = Type.getClassName( expectedException );
        var exceptionCaught : Exception         	= null;

        try
        {
            Reflect.callMethod( scope, methodReference, args );
        }
        catch ( e : Exception )
        {
            exceptionCaught = e;
        }

        if ( exceptionCaught == null || ( exceptionCaught != null && ( Type.getClass( exceptionCaught ) != expectedException ) ) )
        {
            Assert._fail( "Expected '" + expectedExceptionType +"' but was '" + exceptionCaught + "'", userMessage, posInfos );
        }
    }
	
	/**
     * Asserts that setting value to property throws 'expectedException'
	 * Not available on Flash platform because error is caught while 
	 * setting the value.
     */
	#if !flash
    public static function setPropertyThrows( expectedException : Class<Exception>, instance : Dynamic, propertyName : String, value : Dynamic, userMessage : String = "", ?posInfos : PosInfos ) : Void
	{
		Assert._LOG_ASSERT( userMessage );

        var expectedExceptionType : String      = Type.getClassName( expectedException );
        var exceptionCaught : Exception         = null;

        try
        {
			Reflect.setProperty( instance, propertyName, value );
		}
		catch ( e : Exception )
        {
            exceptionCaught = e;
        }
		
		if ( exceptionCaught == null || ( exceptionCaught != null && ( Type.getClass( exceptionCaught ) != expectedException ) ) )
        {
            Assert._fail( "Expected '" + expectedExceptionType +"' but was '" + exceptionCaught + "'", userMessage, posInfos );
        }
	}
	#end
	
	/**
	 * Use this method to trigger a unit test failure
	 * 
	 * @param	assertMessage	Error message for the assertion type
	 * @param	userMessage		Error message for the current assertion
	 * @param	posInfos		Error position infos
	 */
	public static function fail( assertMessage : String, userMessage : String = "", ?posInfos : PosInfos ) : Void
    {
		Assert._LOG_ASSERT( userMessage );
		Assert._fail( assertMessage, userMessage, posInfos ) ;
    }
	
	/**
	 * This method is used to test hexUnit framework
	 */
	static public function revertFailure() : Void
	{
		Assert._assertFailedCount--;
	}
	
	/**
	 * This method is used to report system exception that
	 * is not caught by assertion.
	 */
	@:allow( hex.unittest )
	static function _logFailedAssertion() : Void
	{
		Assert._assertFailedCount++;
	}
	
	//
	static function _fail( assertMessage : String, userMessage : String, ?posInfos : PosInfos ) : Void
    {
		Assert._assertFailedCount++;
        throw new AssertException( assertMessage + ( userMessage.length < 0 ? ": " + userMessage : "" ), posInfos );
    }
}