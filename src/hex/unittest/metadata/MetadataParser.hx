package hex.unittest.metadata;

import hex.util.ClassUtil;
import Reflect;
import hex.unittest.description.TestMethodDescriptor;
import hex.unittest.description.TestClassDescriptor;
import haxe.rtti.Meta;

/**
 * ...
 * @author Francis Bourre
 */
class MetadataParser
{
    public function new()
    {
        //
    }

    public function parse( type : Class<Dynamic> ) : TestClassDescriptor
    {
        var descriptor : TestClassDescriptor = new TestClassDescriptor( type );
        this._parse( descriptor );
        return descriptor;
    }

    private function _parse( descriptor : TestClassDescriptor ) : Void
    {
        if ( !this._isSuite( descriptor ) )
        {
            var inherintanceChain                       = ClassUtil.getInheritanceChain( descriptor.type );
            var metadata                                = this._collectMetadata( inherintanceChain );
            this._scanTestClass( descriptor, metadata );
        }
    }

    private function _isSuite( descriptor : TestClassDescriptor  ) : Bool
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
                        isSuiteClass = descriptor.isSuiteClass = true;
                        descriptor.instance = Type.createInstance( descriptor.type, [] );
                    }

                    var suites : Array<Class<Dynamic>> = Reflect.field( descriptor.instance, fieldName );
                    for ( testClass in suites )
                    {
                        var classDescriptor : TestClassDescriptor = new TestClassDescriptor( testClass );
                        descriptor.addTestClassDescriptor( classDescriptor );
                        this._parse( classDescriptor );
                    }
                }
            }
        }

        return isSuiteClass;
    }

    private function _collectMetadata( inherintanceChain : Array<Class<Dynamic>> ) : Dynamic
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

    private function _scanTestClass( testDescriptor : TestClassDescriptor, fieldMeta : Dynamic ) : Void
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

    private function _searchForStaticMetadata( testDescriptor : TestClassDescriptor ) : Void
    {
        var staticMetadata = Meta.getStatics( testDescriptor.type );
        var fields = Reflect.fields( staticMetadata  );
        for ( fieldName in fields )
        {
            var field = Reflect.field( staticMetadata, fieldName );

            if ( Reflect.hasField( field, MetadataList.BEFORE_CLASS ) )
            {
                testDescriptor.beforeClass = Reflect.field( testDescriptor.type, fieldName );
            }

            if ( Reflect.hasField( field, MetadataList.AFTER_CLASS ) )
            {
                testDescriptor.afterClass = Reflect.field( testDescriptor.type, fieldName );
            }
        }
    }

    private function _searchForInstanceMetadata( testDescriptor : TestClassDescriptor, fieldName : String, func : Dynamic, funcMeta : Dynamic ) : Void
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

                switch( tag )
                {
                    case MetadataList.BEFORE_CLASS :
                        testDescriptor.beforeClass = func;
                        break;

                    case MetadataList.AFTER_CLASS :
                        testDescriptor.afterClass = func;
                        break;

                    case MetadataList.SETUP :
                        testDescriptor.setUp = func;
                        break;

                    case MetadataList.TEARDOWN :
                        testDescriptor.tearDown = func;
                        break;

                    case MetadataList.TEST :
                        testDescriptor.addTestMethodDescriptor( new TestMethodDescriptor( fieldName/*, func*/, false, isIgnored, description ) );
                        break;

                    case MetadataList.ASYNC:
                        testDescriptor.addTestMethodDescriptor( new TestMethodDescriptor( fieldName/*, func*/, true, isIgnored, description ) );
                }
            }
        }
    }
}