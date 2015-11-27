# hexUnit
[![TravisCI Build Status](https://travis-ci.org/DoclerLabs/hexUnit.svg?branch=master)](https://travis-ci.org/DoclerLabs/hexUnit)
OOP Unit testing framework written in Haxe.


## Dependencies

* [hexCore](https://github.com/DoclerLabs/hexCore)

	
## Features

- Tests and suites are generated with annotations. No inheritance and implementation needed.
- Asynchronous testing.
- Solution event based. Define your own console/system to display/write your results.
- Compatible with NodeJS for Travis integration.


## List of metadatas
- @test
- @async
- @ignore
- @setUp
- @tearDown
- @beforeClass
- @afterClass
- @suite


## Assertions provided

- assertTrue
- ailTrue
- assertIsNull
- failIsNull
- assertIsType
- failIsType
- assertEquals
- assertDeepEquals
- assertArrayContains
- failEquals
- assertConstructorCallThrows
- assertMethodCallThrows
- assertSetPropertyThrows


## How to run framework tests inside the browser
```haxe
var emu : ExMachinaUnitCore = new ExMachinaUnitCore();
emu.addListener( new BrowserUnitTestNotifier( "console" ) );
emu.addTest( HexMVCSuite );
emu.addTest( HexCoreSuite );
emu.addTest( HexInjectSuite );
emu.addTest( HexMachinaSuite );
emu.addTest( HexUnitSuite );
emu.run();
```


## How to run framework tests inside NodeJS
```haxe
var emu : ExMachinaUnitCore = new ExMachinaUnitCore();
emu.addListener( new ConsoleNotifier(false) );
emu.addTest( HexMVCSuite );
emu.addTest( HexCoreSuite );
emu.addTest( HexInjectSuite );
emu.addTest( HexMachinaSuite );
emu.addTest( HexUnitSuite );
emu.run();
```


## Suite example
```haxe
class AsyncSuite
{
	@suite("Async suite")
    public var list : Array<Class<Dynamic>> = [AsyncCommandEventTest, AsyncCommandTest, AsyncCommandUtilTest ];
}
```


## Test example
```haxe
class DomainTest
{
    @test( "Test 'name' property passed to constructor" )
    public function testConstructor() : Void
    {
        var domain : Domain = new Domain( "testConstructor" );
        Assert.assertEquals( "testConstructor", domain.getName(), "'name' property should be the same passed to constructor" );
    }

    @test( "Test null 'name' value passed to constructor" )
    public function testConstructorNullException() : Void
    {
        Assert.assertConstructorCallThrows( NullPointerException, Domain, [], "" );
    }

    @test( "Test using twice the same 'name' value" )
    public function testConstructorWithNameValues() : Void
    {
        var domain : Domain = new Domain( "testConstructorWithNameValues" );
        Assert.assertConstructorCallThrows( IllegalArgumentException, Domain, ["testConstructorWithNameValues"], "" );
    }
}
```