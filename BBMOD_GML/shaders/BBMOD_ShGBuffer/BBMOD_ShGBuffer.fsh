#pragma include("Uber_PS.xsh", "glsl")
#define MUL(m, v) ((m) * (v))
#define IVec4 ivec4

varying vec3 v_vVertex;
//varying vec4 v_vColor;
varying vec2 v_vTexCoord;
varying mat3 v_mTBN;
varying float v_fDepth;


// RGB: Base color, A: Opacity
#define bbmod_BaseOpacity gm_BaseTexture

// RGB: Tangent space normal, A: Roughness
uniform sampler2D bbmod_NormalRoughness;

// R: Metallic, G: Ambient occlusion
uniform sampler2D bbmod_MetallicAO;

// RGB: Subsurface color, A: Intensity
uniform sampler2D bbmod_Subsurface;

// RGBM encoded emissive color
uniform sampler2D bbmod_Emissive;

// Prefiltered octahedron env. map
uniform sampler2D bbmod_IBL;

// Texel size of one octahedron.
uniform vec2 bbmod_IBLTexel;

// Preintegrated env. BRDF
uniform sampler2D bbmod_BRDF;

// Camera's position in world space
uniform vec3 bbmod_CamPos;

// Camera's exposure value
uniform float bbmod_Exposure;

uniform sampler2D bbmod_Shadowmap;

uniform mat4 bbmod_ShadowmapMatrix;

uniform vec2 bbmod_ShadowmapTexel;

// Pixels with alpha less than this value will be discarded.
uniform float bbmod_AlphaTest;


// #pragma include("BRDF.xsh")
#ifndef X_F0_DEFAULT
#define X_F0_DEFAULT vec3(0.04, 0.04, 0.04)
#endif
#define X_GAMMA 2.2

/// @desc Converts gamma space color to linear space.
vec3 xGammaToLinear(vec3 rgb)
{
	return pow(rgb, vec3(X_GAMMA));
}

/// @desc Converts linear space color to gamma space.
vec3 xLinearToGamma(vec3 rgb)
{
	return pow(rgb, vec3(1.0 / X_GAMMA));
}

/// @desc Gets color's luminance.
float xLuminance(vec3 rgb)
{
	return (0.2126 * rgb.r + 0.7152 * rgb.g + 0.0722 * rgb.b);
}
/// @note Input color should be in gamma space.
/// @source https://graphicrants.blogspot.cz/2009/04/rgbm-color-encoding.html
vec4 xEncodeRGBM(vec3 color)
{
	vec4 rgbm;
	color *= 1.0 / 6.0;
	rgbm.a = clamp(max(max(color.r, color.g), max(color.b, 0.000001)), 0.0, 1.0);
	rgbm.a = ceil(rgbm.a * 255.0) / 255.0;
	rgbm.rgb = color / rgbm.a;
	return rgbm;
}

/// @source https://graphicrants.blogspot.cz/2009/04/rgbm-color-encoding.html
vec3 xDecodeRGBM(vec4 rgbm)
{
	return 6.0 * rgbm.rgb * rgbm.a;
}

struct Material
{
	vec3 Base;
	float Opacity;
	vec3 Normal;
	float Roughness;
	float Metallic;
	float AO;
	vec4 Subsurface;
	vec3 Emissive;
	vec3 Specular;
};

Material UnpackMaterial(
	sampler2D texBaseOpacity,
	sampler2D texNormalRoughness,
	sampler2D texMetallicAO,
	sampler2D texSubsurface,
	sampler2D texEmissive,
	mat3 tbn,
	vec2 uv)
{
	vec4 baseOpacity = texture2D(texBaseOpacity, uv);
	vec3 base = xGammaToLinear(baseOpacity.rgb);
	float opacity = baseOpacity.a;

	vec4 normalRoughness = texture2D(texNormalRoughness, uv);
	vec3 normal = normalize(MUL(tbn, normalRoughness.rgb * 2.0 - 1.0));
	float roughness = mix(0.1, 0.9, normalRoughness.a);

	vec4 metallicAO = texture2D(texMetallicAO, uv);
	float metallic = metallicAO.r;
	float AO = metallicAO.g;

	vec4 subsurface = texture2D(texSubsurface, uv);
	subsurface.rgb = xGammaToLinear(subsurface.rgb);

	vec3 emissive = xGammaToLinear(xDecodeRGBM(texture2D(texEmissive, uv)));

	vec3 specular = mix(X_F0_DEFAULT, base, metallic);
	base *= (1.0 - metallic);

	return Material(
		base,
		opacity,
		normal,
		roughness,
		metallic,
		AO,
		subsurface,
		emissive,
		specular);
}


