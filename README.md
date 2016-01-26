# hexUnit
[![TravisCI Build Status](https://travis-ci.org/DoclerLabs/hexUnit.svg?branch=master)](https://travis-ci.org/DoclerLabs/hexUnit)
OOP Unit testing framework written in Haxe.

![alt tag](https://github.com/DoclerLabs/hexUnit/blob/master/hexunit.png)


## Dependencies

* [hexCore](https://github.com/DoclerLabs/hexCore)

	
## Features

- Tests and suites are generated with annotations. No inheritance and implementation needed.
- Asynchronous testing.
- Solution event based. Define your own console/system to display/write your results.
- Compatible with NodeJS for Travis integration.
- Possibility to test only one method (For shortcut IDE integration)


## List of metadatas
- @Test
- @Async
- @Ignore
- @Before
- @After
- @BeforeClass
- @AfterClass
- @Suite


## Assertions provided

- isTrue
- isFalse
- isNull
- isNotNull
- isInstanceOf
- isNotInstanceOf
- equals
- deepEquals
- arrayContains
- notEquals
- constructorCallThrows
- methodCallThrows
- setPropertyThrows


## FlashDevelop integration
Macro designed for FlashDevelop to run only one unit test class or a test function (instead of a whole suit)
You can download it [here](https://github.com/DoclerLabs/hex3rdPartyTools/tree/master/utilities/unittest/FlashDevelopMacro) 


## How to run framework tests inside the browser
```haxe
var emu = new ExMachinaUnitCore();
emu.addListener( new BrowserUnitTestNotifier( "console" ) );
emu.addTest( HexMVCSuite );
emu.addTest( HexCoreSuite );
emu.addTest( HexInjectSuite );
emu.addTest( HexMachinaSuite );
emu.addTest( HexUnitSuite );
emu.run();
```


## How to run tests with NodeJS (you can mix tests classes with suites)
```haxe
var emu = new ExMachinaUnitCore();
emu.addListener( new ConsoleNotifier(false) );
emu.addTest( InjectorTest );
emu.addTest( HexCoreSuite );
emu.run();
```


## How to test only one method
```haxe
var emu = new ExMachinaUnitCore();
emu.addListener( new BrowserUnitTestNotifier( "console" ) );
emu.addTestMethod( InjectorTest, "get_instance_errors_for_unmapped_class" );
emu.run();
```


## Suite example (you can mix tests classes with suites)
```haxe
class AsyncSuite
{
	@Suite("Async suite")
    public var list : Array<Class<Dynamic>> = [AsyncCommandSuite, AsyncCommandTest];
}
```


## Test example
```haxe
class DomainTest
{
    @Test( "Test 'name' property passed to constructor" )
    public function testConstructor() : Void
    {
        var domain = new Domain( "testConstructor" );
        Assert.equals( "testConstructor", domain.getName(), "'name' property should be the same passed to constructor" );
    }

    @Test( "Test null 'name' value passed to constructor" )
    public function testConstructorNullException() : Void
    {
        Assert.constructorCallThrows( NullPointerException, Domain, [], "" );
    }

    @Test( "Test using twice the same 'name' value" )
    public function testConstructorWithNameValues() : Void
    {
        var domain = new Domain( "testConstructorWithNameValues" );
        Assert.constructorCallThrows( IllegalArgumentException, Domain, ["testConstructorWithNameValues"], "" );
    }
}
```


## Asynchronous test example
```haxe
@Async( "Test every command was executed" )
public function testHasRunEveryCommand() : Void
{
	this._macroExecutor.add( MockAsyncCommand );
	Assert.failTrue( this._macroExecutor.hasRunEveryCommand, "'hasRunEveryCommand' should return false" );
	this._macroExecutor.executeNextCommand();
	Timer.delay( MethodRunner.asyncHandler( this._onTestHasRunEveryCommand ), 100 );
}

private function _onTestHasRunEveryCommand() : Void
{
	Assert.isTrue( this._macroExecutor.hasRunEveryCommand, "'hasRunEveryCommand' should return true" );
}
```