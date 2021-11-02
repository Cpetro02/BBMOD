function __bbmod_shader_gbuffer()
{
	static _shader = new BBMOD_PBRShader(BBMOD_ShShadowmap, BBMOD_VFORMAT_DEFAULT);
	return _shader;
}

function __bbmod_shader_gbuffer_animated()
{
	static _shader = new BBMOD_PBRShader(BBMOD_ShShadowmapAnimated, BBMOD_VFORMAT_DEFAULT_ANIMATED);
	return _shader;
}

function __bbmod_shader_gbuffer_batched()
{
	static _shader = new BBMOD_PBRShader(BBMOD_ShShadowmapBatched, BBMOD_VFORMAT_DEFAULT_BATCHED);
	return _shader;
}

/// @macro {BBMOD_PBRShader} Shadowmap shader for static models.
/// @see BBMOD_PBRShader
#macro BBMOD_SHADER_GBUFFER __bbmod_shader_gbuffer()

/// @macro {BBMOD_PBRShader} Shadowmap shader for animated models with bones.
/// @see BBMOD_PBRShader
#macro BBMOD_SHADER_GBUFFER_ANIMATED __bbmod_shader_gbuffer_animated()

/// @macro {BBMOD_PBRShader} Shadowmap shader for dynamically batched models.
/// @see BBMOD_PBRShader
/// @see BBMOD_DynamicBatch
#macro BBMOD_SHADER_GBUFFER_BATCHED __bbmod_shader_gbuffer_batched()