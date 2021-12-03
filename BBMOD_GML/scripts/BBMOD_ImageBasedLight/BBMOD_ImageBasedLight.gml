/// @func BBMOD_ImageBasedLight(_texture)
/// @extends BBMOD_Light
/// @desc An image based light.
/// @param {ptr} _texture A texture containing 8 prefiltered RGBM-encoded
/// octahedrons, where the first 7 are for specular reflections with increasing
/// roughness and the last one is for diffuse lighting.
function BBMOD_ImageBasedLight(_texture)
	: BBMOD_Light() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {ptr} The texture of the IBL.
	/// @readonly
	Texture = _texture;

	/// @var {real} The texel height of the texture.
	/// @readonly
	Texel = texture_get_texel_height(Texture);
}

function bbmod_ibl_null()
{
	static _ibl = undefined;
	if (_ibl == undefined)
	{
		var _surface = surface_create(1, 1);
		surface_set_target(_surface);
		draw_clear(0);
		surface_reset_target();
		var _sprite = sprite_create_from_surface(_surface, 0, 0, 1, 1, false, false, 0, 0);
		surface_free(_surface);
		_ibl = new BBMOD_ImageBasedLight(sprite_get_texture(_sprite, 0));
	}
	return _ibl;
}