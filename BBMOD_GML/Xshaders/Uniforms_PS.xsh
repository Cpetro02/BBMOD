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

uniform Texture2D bbmod_Shadowmap;

uniform Mat4 bbmod_ShadowmapMatrix;

uniform Vec2 bbmod_ShadowmapTexel;
#endif

// Pixels with alpha less than this value will be discarded.
uniform float bbmod_AlphaTest;
