/// @func BBMOD_PointLight()
/// @extends BBMOD_Light
function BBMOD_PointLight()
	: BBMOD_Light() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {real} The range of the light.
	Range = 1.0;
}