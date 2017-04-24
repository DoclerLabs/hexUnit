package hex.unittest.assertion;

import hex.error.IllegalArgumentException;
import hex.error.NoSuchElementException;
import hex.error.PrivateConstructorException;
import hex.unittest.error.AssertException;
import jsonStream.testUtil.JsonEquality;

/**
 * ...
 * @author Francis Bourre
 */
class AssertionTest
{
	@Test( "test Assert.isTrue" )
	public function testAssertIsTrue() : Void
	{
		Assert.isTrue( true, "assertion should pass" );
	}
	
	@Test( "test Assert.isTrue failure" )
	public function testAssertIsTrueFailure() : Void
	{
		try 
		{
			Assert.isTrue( false, "assertion should not pass" );
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	
	@Test( "test Assert.isFalse" )
	public function testAssertIsFalse() : Void
	{
		Assert.isFalse( false, "assertion should pass" );
	}
	
	@Test( "test Assert.isFalse failure" )
	public function testAssertIsFalseFailure() : Void
	{
		try 
		{
			Assert.isFalse( true, "assertion should not pass" );
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	
	@Test( "test Assert.isNull" )
	public function testAssertIsNull() : Void
	{
		Assert.isNull( null, "assertion should pass" );
	}
	
	@Test( "test Assert.isNull failure" )
	public function testAssertIsNullFailure() : Void
	{
		try 
		{
			Assert.isNull( {}, "assertion should not pass" );
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	
	@Test( "test Assert.isNotNull" )
	public function testAssertIsNotNull() : Void
	{
		Assert.isNotNull( {}, "assertion should pass" );
	}
	
	@Test( "test Assert.isNotNull failure" )
	public function testAssertIsNotNullFailure() : Void
	{
		try 
		{
			Assert.isNotNull( null, "assertion should not pass" );
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	
	@Test( "test Assert.isInstanceOf" )
	public function testAssertisInstanceOf() : Void
	{
		Assert.isInstanceOf( this, AssertionTest, "assertion should pass" );
	}
	
	@Test( "test Assert.isInstanceOf failure" )
	public function testAssertIsInstanceOfFailure() : Void
	{
		try 
		{
			Assert.isInstanceOf( this, AssertException, "assertion should not pass" );
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	
	@Test( "test Assert.isNotInstanceOf" )
	public function testAssertIsNotInstanceOf() : Void
	{
		Assert.isNotInstanceOf( this, AssertException, "assertion should pass" );
	}
	
	@Test( "test Assert.isNotInstanceOf failure" )
	public function testAssertIsNotInstanceOfFailure() : Void
	{
		try 
		{
			Assert.isNotInstanceOf( this, AssertionTest, "assertion should not pass" );
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	
	@Test( "test Assert.equals" )
	public function testAssertEquals() : Void
	{
		Assert.equals( this, this, "assertion should pass" );
	}
	
	@Test( "test Assert.equals failure" )
	public function testAssertEqualsFailure() : Void
	{
		try 
		{
			Assert.equals( this, {}, "assertion should not pass" );
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	
	@Test( "test Assert.notEquals" )
	public function testAssertNotEquals() : Void
	{
		Assert.notEquals( this, {}, "assertion should pass" );
	}
	
	@Test( "test Assert.notEquals failure" )
	public function testAssertNotEqualsFailure() : Void
	{
		try 
		{
			Assert.equals( this, this, "assertion should not pass" );
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	
	//
	@Test( "test Assert.equals with closures" )
	public function testAssertEqualsWithClosures() : Void
	{
		Assert.equals( this.testAssertEquals, this.testAssertEquals, "assertion should pass" );
	}
	
	@Test( "test Assert.equals failure with closures" )
	public function testAssertEqualsWithClosuresFailure() : Void
	{
		var f1 = function () {};
		var f2 = function () {};
		
		try 
		{
			Assert.equals( this.testAssertEquals, this.testAssertEqualsFailure, "assertion should not pass" );
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	
	@Test( "test Assert.notEquals with closures" )
	public function testAssertNotEqualsWithClosures() : Void
	{
		Assert.notEquals( this.testAssertEquals, this.testAssertEqualsFailure, "assertion should pass" );
	}
	
	@Test( "test Assert.notEquals failure with closures" )
	public function testAssertNotEqualsWithClosuresFailure() : Void
	{
		try 
		{
			Assert.equals( this.testAssertEquals, this.testAssertEquals, "assertion should not pass" );
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	//
	
	@Test( "test Assert.deepEquals with anonymous object" )
	public function testAssertDeepEqualsWithAnonymousObject() : Void
	{
		var o1 = { p:"property", b:true, o:{ p2:"property", b2:true }, i:4, f:1.23 };
		var o2 = { f:1.23, p:"property", o: { b2:true, p2:"property" }, b:true, i:4  };
		
		Assert.deepEquals( o1, o2, "assertion should pass" );
	}
	
	@Test( "test Assert.deepEquals with anonymous object failure" )
	public function testAssertDeepEqualsWithAnonymousObjectFailure() : Void
	{
		var o1 = { p:"property", b:true, o:{ p2:"property", b2:true }, i:4, f:1.23 };
		var o2 = { f:1.23, p:"property", o: { b2:false, p2:"property" }, b:true, i:4  };
		
		try 
		{
			Assert.deepEquals( o1, o2, "assertion should not pass" );
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	
	@Test( "test Assert.deepEquals with array" )
	public function testAssertDeepEqualsWithArray() : Void
	{
		var a1 = [ [ 0, 1, 2, 3 ], [ 6, 7, 8 ], [ 4, 5 ] ];
		var a2 = [ [ 0, 1, 2, 3 ], [ 6, 7, 8 ], [ 4, 5 ] ];

		
		Assert.deepEquals( a1, a2, "assertion should pass" );
	}
	
	@Test( "test Assert.deepEquals with array failure" )
	public function testAssertDeepEqualsWithArrayFailure() : Void
	{
		var a1 = [ [ 0, 1, 2, 3 ], [ 6, 7, 8 ], [ 4, 5 ] ];
		var a2 = [ [ 0, 1, 2, 3 ], [ 6, 7, 8 ], [ 5, 4 ] ];
		
		try 
		{
			Assert.deepEquals( a1, a2, "assertion should not pass" );
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	
	@Test( "test Assert.deepEquals with class instance" )
	public function testAssertDeepEqualsWithClassInstance() : Void
	{
		var ao1 = { p:"property", b:true, o: { p2:"property", b2:true }, i:4, f:1.23 };
		var ao2 = { f:1.23, p:"property", o: { b2:true, p2:"property" }, b:true, i:4  };
		
		var o1 = new MockClassForDeepComparison( 3, true, "test", ao1, new MockClassForDeepComparison( 3, true, "test" ) );
		var o2 = new MockClassForDeepComparison( 3, true, "test", ao2, new MockClassForDeepComparison( 3, true, "test" ) );

		Assert.deepEquals( o1, o2, "assertion should pass" );
	}
	
	@Test( "test Assert.deepEquals with class instance failure" )
	public function testAssertDeepEqualsWithClassInstanceFailure() : Void
	{
		var ao1 = { p:"property", b:true, o: { p2:"property", b2:true }, i:4, f:1.23 };
		var ao2 = { f:1.23, p:"property", o: { b2:true, p2:"property" }, b:true, i:4  };
		
		var o1 = new MockClassForDeepComparison( 3, true, "test", ao1, new MockClassForDeepComparison( 3, true, "test" ) );
		var o2 = new MockClassForDeepComparison( 3, true, "test", ao2, new MockClassForDeepComparison( 3, false, "test" ) );
		
		try 
		{
			Assert.deepEquals( o1, o2, "assertion should not pass" );
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	
	@Test( "test Assert.notDeepEquals with anonymous object" )
	public function testAssertNotDeepEqualsWithAnonymousObject() : Void
	{
		var o1 = { p:"property", b:true, o:{ p2:"property", b2:true }, i:4, f:1.23 };
		var o2 = { f:1.23, p:"property", o: { b2:false, p2:"property" }, b:true, i:4  };
		
		Assert.notDeepEquals( o1, o2, "assertion should pass" );
	}
	
	@Test( "test Assert.notDeepEquals with anonymous object failure" )
	public function testAssertNotDeepEqualsWithAnonymousObjectFailure() : Void
	{
		var o1 = { p:"property", b:true, o:{ p2:"property", b2:true }, i:4, f:1.23 };
		var o2 = { f:1.23, p:"property", o: { b2:true, p2:"property" }, b:true, i:4  };
		
		try 
		{
			Assert.notDeepEquals( o1, o2, "assertion should not pass" );
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	
	@Test( "test Assert.notDeepEquals with array" )
	public function testAssertNotDeepEqualsWithArray() : Void
	{
		var a1 = [ [ 0, 1, 2, 3 ], [ 6, 7, 8 ], [ 4, 5 ] ];
		var a2 = [ [ 0, 1, 2, 3 ], [ 6, 7, 8 ], [ 5, 4 ] ];
		
		Assert.notDeepEquals( a1, a2, "assertion should pass" );
	}
	
	@Test( "test Assert.notDeepEquals with array failure" )
	public function testAssertNotDeepEqualsWithArrayFailure() : Void
	{
		var a1 = [ [ 0, 1, 2, 3 ], [ 6, 7, 8 ], [ 4, 5 ] ];
		var a2 = [ [ 0, 1, 2, 3 ], [ 6, 7, 8 ], [ 4, 5 ] ];
		
		try 
		{
			Assert.notDeepEquals( a1, a2, "assertion should not pass" );
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	
	@Test( "test Assert.notDeepEquals with class instance" )
	public function testAssertNotDeepEqualsWithClassInstance() : Void
	{
		var o1 = { p:"property", b:true, o: { p2:"property", b2:true }, i:4, f:1.23 };
		var o2 = { p:"property", b:true, o: { p2:"property", b2:false, }, i:4, f:1.23 };

		Assert.notDeepEquals( o1, o2, "assertion should pass" );
	}
	
	@Test( "test Assert.notDeepEquals with class instance failure" )
	public function testAssertNotDeepEqualsWithClassInstanceFailure() : Void
	{
		var o1 = { p:"property", b:true, o: { p2:"property", b2:true }, i:4, f:1.23 };
		var o2 = { p:"property", b:true, o: { p2:"property", b2:true, }, i:4, f:1.23 };
		
		try 
		{
			Assert.notDeepEquals( o1, o2, "assertion should not pass" );
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	
	@Test( "test Assert.deepEquals with closures" )
	public function testAssertDeepEqualsWithClosures() : Void
	{
		var f0 = function() { };
		var f1 = function() { };
		var f2 = function() { };

		var a1 = [ f0, f1, f2 ];
		var a2 = [ f0, f1, f2 ];
		
		Assert.deepEquals( a1, a2, "assertion should pass" );
	}
	
	@Test( "test Assert.deepEquals with closures failure" )
	public function testAssertDeepEqualsWithClosuresFailure() : Void
	{
		var f0 = function() { };
		var f1 = function() { };
		var f2 = function() { };

		var a1 = [ f0, f1, f2 ];
		var a2 = [ f0, f2 ];
		
		try 
		{
			Assert.deepEquals( a1, a2, "assertion should not pass" );
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	
	@Test( "test Assert.notDeepEquals with closures" )
	public function testAssertNotDeepEqualsWithClosures() : Void
	{
		var f0 = function() { };
		var f1 = function() { };
		var f2 = function() { };

		var a1 = [ f0, f1, f2 ];
		var a2 = [ f0, f2 ];
		
		Assert.notDeepEquals( a1, a2, "assertion should pass" );
	}
	
	@Test( "test Assert.notDeepEquals with closures failure" )
	public function testAssertNotDeepEqualsWithClosuresFailure() : Void
	{
		var f0 = function() { };
		var f1 = function() { };
		var f2 = function() { };

		var a1 = [ f0, f1, f2 ];
		var a2 = [ f0, f1, f2 ];
		
		try 
		{
			Assert.notDeepEquals( a1, a2, "assertion should not pass" );
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	
	@Test( "test Assert.arrayContainsElement" )
	public function testAssertArrayContainsElement() : Void
	{
		var a : Array<Dynamic> = [ 0, 1, 2, 3, this, 5, 6, 7, 8 ];
		Assert.arrayContainsElement( a, this, "assertion should pass" );
	}
	
	@Test( "test Assert.arrayContainsElement failure" )
	public function testAssertArrayContainsElementFailure() : Void
	{
		var a : Array<Dynamic> = [ 0, 1, 2, 3, 4, 5, 6, 7, 8 ];
		
		try 
		{
			Assert.arrayContainsElement( a, this, "assertion should not pass" );
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	
	@Test("test Assert.arrayDeepContainsElement")
	public function testAssertArrayDeepContainsElement()
	{
		var a1 = [{a:1, b:1}, {a:2, b:2}, {a:3, b:3}];
		var element = {a:3, b:3};
		
		Assert.arrayDeepContainsElement(a1, element, "assertion should pass");
	}
	
	@Test("test Assert.arrayDeepContainsElement failure")
	public function testAssertArrayDeepContainsElementFailure()
	{
		var a1 = [{a:1, b:1}, {a:2, b:2}, {a:3, b:3}];
		var element = {a:4, b:4};
		
		try 
		{
			Assert.arrayDeepContainsElement(a1, element, "assertion should pass");
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	
	@Test( "test Assert.arrayContainsElement" )
	public function testAssertArrayNotContainsElement() : Void
	{
		var a : Array<Dynamic> = [ 0, 1, 2, 3, 4, 5, 6, 7, 8 ];
		Assert.arrayNotContainsElement( a, this, "assertion should pass" );
	}
	
	@Test( "test Assert.arrayNotContainsElement failure" )
	public function testAssertArrayNotContainsElementFailure() : Void
	{
		var a : Array<Dynamic> = [ 0, 1, 2, 3, this, 5, 6, 7, 8 ];
		
		try 
		{
			Assert.arrayNotContainsElement( a, this, "assertion should not pass" );
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	
	@Test( "test Assert.arrayContainsElementsFrom" )
	public function testAssertArrayContainsElementsFrom() : Void
	{
		var a1 = [ 0, 1, 2, 3, 4, 5, 6, 7, 8 ];
		var a2 = [ 0, 1, 2, 3, 4, 6, 7, 8 ];
		
		Assert.arrayContainsElementsFrom( a1, a2, "assertion should pass" );
	}
	
	@Test( "test Assert.arrayContainsElementsFrom with less values in random order" )
	public function testAssertArrayContainsElementsFromWithLessValuesInRandomOrder() : Void
	{
		var a1 = [ 0, 1, 2, 3, 4, 5, 6, 7, 8 ];
		var a2 = [ 7, 0, 3 ];
		
		Assert.arrayContainsElementsFrom( a1, a2, "assertion should pass" );
	}
	
	@Test( "test Assert.arrayContainsElementsFrom failure" )
	public function testAssertArrayContainsElementsFromFailure() : Void
	{
		var a1 = [ 0, 1, 2, 3, 4, 5, 6, 7, 8 ];
		var a2 = [ 0, 1, 2, 3, 13 ];
		
		try 
		{
			Assert.arrayContainsElementsFrom( a1, a2, "assertion should not pass" );
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	
	@Test("test Assert.arrayDeepContainsElementsFrom")
	public function testAssertArrayDeepContainsElementsFrom()
	{
		var a1 = [{a:1, b:1}, {a:2, b:2}, {a:3, b:3}];
		var a2 = [{a:1, b:1}, {a:2, b:2}];
		
		Assert.arrayDeepContainsElementsFrom(a1, a2, "assertion should pass");
	}
	
	@Test("test Assert.arrayDeepContainsElementsFrom failure")
	public function testAssertArrayDeepContainsElementsFromFailure()
	{
		var a1 = [{a:1, b:1}, {a:2, b:2}, {a:3, b:3}];
		var a2 = [{a:1, b:1}, {a:4, b:4}];
		try
		{
			Assert.arrayDeepContainsElementsFrom(a1, a2, "assertion should not pass");
		}
		catch (e:AssertException)
		{
			Assert.revertFailure();
		}
		catch (e:Dynamic)
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	
	@Test( "test Assert.constructorIsPrivate" )
	public function testAssertConstructorIsPrivate() : Void
	{
		Assert.constructorIsPrivate( MockClassWithPrivateConstructorException, "assertion should pass" );
	}
	
	@Test( "test Assert.constructorIsPrivate" )
	public function testAssertConstructorIsPrivateFailure() : Void
	{
		try 
		{
			Assert.constructorIsPrivate( MockClassWithoutPrivateConstructorException, "assertion should not pass" );
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	
	@Test( "test Assert.constructorCallThrows" )
	public function testAssertConstructorCallThrows() : Void
	{
		Assert.constructorCallThrows( IllegalArgumentException, MockClassWithConstructorException, [], "assertion should pass" );
	}
	
	@Test( "test Assert.constructorCallThrows failure with wrong exception type" )
	public function testAssertConstructorCallThrowsFailureWithWrongExceptionType() : Void
	{
		try 
		{
			Assert.constructorCallThrows( NoSuchElementException, MockClassWithConstructorException, [], "assertion should not pass" );
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	
	@Test( "test Assert.constructorCallThrows failure with no exception caught" )
	public function testAssertConstructorCallThrowsFailureWithNoExceptionCaught() : Void
	{
		try 
		{
			Assert.constructorCallThrows( IllegalArgumentException, MockClassWithConstructorException, [ false ], "assertion should not pass" );
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	
	@Test( "test Assert.methodCallThrows" )
	public function testAssertMethodCallThrows() : Void
	{
		var o = new MockClassWithMethodThatThrowsException();
		Assert.methodCallThrows( IllegalArgumentException, o, o.call, [], "assertion should pass" );
	}
	
	@Test( "test Assert.methodCallThrows failure with wrong exception type" )
	public function testAssertMethodCallThrowsFailureWithWrongExceptionType() : Void
	{
		var o = new MockClassWithMethodThatThrowsException();
		
		try 
		{
			Assert.methodCallThrows( NoSuchElementException, o, o.call, [], "assertion should not pass" );
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	
	@Test( "test Assert.methodCallThrows failure with no exception caught" )
	public function testAssertMethodCallThrowsFailureWithNoExceptionCaught() : Void
	{
		var o = new MockClassWithMethodThatThrowsException();
		
		try 
		{
			Assert.methodCallThrows( IllegalArgumentException, o, o.call, [ false ], "assertion should not pass" );
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	
	#if !flash
	@Test( "test Assert.setPropertyThrows" )
	public function testAssertSetPropertyThrows() : Void
	{
		var o = new MockClassWithPropertyThatThrowsException();
		Assert.setPropertyThrows( IllegalArgumentException, o, "property", true, "assertion should pass" );
	}
	
	@Test( "test Assert.setPropertyThrows failure with wrong exception type" )
	public function testAssertSetPropertyThrowsFailureWithWrongExceptionType() : Void
	{
		var o = new MockClassWithPropertyThatThrowsException();
		
		try 
		{
			Assert.setPropertyThrows( NoSuchElementException, o, "property", true, "assertion should not pass" );
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	
	@Test( "test Assert.setPropertyThrows failure with no exception caught" )
	public function testAssertSetPropertyThrowsFailureWithNoExceptionCaught() : Void
	{
		var o = new MockClassWithPropertyThatThrowsException();
		
		try 
		{
			Assert.setPropertyThrows( IllegalArgumentException, o, "property", false, "assertion should not pass" );
		}
		catch ( e : AssertException )
		{
			Assert.revertFailure();
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
	}
	#end
	
	@Test( "test Assert.fail" )
	public function testAssertFail() : Void
	{
		var exception : AssertException = null;
		
		var expectedFailedAssertionsCount = Assert.getAssertionFailedCount();
		expectedFailedAssertionsCount++;
		
		var expectedAssertionsCount = Assert.getAssertionCount();
		expectedAssertionsCount++;

		try 
		{
			Assert.fail( "assertMessage", "userMessage" );
		}
		catch ( e : AssertException )
		{
			exception = e;
			Assert.equals( expectedAssertionsCount, Assert.getAssertionCount(), "assertions count should not have been incremented" );
			Assert.equals( expectedFailedAssertionsCount, Assert.getAssertionFailedCount(), "assertions failures count should have been incremented" );
			
			
			Assert.revertFailure();
			
			Assert.equals( expectedFailedAssertionsCount -1, Assert.getAssertionFailedCount(), "assertions failures count should have been decremented after 'revertFailure' call" );
			Assert.equals( expectedAssertionsCount+3, Assert.getAssertionCount(), "assertions count should be the same after 'revertFailure' call" );
		}
		catch ( e : Dynamic )
		{
			Assert.fail( "assertion failed", "assertion failure should return 'AssertException'" );
		}
		
		Assert.isInstanceOf( exception, AssertException, "exception thrown should be an instance of 'AssertException'" );
		Assert.equals( "assertMessage", exception.message, "exception messages should be the same" );
	}
}

private class MockClassForDeepComparison
{
	public var n 	: Int;
	public var b 	: Bool;
	public var s 	: String;
	public var o 	: Dynamic;
	public var i 	: MockClassForDeepComparison;

	public function new( n : Int, b : Bool, s : String, ?o : Dynamic, ?i : MockClassForDeepComparison )
	{
		this.n = n;
		this.b = b;
		this.s = s;
		this.o = o;
		this.i = i;
	}
}

private class MockClassWithConstructorException
{
	public function new( throwException : Bool = true )
	{
		if ( throwException )
		{
			throw new IllegalArgumentException( 'message' );
		}
	}
}

private class MockClassWithMethodThatThrowsException
{
	public function new()
	{
		
	}
	
	public function call( throwException : Bool = true ) : Void
	{
		if ( throwException )
		{
			throw new IllegalArgumentException( 'message' );
		}
	}
}

private class MockClassWithPropertyThatThrowsException
{
	var _property : Bool;
	
	public function new()
	{
		
	}
	
	@:isVar
	public var property( get, set ) : Bool;
	public function get_property() : Bool
	{
		return this._property;
	}

	function set_property( value : Bool = true ) : Bool
	{
		if ( value )
		{
			throw new IllegalArgumentException( 'message' );
		}
		
		this._property = value;
		return this._property;
	}
}

private class MockClassWithPrivateConstructorException
{
	public function new()
	{
		throw new PrivateConstructorException();
	}
}

private class MockClassWithoutPrivateConstructorException
{
	public function new()
	{
		
	}
}