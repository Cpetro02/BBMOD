# Changelog 3.2.0

## GML API:
**Core module:**
* Parameter `_shader` in the constructor of `BBMOD_Material` is now optional.
* Removed property `Shader` of `BBMOD_Material`.
* Added new methods `set_shader`, `has_shader`, `get_shader` and `remove_shader` to `BBMOD_Material`, using which you can define shaders used by the material in specific render passes.
* Added new macro `BBMOD_RENDER_ALPHA`.
* Method `BBMOD_Material.apply` now returns `true` or `false` based on whether the material was applied (instead of always returning `self`).
* Method `BBMOD_Material.submit_queue` does not longer automatically clear the queue.
* Added new method `BBMOD_Material.clear_queue`, which clears the material's render queue.

**PBR module:**
* Parameter `_shader` in the constructor of `BBMOD_PBRMaterial` is now optional.
* PBR module now requires Renderer module.
* Added new struct `BBMOD_PBRRenderer`.

**Shadow mapping module:**
* Added new module - Shadow mapping.
* Added new shaders `BBMOD_ShDepth`, `BBMOD_ShDepthAnimated` and `BBMOD_ShDepthBatched`, which only output the scene's depth.
* Added new struct `BBMOD_DepthShader`.
* Added new macros `BBMOD_SHADER_DEPTH`, `BBMOD_SHADER_DEPTH_ANIMATED` and `BBMOD_SHADER_DEPTH_BATCHED`.
* Added new variable `global.bbmod_camera_clip_far`.
