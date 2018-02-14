package hex.unittest.runner;

import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class ClassDescriptorGeneratorTest 
{
	/*#if genunit*/
	@Test( "test ClassDescriptor generation" )
	public function testGenerate() : Void
	{
		Assert.isNotNull( ClassDescriptorGenerator.generate( HexUnitSuite ) );
	}
	/*#end*/
}