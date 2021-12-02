/// @func BBMOD_PBRShader(_shader, _vertexFormat)
/// @extends BBMOD_DefaultShader
/// @desc A wrapper for a raw GameMaker shader resource using PBR.
/// @param {shader} _shader The shader resource.
/// @param {BBMOD_VertexFormat} _vertexFormat The vertex format required by the shader.
function BBMOD_PBRShader(_shader, _vertexFormat)
	: BBMOD_DefaultShader(_shader, _vertexFormat) constructor
{
	static Super_Shader = {
		set_material: set_material,
	};

	UCamPos = get_uniform("bbmod_CamPos");

	UExposure = get_uniform("bbmod_Exposure");

	UNormalRoughness = get_sampler_index("bbmod_NormalRoughness");

	UMetallicAO = get_sampler_index("bbmod_MetallicAO");

	USubsurface = get_sampler_index("bbmod_Subsurface");

	UEmissive = get_sampler_index("bbmod_Emissive");

	UIBL = get_sampler_index("bbmod_IBL");

	UIBLTexel = get_uniform("bbmod_IBLTexel");

	UShadowmap = get_sampler_index("bbmod_Shadowmap");

	UShadowmapMatrix = get_uniform("bbmod_ShadowmapMatrix");

	UShadowmapTexel = get_uniform("bbmod_ShadowmapTexel");

	UShadowmapArea = get_uniform("bbmod_ShadowmapArea");

	UShadowmapNormalOffset = get_uniform("bbmod_ShadowmapNormalOffset");

	ULightDirectionalDir = get_uniform("bbmod_LightDirectionalDir");

	ULightDirectionalColor = get_uniform("bbmod_LightDirectionalColor");

	ULightPointData = get_uniform("bbmod_LightPointData");

	USSAO = get_sampler_index("bbmod_SSAO");

	/// @func set_cam_pos(_x[, _y, _z])
	/// @desc Sets a fragment shader uniform `bbmod_CamPos` to the given position.
	/// @param {BBMOD_Vec3/real} _x Either a vector with the camera's position
	/// or the x position of the camera.
	/// @param {real} [_y] The y position of the camera.
	/// @param {real} [_z] The z position of the camera.
	/// @return {BBMOD_Shader} Returns `self`.
	static set_cam_pos = function (_x, _y, _z) {
		gml_pragma("forceinline");
		if (is_struct(_x))
		{
			set_uniform_f3(UCamPos, _x.X, _x.Y, _x.Z);
		}
		else
		{
			set_uniform_f3(UCamPos, _x, _y, _z);
		}
		return self;
	};

	/// @func set_exposure(_value)
	/// @desc Sets the `bbmod_Exposure` uniform.
	/// @param {real} _value The new camera exposure.
	/// @return {BBMOD_PBRShader} Returns `self`.
	static set_exposure = function (_value) {
		gml_pragma("forceinline");
		return set_uniform_f(UExposure, _value);
	};

	/// @func set_normal_roughness(_texture)
	/// @desc Sets the `bbmod_NormalRoughness` uniform.
	/// @param {real} _texture The new texture with normal vector in the RGB
	/// channels and roughness in the A channel.
	/// @return {BBMOD_PBRShader} Returns `self`.
	static set_normal_roughness = function (_texture) {
		gml_pragma("forceinline");
		return set_sampler(UNormalRoughness, _texture);
	};

	/// @func set_metallic_ao(_texture)
	/// @desc Sets the `bbmod_MetallicAO` uniform.
	/// @param {real} _texture The new texture with metalness in the R channel
	/// and ambient occlusion in the G channel.
	/// @return {BBMOD_PBRShader} Returns `self`.
	static set_metallic_ao = function (_texture) {
		gml_pragma("forceinline");
		return set_sampler(UMetallicAO, _texture);
	};

	/// @func set_subsurface(_texture)
	/// @desc Sets the `bbmod_Subsurface` uniform.
	/// @param {real} _texture The new texture with subsurface color in the
	/// RGB channels and its intensity in the A channel.
	/// @return {BBMOD_PBRShader} Returns `self`.
	static set_subsurface = function (_texture) {
		gml_pragma("forceinline");
		return set_sampler(USubsurface, _texture);
	};

	/// @func set_emissive(_texture)
	/// @desc Sets the `bbmod_Emissive` uniform.
	/// @param {real} _texture The new RGBM encoded emissive color.
	/// @return {BBMOD_PBRShader} Returns `self`.
	static set_emissive = function (_texture) {
		gml_pragma("forceinline");
		return set_sampler(UEmissive, _texture);
	};

	/// @func set_ibl()
	/// @desc Sets a fragment shader uniform `bbmod_IBLTexel` and samplers
	/// `bbmod_IBL` and `bbmod_BRDF`. These are required for image based
	/// lighting.
	/// @return {BBMOD_PBRShader} Returns `self`.
	/// @see bbmod_set_ibl_sprite
	/// @see bbmod_set_ibl_texture
	static set_ibl = function () {
		var _texture = global.__bbmodIblTexture;
		if (_texture == pointer_null)
		{
			return self;
		}

		gpu_set_tex_mip_enable_ext(UIBL, mip_off);
		gpu_set_tex_filter_ext(UIBL, true);
		gpu_set_tex_repeat_ext(UIBL, false);
		set_sampler(UIBL, _texture);

		var _texel = global.__bbmodIblTexel;
		set_uniform_f(UIBLTexel, _texel, _texel);

		return self;
	};

	/// @func set_shadowmap(_texture, _matrix, _area, _normalOffset)
	/// @desc Sets uniforms `bbmod_Shadowmap`, `bbmod_ShadowmapMatrix`,
	/// `bbmod_ShadowmapArea` and `bbmod_ShadowmapNormalOffset`, required for
	/// shadow mapping.
	/// @param {ptr} _texture The shadowmap texture.
	/// @param {real[16]} _matrix The wolrd-view-projection matrix used when
	/// rendering the shadowmap.
	/// @param {real} _area The area that the shadowmap captures.
	/// @param {real} _normalOffset The area that the shadowmap captures.
	/// @return {BBMOD_PBRShader} Returns `self`.
	static set_shadowmap = function (_texture, _matrix, _area, _normalOffset) {
		gml_pragma("forceinline");
		set_sampler(UShadowmap, _texture);
		gpu_set_tex_mip_enable_ext(UShadowmap, false);
		gpu_set_tex_filter_ext(UShadowmap, true);
		gpu_set_tex_repeat_ext(UShadowmap, false);
		set_uniform_f2(UShadowmapTexel,
			texture_get_texel_width(_texture),
			texture_get_texel_height(_texture));
		set_uniform_f(UShadowmapArea, _area);
		set_uniform_f(UShadowmapNormalOffset, _normalOffset);
		set_uniform_matrix_array(UShadowmapMatrix, _matrix);
		return self;
	};

	/// @func set_directional_light(_light)
	/// @desc Sets uniforms `bbmod_LightDirectionalDir` and
	/// `bbmod_LightDirectionalColor`.
	/// @param {BBMOD_DirectionalLight} _light The directional light.
	/// @return {BBMOD_PBRShader} Returns `self`.
	/// @see BBMOD_DirectionalLight
	static set_directional_light = function (_light) {
		gml_pragma("forceinline");
		var _direction = _light.Direction;
		set_uniform_f3(ULightDirectionalDir, _direction.X, _direction.Y, _direction.Z);
		set_uniform_f_array(ULightDirectionalColor, _light.Color.ToRGBM());
		return self;
	};

	/// @func set_point_lights(_lights)
	/// @desc Sets uniform `bbmod_LightPointData`.
	/// @param {BBMOD_PointLight[]} _lights An array of point lights.
	/// @return {BBMOD_PBRShader} Returns `self`.
	static set_point_lights = function (_lights) {
		gml_pragma("forceinline");
		var _maxLights = 4;
		var _data = array_create(_maxLights * 8, 0);
		var _imax = min(array_length(_lights), _maxLights);
		for (var i = 0; i < _imax; ++i)
		{
			var _index = i * 8;
			var _light = _lights[i];
			_light.Position.ToArray(_data, _index);
			_data[@ _index + 3] = _light.Range;
			_light.Color.ToRGBM(_data, _index + 4);
		}
		set_uniform_f_array(ULightPointData, _data);
		return self;
	};

	static set_ssao = function (_texture) {
		gml_pragma("forceinline");
		set_sampler(USSAO, _texture);
		return self;
	};

	static set_material = function (_material) {
		gml_pragma("forceinline");
		method(self, Super_Shader.set_material)(_material);
		set_metallic_ao(_material.MetallicAO);
		set_normal_roughness(_material.NormalRoughness);
		set_subsurface(_material.Subsurface);
		set_emissive(_material.Emissive);
		set_cam_pos(global.bbmod_camera_position);
		set_exposure(global.bbmod_camera_exposure);
		set_ibl();
		return self;
	};
}

////////////////////////////////////////////////////////////////////////////////
//
// Camera
//

/// @var {real[]} The current `[x,y,z]` position of the camera. This should be
/// updated every frame before rendering models.
/// @see bbmod_set_camera_position
global.bbmod_camera_position = new BBMOD_Vec3();

/// @var {real} The current camera exposure.
global.bbmod_camera_exposure = 1.0;

/// @func bbmod_set_camera_position(_x, _y, _z)
/// @desc Changes camera position to given coordinates.
/// @param {real} _x The x position of the camera.
/// @param {real} _y The y position of the camera.
/// @param {real} _z The z position of the camera.
/// @see global.bbmod_camera_position
function bbmod_set_camera_position(_x, _y, _z)
{
	gml_pragma("forceinline");
	var _position = global.bbmod_camera_position;
	_position.X = _x;
	_position.Y = _y;
	_position.Z = _z;
}