/// @func BBMOD_DirectionalLight()
/// @extends BBMOD_Light
/// @implements {BBMOD_IRenderTarget}
function BBMOD_DirectionalLight()
	: BBMOD_Light() constructor
{
	implement(BBMOD_IRenderTarget);

	static Super_Light = {
		destroy: destroy,
	};

	/// @var {BBMOD_Vec3} The direction of the light.
	Direction = new BBMOD_Vec3(-1.0, 0.0, -1.0).Normalize();

	/// @var {bool} If `true` then the light casts shadows. Defaults to `false`.
	CastShadows = false;

	/// @var {surface} The surface used for rendering the scene's depth from the
	/// light's view.
	/// @private
	Shadowmap = noone;

	/// @var {real} The area captured by the shadowmap.
	ShadowmapArea = 1024;

	/// @var {uint} The resolution of the shadowmap surface.
	/// @readonly
	/// @see BBMOD_DirectionalLight.set_shadowmap_resolution
	ShadowmapResolution = 1024;

	/// @func get_shadowmap_surface()
	/// @desc Retrieves the shadowmap surface.
	/// @return {surface} The shadowmap surface.
	static get_shadowmap_surface = function () {
		gml_pragma("forceinline");
		Shadowmap = bbmod_surface_check(
			Shadowmap, ShadowmapResolution, ShadowmapResolution);
		return Shadowmap;
	};

	/// @func get_view_matrix()
	/// @desc Creates the view matrix.
	/// @return {real[16]} The view matrix.
	static get_view_matrix = function () {
		gml_pragma("forceinline");
		return matrix_build_lookat(
			Position.X,
			Position.Y,
			Position.Z,
			Position.X + Direction.X,
			Position.Y + Direction.Y,
			Position.Z + Direction.Z,
			0, 0, 1, // TODO: Find the up vector
		);
	};

	/// @func get_projection_matrix()
	/// @desc Creates the projection matrix.
	/// @return {real[16]} The projection matrix.
	static get_projection_matrix = function () {
		gml_pragma("forceinline");
		return matrix_build_projection_ortho(
			ShadowmapArea, ShadowmapArea, -ShadowmapArea * 0.5, ShadowmapArea * 0.5);
	};

	static set_target = function () {
		gml_pragma("forceinline");
		surface_set_target(get_shadowmap_surface());
		matrix_set(matrix_view, get_view_matrix());
		matrix_set(matrix_projection, get_projection_matrix());
		return true;
	};

	static reset_target = function () {
		gml_pragma("forceinline");
		surface_reset_target();
		return self;
	};

	static destroy = function () {
		method(self, Super_Light.destroy)();
		if (Shadowmap != undefined
			&& surface_exists(Shadowmap))
		{
			surface_free(Shadowmap);
		}
	};
}