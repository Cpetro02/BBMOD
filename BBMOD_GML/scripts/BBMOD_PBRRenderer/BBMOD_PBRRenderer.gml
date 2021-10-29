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

		// Shadows pass
		if (DirectionalLight != undefined
			&& DirectionalLight.CastShadows
			&& DirectionalLight.set_target())
		{
			draw_clear(c_red);

			global.bbmod_render_pass = BBMOD_RENDER_SHADOWS;
			_materials = bbmod_get_materials(global.bbmod_render_pass);
			m = 0;
			repeat (array_length(_materials))
			{
				var _material = _materials[m++];
				if (_material.has_commands())
				{
					if (_material.apply())
					{
						_material.submit_queue();
					}
				}
			}

			DirectionalLight.reset_target();

			// Reset to the current camera's matrices
			matrix_set(matrix_view, _view);
			matrix_set(matrix_projection, _projection);
		}

		// Forward pass
		global.bbmod_render_pass = BBMOD_RENDER_FORWARD;
		_materials = bbmod_get_materials(global.bbmod_render_pass);
		m = 0;
		repeat (array_length(_materials))
		{
			var _material = _materials[m++];
			if (_material.has_commands())
			{
				if (_material.apply())
				{
					if (DirectionalLight != undefined
						&& DirectionalLight.CastShadows)
					{
						try
						{
							var _shadowmap = surface_get_texture(
								DirectionalLight.get_shadowmap_surface());
							var _matrix = matrix_multiply(
								DirectionalLight.get_view_matrix(),
								DirectionalLight.get_projection_matrix());
							BBMOD_SHADER_CURRENT.set_shadowmap(_shadowmap, _matrix);
						}
						catch (_ignore)
						{
							show_debug_message(_ignore);
						}
					}

					_material.submit_queue()
						.clear_queue();
				}
			}
		}

		bbmod_material_reset();
		matrix_set(matrix_world, _world);

		return self;
	};
}