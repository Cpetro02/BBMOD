/// @func BBMOD_Light()
/// @extends BBMOD_Class
function BBMOD_Light()
	: BBMOD_Class() constructor
{
	/// @var {BBMOD_Vec3} The position of the light.
	Position = new BBMOD_Vec3();

	/// @var {uint} The color of the light. Defaults to `c_white`.
	Color = c_white;

	/// @var {real} The intensity of the light. Defaults to 1.
	Intensity = 1.0;
}