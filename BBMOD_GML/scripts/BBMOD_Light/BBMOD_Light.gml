/// @func BBMOD_Light()
/// @extends BBMOD_Class
function BBMOD_Light()
	: BBMOD_Class() constructor
{
	/// @var {BBMOD_Vec3} The position of the light.
	Position = new BBMOD_Vec3();

	/// @var {BBMOD_Color} The color of the light. Defaults to white.
	Color = new BBMOD_Color();
}