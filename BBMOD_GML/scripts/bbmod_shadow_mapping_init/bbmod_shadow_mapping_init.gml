function __bbmod_shader_depth()
{
	static _shader = new BBMOD_DepthShader(BBMOD_ShDepth, BBMOD_VFORMAT_DEFAULT);
	return _shader;
}

function __bbmod_shader_depth_animated()
{
	static _shader = new BBMOD_DepthShader(BBMOD_ShDepthAnimated, BBMOD_VFORMAT_DEFAULT_ANIMATED);
	return _shader;
}

function __bbmod_shader_depth_batched()
{
	static _shader = new BBMOD_DepthShader(BBMOD_ShDepthBatched, BBMOD_VFORMAT_DEFAULT_BATCHED);
	return _shader;
}