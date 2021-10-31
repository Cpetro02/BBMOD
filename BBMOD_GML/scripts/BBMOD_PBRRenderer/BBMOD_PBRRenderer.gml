/// @func BBMOD_PBRRenderer()
/// @extends BBMOD_Renderer
function BBMOD_PBRRenderer()
	: BBMOD_Renderer() constructor
{
	static render = function () {
		var _world = matrix_get(matrix_world);
		var _view = matrix_get(matrix_view);
		var _projection = matrix_get(matrix_projection);

		var i = 0;
		repeat (array_length(Renderables))
		{
			with (Renderables[i++])
			{
				render();
			}
		}

		bbmod_material_reset();

		var _materials, m;

		var _directionalLight = DirectionalLight;
		var _directionalLightCastShadows = false;
		var _directionalLightTexture;
		var _directionalLightMatrix;

		if (_directionalLight != undefined)
		{
			_directionalLightCastShadows = _directionalLight.CastShadows;
			if (_directionalLightCastShadows)
			{
				_directionalLightTexture = surface_get_texture(_directionalLight.get_shadowmap_surface());
				_directionalLightMatrix = matrix_multiply(
					_directionalLight.get_view_matrix(),
					_directionalLight.get_projection_matrix());
			}
		}

		// Shadows pass
		if (_directionalLightCastShadows
			&& _directionalLight.set_target())
		{
			draw_clear(c_red);

			global.bbmod_render_pass = BBMOD_ERenderPass.Shadows;
			_materials = bbmod_get_materials(global.bbmod_render_pass);
			m = 0;
			repeat (array_length(_materials))
			{
				var _material = _materials[m++];
				if (!_material.has_commands()
					|| !_material.apply())
				{
					continue;
				}
				_material.submit_queue();
			}

			_directionalLight.reset_target();

			// Reset to the current camera's matrices
			matrix_set(matrix_view, _view);
			matrix_set(matrix_projection, _projection);
		}

		// Forward pass
		global.bbmod_render_pass = BBMOD_ERenderPass.Forward;
		_materials = bbmod_get_materials(global.bbmod_render_pass);
		m = 0;
		repeat (array_length(_materials))
		{
			var _material = _materials[m++];
	
			if (!_material.has_commands()
				|| !_material.apply())
			{
				continue;
			}

			if (_directionalLightCastShadows)
			{
				try
				{
					BBMOD_SHADER_CURRENT.set_shadowmap(
						_directionalLightTexture,
						_directionalLightMatrix);
				}
				catch (_ignore)
				{
				}
			}

			_material.submit_queue()
				.clear_queue();
		}

		bbmod_material_reset();
		matrix_set(matrix_world, _world);

		return self;
	};

	static present = function () {
		if (UseAppSurface)
		{
			gpu_push_state();
			gpu_set_tex_filter(true);
			var _shader = BBMOD_ShPostProcess;
			shader_set(_shader);
			texture_set_stage(shader_get_sampler_index(_shader, "u_sLut"), sprite_get_texture(BBMOD_SprColorLUT, 0));
			shader_set_uniform_f(shader_get_uniform(_shader, "u_fLutIndex"), !keyboard_check(ord("C")));
			shader_set_uniform_f(shader_get_uniform(_shader, "u_vTexel"),
				1 / surface_get_width(application_surface),
				1 / surface_get_height(application_surface));
			shader_set_uniform_f(shader_get_uniform(_shader, "u_fDistortion"), 4);
			draw_surface_stretched(application_surface, 0, 0, window_get_width(), window_get_height());
			shader_reset();
			gpu_pop_state();
		}
		return self;
	};
}