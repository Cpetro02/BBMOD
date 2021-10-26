# Changelog 3.2.0

## GML API:
**Core module:**
* Parameter `_shader` in the constructor of `BBMOD_Material` is now optional.
* Removed property `Shader` of `BBMOD_Material`.
* Added new methods `set_shader`, `has_shader`, `get_shader` and `remove_shader` to `BBMOD_Material`, using which you can define shaders used by the material in specific render passes.
* Added new macro `BBMOD_RENDER_ALPHA`.

**PBR module:**
* Parameter `_shader` in the constructor of `BBMOD_PBRMaterial` is now optional.
