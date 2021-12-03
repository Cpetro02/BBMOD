#if PBR
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
// RGBM encoded ambient light color on the upper hemisphere.
uniform Vec4 bbmod_AmbientUp;

/// RGBM encoded ambient light color on the lower hemisphere.
uniform Vec4 bbmod_AmbientDown;

// Prefiltered octahedron env. map
uniform Texture2D bbmod_IBL;

// Texel size of one octahedron.
uniform Vec2 bbmod_IBLTexel;

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

// The area that the shadowmap captures.
uniform float bbmod_ShadowmapArea;

// Offsets vertex position by its normal scaled by this value.
uniform float bbmod_ShadowmapNormalOffset;

// Direction of the directional light
uniform Vec3 bbmod_LightDirectionalDir;

// RGBM encoded color of the directional light
uniform Vec4 bbmod_LightDirectionalColor;

// [(x, y, z, range), (r, g, b, m), ...]
uniform Vec4 bbmod_LightPointData[MAX_LIGHTS * 2];

// SSAO texture
uniform Texture2D bbmod_SSAO;
#endif

// Pixels with alpha less than this value will be discarded.
uniform float bbmod_AlphaTest;

// Distance to the far clipping plane.
uniform float bbmod_ClipFar;
