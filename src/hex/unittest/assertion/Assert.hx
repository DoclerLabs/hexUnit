package hex.unittest.assertion;

import hex.error.Exception;
import hex.log.Stringifier;
import hex.unittest.error.AssertException;
import haxe.PosInfos;

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
    public static function isTrue( value : Bool, userMessage : String, ?posInfos : PosInfos ) : Void
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
    public static function isFalse( value : Bool, userMessage : String, ?posInfos : PosInfos ) : Void
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
    public static function isNull( value : Dynamic, userMessage : String, ?posInfos : PosInfos ) : Void
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
    public static function isNotNull( value : Dynamic, userMessage : String, ?posInfos : PosInfos ) : Void
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
    public static function isInstanceOf( value : Dynamic, type : Dynamic, userMessage : String, ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );

        if ( !Std.is( value, type ) )
        {
            Assert._fail( "Expected '" + Type.getClassName( type ) + "' was of type '" + Stringifier.stringify( value ) + "'", userMessage, posInfos );
        }
    }

    /**
     * Asserts that 'value' is not type of 'type'
     */
    public static function isNotInstanceOf( value : Dynamic, type : Dynamic, userMessage : String, ?posInfos : PosInfos ) : Void
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
    public static function equals( expected : Dynamic, value : Dynamic, userMessage : String, ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );

        if ( expected != value )
        {
            Assert._fail( "Expected '" + expected +"' but was '" + value + "'", userMessage, posInfos );
        }
    }
	
	public static function deepEquals( expected : Dynamic, value : Dynamic, userMessage : String, ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );

        if ( Std.string( expected ) != Std.string( value ) )
        {
            Assert._fail( "Expected '" + expected +"' but was '" + value + "'", userMessage, posInfos );
        }
    }
	
	public static function arrayContains( expected : Array<Dynamic>, value : Array<Dynamic>, userMessage : String, ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );
		
		var numElement : Int = 0;
		for ( valueElement in value )
		{
			for ( expectedElement in expected )
			{
				if ( valueElement == expectedElement )
				{
					numElement++;
				}
			}
		}
		
		if ( numElement != expected.length )
        {
            Assert._fail( "Expected '" + expected +"' but was '" + value + "'", userMessage, posInfos );
        }
    }

    /**
     * Asserts that 'expected' and 'actual' are not equal
     */
    public static function notEquals( expected : Dynamic, value : Dynamic, userMessage : String, ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );

        if ( expected == value )
        {
            Assert._fail( "Expected '" + expected +"' was not equal to '" + value + "'", userMessage, posInfos );
        }
    }

    /**
     * Asserts class constructor call throws 'expectedException'
     */
    public static function constructorCallThrows( expectedException : Class<Exception>, type : Class<Dynamic>, args : Array<Dynamic>, userMessage : String, ?posInfos : PosInfos ) : Void
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
     * Asserts method call throws 'expectedException'
     */
    public static function methodCallThrows( expectedException : Class<Exception>, scope : Dynamic, methodReference : Dynamic, args : Array<Dynamic>, userMessage : String, ?posInfos : PosInfos ) : Void
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
     */
    public static function setPropertyThrows( expectedException : Class<Exception>, instance : Dynamic, propertyName : String, value : Dynamic, userMessage : String, ?posInfos : PosInfos ) : Void
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
	
	/**
	 * Use this method to trigger a unit test failure
	 * 
	 * @param	assertMessage	Error message for the assertion type
	 * @param	userMessage		Error message for the current assertion
	 * @param	posInfos		Error position infos
	 */
	public static function fail( assertMessage : String, userMessage : String, ?posInfos : PosInfos ) : Void
    {
        throw new AssertException( assertMessage + ( userMessage.length < 0 ? ": " + userMessage : "" ), posInfos );
    }
	
	//
	static function _fail( assertMessage : String, userMessage : String, ?posInfos : PosInfos ) : Void
    {
		Assert._assertFailedCount++;
		Assert.fail( assertMessage, userMessage, posInfos ) ;
    }
}