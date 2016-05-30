package hex.event;

import hex.error.Exception;
import hex.unittest.assertion.Assert;
import hex.unittest.description.TestClassDescriptor;
import hex.unittest.event.TestRunnerEvent;
import hex.unittest.runner.TestRunner;

/**
 * ...
 * @author Francis Bourre
 */
class TestRunnerEventTest
{
	public function new( )
	{
		
	}
	
	@Test( "Test 'type' parameter passed to constructor" )
    public function testType() : Void
    {
        var type : String = "type";
		var descriptor = new TestClassDescriptor( TestRunnerEventTest );
		var target = new TestRunner( descriptor );
        var e = new TestRunnerEvent( type, target, descriptor );
		
        Assert.equals( type, e.type, "'type' property should be the same passed to constructor" );
    }

    @Test( "Test 'target' parameter passed to constructor" )
    public function testTarget() : Void
    {
        var descriptor = new TestClassDescriptor( TestRunnerEventTest );
		var target = new TestRunner( descriptor );
        var e = new TestRunnerEvent( "", target, descriptor );

        Assert.equals( target, e.target, "'target' property should be the same passed to constructor" );
    }

    @Test( "Test clone method" )
    public function testClone() : Void
    {
        var type : String = "type";
        var descriptor = new TestClassDescriptor( TestRunnerEventTest );
		var target = new TestRunner( descriptor );
		var ex = new Exception( "error" );
        var e = new TestRunnerEvent( type, target, descriptor, 150, ex );
        var clonedEvent : TestRunnerEvent = cast e.clone();
		
		Assert.isInstanceOf( clonedEvent, TestRunnerEvent, "'clonedEvent' should be an instance of 'TestRunnerEvent' class" );

        Assert.equals( type, clonedEvent.type, "'clone' method should return cloned event with same 'type' property" );
        Assert.equals( target, clonedEvent.target, "'clone' method should return cloned event with same 'target' property" );
		Assert.equals( descriptor, e.getDescriptor(), "'getDescriptor' accessor should return property passed to constructor" );
        Assert.equals( 150, e.getTimeElapsed(), "'getTimeElapsed' accessor should return property passed to constructor" );
		Assert.equals( ex, e.getError(), "'getError' accessor should return property passed to constructor" );
    }
	
	@Test( "Test parameters passed to constructor with accessors" )
    public function testAccessors() : Void
    {
		var descriptor = new TestClassDescriptor( TestRunnerEventTest );
		var target = new TestRunner( descriptor );
		var ex = new Exception( "error" );
        var e = new TestRunnerEvent( "eventType", target, descriptor, 150, ex );

        Assert.equals( target, e.getRunner(), "'getRunner' accessor should return property passed to constructor" );
        Assert.equals( descriptor, e.getDescriptor(), "'getDescriptor' accessor should return property passed to constructor" );
        Assert.equals( 150, e.getTimeElapsed(), "'getTimeElapsed' accessor should return property passed to constructor" );
		Assert.equals( ex, e.getError(), "'getError' accessor should return property passed to constructor" );
    }
}