function __bbmod_shader_shadowmap()
{
	static _shader = new BBMOD_Shader(BBMOD_ShShadowmap, BBMOD_VFORMAT_DEFAULT);
	return _shader;
}

function __bbmod_shader_shadowmap_animated()
{
	static _shader = new BBMOD_Shader(BBMOD_ShShadowmapAnimated, BBMOD_VFORMAT_DEFAULT_ANIMATED);
	return _shader;
}

function __bbmod_shader_shadowmap_batched()
{
	static _shader = new BBMOD_Shader(BBMOD_ShShadowmapBatched, BBMOD_VFORMAT_DEFAULT_BATCHED);
	return _shader;
}

/// @macro {BBMOD_Shader} Shadowmap shader for static models.
/// @see BBMOD_Shader
#macro BBMOD_SHADER_SHADOWMAP __bbmod_shader_shadowmap()

/// @macro {BBMOD_Shader} Shadowmap shader for animated models with bones.
/// @see BBMOD_Shader
#macro BBMOD_SHADER_SHADOWMAP_ANIMATED __bbmod_shader_shadowmap_animated()

/// @macro {BBMOD_Shader} Shadowmap shader for dynamically batched models.
/// @see BBMOD_Shader
/// @see BBMOD_DynamicBatch
#macro BBMOD_SHADER_SHADOWMAP_BATCHED __bbmod_shader_shadowmap_batched()