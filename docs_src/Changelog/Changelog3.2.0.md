# Changelog 3.2.0

## GML API:
### Core module:
* Parameter `_shader` in the constructor of `BBMOD_Material` is now optional.
* Removed property `Shader` of `BBMOD_Material`.
* Added new methods `set_shader`, `has_shader`, `get_shader` and `remove_shader` to `BBMOD_Material`, using which you can define shaders used by the material in specific render passes.
* Method `BBMOD_Material.apply` now returns `true` or `false` based on whether the material was applied (instead of always returning `self`).
* Method `BBMOD_Material.submit_queue` does not longer automatically clear the queue.
* Added new method `BBMOD_Material.clear_queue`, which clears the material's render queue.
* Added new function `bbmod_surface_check`, which creates a new surface if it does not exist or if it has wrong size.
* Added new interface `BBMOD_IRenderTarget` for structs that can be set as a render target.
* Added new macro `BBMOD_RGBM_VALUE_MAX`, which defines the maximum value which a single color channel can have before it is converted to RGBM.
* Added new struct `BBMOD_Color`.
* Added new struct `BBMOD_OutOfRangeException`.
* Added new methods `Set` and `SetIndex` to `BBMOD_Vec2`, `BBMOD_Vec3` and `BBMOD_Vec4` using which you can change the vector components in-place.
* New `BBMOD_Material`s no longer use the checkerboard texture as the default. The texture is still used by `BBMOD_MATERIAL_DEFAULT*` materials.
* Added new enum of render passes `BBMOD_ERenderPass`.
* Deprecated macros `BBMOD_RENDER_DEFERRED`, `BBMOD_RENDER_FORWARD` and `BBMOD_RENDER_SHADOWS`. Use appropriate members of `BBMOD_ERenderPass` instead, as these macros will be removed in a future release.
* Function `bbmod_get_materials` now accepts an optional render pass argument, using which you can retrieve only materials that have a shader for a specific render pass.
* Added new utility function `bbmod_get_calling_function_name` using which you can retrieve the name of the function that calls it.

### Rendering module:
* Added new module - Rendering - which encapsulates modules related to rendering.

#### Cubemap module:
* Added new Rendering submodule - Cubemap.
* Added new struct `BBMOD_Cubemap`.

#### Lights module:
* Added new Rendering submodule - Lights.
* Added new struct `BBMOD_Light`.
* Added new struct `BBMOD_DirectionalLight`.
* Added new struct `BBMOD_PointLight`.

#### PBR module:
* The PBR module is now a submodule of the Rendering module.
* Parameter `_shader` in the constructor of `BBMOD_PBRMaterial` is now optional.
* Method `BBMOD_PBRMaterial.set_emissive` now accepts `BBMOD_Color` as an argument. The variant with 3 arguments (one for each color channel) is kept for backwards compatibility, but it should not be used anymore, as it will be removed in a future release!
* The PBR module now requires the Renderer module.
* Added new struct `BBMOD_PBRRenderer`.

#### Shadow mapping module:
* Added new Rendering submodule - Shadow mapping.
* Added new shaders `BBMOD_ShShadowmap`, `BBMOD_ShShadowmapAnimated` and `BBMOD_ShShadowmapBatched` for shadow mapping.
* Added new macros `BBMOD_SHADER_SHADOWMAP`, `BBMOD_SHADER_SHADOWMAP_ANIMATED` and `BBMOD_SHADER_SHADOWMAP_BATCHED`.
