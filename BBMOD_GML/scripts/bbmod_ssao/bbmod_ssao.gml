/// @func ssao_init(_radius, _bias, _power)
/// @desc Initializes resources necessary for the SSAO funcionality.
/// @param {real} _radius Radius of the occlusion effect. Anything further than
///                       that won't add to occlusion.
/// @param {real} _bias   Depth bias to avoid too much self occlusion. Higher
///                       values mean lower self occlusion.
/// @param {real} _power  Strength of the occlusion effect. Should be greater
///                       than 0.
function ssao_init(_radius, _bias, _power) {


	//> Size of the noise texture. Must be the same value as in the ShSSAOBlur
	//> shader!
#macro SSAO_NOISE_TEXTURE_SIZE 4

	//> The higher the better quality, but lower performance. Values between 16 and
	//> 64 are suggested. Must be the same values as in the ShSSAO shader!
#macro SSAO_KERNEL_SIZE 8

	surSsaoNoise = ssao_make_noise_surface(SSAO_NOISE_TEXTURE_SIZE);
	ssaoKernel   = ssao_create_kernel(SSAO_KERNEL_SIZE);
	ssaoRadius   = _radius;
	ssaoBias     = _bias;
	ssaoPower    = _power;

	// Uniforms
	// TODO: Make BBMOD_SSAOShader and BBMOD_SSAOBlurShader structs!
	uSsaoTexNoise     = shader_get_sampler_index(BBMOD_ShSSAO, "u_texNoise");
	uSsaoTexel        = shader_get_uniform(BBMOD_ShSSAO, "u_vTexel");
	uSsaoClipFar      = shader_get_uniform(BBMOD_ShSSAO, "u_fClipFar");
	uSsaoTanAspect    = shader_get_uniform(BBMOD_ShSSAO, "u_vTanAspect");
	uSsaoSampleKernel = shader_get_uniform(BBMOD_ShSSAO, "u_vSampleKernel");
	uSsaoRadius       = shader_get_uniform(BBMOD_ShSSAO, "u_fRadius");
	uSsaoPower        = shader_get_uniform(BBMOD_ShSSAO, "u_fPower");
	uSsaoNoiseScale   = shader_get_uniform(BBMOD_ShSSAO, "u_vNoiseScale");
	uSsaoBias         = shader_get_uniform(BBMOD_ShSSAO, "u_fBias");
	uSsaoBlurTexel    = shader_get_uniform(BBMOD_ShSSAOBlur, "u_vTexel");
	uSsaoBlurTexDepth = shader_get_sampler_index(BBMOD_ShSSAOBlur, "u_texDepth");
	uSsaoBlurClipFar  = shader_get_uniform(BBMOD_ShSSAOBlur, "u_fClipFar");
}

/// @func ssao_make_noise_surface(_size)
/// @desc Creates a surface containing a random noise for the SSAO.
/// @param {uint} _size The size of the surface.
/// @return {real} The created noise surface.
function ssao_make_noise_surface(_size)
{
	var _seed = random_get_seed();
	randomize();
	var _sur = surface_create(_size, _size);
	surface_set_target(_sur);
	draw_clear(0);
	var _dir = 0;
	var _dirStep = 180 / (_size * _size);
	for (var i = 0; i < _size; ++i)
	{
		for (var j = 0; j < _size; ++j)
		{
			var _col = make_colour_rgb(
				(dcos(_dir) * 0.5 + 0.5) * 255,
				(dsin(_dir) * 0.5 + 0.5) * 255,
				0);
			draw_point_colour(i, j, _col);
			_dir += _dirStep;
		}
	}
	surface_reset_target();
	random_set_seed(_seed);
	return _sur;
}

/// @func ssao_create_kernel(_size)
/// @desc Generates a kernel of random vectors to be used for the SSAO.
/// @param {real} _size Number of vectors in the kernel.
/// @return {array} The created kernel as `[v1X, v1Y, v1Z, v2X, v2Y, v2Z, ...,///                 vnX, vnY, vnZ]`.
function ssao_create_kernel(_size)
{
	var _seed = random_get_seed();
	randomize();
	var _kernel = array_create(_size * 2, 0.0);
	var _dir = 0;
	var _dirStep = 360 / _size;
	for (var i = _size - 1; i >= 0; --i)
	{
		var _len = (i + 1) / _size;
		_kernel[i * 2 + 0] = lengthdir_x(_len, _dir);
		_kernel[i * 2 + 1] = lengthdir_y(_len, _dir);
		_dir += _dirStep;
	}
	random_set_seed(_seed);
	return _kernel;
}

