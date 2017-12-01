package hex.unittest.runner;

#if macro
import haxe.macro.*;
import haxe.macro.Expr;
import haxe.macro.Type;
import hex.unittest.description.ClassDescriptor;
import hex.unittest.description.MethodDescriptor;
import hex.unittest.metadata.MetadataList;
import hex.util.MacroUtil;

using hex.unittest.description.ClassDescriptorUtil;
using Lambda;
#end

/**
 * ...
 * @author Francis Bourre
 */
class ClassDescriptorGenerator 
{
	/** @private */ function new() throw new hex.error.PrivateConstructorException();
	
	macro public static function generate( testableClass : haxe.macro.Expr.ExprOf<Class<Dynamic>> )
	{
		var stringClassRepresentation = _getStringClassRepresentation( testableClass );
		var classDescriptor = _parseClass( _getClassDescriptor( stringClassRepresentation ) );
		return ExprUtil.genClass( classDescriptor );
	}
	
	#if macro
	static function _parseClass( classDescriptor : ClassDescriptor ) : ClassDescriptor
	{
		var hasMeta = MetaUtil.hasMeta;
		var description = MetaUtil.getDescription;
		
		switch( Context.getType( classDescriptor.className ) )
		{
			case TInst( instance, a ):
				var fields = _getFields( instance.get(), [] );

				for ( field in fields )
				{
					var meta = field.meta.get();
					
					//We got a suite here
					if ( hasMeta( MetadataList.SUITE, meta ) )
					{
						_parseSuite( classDescriptor, field, description( MetadataList.SUITE, meta ) );
					}
					
					//This is a test method
					else if ( hasMeta( MetadataList.TEST, meta ) )
					{
						_addTest( classDescriptor, instance.get().statics.get(), MetadataList.TEST, field, meta );
					}
					else if ( hasMeta( MetadataList.ASYNC, meta ) )
					{
						_addTest( classDescriptor, instance.get().statics.get(), MetadataList.ASYNC, field, meta );
					}
					else if ( hasMeta( MetadataList.IGNORE, meta ) )
					{
						_addTest( classDescriptor, instance.get().statics.get(), MetadataList.IGNORE, field, meta );
					}
					else if ( hasMeta( MetadataList.BEFORE, meta )  )
					{
						classDescriptor.setUpFieldName = field.name;
					}
					else if ( hasMeta( MetadataList.AFTER, meta )  )
					{
						classDescriptor.tearDownFieldName = field.name;
					}
				}
				
				for ( field in instance.get().statics.get() )
				{
					var meta = field.meta.get();
					if ( hasMeta( MetadataList.BEFORE_CLASS, meta ) )
					{
						classDescriptor.beforeClassFieldName = field.name;
					}
					else if ( hasMeta( MetadataList.AFTER_CLASS, meta )  )
					{
						classDescriptor.afterClassFieldName = field.name;
					}
				}
				
			case _:
		}
		
		return classDescriptor;
	}
	
	public static function _addTest( classDescriptor : ClassDescriptor, statics : Array<ClassField>, metaName : String, field, meta, description : String = "" )
	{
		var description = MetaUtil.getDescription;
		var dataProvider = MetaUtil.getDataProvider;
		var dataProviderFieldName = dataProvider( MetadataList.DATA_PROVIDER, meta );
		var length = _getDataProviderLength( dataProviderFieldName, classDescriptor, statics );
		
		for ( i in 0...length ) classDescriptor.methodDescriptors.push( _parseTest( _getMethodDescriptor( field.name ), field, description( metaName, meta ), dataProviderFieldName, i ) );
	}
	
	static function _getDataProviderLength( dataProviderFieldName, classDescriptor : ClassDescriptor, statics : Array<ClassField> )
	{
		return if ( dataProviderFieldName != "" )
		{
			var field = statics.find( function ( field ) return field.name == dataProviderFieldName );
			if ( field != null )
			{
				return switch( field.expr().expr )
				{
					case TArrayDecl( a ): a.length;
					case _: 1;
				}
			} else 1;
		} else 1;
	}
	
	public static function _parseTest( 
										methodDescriptor 		: MethodDescriptor, 
										field 					: ClassField, 
										description 			: String = "", 
										dataProviderFieldName 	: String = "", 
										dataProviderIndex 		: UInt = 0 )
	{
		var meta 								= field.meta.get();
		methodDescriptor.isAsync 				= MetaUtil.hasMeta( MetadataList.ASYNC, meta );
		if ( methodDescriptor.isAsync ) methodDescriptor.timeout = MetaUtil.getTimeout( meta );
		
		methodDescriptor.isIgnored 				= MetaUtil.hasMeta( MetadataList.IGNORE, meta );
		methodDescriptor.description 			= description;
		methodDescriptor.dataProviderFieldName	= dataProviderFieldName;
		methodDescriptor.dataProviderIndex		= dataProviderIndex;

		return methodDescriptor;
	}
	
	public static function _parseSuite( cd : ClassDescriptor, field, description : String = "" )
	{
		cd.isSuiteClass = true;
		cd.name = description;
		var e = Context.getTypedExpr( field.expr() );
		switch( e.expr )
		{
			case EArrayDecl( values ):
				values.iter( 
					function( value ) cd.classDescriptors.push( _parseClass( _getClassDescriptor( MacroUtil.compressField( value ) ) ) )
				);

			case _:
		}
	}
	
