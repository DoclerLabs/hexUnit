package hex.unittest.runner;
import hex.unittest.description.MethodDescriptor;

#if macro
import haxe.macro.*;
import haxe.macro.Expr;
import haxe.macro.Type;
import hex.error.Exception;
import hex.unittest.event.ITestClassResultListener;
import hex.unittest.description.ClassDescriptor;
import hex.util.MacroUtil;

using hex.unittest.description.ClassDescriptorUtil;
#end

/**
 * ...
 * @author Francis Bourre
 */
class TestGenerator 
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	#if gentest
	macro public static function generate( testableClass : haxe.macro.Expr.ExprOf<Class<Dynamic>> )
	{
		var stringClassRepresentation 	= ClassDescriptorGenerator.getStringClassRepresentation( testableClass );
		var classDescriptor 			= ClassDescriptorGenerator.parseClass( ClassDescriptorGenerator.getClassDescriptor( stringClassRepresentation ) );
		
		return TestGenerator.genCode( classDescriptor );
	}
	#end
	
	#if macro
	static function genCode( classDescriptor : ClassDescriptor ) : ExprOf<hex.unittest.runner.ITestRunner>
	{
		var expressions = [ macro { } ];
		var runnerBody 	= [ macro {} ];
		var runnerTD 	= _generateRunner();
		
		//Start Tests
		var descriptor = ClassDescriptorGenerator.generateClass( classDescriptor );
		runnerBody.push(
			macro @:mergeBlock 
			{
				var descriptor : hex.unittest.description.ClassDescriptor = $descriptor;
				hex.unittest.assertion.Assert.resetAssertionLog();
				this.onStartRun( descriptor );
				var time = 0.0;
				var runTest : hex.unittest.description.ClassDescriptor->Void = null;
			}
		);
		
		//Parse tests
		_parseDescriptor( classDescriptor, runnerBody );
		
		//End Tests
		runnerBody.push( macro @:mergeBlock { this.onEndRun( descriptor ); } );

		//Implement run
		runnerTD.fields.push(
		{
			name: 'run',
			pos: haxe.macro.Context.currentPos(),
			kind: FFun( 
			{
				args: [],
				ret: macro : Void,
				expr: macro $b{ runnerBody }
			}),
			access: [ APublic ]
		});
		
		//Define and instantiate runner class
		haxe.macro.Context.defineType( runnerTD );
		var typePath = MacroUtil.getTypePath( 'hex.unittest.generator.TestClassResultTrigger' );
		descriptor = ClassDescriptorGenerator.generateClass( classDescriptor );
		expressions.push( macro @:mergeBlock { new $typePath(); } );

		return 
		{
			expr: ECheckType
			( 
				macro $b{ expressions },
				macro :hex.unittest.runner.ITestRunner
			), 	pos: Context.currentPos()
		};
	}
	
	static function _parseDescriptor( classDescriptor : ClassDescriptor, runnerBody : Array<Expr> )
	{
		if ( classDescriptor.isSuiteClass )
		{
			_parseSuite( classDescriptor, runnerBody );
		}
		else
		{
			_parseTest( classDescriptor, runnerBody );
		}
	}
	
	static function _parseSuite( classDescriptor : ClassDescriptor, runnerBody : Array<Expr> )
	{
		var descriptor = ClassDescriptorGenerator.generateClass( classDescriptor );
		runnerBody.push(
				macro @:mergeBlock 
				{
					descriptor = $descriptor;
					this.onSuiteClassStartRun( descriptor );
				}
			);
		
		for ( test in classDescriptor.classDescriptors )
		{
			_parseDescriptor( test, runnerBody );
		}
		
		runnerBody.push(
				macro @:mergeBlock 
				{
					descriptor = $descriptor;
					this.onSuiteClassEndRun( descriptor );
				}
			);
	}
	
	static function _parseTest( classDescriptor : ClassDescriptor, runnerBody : Array<Expr> )
	{
		//Instantiate test class
		var testClass = MacroUtil.getTypePath( classDescriptor.className );
		runnerBody.push( macro @:mergeBlock { var test = new $testClass(); } );
		
		var descriptor = ClassDescriptorGenerator.generateClass( classDescriptor );
		runnerBody.push( macro @:mergeBlock { descriptor = $descriptor; } );
		runnerBody.push( macro @:mergeBlock { this.onTestClassStartRun( descriptor ); } );
		
		if ( classDescriptor.beforeClassFieldName != null )
		{
			var before = classDescriptor.beforeClassFieldName;
			runnerBody.push( macro @:mergeBlock { $p{ MacroUtil.getPack( classDescriptor.className ) }.$before(); } );
		}
		
		for ( m in classDescriptor.methodDescriptors ) 
		{
			runnerBody = m.isAsync ? _parseAsyncMethod( m, classDescriptor, runnerBody ) : _parseSyncMethod( m, classDescriptor, runnerBody );
		}
		
		if ( classDescriptor.afterClassFieldName != null )
		{
			var after = classDescriptor.afterClassFieldName;
			runnerBody.push( macro @:mergeBlock { $p{ MacroUtil.getPack( classDescriptor.className ) }.$after(); } );
		}
		
		runnerBody.push( macro @:mergeBlock { this.onTestClassEndRun( descriptor ); } );
	}
	
	static function _parseAsyncMethod( m : MethodDescriptor, classDescriptor : ClassDescriptor, runnerBody : Array<Expr> )
	{
		var testBody = [ macro {} ];
		
		if ( classDescriptor.setUpFieldName != null )
		{
			var setup = classDescriptor.setUpFieldName;
			testBody.push( macro @:mergeBlock { test.$setup(); } );
		}
		
		var methodName = m.methodName;
		var provider = m.dataProviderFieldName;
		var methodCall;

		if ( provider == '' )
		{
			methodCall = macro test.$methodName();
		}
		else
		{
			methodCall = macro test.$methodName( $p{ MacroUtil.getPack( classDescriptor.className ) }.$provider[ $v{m.dataProviderIndex} ] );
		}

		testBody.push( macro @:mergeBlock 
			{
				time = Date.now().getTime();
				try
				{
					$methodCall;
				}
				catch ( err : Dynamic )
				{
					this._notifyError( d, Date.now().getTime() - time, err );
				}
			});
		
		testBody.push( macro @:mergeBlock { this.onSuccess( d, Date.now().getTime() - time ); } );
		
		if ( classDescriptor.tearDownFieldName != null )
		{
			var teardown = classDescriptor.tearDownFieldName;
			testBody.push( macro @:mergeBlock { test.$teardown(); } );
		}
		
		runnerBody.push( macro @:mergeBlock { runTest = function( d : hex.unittest.description.ClassDescriptor ) { $b { testBody }; }; runTest( descriptor ); descriptor.methodIndex++; } );
		
		return runnerBody;
	}
	
	static function _parseSyncMethod( m : MethodDescriptor, classDescriptor : ClassDescriptor, runnerBody : Array<Expr> )
	{
		var testBody = [ macro {} ];
		
		if ( classDescriptor.setUpFieldName != null )
		{
			var setup = classDescriptor.setUpFieldName;
			testBody.push( macro @:mergeBlock { test.$setup(); } );
		}
		
		var methodName = m.methodName;
		var provider = m.dataProviderFieldName;
		var methodCall;

		if ( provider == '' )
		{
			methodCall = macro test.$methodName();
		}
		else
		{
			methodCall = macro test.$methodName( $p{ MacroUtil.getPack( classDescriptor.className ) }.$provider[ $v{m.dataProviderIndex} ] );
		}

		testBody.push( macro @:mergeBlock 
			{
				time = Date.now().getTime();
				try
				{
					$methodCall;
				}
				catch ( err : Dynamic )
				{
					this._notifyError( d, Date.now().getTime() - time, err );
				}
			});
		
		testBody.push( macro @:mergeBlock { this.onSuccess( d, Date.now().getTime() - time ); } );
		
		if ( classDescriptor.tearDownFieldName != null )
		{
			var teardown = classDescriptor.tearDownFieldName;
			testBody.push( macro @:mergeBlock { test.$teardown(); } );
		}
		
		runnerBody.push( macro @:mergeBlock { runTest = function( d : hex.unittest.description.ClassDescriptor ) { $b { testBody }; }; runTest( descriptor ); descriptor.methodIndex++; } );
		
		return runnerBody;
	}
	
	static function _generateRunner() : TypeDefinition
	{
		var className 					= "TestClassResultTrigger";
		var ctITestClassResultListener 	= macro:hex.unittest.event.ITestClassResultListener;
		var ctClassDescriptor 			= macro:hex.unittest.description.ClassDescriptor;
		var ctException 				= macro:hex.error.Exception;
		var tpITestRunner 				= MacroUtil.getTypePath( 'hex.unittest.runner.ITestRunner' );
		
		var classExpr = 
		macro class $className implements $tpITestRunner
		{
			var _inputs : Array<$ctITestClassResultListener>;

			public function new() 
			{
				this._inputs = [];
			}
			
			function _notifyError( classDescriptor : $ctClassDescriptor, timeElapsed : Float, e : Dynamic )
			{
				if ( !Std.is( e, hex.error.Exception ) )
				{
					var err : hex.error.Exception = null;
					#if php
					err = new hex.error.Exception( "" + e, e.p );
					#elseif flash
					err = new hex.error.Exception( cast( e ).message );
					#else
					err = new hex.error.Exception( e.toString(), e.posInfos );
					#end
					this.onFail( classDescriptor, timeElapsed, err );
					hex.unittest.assertion.Assert._logFailedAssertion();
				}
				else
				{
					this.onFail( classDescriptor, timeElapsed, e );
					hex.unittest.assertion.Assert._logFailedAssertion();
				}
			}
			
			public function addListener( listener : $ctITestClassResultListener ) : Bool
			{
				return this.connect( listener );
			}

			public function removeListener( listener : $ctITestClassResultListener ) : Bool
			{
				return this.disconnect( listener );
			}

			public function connect( input : $ctITestClassResultListener ) : Bool
			{
				if ( this._inputs.indexOf( input ) == -1 )
				{
					this._inputs.push( input );
					return true;
				}
				else
				{
					return false;
				}
			}

			public function disconnect( input : $ctITestClassResultListener ) : Bool
			{
				var index = this._inputs.indexOf( input );
				
				if ( index > -1 )
				{
					this._inputs.splice( index, 1 );
					return true;
				}
				else
				{
					return false;
				}
			}
			
			public function disconnectAll() : Void
			{
				this._inputs = [];
			}
			
			public function onStartRun( descriptor : $ctClassDescriptor ) : Void
			{
				var inputs = this._inputs.copy();
				for ( input in inputs ) input.onStartRun( descriptor );
			}
			
			public function onEndRun( descriptor : $ctClassDescriptor ) : Void
			{
				var inputs = this._inputs.copy();
				for ( input in inputs ) input.onEndRun( descriptor );
			}

			public function onSuiteClassStartRun( descriptor : $ctClassDescriptor ) : Void
			{
				var inputs = this._inputs.copy();
				for ( input in inputs ) input.onSuiteClassStartRun( descriptor );
			}
			
			public function onSuiteClassEndRun( descriptor : $ctClassDescriptor ) : Void
			{
				var inputs = this._inputs.copy();
				for ( input in inputs ) input.onSuiteClassEndRun( descriptor );
			}
			
			public function onTestClassStartRun( descriptor : $ctClassDescriptor ) : Void
			{
				var inputs = this._inputs.copy();
				for ( input in inputs ) input.onTestClassStartRun( descriptor );
			}
			
			public function onTestClassEndRun( descriptor : $ctClassDescriptor ) : Void
			{
				var inputs = this._inputs.copy();
				for ( input in inputs ) input.onTestClassEndRun( descriptor );
			}
			
			public function onSuccess( descriptor : $ctClassDescriptor, timeElapsed : Float ) : Void
			{
				var inputs = this._inputs.copy();
				for ( input in inputs ) input.onSuccess( descriptor, timeElapsed );
			}
			
			public function onFail( descriptor : $ctClassDescriptor, timeElapsed : Float, error : $ctException ) : Void
			{
				var inputs = this._inputs.copy();
				for ( input in inputs ) input.onFail( descriptor, timeElapsed, error );
			}
			
			public function onTimeout( descriptor : $ctClassDescriptor, timeElapsed : Float, error : $ctException ) : Void
			{
				var inputs = this._inputs.copy();
				for ( input in inputs ) input.onTimeout( descriptor, timeElapsed, error );
			}
			
			public function onIgnore( descriptor : $ctClassDescriptor ) : Void
			{
				var inputs = this._inputs.copy();
				for ( input in inputs ) input.onIgnore( descriptor );
			}
		};
		
		classExpr.pack = [ "hex", "unittest", "generator" ];
		return classExpr;
	}
	#end
}