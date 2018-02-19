package hex.unittest.runner;

import hex.unittest.assertion.Assert;

/**
 * ...
 * @author Francis Bourre
 */
class ClassDescriptorGeneratorTest 
{
	@Test( "test ClassDescriptor generation" )
	public function testGenerate() : Void
	{
		Assert.isNotNull( ClassDescriptorGenerator.generate( HexUnitSuite ) );
	}
}