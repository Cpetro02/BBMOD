#if PBR || GBUFFER
// RGB: Base color, A: Opacity
#define bbmod_BaseOpacity gm_BaseTexture

// RGB: Tangent space normal, A: Roughness
uniform Texture2D bbmod_NormalRoughness;

// R: Metallic, G: Ambient occlusion
uniform Texture2D bbmod_MetallicAO;

// RGB: Subsurface color, A: Intensity
uniform Texture2D bbmod_Subsurface;

// RGBM encoded emissive color
uniform Texture2D bbmod_Emissive;
#endif

#if PBR
// Prefiltered octahedron env. map
uniform Texture2D bbmod_IBL;

// Texel size of one octahedron.
uniform Vec2 bbmod_IBLTexel;

// Preintegrated env. BRDF
uniform Texture2D bbmod_BRDF;

// Camera's position in world space
uniform Vec3 bbmod_CamPos;

// Camera's exposure value
uniform float bbmod_Exposure;

// Shadowmap texture
uniform Texture2D bbmod_Shadowmap;

// WORLD_VIEW_PROJECTION matrix used when rendering shadowmap
uniform Mat4 bbmod_ShadowmapMatrix;

// (1.0/shadowmapWidth, 1.0/shadowmapHeight)
uniform Vec2 bbmod_ShadowmapTexel;

// Direction of the directional light
uniform Vec3 bbmod_LightDirectionalDir;

// RGBM encoded color of the directional light
uniform Vec4 bbmod_LightDirectionalColor;

// [(x, y, z, range), (r, g, b, m), ...]
uniform Vec4 bbmod_LightPointData[MAX_LIGHTS * 2];
#endif

// Pixels with alpha less than this value will be discarded.
uniform float bbmod_AlphaTest;
