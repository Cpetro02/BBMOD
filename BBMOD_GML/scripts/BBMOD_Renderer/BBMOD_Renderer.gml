/// @func BBMOD_Renderer()
/// @extends BBMOD_Class
/// @desc Implements a basic renderer which automatically renders all added
/// [renderables](./BBMOD_Renderer.Renderables.html) sorted by
/// [materials](./BBMOD_Material.html), sorted by their
/// [priority](./BBMOD_Material.Priority.html).
/// @example
/// Following code is a typical use of the renderer.
/// ```gml
/// // Create event
/// renderer = new BBMOD_Renderer()
///     .add(OCharacter)
///     .add(OTree)
///     .add(OTerrain)
///     .add(OSky);
/// renderer.UseAppSurface = true;
/// renderer.RenderScale = 2.0;
///
/// camera = new BBMOD_Camera();
/// camera.FollowObject = OPlayer;
///
/// // Step event
/// camera.set_mouselook(true);
/// camera.update(delta_time);
/// renderer.update(delta_time);
///
/// // Draw event
/// camera.apply();
/// renderer.render();
/// 
/// // Post-Draw event
/// renderer.present();
///
/// // Clean Up event
/// renderer.destroy();
/// ```
/// @see BBMOD_IRenderable
/// @see BBMOD_Camera
function BBMOD_Renderer()
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	/// @var {BBMOD_IRenderable[]} An array of renderable objects and structs.
	/// These are automatically rendered in {@link BBMOD_Renderer.render}.
	/// @readonly
	/// @see BBMOD_Renderer.add
	/// @see BBMOD_Renderer.remove
	/// @see BBMOD_IRenderable
	Renderables = [];

	/// @var {bool} Set to `true` to enable the `application_surface`.
	/// Use method {@link BBMOD_Renderer.present} to draw the
	/// `application_surface` to the screen. Defaults to `false`.
	UseAppSurface = false;

	/// @var {real} Resolution multiplier for the `application_surface`.
	/// {@link BBMOD_Renderer.UseAppSurface} must be enabled for this to
	/// have any effect. Defaults to 1.
	RenderScale = 1.0;

	/// @var {bool} Enables rendering into a G-buffer in the deferred pass.
	/// Defaults to `true`.
	/// @see BBMOD_ERenderPass.Deferred
	EnableGBuffer = true;

	/// @var {real} Resolution multiplier for the G-buffer surface. Defaults
	/// to 1.
	GBufferScale = 1.0;

	/// @var {surface} The G-buffer surface.
	/// @private
	SurGBuffer = noone;

	/// @var {bool} Enables screen-space ambient occlusion. This requires
	/// the G-buffer. Defaults to `true`.
	/// @see BBMOD_Renderer.EnableGBuffer
	EnableSSAO = true;

	/// @var {real} Resolution multiplier for SSAO surface. Defaults to 1.
	SSAOScale = 1.0;

	/// @var {BBMOD_Color} The color of the ambient light on the upper hemisphere.
	/// Defaults to black.
	AmbientLightUp = new BBMOD_Color(0, 0, 0);

	/// @var {BBMOD_Color} The color of the ambient light on the lower hemisphere.
	/// Defaults to black.
	AmbientLightDown = new BBMOD_Color(0, 0, 0);

	/// @var {BBMOD_ImageBasedLight/undefined} An image based light.
	ImageBasedLight = undefined;

	/// @var {BBMOD_DirectionalLight/undefined} The directional light.
	DirectionalLight = undefined;

	/// @var {bool} Enables rendering into a shadowmap in the shadows render pass.
	/// Defauls to `true`.
	/// @see BBMOD_Renderer.ShadowmapArea
	/// @see BBMOD_Renderer.ShadowmapResolution
	EnableShadows = true;

	/// @var {surface} The surface used for rendering the scene's depth from the
	/// directional light's view.
	/// @private
	SurShadowmap = noone;

	/// @var {real} The area captured by the shadowmap. Defaults to 256.
	ShadowmapArea = 256;

	/// @var {uint} The resolution of the shadowmap surface. Must be power of 2.
	/// Defaults to 1024.
	ShadowmapResolution = 1024;

	/// @var {real} When rendering shadows, offsets vertex position by its normal
	/// scaled by this value. Defaults to 1. Increasing the value can remove some
	/// artifacts but using too high value could make the objects appear flying
	/// above the ground.
	ShadowmapNormalOffset = 1.0;

	/// @var {BBMOD_PointLight[]} An array of point lights.
	/// @readonly
	PointLights = [];

	/// @var {bool} Enables post-processing effects. Defaults to `true`.
	EnablePostProcessing = true;

	/// @var {ptr} The lookup table texture used for color grading.
	/// @note Post-processing must be enabled for this to have any effect!
	/// @see BBMOD_Renderer.EnablePostProcessing
	ColorGradingLUT = sprite_get_texture(BBMOD_SprColorGradingLUT, 0);

	/// @var {real} The strength of the chromatic aberration effect. Use 0 to
	/// disable the effect. Defaults to 2.
	/// @note Post-processing must be enabled for this to have any effect!
	/// @see BBMOD_Renderer.EnablePostProcessing
	ChromaticAberration = 2.0;

	/// @var {real} The strength of the grayscale effect. Use values in range 0..1,
	/// where 0 means the original color and 1 means grayscale. Defaults to 0.
	/// @note Post-processing must be enabled for this to have any effect!
	/// @see BBMOD_Renderer.EnablePostProcessing
	Grayscale = 0.0;

	ssao_init(8.0, 1.0, 1.0);

	/// @func add(_renderable)
	/// @desc Adds a renderable object or struct to the renderer.
	/// @param {BBMOD_IRenderable} _renderable The renderable object or struct
	/// to add.
	/// @return {BBMOD_Renderer} Returns `self`.
	/// @see BBMOD_Renderer.remove
	/// @see BBMOD_IRenderable
	static add = function (_renderable) {
		gml_pragma("forceinline");
		array_push(Renderables, _renderable);
		return self;
	};

	/// @func remove(_renderable)
	/// @desc Removes a renderable object or a struct from the renderer.
	/// @param {BBMOD_IRenderable} _renderable The renderable object or struct
	/// to remove.
	/// @return {BBMOD_Renderer} Returns `self`.
	/// @see BBMOD_Renderer.add
	/// @see BBMOD_IRenderable
	static remove = function (_renderable) {
		gml_pragma("forceinline");
		for (var i = array_length(Renderables) - 1; i >= 0; --i)
		{
			if (Renderables[i] == _renderable)
			{
				array_delete(Renderables, i, 1);
			}
		}
		return self;
	};

	/// @func add_point_light(_pointLight)
	/// @desc Adds a point light to the renderer.
	/// @param {BBMOD_PointLight} _pointLight The point light to add.
	/// @return {BBMOD_Renderer} Returns `self`.
	/// @see BBMOD_PointLight
	static add_point_light = function (_pointLight) {
		gml_pragma("forceinline");
		array_push(PointLights, _pointLight);
		return self;
	};

	/// @func remove_point_light(_pointLight)
	/// @desc Removes a point light from the renderer.
	/// @param {BBMOD_PointLight} _pointLight The point light to remove.
	/// @return {BBMOD_Renderer} Returns `self`.
	/// @see BBMOD_PointLight
	static add_point_light = function (_pointLight) {
		gml_pragma("forceinline");
		for (var i = array_length(PointLights) - 1; i >= 0; --i)
		{
			if (PointLights[i] == _pointLight)
			{
				array_delete(PointLights, i, 1);
			}
		}
		return self;
	};

	/// @func update(_deltaTime)
	/// @desc Updates the renderer. This should be called in the Step event.
	/// @param {real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	/// @return {BBMOD_Renderer} Returns `self`.
	static update = function (_deltaTime) {
		if (UseAppSurface)
		{
			application_surface_enable(true);
			application_surface_draw_enable(false);

			var _windowWidth = max(window_get_width(), 1);
			var _windowHeight = max(window_get_height(), 1);
			var _surfaceWidth = floor(max(_windowWidth * RenderScale, 1.0));
			var _surfaceHeight = floor(max(_windowHeight * RenderScale, 1.0));

			if (surface_get_width(application_surface) != _surfaceWidth
				|| surface_get_height(application_surface) != _surfaceHeight)
			{
				surface_resize(application_surface, _surfaceWidth, _surfaceHeight);
			}
		}
		return self;
	};

	static get_shadowmap_view = function () {
		gml_pragma("forceinline");
		var _directionalLight = DirectionalLight;
		if (_directionalLight == undefined)
		{
			return matrix_build_identity();
		}
		var _directionalLightPosition = _directionalLight.Position;
		var _directionalLightDirection = _directionalLight.Direction;
		return matrix_build_lookat(
			_directionalLightPosition.X,
			_directionalLightPosition.Y,
			_directionalLightPosition.Z,
			_directionalLightPosition.X + _directionalLightDirection.X,
			_directionalLightPosition.Y + _directionalLightDirection.Y,
			_directionalLightPosition.Z + _directionalLightDirection.Z,
			0.0, 0.0, 1.0); // TODO: Find the up vector
	};

	static get_shadowmap_projection = function () {
		gml_pragma("forceinline");
		return matrix_build_projection_ortho(
			ShadowmapArea, ShadowmapArea, -ShadowmapArea * 0.5, ShadowmapArea * 0.5);
	};

	static get_shadowmap_matrix = function () {
		gml_pragma("forceinline");
		if (DirectionalLight == undefined)
		{
			return matrix_build_identity();
		}
		return matrix_multiply(
			get_shadowmap_view(),
			get_shadowmap_projection());
	};

	/// @func render_shadowmap()
	/// @desc Renders shadowmap.
	/// @note This modifies render pass and view and projection matrices and
	/// for optimization reasons it does not reset them back! Make sure to do
	/// that yourself in the calling function if needed.
	/// @private
	static render_shadowmap = function () {
		gml_pragma("forceinline");

		var _directionalLight = DirectionalLight;
		if (_directionalLight == undefined)
		{
			_directionalLight = new BBMOD_DirectionalLight();
			_directionalLight.CastShadows = false;
		}

		var _castShadows = (EnableShadows && _directionalLight.CastShadows);
		if (_castShadows)
		{
			SurShadowmap = bbmod_surface_check(SurShadowmap, ShadowmapResolution, ShadowmapResolution);
		}
		else
		{
			SurShadowmap = bbmod_surface_check(SurShadowmap, 1, 1);
		}

		surface_set_target(SurShadowmap);
		draw_clear(c_red);
		if (_castShadows)
		{
			matrix_set(matrix_view, get_shadowmap_view());
			matrix_set(matrix_projection, get_shadowmap_projection());
			var _shadowmapArea = ShadowmapArea;
			global.bbmod_render_pass = BBMOD_ERenderPass.Shadows;
			var _materials = bbmod_get_materials(global.bbmod_render_pass);
			var m = 0;
			repeat (array_length(_materials))
			{
				var _material = _materials[m++];
				if (!_material.has_commands()
					|| !_material.apply())
				{
					continue;
				}
				try
				{
					BBMOD_SHADER_CURRENT.set_clip_far(_shadowmapArea);
				}
				catch (_ignore) {}
				_material.submit_queue();
			}
		}
		surface_reset_target();
	};

	SurSSAO = noone;
	SurWork = noone;

	/// @func render()
	/// @desc Renders all added [renderables](./BBMOD_Renderer.Renderables.html)
	/// to the current render target.
	/// @return {BBMOD_Renderer} Returns `self`.
	static render = function () {
		var _windowWidth = window_get_width();
		var _windowHeight = window_get_height();
		var _world = matrix_get(matrix_world);
		var _view = matrix_get(matrix_view);
		var _projection = matrix_get(matrix_projection);
		var _clipFar = OPlayer.camera.ZFar; // TODO: Get cam clip far!

		var i = 0;
		repeat (array_length(Renderables))
		{
			with (Renderables[i++])
			{
				render();
			}
		}

		bbmod_material_reset();

		render_shadowmap();

		var _materials, m;

		////////////////////////////////////////////////////////////////////////
		// G-buffer pass
		if (EnableGBuffer)
		{
			var _target = surface_get_target();
			var _width = _windowWidth * GBufferScale;
			var _height = _windowHeight * GBufferScale;
			SurGBuffer = bbmod_surface_check(SurGBuffer, _width, _height);
			surface_set_target(SurGBuffer);
			draw_clear(c_white);
			matrix_set(matrix_view, _view);
			matrix_set(matrix_projection, _projection);

			global.bbmod_render_pass = BBMOD_ERenderPass.Deferred;
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

				try
				{
					BBMOD_SHADER_CURRENT.set_clip_far(_clipFar);
				}
				catch (_ignore) {}

				_material.submit_queue();
			}

			surface_reset_target();
		}

		////////////////////////////////////////////////////////////////////////
		// Render SSAO
		if (EnableGBuffer && EnableSSAO)
		{
			bbmod_material_reset();
			var _target = surface_get_target();
			var _width = _windowWidth * SSAOScale;
			var _height = _windowHeight * SSAOScale;
			SurSSAO = bbmod_surface_check(SurSSAO, _width, _height);
			SurWork = bbmod_surface_check(SurWork, _width, _height);
			ssao_draw(SurSSAO, SurWork, SurGBuffer, _projection, _clipFar);
			bbmod_material_reset();
		}

		////////////////////////////////////////////////////////////////////////
		// Forward pass
		matrix_set(matrix_view, _view);
		matrix_set(matrix_projection, _projection);

		global.bbmod_render_pass = BBMOD_ERenderPass.Forward;
		_materials = bbmod_get_materials(global.bbmod_render_pass);
		m = 0;

		var _ambientLightUp = AmbientLightUp;
		var _ambientLightDown = AmbientLightDown;
		var _imageBasedLight = ImageBasedLight ?? bbmod_ibl_null();
		var _directionalLight = DirectionalLight;
		var _shadowmapTexture = surface_get_texture(SurShadowmap);
		var _shadowmapMatrix = get_shadowmap_matrix();
		var _shadowmapArea = ShadowmapArea;
		var _shadowmapNormalOffset = ShadowmapNormalOffset;

		repeat (array_length(_materials))
		{
			var _material = _materials[m++];
	
			if (!_material.has_commands()
				|| !_material.apply())
			{
				continue;
			}

			try
			{
				BBMOD_SHADER_CURRENT.set_ambient_light(_ambientLightUp, _ambientLightDown);
			}
			catch (_ignore) {}

			try
			{
				BBMOD_SHADER_CURRENT.set_image_based_light(_imageBasedLight);
			}
			catch (_ignore) {}

			try
			{
				BBMOD_SHADER_CURRENT.set_directional_light(_directionalLight);
			}
			catch (_ignore) {}

			try
			{
				BBMOD_SHADER_CURRENT.set_shadowmap(
					_shadowmapTexture,
					_shadowmapMatrix,
					_shadowmapArea,
					_shadowmapNormalOffset);
			}
			catch (_ignore) {}

			try
			{
				BBMOD_SHADER_CURRENT.set_point_lights(PointLights);
			}
			catch (_ignore) {}

			try
			{
				BBMOD_SHADER_CURRENT.set_ssao(surface_get_texture(SurSSAO));
			}
			catch (_ignore) {}

			try
			{
				BBMOD_SHADER_CURRENT.set_cam_pos(global.bbmod_camera_position);
			}
			catch (_ignore) {}

			try
			{
				BBMOD_SHADER_CURRENT.set_exposure(global.bbmod_camera_exposure);
			}
			catch (_ignore) {}

			_material.submit_queue()
				.clear_queue();
		}

		bbmod_material_reset();
		matrix_set(matrix_world, _world);

		return self;
	};

	/// @func present()
	/// @desc Renders the `application_surface` to the screen.
	/// {@link BBMOD_Renderer.UseAppSurface} must be enabled for this to
	/// have any effect.
	/// @return {BBMOD_Renderer} Returns `self`.
	static present = function () {
		if (UseAppSurface)
		{
			var _windowWidth = window_get_width();
			var _windowHeight = window_get_height();
			gpu_push_state();
			gpu_set_tex_filter(true);
			if (EnablePostProcessing)
			{
				var _shader = BBMOD_ShPostProcess;
				shader_set(_shader);
				texture_set_stage(shader_get_sampler_index(_shader, "u_texLut"), ColorGradingLUT);
				shader_set_uniform_f(shader_get_uniform(_shader, "u_vTexel"), 1 / _windowWidth, 1 / _windowHeight);
				shader_set_uniform_f(shader_get_uniform(_shader, "u_fDistortion"), ChromaticAberration);
				shader_set_uniform_f(shader_get_uniform(_shader, "u_fGrayscale"), Grayscale);
			}
			draw_surface_stretched(application_surface, 0, 0, _windowWidth, _windowHeight);
			if (EnablePostProcessing)
			{
				shader_reset();
			}
			gpu_pop_state()
		}
		return self;
	};
}