/// @func ssao_draw(_surSsao, _surWork, _surGBuffer, _matProj, _clipFar)
/// @desc Renders SSAO into the `surSsao` surface.
/// @param {real}  _surSsao    The surface to draw the SSAO to.
/// @param {real}  _surWork    A working surface used for blurring the SSAO. Must
///                            have the same size as `surSsao`!
/// @param {real}  _surGBuffer G-buffer surface.
/// @param {array} _matProj    The projection matrix used when rendering the scene.
/// @param {real}  _clipFar    A distance to the far clipping plane (same as in the
///                            projection used when rendering the scene).
function ssao_draw(_surSsao, _surWork, _surGBuffer, _matProj, _clipFar)
{
	var _tanAspect      = [1.0 / _matProj[0], -1.0 / _matProj[5]];
	var _width          = surface_get_width(_surSsao);
	var _height         = surface_get_height(_surSsao);

	if (!surface_exists(surSsaoNoise))
	{
		matrix_set(matrix_world, matrix_build_identity());
		surSsaoNoise = ssao_make_noise_surface(SSAO_NOISE_TEXTURE_SIZE);
	}

	gpu_push_state();
	gpu_set_tex_repeat(false);

	var _cam = camera_create();
	camera_set_view_size(_cam, _width, _height);

	gpu_set_tex_filter(false);

	surface_set_target(_surSsao);
	matrix_set(matrix_world, matrix_build_identity());
	camera_apply(_cam);
	draw_clear(c_white);

	shader_set(BBMOD_ShSSAO);
	texture_set_stage(uSsaoTexNoise, surface_get_texture(surSsaoNoise));
	gpu_set_texrepeat_ext(uSsaoTexNoise, true);
	shader_set_uniform_f(uSsaoTexel, 1/_width, 1/_height);
	shader_set_uniform_f(uSsaoClipFar, _clipFar);
	shader_set_uniform_f_array(uSsaoTanAspect, _tanAspect);
	shader_set_uniform_f_array(uSsaoSampleKernel, ssaoKernel);
	shader_set_uniform_f(uSsaoRadius, ssaoRadius);
	shader_set_uniform_f(uSsaoPower, ssaoPower);
	shader_set_uniform_f(uSsaoNoiseScale, _width/SSAO_NOISE_TEXTURE_SIZE, _height/SSAO_NOISE_TEXTURE_SIZE);
	shader_set_uniform_f(uSsaoBias, ssaoBias);
	draw_surface_stretched(_surGBuffer, 0, 0, _width, _height);
	shader_reset();

	surface_reset_target();

	gpu_set_tex_filter(true);

	surface_set_target(_surWork);
	camera_apply(_cam);
	draw_clear(0);
	shader_set(BBMOD_ShSSAOBlur);
	shader_set_uniform_f(uSsaoBlurTexel, 1/_width, 0);
	shader_set_uniform_f(uSsaoBlurClipFar, _clipFar);
	texture_set_stage(uSsaoBlurTexDepth, surface_get_texture(_surGBuffer));
	draw_surface(_surSsao, 0, 0);
	shader_reset();
	surface_reset_target();

	surface_set_target(_surSsao);
	camera_apply(_cam);
	draw_clear(0);
	shader_set(BBMOD_ShSSAOBlur);
	shader_set_uniform_f(uSsaoBlurTexel, 0, 1/_height);
	shader_set_uniform_f(uSsaoBlurClipFar, _clipFar);
	texture_set_stage(uSsaoBlurTexDepth, surface_get_texture(_surGBuffer));
	draw_surface(_surWork, 0, 0);
	shader_reset();
	surface_reset_target();

	gpu_pop_state();

	camera_destroy(_cam);
}

/// @func ssao_draw_debug(_x, _y, _radius)
/// @param {real} _x
/// @param {real} _y
/// @param {real} _radius
function ssao_draw_debug(_x, _y, _radius)
{
	for (var i = 0; i < SSAO_NOISE_TEXTURE_SIZE; ++i)
	{
		for (var j = 0; j < SSAO_NOISE_TEXTURE_SIZE; ++j)
		{
			var _pixel = surface_getpixel(surSsaoNoise, i, j);
			var _dcos = (color_get_red(_pixel) / 255) * 2.0 - 1.0;
			var _dsin = (color_get_green(_pixel) / 255) * 2.0 - 1.0;
			for (var k = 0; k < array_length(ssaoKernel); k += 2)
			{
				var _kx = ssaoKernel[k + 0];
				var _ky = ssaoKernel[k + 1];
				var _x1 = _x + (_kx*_dcos - _ky*_dsin) * _radius;
				var _y1 = _y + (_kx*_dsin + _ky*_dcos) * _radius;
				var _x2 = _x - (_kx*_dcos - _ky*_dsin) * _radius;
				var _y2 = _y - (_kx*_dsin + _ky*_dcos) * _radius;
				draw_circle_color(_x1, _y1, 2, c_red, c_red, false);
				draw_circle_color(_x2, _y2, 2, c_lime, c_lime, false);
			}
		}
	}
	draw_circle_color(_x, _y, _radius, 0, 0, true);
}

/// @func ssao_free()
/// @desc Frees resources used by the SSAO from memory.
function ssao_free()
{
	if (surface_exists(surSsaoNoise))
	{
		surface_free(surSsaoNoise);
	}
	ssaoKernel = noone;
}