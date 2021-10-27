function __bbmod_shader_pbr()
{
	static _shader = new BBMOD_PBRShader(BBMOD_ShPBR, BBMOD_VFORMAT_DEFAULT);
	return _shader;
}

function __bbmod_shader_pbr_animated()
{
	static _shader = new BBMOD_PBRShader(BBMOD_ShPBRAnimated, BBMOD_VFORMAT_DEFAULT_ANIMATED);
	return _shader;
}

function __bbmod_shader_pbr_batched()
{
	static _shader = new BBMOD_PBRShader(BBMOD_ShPBRBatched, BBMOD_VFORMAT_DEFAULT_BATCHED);
	return _shader;
}

function __bbmod_material_pbr()
{
	static _material = undefined;
	if (_material == undefined)
	{
		_material = new BBMOD_PBRMaterial(BBMOD_SHADER_PBR);
		_material.set_shader(BBMOD_RENDER_SHADOWS, BBMOD_SHADER_SHADOWMAP);
	}
	return _material;
}

function __bbmod_material_pbr_animated()
{
	static _material = undefined;
	if (_material == undefined)
	{
		_material = new BBMOD_PBRMaterial(BBMOD_SHADER_PBR_ANIMATED);
		_material.set_shader(BBMOD_RENDER_SHADOWS, BBMOD_SHADER_SHADOWMAP_ANIMATED);
	}
	return _material;
}

function __bbmod_material_pbr_batched()
{
	static _material = undefined;
	if (_material == undefined)
	{
		_material = new BBMOD_PBRMaterial(BBMOD_SHADER_PBR_BATCHED);
		_material.set_shader(BBMOD_RENDER_SHADOWS, BBMOD_SHADER_SHADOWMAP_BATCHED);
	}
	return _material;
}

function __bbmod_material_sky()
{
	static _material = undefined;

	if (_material == undefined)
	{
		var _sprIbl = sprite_add("Data/BBMOD/Skies/IBL+80.png", 0, false, true, 0, 0);
		var _sprSky = sprite_add("Data/BBMOD/Skies/Sky+80.png", 0, false, true, 0, 0);

		bbmod_set_ibl_sprite(_sprIbl, 0);

		var _skSky = new BBMOD_PBRShader(BBMOD_ShSky, new BBMOD_VertexFormat(true));

		_material = new BBMOD_PBRMaterial(_skSky);
		_material.BaseOpacity = sprite_get_texture(_sprSky, 0);
		_material.Culling = cull_noculling;
		_material.Mipmapping = false;
		_material.ZWrite = false;
		_material.ZTest = false;
		_material.Filtering = true;
		_material.set_priority(-$FFFFFFFF);
	}

	return _material;
}