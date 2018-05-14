package hex.unittest.metadata;

import Reflect;
import haxe.rtti.Meta;
import hex.error.NoSuchElementException;
import hex.unittest.description.ClassDescriptor;
import hex.unittest.description.MethodDescriptor;
import hex.util.ClassUtil;

using hex.unittest.description.ClassDescriptorUtil;

/**
 * ...
 * @author Francis Bourre
 */
class MetadataParser
{
    public function new(){}

    public function parse( type : Class<Dynamic> ) : ClassDescriptor
    {
        var descriptor = _getClassDescriptor( type );
        this._parse( descriptor );
        return descriptor;
    }
	
	public function parseMethod( type : Class<Dynamic>, methodName : String ) : ClassDescriptor
    {
		var descriptor = _getClassDescriptor( type );
		this._parse( descriptor );
		descriptor.keepOnlyThisMethod( methodName );
		return descriptor;
	}

    function _parse( descriptor : ClassDescriptor ) : Void
    {
        if ( !this._isSuite( descriptor ) )
        {
            var inherintanceChain                       = ClassUtil.getInheritanceChain( descriptor.type );
            var metadata                                = this._collectMetadata( inherintanceChain );
            this._scanTestClass( descriptor, metadata );
        }
    }

    function _isSuite( descriptor : ClassDescriptor  ) : Bool
    {
        var isSuiteClass : Bool = false;

        var metadata            = Meta.getFields( descriptor.type );
        var instance            = descriptor.instance;
        var fields              = Reflect.fields( metadata );

        for ( fieldName in fields )
        {
            var f : Dynamic = Reflect.field( instance, fieldName );
            if ( !Reflect.isFunction( f ) )
            {
                var metadataField = Reflect.field( metadata, fieldName );
                if ( Reflect.hasField( metadataField, MetadataList.SUITE ) )
                {
                    if ( !isSuiteClass )
                    {
						var metadatas : Array<Dynamic> = Reflect.field( metadataField, MetadataList.SUITE );
						descriptor.name = metadatas[ 0 ];
                        isSuiteClass = descriptor.isSuiteClass = true;
                        descriptor.instance = Type.createInstance( descriptor.type, [] );
                    }

                    var suites : Array<Class<Dynamic>> = Reflect.field( descriptor.instance, fieldName );
                    for ( testClass in suites )
                    {
                        var classDescriptor = _getClassDescriptor( testClass );
                        descriptor.classDescriptors.push( classDescriptor );
                        this._parse( classDescriptor );
                    }
                }
            }
        }

        return isSuiteClass;
    }

    function _collectMetadata( inherintanceChain : Array<Class<Dynamic>> ) : Dynamic
    {
        var meta = {};
        while ( inherintanceChain.length > 0 )
        {
            var clazz = inherintanceChain.pop(); // start at root
            var newMeta = Meta.getFields( clazz );
            var markedFieldNames = Reflect.fields( newMeta );

            for ( fieldName in markedFieldNames )
            {
                var recordedFieldTags = Reflect.field( meta, fieldName );
                var newFieldTags = Reflect.field( newMeta, fieldName );

                var newTagNames = Reflect.fields( newFieldTags );
                if ( recordedFieldTags == null )
                {
                    // need to create copy of tags as may need to remove
                    // some later and this could impact other tests which
                    // extends the same class.
                    var tagsCopy = {};
                    for ( tagName in newTagNames )
                    {
                        Reflect.setField( tagsCopy, tagName, Reflect.field(newFieldTags, tagName ) );
                    }

                    Reflect.setField( meta, fieldName, tagsCopy );
                }
                else
                {
                    var ignored = false;
                    for ( tagName in newTagNames )
                    {
                        if ( tagName == MetadataList.IGNORE )
                            ignored = true;

                        // @Test in subclass takes precendence over @Ignore in parent
                        if ( !ignored && ( tagName == MetadataList.TEST
                            || tagName == MetadataList.ASYNC ) &&
                                Reflect.hasField( recordedFieldTags, MetadataList.IGNORE ) )
                        {
                            Reflect.deleteField( recordedFieldTags, MetadataList.IGNORE );
                        }

                        var tagValue = Reflect.field( newFieldTags, tagName );
                        Reflect.setField( recordedFieldTags, tagName, tagValue );
                    }
                }
            }
        }
        return meta;
    }

    function _scanTestClass( testDescriptor : ClassDescriptor, fieldMeta : Dynamic ) : Void
    {
        var fieldNames = Reflect.fields( fieldMeta );
        for ( fieldName in fieldNames )
        {
            var f:Dynamic = Reflect.field( testDescriptor.instance, fieldName );
            var funcMeta : Dynamic = Reflect.field( fieldMeta, fieldName );
            if ( Reflect.isFunction( f ) )
            {
                this._searchForInstanceMetadata( testDescriptor, fieldName, f, funcMeta );
            }
        }

        this._searchForStaticMetadata( testDescriptor );
    }

