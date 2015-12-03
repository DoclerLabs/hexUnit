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
	@test( "Test 'type' parameter passed to constructor" )
    public function testType() : Void
    {
        var type : String = "type";
		var descriptor : TestClassDescriptor = new TestClassDescriptor( TestRunnerEventTest );
		var target : TestRunner = new TestRunner( descriptor );
        var e : TestRunnerEvent = new TestRunnerEvent( type, target, descriptor );
		
        Assert.equals( type, e.type, "'type' property should be the same passed to constructor" );
    }

    @test( "Test 'target' parameter passed to constructor" )
    public function testTarget() : Void
    {
        var descriptor : TestClassDescriptor = new TestClassDescriptor( TestRunnerEventTest );
		var target : TestRunner = new TestRunner( descriptor );
        var e : TestRunnerEvent = new TestRunnerEvent( "", target, descriptor );

        Assert.equals( target, e.target, "'target' property should be the same passed to constructor" );
    }

    @test( "Test clone method" )
    public function testClone() : Void
    {
        var type : String = "type";
        var descriptor : TestClassDescriptor = new TestClassDescriptor( TestRunnerEventTest );
		var target : TestRunner = new TestRunner( descriptor );
		var ex : Exception = new Exception( "error" );
        var e : TestRunnerEvent = new TestRunnerEvent( type, target, descriptor, 150, ex );
        var clonedEvent : TestRunnerEvent = cast e.clone();
		
		Assert.isInstanceOf( clonedEvent, TestRunnerEvent, "'clonedEvent' should be an instance of 'TestRunnerEvent' class" );

        Assert.equals( type, clonedEvent.type, "'clone' method should return cloned event with same 'type' property" );
        Assert.equals( target, clonedEvent.target, "'clone' method should return cloned event with same 'target' property" );
		Assert.equals( descriptor, e.getDescriptor(), "'getDescriptor' accessor should return property passed to constructor" );
        Assert.equals( 150, e.getTimeElapsed(), "'getTimeElapsed' accessor should return property passed to constructor" );
		Assert.equals( ex, e.getError(), "'getError' accessor should return property passed to constructor" );
    }
	
	@test( "Test parameters passed to constructor with accessors" )
    public function testAccessors() : Void
    {
		var descriptor : TestClassDescriptor = new TestClassDescriptor( TestRunnerEventTest );
		var target : TestRunner = new TestRunner( descriptor );
		var ex : Exception = new Exception( "error" );
        var e : TestRunnerEvent = new TestRunnerEvent( "eventType", target, descriptor, 150, ex );

        Assert.equals( target, e.getRunner(), "'getRunner' accessor should return property passed to constructor" );
        Assert.equals( descriptor, e.getDescriptor(), "'getDescriptor' accessor should return property passed to constructor" );
        Assert.equals( 150, e.getTimeElapsed(), "'getTimeElapsed' accessor should return property passed to constructor" );
		Assert.equals( ex, e.getError(), "'getError' accessor should return property passed to constructor" );
    }
}