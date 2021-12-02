/// @func BBMOD_PointLight([_color[, _position[, _range]]])
/// @extends BBMOD_Light
/// @desc A point light.
/// @param {BBMOD_Color} [_color] The light's color.
/// @param {BBMOD_Vec3} [_position] The light's position.
/// @param {real} [_range] The light's range. Defaults to 1.
function BBMOD_PointLight(_color=undefined, _position=undefined, _range=1.0)
	: BBMOD_Light() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {real} The range of the light.
	Range = _range;

	if (_position != undefined)
	{
		Position = _position;
	}

	if (_color != undefined)
	{
		Color = _color;
	}
}