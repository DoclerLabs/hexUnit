package hex.unittest.matcher.object;
import org.hamcrest.Description;
import org.hamcrest.DiagnosingMatcher;
import org.hamcrest.Matcher;

/**
 * Tests whether the value is deeply equals with the expected object.
 * @author duke
 */
class IsDeepEqual<T> extends DiagnosingMatcher<T>
{
    var expected:Dynamic;

    /**
     * Creates a new instance of DeepEqual
     *
     * @param expectedClass The predicate evaluates to true for instances of this class
     *                 or one of its subclasses.
     */
    public function new(expected:Dynamic)
    {
    	super();
        this.expected = expected;
    }

    override function isMatch(item:Dynamic, mismatchDescription:Description):Bool
    {
		if ( Std.string( this.expected ) == Std.string( item ) )
		{
			return true;
		}
		else
		{
			mismatchDescription.appendValue(item).appendText(" is not deep equals to " + this.expected);
		}
		
		return false;
	}

    override public function describeTo(description:Description):Void
    {
        description.appendText("is deep equals to" + Type.resolveClass(this.expected));
    }
	
	public static function deepEqual<T>( expected:Dynamic ):Matcher<T>
	{
		return new IsDeepEqual<T>(expected);
	}
}