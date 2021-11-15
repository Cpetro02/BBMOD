/// @func ssao_create_kernel(size)
/// @desc Generates a kernel of random vectors to be used for the SSAO.
/// @param {real} size Number of vectors in the kernel.
/// @return {array} The created kernel as `[v1X, v1Y, v1Z, v2X, v2Y, v2Z, ...,///                 vnX, vnY, vnZ]`.
function ssao_create_kernel(argument0) {
	var _kernel;
	for (var i = argument0 - 1; i >= 0; --i)
	{
		var _vec = vec3_create(random_range(-1, 1), random_range(-1, 1), random(1));
		vec3_normalize(_vec);
		var _s = i/argument0;
		_s = lerp(0.1, 1.0, _s*_s);
		vec3_scale(_vec, _s);
		var _i3 = i*3;
		_kernel[_i3 + 2] = _vec[2];
		_kernel[_i3 + 1] = _vec[1];
		_kernel[_i3]     = _vec[0];
	}
	return _kernel;
}

/// @func ssao_draw(surSsao, surWork, surDepth, surNormal, matView, matProj, clipFar)
/// @desc Renders SSAO into the `surSsao` surface.
/// @param {real}  surSsao   The surface to draw the SSAO to.
/// @param {real}  surWork   A working surface used for blurring the SSAO. Must
///                          have the same size as `surSsao`!
/// @param {real}  surDepth  A surface containing the scene depth.
/// @param {real}  surNormal A surface containing the scene normals.
/// @param {array} matView   The view matrix used when rendering the scene.
/// @param {array} matProj   The projection matrix used when rendering the scene.
/// @param {real}  clipFar   A distance to the far clipping plane (same as in the
///                          projection used when rendering the scene).
function ssao_draw(argument0, argument1, argument2, argument3, argument4, argument5, argument6) {
	var _surSsao        = argument0;
	var _surWork        = argument1;
	var _surSceneDepth  = argument2;
	var _texSceneNormal = surface_get_texture(argument3);
	var _matView        = argument4;
	var _matProj        = argument5;
	var _clipFar        = argument6;
	var _tanAspect      = [1/_matProj[0], -1/_matProj[5]];
	var _width          = surface_get_width(_surSsao);
	var _height         = surface_get_height(_surSsao);

	if (!surface_exists(surSsaoNoise))
	{
		surSsaoNoise = ssao_make_noise_surface(SSAO_NOISE_TEXTURE_SIZE);
	}

	// TODO: For the SSAO, texture repeat should be enabled only for the noise
	// texture, otherwise false occlusion occurs on the screen edges.
	var _texRepeat = gpu_get_tex_repeat();
	gpu_set_tex_repeat(false);

	surface_set_target(_surSsao);
	draw_clear(0);
	shader_set(ShSSAO);
	texture_set_stage(uSsaoTexNormal, _texSceneNormal);
	texture_set_stage(uSsaoTexRandom, surface_get_texture(surSsaoNoise));
	gpu_set_texrepeat_ext(uSsaoTexRandom, true);

	if (SSAO_WORLD_SPACE_NORMALS)
	{
		shader_set_uniform_matrix_array(uSsaoMatView, _matView);
	}
	shader_set_uniform_matrix_array(uSsaoMatProj, _matProj);
	shader_set_uniform_f(uSsaoTexel, 1/_width, 1/_height);
	shader_set_uniform_f(uSsaoClipFar, _clipFar); 
	shader_set_uniform_f_array(uSsaoTanAspect, _tanAspect);
	shader_set_uniform_f_array(uSsaoSampleKernel, ssaoKernel);
	shader_set_uniform_f(uSsaoRadius, ssaoRadius);
	shader_set_uniform_f(uSsaoPower, ssaoPower);
	shader_set_uniform_f(uSsaoNoiseScale, _width/SSAO_NOISE_TEXTURE_SIZE, _height/SSAO_NOISE_TEXTURE_SIZE);
	shader_set_uniform_f(uSsaoBias, ssaoBias);
	draw_surface_stretched(_surSceneDepth, 0, 0, _width, _height);
	shader_reset();
	surface_reset_target();

	surface_set_target(_surWork);
	draw_clear(0);
	shader_set(ShSSAOBlur);
	shader_set_uniform_f(uSsaoBlurTexel, 1/_width, 0);
	draw_surface(_surSsao, 0, 0);
	shader_reset();
	surface_reset_target();

	surface_set_target(_surSsao);
	draw_clear(0);
	shader_set(ShSSAOBlur);
	shader_set_uniform_f(uSsaoBlurTexel, 0, 1/_height);
	draw_surface(_surWork, 0, 0);
	shader_reset();
	surface_reset_target();

	gpu_set_tex_repeat(_texRepeat);
}

