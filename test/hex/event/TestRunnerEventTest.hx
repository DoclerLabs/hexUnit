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
		
        Assert.assertEquals( type, e.type, "'type' property should be the same passed to constructor" );
    }

    @test( "Test 'target' parameter passed to constructor" )
    public function testTarget() : Void
    {
        var descriptor : TestClassDescriptor = new TestClassDescriptor( TestRunnerEventTest );
		var target : TestRunner = new TestRunner( descriptor );
        var e : TestRunnerEvent = new TestRunnerEvent( "", target, descriptor );

        Assert.assertEquals( target, e.target, "'target' property should be the same passed to constructor" );
    }

    @test( "Test clone method" )
    public function testClone() : Void
    {
        var type : String = "type";
        var descriptor : TestClassDescriptor = new TestClassDescriptor( TestRunnerEventTest );
		var target : TestRunner = new TestRunner( descriptor );
        var e : TestRunnerEvent = new TestRunnerEvent( type, target, descriptor );
        var clonedEvent : TestRunnerEvent = cast e.clone();

        Assert.assertEquals( type, clonedEvent.type, "'clone' method should return cloned event with same 'type' property" );
        Assert.assertEquals( target, clonedEvent.target, "'clone' method should return cloned event with same 'target' property" );
    }
	
	@test( "Test parameters passed to constructor with accessors" )
    public function testAccessors() : Void
    {
		var descriptor : TestClassDescriptor = new TestClassDescriptor( TestRunnerEventTest );
		var target : TestRunner = new TestRunner( descriptor );
		var ex : Exception = new Exception( "error" );
        var e : TestRunnerEvent = new TestRunnerEvent( "eventType", target, descriptor, 150, ex );

        Assert.assertEquals( target, e.getRunner(), "'getRunner' accessor should return property passed to constructor" );
        Assert.assertEquals( descriptor, e.getDescriptor(), "'getDescriptor' accessor should return property passed to constructor" );
        Assert.assertEquals( 150, e.getTimeElapsed(), "'getTimeElapsed' accessor should return property passed to constructor" );
		Assert.assertEquals( ex, e.getError(), "'getError' accessor should return property passed to constructor" );
    }
}