    function _searchForStaticMetadata( testDescriptor : ClassDescriptor ) : Void
    {
        var staticMetadata = Meta.getStatics( testDescriptor.type );
        var fields = Reflect.fields( staticMetadata  );
        for ( fieldName in fields )
        {
            var field = Reflect.field( staticMetadata, fieldName );

            if ( Reflect.hasField( field, MetadataList.BEFORE_CLASS ) )
            {
                testDescriptor.beforeClassFieldName = fieldName;
            }

            if ( Reflect.hasField( field, MetadataList.AFTER_CLASS ) )
            {
                testDescriptor.afterClassFieldName = fieldName;
            }
        }
    }

    function _searchForInstanceMetadata( testDescriptor : ClassDescriptor, fieldName : String, func : Dynamic, funcMeta : Dynamic ) : Void
    {
        for ( tag in MetadataList.INSTANCE_METADATA )
        {
            if ( Reflect.hasField( funcMeta, tag ) )
            {
                var args : Array<String> = Reflect.field( funcMeta, tag );
                var description = ( args != null ) ? args[ 0 ] : "";

                var isIgnored = Reflect.hasField( funcMeta, MetadataList.IGNORE );
                if ( isIgnored )
                {
                    args = Reflect.field( funcMeta, MetadataList.IGNORE );
                    description = ( args != null ) ? args[ 0 ] : "";
                }
                
                var isDataDriven = Reflect.hasField( funcMeta, MetadataList.DATA_PROVIDER );
                var dataProvider:Array<Array<Dynamic>> = null;
				var dataProviderFieldName = "";
                if ( isDataDriven )
                {
                    args = Reflect.field( funcMeta, MetadataList.DATA_PROVIDER );
                    dataProviderFieldName = ( args != null ) ? args [0] : "";
                }

                switch( tag )
                {
                    case MetadataList.BEFORE_CLASS :
                        testDescriptor.beforeClassFieldName = fieldName;
                        break;

                    case MetadataList.AFTER_CLASS :
                        testDescriptor.afterClassFieldName = fieldName;
                        break;

                    case MetadataList.BEFORE :
                        testDescriptor.setUpFieldName = fieldName;
                        break;

                    case MetadataList.AFTER :
                        testDescriptor.tearDownFieldName = fieldName;
                        break;

                    case MetadataList.TEST :
                        this._addTestToDescriptor(testDescriptor, fieldName, false, isIgnored, description, 0, dataProviderFieldName );
                        break;

                    case MetadataList.ASYNC:
						var hasTimeout = Reflect.hasField( funcMeta, MetadataList.TIMEOUT );
						var timeout = hasTimeout ? Reflect.field( funcMeta, MetadataList.TIMEOUT )[ 0 ] : 1500;
						this._addTestToDescriptor( testDescriptor, fieldName, true, isIgnored, description, timeout, dataProviderFieldName );
                }
            }
        }
    }

    function _addTestToDescriptor( 	testDescriptor 			: ClassDescriptor, 
									fieldName 				: String, 
									isAsync 				: Bool, 
									isIgnored 				: Bool, 
									description 			: String, 
									timeout 				: UInt,
									dataProviderFieldName 	: String ) : Void
    {
        if ( dataProviderFieldName != '' )
        {
			var length = 0;
			try
			{
				length = Reflect.field( testDescriptor.type, dataProviderFieldName ).length;
			}
			catch ( e : Dynamic )
			{
				throw new NoSuchElementException( "Class " + testDescriptor.className + " is missing dataProvider '" + dataProviderFieldName + "' for method '" + fieldName + "'" );
			}
			
            for ( dataProviderIndex in 0...length ) 
			{
				testDescriptor.methodDescriptors.push( _getMethodDescriptor( fieldName, isAsync, isIgnored, description, dataProviderFieldName, dataProviderIndex ) );
			}
        }
        else
        {
            testDescriptor.methodDescriptors.push( _getMethodDescriptor( fieldName, isAsync, isIgnored, description, dataProviderFieldName, 0 ) );
        }
    }
	
	static function _getClassDescriptor( type : Class<Dynamic> ) : ClassDescriptor
		return
		{
			instance: 				Type.createEmptyInstance( type ),
			type: 					type,
			className:				Type.getClassName( type ),
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
	
	static function _getMethodDescriptor(  	methodName       		: String,
											isAsync           		: Bool,
											isIgnored         		: Bool,
											?description      		: String,
											dataProviderFieldName 	: String,
											dataProviderIndex 		: UInt ) : MethodDescriptor
		return 
		{
			methodName: 			methodName,
			isAsync:				isAsync,
			isIgnored:				isIgnored,
			description:			description != null ? description : "",
			timeout:				1500,
			dataProviderFieldName:	dataProviderFieldName,
			dataProviderIndex:		dataProviderIndex
		}
}