/// @func ssao_free()
/// @desc Frees resources used by the SSAO from memory.
function ssao_free() {
	if (surface_exists(surSsaoNoise))
	{
		surface_free(surSsaoNoise);
	}
	ssaoKernel = noone;
}

/// @func ssao_init(radius, bias, power)
/// @desc Initializes resources necessary for the SSAO funcionality.
/// @param {real} radius Radius of the occlusion effect. Anything further than
///                      that won't add to occlusion.
/// @param {real} bias   Depth bias to avoid too much self occlusion. Higher
///                      values mean lower self occlusion.
/// @param {real} power  Strength of the occlusion effect. Should be greater
///                      than 0.
function ssao_init(argument0, argument1, argument2) {

	//> Comment out if you are using view-space normals instead of world-space.
	//> This line is also present in the ShSSAO shader, so don't forget to comment
	//> out that one as well!
#macro SSAO_WORLD_SPACE_NORMALS true

	//> Size of the noise texture. Must be the same value as in the ShSSAOBlur
	//> shader!
#macro SSAO_NOISE_TEXTURE_SIZE 4

	//> The higher the better quality, but lower performance. Values between 16 and
	//> 64 are suggested. Must be the same values as in the ShSSAO shader!
#macro SSAO_KERNEL_SIZE 16

	surSsaoNoise = noone;
	ssaoKernel   = ssao_create_kernel(SSAO_KERNEL_SIZE);
	ssaoRadius   = argument0;
	ssaoBias     = argument1;
	ssaoPower    = argument2;

	// Uniforms
	uSsaoTexNormal    = shader_get_sampler_index(ShSSAO, "texNormal");
	uSsaoTexRandom    = shader_get_sampler_index(ShSSAO, "texRandom");
	uSsaoMatView      = shader_get_uniform(ShSSAO, "u_mView");
	uSsaoMatProj      = shader_get_uniform(ShSSAO, "u_mProjection");
	uSsaoTexel        = shader_get_uniform(ShSSAO, "u_vTexel");
	uSsaoClipFar      = shader_get_uniform(ShSSAO, "u_fClipFar");
	uSsaoTanAspect    = shader_get_uniform(ShSSAO, "u_vTanAspect");
	uSsaoSampleKernel = shader_get_uniform(ShSSAO, "u_vSampleKernel");
	uSsaoRadius       = shader_get_uniform(ShSSAO, "u_fRadius");
	uSsaoPower        = shader_get_uniform(ShSSAO, "u_fPower");
	uSsaoNoiseScale   = shader_get_uniform(ShSSAO, "u_vNoiseScale");
	uSsaoBias         = shader_get_uniform(ShSSAO, "u_fBias");
	uSsaoBlurTexel    = shader_get_uniform(ShSSAOBlur, "u_vTexel");
}

/// @func ssao_make_noise_surface(size)
/// @desc Creates a surface containing a random noise for the SSAO.
/// @param {real} size Size of the noise surface.
/// @return {real} The created noise surface.
function ssao_make_noise_surface(argument0) {
	var _sur = surface_create(argument0, argument0);
	surface_set_target(_sur);
	draw_clear(0);
	for (var i = 0; i < argument0; ++i)
	{
		for (var j = 0; j < argument0; ++j)
		{
			var _vec = vec3_create(random_range(-1, 1), random_range(-1, 1), 0);
			vec3_normalize(_vec);
			var _col = make_colour_rgb(
				(_vec[0] * 0.5 + 0.5) * 255,
				(_vec[1] * 0.5 + 0.5) * 255,
				(_vec[2] * 0.5 + 0.5) * 255);
			draw_point_colour(i, j, _col);
		}
	}
	surface_reset_target();
	return _sur;


}
