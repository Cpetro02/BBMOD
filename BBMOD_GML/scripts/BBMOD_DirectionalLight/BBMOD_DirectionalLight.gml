/// @func BBMOD_DirectionalLight([_color[, _direction]])
/// @extends BBMOD_Light
/// @desc A directional light.
/// @param {BBMOD_Color} [_color] The light's color.
/// @param {BBMOD_Vec3} [_direction] The light's direction.
function BBMOD_DirectionalLight(_color=undefined, _direction=undefined)
	: BBMOD_Light() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {BBMOD_Vec3} The direction of the light.
	Direction = (_direction != undefined)
		? _direction
		: new BBMOD_Vec3(-1.0, 0.0, -1.0).Normalize();

	if (_color != undefined)
	{
		Color = _color;
	}
}