/// @desc Evalutes to 1.0 if a < b, otherwise to 0.0.
#define xIsLess(a, b) (((a) < (b)) ? 1.0 : 0.0)

/// @desc Evalutes to 1.0 if a <= b, otherwise to 0.0.
#define xIsLessEqual(a, b) (((a) <= (b)) ? 1.0 : 0.0)

/// @desc Evalutes to 1.0 if a == b, otherwise to 0.0.
#define xIsEqual(a, b) (((a) == (b)) ? 1.0 : 0.0)

/// @desc Evalutes to 1.0 if a != b, otherwise to 0.0.
#define xIsNotEqual(a, b) (((a) != (b)) ? 1.0 : 0.0)

/// @desc Evalutes to 1.0 if a >= b, otherwise to 0.0.
#define xIsGreaterEqual(a, b) (((a) >= (b)) ? 1.0 : 0.0)

/// @desc Evalutes to 1.0 if a > b, otherwise to 0.0.
#define xIsGreater(a, b) (((a) > (b)) ? 1.0 : 0.0)

/// @desc Encodes depth and a normal vector into RGBA.
/// @param depth The depth to encode. Must be linearized.
/// @param N The world-space normal vector to encode.
/// @author TheSnidr
vec4 xEncodeDepth20Normal12(float depth, vec3 N)
{
	vec4 enc;
	// Encode normal to green channel
	vec3 aN = abs(N);
	float M = max(aN.x, max(aN.y, aN.z));
	vec3 n = (N / M) * 0.5 + 0.5;

	// Figure out which primary direction the normal points in
	float dim = xIsEqual(N.x, -M);
	dim += (1.0 - abs(sign(dim))) * 2.0 * xIsEqual(N.y, M);
	dim += (1.0 - abs(sign(dim))) * 3.0 * xIsEqual(N.y, -M);
	dim += (1.0 - abs(sign(dim))) * 4.0 * xIsEqual(N.z, M);
	dim += (1.0 - abs(sign(dim))) * 5.0 * xIsEqual(N.z, -M);

	// Now that we've found the primary direction, we can pack the two remaining dimensions
	float d1 = mix(n.y, n.x, step(2.0, dim)); // Save y in the 1st slot if the primary direction is x+ or x-. Otherwise save x
	float d2 = mix(n.z, n.y, step(4.0, dim)); // Save z in the 2nd slot if the primary direction is along x or y. Otherwise save y
	float num = 26.0; // 6 * 26 * 26 is 4056, which is less than 2^20 = 4096

	// Find the unique value for this vector, from 0 to 4056 (12 bits)
	float encN = dim * num * num; // Save primary dimension
	encN += floor(clamp(d1 * num - 0.5, 0.0, num - 1.0) + 0.5); // Save first secondary dimension
	encN += floor(clamp(d2 * num - 0.5, 0.0, num - 1.0) + 0.5) * num; // Save second secondary dimension

	// Special case: Up-vector is stored to unused index 4056
	encN = mix(encN, 4056.0, xIsEqual(N.z, M) * xIsLess(abs(n.x - 0.5) + abs(n.y - 0.5), 0.01));

	// Special case: Down-vector is stored to unused index 4057
	encN = mix(encN, 4057.0, xIsEqual(N.z, -M) * xIsLess(abs(n.x - 0.5) + abs(n.y - 0.5), 0.01));

	// Encode depth into 16 bits
	float d = depth * 255.0;
	enc.r = floor(d) / 255.0;
	d = fract(d) * 255.0;
	enc.g = floor(d) / 255.0;

	// Encode normal into 8 bits
	enc.b = mod(encN, 256.0) / 255.0;

	// Encode 4 bits of depth and 4 bits of normal into alpha channel
	enc.a = floor(fract(d) * 16.0);
	enc.a += 16.0 * floor(encN / 256.0);
	enc.a /= 255.0;

	return enc;
}


void main()
{
	vec4 baseOpacity = texture2D(gm_BaseTexture, v_vTexCoord);
	if (baseOpacity.a < bbmod_AlphaTest)
	{
		discard;
	}
	Material material = UnpackMaterial(
		bbmod_BaseOpacity,
		bbmod_NormalRoughness,
		bbmod_MetallicAO,
		bbmod_Subsurface,
		bbmod_Emissive,
		v_mTBN,
		v_vTexCoord);
	vec3 N = material.Normal;
	gl_FragColor = xEncodeDepth20Normal12(v_fDepth, N);
}
// include("Uber_PS.xsh")
