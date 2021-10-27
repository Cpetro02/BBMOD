/// @macro {BBMOD_DepthShader} Depth shader for static models.
/// @see BBMOD_DepthShader
#macro BBMOD_SHADER_DEPTH __bbmod_shader_depth()

/// @macro {BBMOD_DepthShader} Depth shader for animated models with bones.
/// @see BBMOD_DepthShader
#macro BBMOD_SHADER_DEPTH_ANIMATED __bbmod_shader_depth_animated()

/// @macro {BBMOD_DepthShader} Depth shader for dynamically batched models.
/// @see BBMOD_DepthShader
/// @see BBMOD_DynamicBatch
#macro BBMOD_SHADER_DEPTH_BATCHED __bbmod_shader_depth_batched()

/// @func BBMOD_DepthShader(_shader, _vertexFormat)
/// @extends BBMOD_Shader
/// @desc A wrapper for a raw GameMaker shader resource that only outputs depth.
/// @param {shader} _shader The shader resource.
/// @param {BBMOD_VertexFormat} _vertexFormat The vertex format required by the shader.
function BBMOD_DepthShader(_shader, _vertexFormat)
	: BBMOD_Shader(_shader, _vertexFormat) constructor
{
	static Super_Shader = {
		set_material: set_material,
	};

	UClipFar = get_uniform("bbmod_ClipFar");

	/// @func set_clip_far(_value)
	/// @desc Sets the `bbmod_ClipFar` uniform.
	/// @param {real} _value The new distance to the camera's far clipping plane.
	/// @return {BBMOD_DepthShader} Returns `self`.
	static set_clip_far = function (_value) {
		gml_pragma("forceinline");
		return set_uniform_f(UClipFar, _value);
	};

	static set_material = function (_material) {
		gml_pragma("forceinline");
		method(self, Super_Shader.set_material)(_material);
		set_clip_far(global.bbmod_camera_clip_far);
		return self;
	};
}

/// @var {real} The camera's distance to the far clipping plane.
global.bbmod_camera_clip_far = 1.0;