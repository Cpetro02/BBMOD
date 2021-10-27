/// @func BBMOD_PBRRenderer()
/// @extends BBMOD_Renderer
function BBMOD_PBRRenderer()
	: BBMOD_Renderer() constructor
{
	static render = function () {
		var _world = matrix_get(matrix_world);

		var i = 0;
		repeat (array_length(Renderables))
		{
			with (Renderables[i++])
			{
				render();
			}
		}

		bbmod_material_reset();

		var _materials = bbmod_get_materials();
		var m = 0;

		// Shadows pass
		global.bbmod_render_pass = BBMOD_RENDER_SHADOWS;
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

		// Forward pass
		global.bbmod_render_pass = BBMOD_RENDER_FORWARD;
		m = 0;
		repeat (array_length(_materials))
		{
			var _material = _materials[m++];
			if (_material.has_commands())
			{
				if (_material.apply())
				{
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