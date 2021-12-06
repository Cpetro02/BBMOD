////////////////////////////////////////////////////////////////////////////////
// Create material
matMetal = BBMOD_MATERIAL_PBR.clone()
	.set_base_opacity(c_silver, 1)
	.set_metallic_ao(1, 1)
	.set_normal_roughness(BBMOD_VEC3_UP, 0.2);

matDark = BBMOD_MATERIAL_PBR.clone()
	.set_base_opacity($101010, 1)
	.set_normal_roughness(BBMOD_VEC3_UP, 0.7);

matDarkMetal = BBMOD_MATERIAL_PBR.clone()
	.set_base_opacity($101010, 1)
	.set_metallic_ao(1, 1)
	.set_normal_roughness(BBMOD_VEC3_UP, 0.2);

matPurle = BBMOD_MATERIAL_PBR.clone()
	.set_base_opacity(c_fuchsia, 1)
	.set_normal_roughness(BBMOD_VEC3_UP, 0.7);

////////////////////////////////////////////////////////////////////////////////
// Load models and assing materials
var _objImporter = new BBMOD_OBJImporter();

modBlaster = _objImporter.import("Data/FPS/Blaster.obj");
modBlaster.Materials[0] = matMetal;
modBlaster.Materials[1] = matDark;
modBlaster.Materials[2] = matDarkMetal;
modBlaster.Materials[3] = matPurle;
//show_debug_message(modBlaster.MaterialNames);

modCube = _objImporter.import("Data/FPS/Cube.obj");
modCube.Materials[0] = BBMOD_MATERIAL_PBR.clone();

_objImporter.destroy();

////////////////////////////////////////////////////////////////////////////////
// Create a renderer
renderer = new BBMOD_Renderer();
renderer.UseAppSurface = true;
renderer.RenderScale = 2.0;
renderer.EnableShadows = true;
renderer.ShadowmapArea = 512;
renderer.ShadowmapResolution = 2048;
renderer.EnableGBuffer = true;
renderer.EnableSSAO = true;
renderer.EnablePostProcessing = true;

// Define ambient light color for the lower and the upper hemisphere
renderer.AmbientLightUp = new BBMOD_Color().FromConstant(c_silver);
renderer.AmbientLightDown = new BBMOD_Color().FromConstant(c_purple);

var _lightSun = new BBMOD_DirectionalLight(
	new BBMOD_Color().FromConstant(c_orange),
	new BBMOD_Vec3(-1, -1, -0.5).Normalize());
_lightSun.CastShadows = true;
renderer.DirectionalLight = _lightSun;