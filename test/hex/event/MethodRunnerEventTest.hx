package hex.event;

import hex.error.Exception;
import hex.unittest.assertion.Assert;
import hex.unittest.description.TestMethodDescriptor;
import hex.unittest.event.MethodRunnerEvent;
import hex.unittest.runner.MethodRunner;

/**
 * ...
 * @author Francis Bourre
 */
class MethodRunnerEventTest
{
	@Test( "Test 'type' parameter passed to constructor" )
    public function testType() : Void
    {
        var type : String = "type";
		var methodDescriptor : TestMethodDescriptor = new TestMethodDescriptor( "methodDescriptor", true, true );
		var target : MethodRunner = new MethodRunner( this, methodDescriptor );
        var e : MethodRunnerEvent = new MethodRunnerEvent( type, target, methodDescriptor, 10 );
		
        Assert.equals( type, e.type, "'type' property should be the same passed to constructor" );
    }

    @Test( "Test 'target' parameter passed to constructor" )
    public function testTarget() : Void
    {
        var methodDescriptor : TestMethodDescriptor = new TestMethodDescriptor( "methodDescriptor", true, true );
		var target : MethodRunner = new MethodRunner( this, methodDescriptor );
        var e : MethodRunnerEvent = new MethodRunnerEvent( "", target, methodDescriptor, 10 );

        Assert.equals( target, e.target, "'target' property should be the same passed to constructor" );
    }

    @Test( "Test clone method" )
    public function testClone() : Void
    {
        var type : String = "type";
		var methodDescriptor : TestMethodDescriptor = new TestMethodDescriptor( "methodDescriptor", true, true );
		var target : MethodRunner = new MethodRunner( this, methodDescriptor );
		var ex : Exception = new Exception( "error" );
        var e : MethodRunnerEvent = new MethodRunnerEvent( type, target, methodDescriptor, 10, ex );
        var clonedEvent : MethodRunnerEvent = cast e.clone();
		
		Assert.isInstanceOf( clonedEvent, MethodRunnerEvent, "'clonedEvent' should be an instance of 'MethodRunnerEvent' class" );

        Assert.equals( type, clonedEvent.type, "'clone' method should return cloned event with same 'type' property" );
        Assert.equals( target, clonedEvent.target, "'clone' method should return cloned event with same 'target' property" );
		Assert.equals( methodDescriptor, e.getDescriptor(), "'getDescriptor' accessor should return property passed to constructor" );
        Assert.equals( 10, e.getTimeElapsed(), "'getTimeElapsed' accessor should return property passed to constructor" );
		Assert.equals( ex, e.getError(), "'getError' accessor should return property passed to constructor" );
    }
	
	@Test( "Test parameters passed to constructor with accessors" )
    public function testAccessors() : Void
    {
		var ex : Exception = new Exception( "error" );
		var methodDescriptor : TestMethodDescriptor = new TestMethodDescriptor( "methodDescriptor", true, true );
		var target : MethodRunner = new MethodRunner( this, methodDescriptor );
        var e : MethodRunnerEvent = new MethodRunnerEvent( "eventType", target, methodDescriptor, 10, ex );

        Assert.equals( target, e.getRunner(), "'getRunner' accessor should return property passed to constructor" );
        Assert.equals( methodDescriptor, e.getDescriptor(), "'getDescriptor' accessor should return property passed to constructor" );
        Assert.equals( 10, e.getTimeElapsed(), "'getTimeElapsed' accessor should return property passed to constructor" );
		Assert.equals( ex, e.getError(), "'getError' accessor should return property passed to constructor" );
    }
}