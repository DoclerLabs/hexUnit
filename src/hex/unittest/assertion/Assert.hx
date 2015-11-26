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
    private static var _assertCount             : Int = 0;
    private static var _assertFailedCount       : Int = 0;
    private static var _lastAssertionLog        : String = "";
    private static var _assertionLogs           : Array<String> = [];

    private static function _LOG_ASSERT( userMessage : String ) : Void
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
        Assert._assertFailedCount         = 0;
        Assert._lastAssertionLog    = "";
        Assert._assertionLogs       = [];
    }

    /**
     * Asserts that 'value' is true
     */
    public static function assertTrue( value : Bool, userMessage : String, ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );

        if ( value != true )
        {
            Assert.fail( "Expected true but was '" + value + "'", userMessage, posInfos );
        }
    }

    /**
     * Asserts that 'value' is false
     */
    public static function failTrue( value : Bool, userMessage : String, ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );

        if ( value != false )
        {
            Assert.fail( "Expected false but was '" + value + "'", userMessage, posInfos );
        }
    }

    /**
     * Asserts that 'value' is null
     */
    public static function assertIsNull( value : Dynamic, userMessage : String, ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );

        if ( value != null )
        {
            Assert.fail( "Expected null but was '" + Stringifier.stringify( value ) + "'", userMessage, posInfos );
        }
    }

    /**
     * Asserts that 'value' is not null
     */
    public static function failIsNull( value : Dynamic, userMessage : String, ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );

        if ( value == null )
        {
            Assert.fail( "Expected not null but was 'null'", userMessage, posInfos );
        }
    }

    /**
     * Asserts that 'value' is type of 'type'
     */
    public static function assertIsType( value : Dynamic, type : Dynamic, userMessage : String, ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );

        if ( !Std.is( value, type ) )
        {
            Assert.fail( "Expected '" + Stringifier.stringify( value ) + "' was of type '" + Type.getClassName( type ) + "'", userMessage, posInfos );
        }
    }

    /**
     * Asserts that 'value' is not type of 'type'
     */
    public static function failIsType( value : Dynamic, type : Dynamic, userMessage : String, ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );

        if ( Std.is( value, type ) )
        {
            Assert.fail( "Value '" + Stringifier.stringify( value ) + "' was not of type '" + Type.getClassName( type ) + "'", userMessage, posInfos );
        }
    }

    /**
     * Asserts that 'expected' and 'actual' are equal
     */
    public static function assertEquals( expected : Dynamic, value : Dynamic, userMessage : String, ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );

        if ( expected != value )
        {
            Assert.fail( "Expected '" + expected +"' but was '" + value + "'", userMessage, posInfos );
        }
    }
	
	public static function assertDeepEquals( expected : Dynamic, value : Dynamic, userMessage : String, ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );

        if ( Std.string( expected ) != Std.string( value ) )
        {
            Assert.fail( "Expected '" + expected +"' but was '" + value + "'", userMessage, posInfos );
        }
    }
	
	public static function assertArrayContains( expected : Array<Dynamic>, value : Array<Dynamic>, userMessage : String, ?posInfos : PosInfos ) : Void
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
            Assert.fail( "Expected '" + expected +"' but was '" + value + "'", userMessage, posInfos );
        }
    }

    /**
     * Asserts that 'expected' and 'actual' are not equal
     */
    public static function failEquals( expected : Dynamic, value : Dynamic, userMessage : String, ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );

        if ( expected == value )
        {
            Assert.fail( "Expected '" + expected +"' was not equal to '" + value + "'", userMessage, posInfos );
        }
    }

    /**
     * Asserts class constructor call throws 'expectedException'
     */
    public static function assertConstructorCallThrows( expectedException : Class<Exception>, type : Class<Dynamic>, args : Array<Dynamic>, userMessage : String, ?posInfos : PosInfos ) : Void
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
            Assert.fail( "Expected '" + expectedExceptionType +"' but was '" + Stringifier.stringify( exceptionCaught ) + "'", userMessage, posInfos );
        }
    }

    /**
     * Asserts method call throws 'expectedException'
     */
    public static function assertMethodCallThrows( expectedException : Class<Exception>, scope : Dynamic, methodReference : Dynamic, args : Array<Dynamic>, userMessage : String, ?posInfos : PosInfos ) : Void
    {
        Assert._LOG_ASSERT( userMessage );

        var expectedExceptionType : String      = Type.getClassName( expectedException );
        var exceptionCaught : Exception         = null;

        try
        {
            //var scope : Dynamic = Reflect.field( methodReference, "scope" );
            Reflect.callMethod( scope, methodReference, args );
        }
        catch ( e : Exception )
        {
            exceptionCaught = e;
        }

        if ( exceptionCaught == null || ( exceptionCaught != null && ( Type.getClass( exceptionCaught ) != expectedException ) ) )
        {
            Assert.fail( "Expected '" + expectedExceptionType +"' but was '" + exceptionCaught + "'", userMessage, posInfos );
        }
    }
	
	/**
     * Asserts that setting value to property throws 'expectedException'
     */
    public static function assertSetPropertyThrows( expectedException : Class<Exception>, instance : Dynamic, propertyName : String, value : Dynamic, userMessage : String, ?posInfos : PosInfos ) : Void
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
            Assert.fail( "Expected '" + expectedExceptionType +"' but was '" + exceptionCaught + "'", userMessage, posInfos );
        }
		
	}

    private static function fail( assertMessage : String, userMessage : String, ?posInfos : PosInfos ) : Void
    {
		Assert._assertFailedCount++;
        throw new AssertException( assertMessage + ( userMessage.length < 0 ? ": " + userMessage : "" ), posInfos );
    }
}