	static function _getStringClassRepresentation( clazz : haxe.macro.Expr.ExprOf<Class<Dynamic>> ) : String
	{
		switch( clazz.expr )
		{
			case EConst(CIdent( className )):
				return MacroUtil.getFQCNFromComplexType( TypeTools.toComplexType(Context.getType( className )) );
			case _:
		}
		
		Context.error( "Invalid Class", clazz.pos );
		return null;
	}
	
	static function _getFields( ct : ClassType, fields : Array<ClassField> )
	{
		fields = fields.concat( ct.fields.get() );
		if ( ct.superClass != null ) _getFields( ct.superClass.t.get(), fields );
		return fields;
	}
	
	static function _getClassDescriptor( className ) : ClassDescriptor
		return
		{
			instance: 				null,
			className:				className,
			isSuiteClass: 			false,
			beforeClassFieldName: 	null,
			afterClassFieldName: 	null,
			setUpFieldName: 		null,
			tearDownFieldName: 		null,
			classDescriptors: 		[],
			methodDescriptors: 		[],
			classIndex: 			0,
			methodIndex: 			0,
			name:					""
		}
		
	static function _getMethodDescriptor( methodName : String ) : MethodDescriptor
		return
		{
			methodName: 			methodName,
			isAsync:				false,
			isIgnored:				false,
			description:			"",
			timeout:				1500,
			dataProviderFieldName:	"",
			dataProviderIndex:		0
		}
	#end
}

#if macro
class MetaUtil
{
	inline public static function hasMeta( name : String, m : Expr.Metadata )
		return m.find( function f(m) return m.name == name ) != null;
		
	inline public static function getDescription( name : String, m : Expr.Metadata )
	{
		var meta = m.find( function f(m) return m.name == name );
		return meta == null || meta.params.length == 0 ? '' : switch( meta.params[ 0 ].expr )
		{
			case EConst(CString(description)): description;
			case _: '';
		};
	}
	
	inline public static function getDataProvider( name : String, m : Expr.Metadata )
	{
		var meta = m.find( function f(m) return m.name == name );
		return meta == null || meta.params.length == 0 ? "" : switch( meta.params[ 0 ].expr )
		{
			case EConst(CString(dataProviderFieldName)): dataProviderFieldName;
			case _: "";
		};
	}
	
	inline public static function getTimeout( m : Expr.Metadata )
	{
		var meta = m.find( function f(m) return m.name == MetadataList.TIMEOUT );
		return meta == null || meta.params.length == 0 ? 1500 : switch( meta.params[ 0 ].expr )
		{
			case EConst(CInt(value)): Std.parseInt( value );
			case _: 1500;
		};
	}
}

class ExprUtil
{
	public static function genClass( classDescriptor : ClassDescriptor ) : ExprOf<ClassDescriptor>
	{
		return 
		{
			expr: EObjectDecl([
					{ field: "instance", 				expr: macro $v { null } }, 
					{ field: "type", 					expr: macro $p { MacroUtil.getPack( classDescriptor.className ) } }, 
					{ field: "className", 				expr: macro $v { classDescriptor.className } }, 
					{ field: "isSuiteClass", 			expr: macro $v { classDescriptor.isSuiteClass }}, 
					{ field: "beforeClassFieldName", 	expr: macro $v { classDescriptor.beforeClassFieldName } },
					{ field: "afterClassFieldName", 	expr: macro $v { classDescriptor.afterClassFieldName } }, 
					{ field: "setUpFieldName", 			expr: macro $v { classDescriptor.setUpFieldName } }, 
					{ field: "tearDownFieldName", 		expr: macro $v { classDescriptor.tearDownFieldName } }, 
					{ field: "classDescriptors", 		expr: genClassDesc( classDescriptor.classDescriptors ) }, 
					{ field: "methodDescriptors", 		expr: genMethodDesc( classDescriptor.methodDescriptors ) }, 
					{ field: "classIndex", 				expr: macro $v { classDescriptor.classIndex } }, 
					{ field: "methodIndex", 			expr: macro $v { classDescriptor.methodIndex } }, 
					{ field: "name", 					expr: macro $v { classDescriptor.name } }, 
					
				]), 
			pos: Context.currentPos() 
		};
	}
	
	inline public static function genClassDesc( a : Array<ClassDescriptor> )
	{
		var values = [ for ( e in a ) genClass( e ) ];
		return macro ($a { values } :Array<hex.unittest.description.ClassDescriptor>);
	}
	
	inline public static function genMethodDesc( a : Array<MethodDescriptor> )
	{
		var values = [ for ( e in a ) genMethod( e ) ];
		return macro ($a { values } :Array<hex.unittest.description.MethodDescriptor>);
	}
	
	inline public static function genMethod( methodDescriptor : MethodDescriptor )
	{
		return 
		{
			expr: EObjectDecl([
					{ field: "methodName", 				expr: macro $v { methodDescriptor.methodName } }, 
					{ field: "isAsync", 				expr: macro $v { methodDescriptor.isAsync }}, 
					{ field: "isIgnored", 				expr: macro $v { methodDescriptor.isIgnored } },
					{ field: "description", 			expr: macro $v { methodDescriptor.description } }, 
					{ field: "timeout", 				expr: macro $v { methodDescriptor.timeout } }, 
					{ field: "dataProviderFieldName", 	expr: macro $v { methodDescriptor.dataProviderFieldName } }, 
					{ field: "dataProviderIndex", 		expr: macro $v { methodDescriptor.dataProviderIndex } }
				]), 
			pos: Context.currentPos() 
		};
	}
}
#end