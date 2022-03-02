#pragma include("Uber_PS.xsh", "glsl")
// FIXME: Temporary fix!
precision highp float;

////////////////////////////////////////////////////////////////////////////////
//
// Defines
//

// Maximum number of point lights
#define MAX_POINT_LIGHTS 8


////////////////////////////////////////////////////////////////////////////////
//
// Varyings
//
varying vec3 v_vVertex;

varying vec4 v_vColor;

varying vec2 v_vTexCoord;
varying mat3 v_mTBN;
varying float v_fDepth;


////////////////////////////////////////////////////////////////////////////////
//
// Uniforms
//

////////////////////////////////////////////////////////////////////////////////
// Material

// RGB: Base color, A: Opacity
#define bbmod_BaseOpacity gm_BaseTexture
// RGB: Tangent space normal, A: Smoothness
uniform sampler2D bbmod_NormalSmoothness;
// RGB: Specular color
uniform sampler2D bbmod_SpecularColor;
// Pixels with alpha less than this value will be discarded
uniform float bbmod_AlphaTest;

////////////////////////////////////////////////////////////////////////////////
// Camera

// Distance to the far clipping plane
uniform float bbmod_ZFar;
// Camera's exposure value
uniform float bbmod_Exposure;


////////////////////////////////////////////////////////////////////////////////
// Fog

// The color of the fog
uniform vec4 bbmod_FogColor;
// Maximum fog intensity
uniform float bbmod_FogIntensity;
// Distance at which the fog starts
uniform float bbmod_FogStart;
// 1.0 / (fogEnd - fogStart)
uniform float bbmod_FogRcpRange;

////////////////////////////////////////////////////////////////////////////////
// Ambient light

// RGBM encoded ambient light color on the upper hemisphere.
uniform vec4 bbmod_LightAmbientUp;
// RGBM encoded ambient light color on the lower hemisphere.
uniform vec4 bbmod_LightAmbientDown;

////////////////////////////////////////////////////////////////////////////////
// Directional light

// Direction of the directional light
uniform vec3 bbmod_LightDirectionalDir;
// RGBM encoded color of the directional light
uniform vec4 bbmod_LightDirectionalColor;

////////////////////////////////////////////////////////////////////////////////
// Point lights

// [(x, y, z, range), (r, g, b, m), ...]
uniform vec4 bbmod_LightPointData[2 * MAX_POINT_LIGHTS];

////////////////////////////////////////////////////////////////////////////////
// Shadow mapping

// 1.0 to enable shadows
uniform float bbmod_ShadowmapEnablePS;
// Shadowmap texture
uniform sampler2D bbmod_Shadowmap;
// (1.0/shadowmapWidth, 1.0/shadowmapHeight)
uniform vec2 bbmod_ShadowmapTexel;

////////////////////////////////////////////////////////////////////////////////
//
// Includes
//
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

/// @param d Linearized depth to encode.
/// @return Encoded depth.
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
vec3 xEncodeDepth(float d)
{
	const float inv255 = 1.0 / 255.0;
	vec3 enc;
	enc.x = d;
	enc.y = d * 255.0;
	enc.z = enc.y * 255.0;
	enc = fract(enc);
	float temp = enc.z * inv255;
	enc.x -= enc.y * inv255;
	enc.y -= temp;
	enc.z -= temp;
	return enc;
}

/// @param c Encoded depth.
/// @return Docoded linear depth.
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
float xDecodeDepth(vec3 c)
{
	const float inv255 = 1.0 / 255.0;
	return c.x + (c.y * inv255) + (c.z * inv255 * inv255);
}



struct Material
{
	vec3 Base;
	float Opacity;
	vec3 Normal;
	float Smoothness;
	vec3 Specular;
};

/// @desc Unpacks material from textures.
/// @param texBaseOpacity      RGB: base color, A: opacity
/// @param texNormalSmoothness RGB: tangent-space normal vector, A: smoothness
/// @param texSpecularColor    RGB: specular color
/// @param TBN                 Tangent-bitangent-normal matrix
/// @param uv                  Texture coordinates
Material UnpackMaterial(
	sampler2D texBaseOpacity,
	sampler2D texNormalSmoothness,
	sampler2D texSpecularColor,
	mat3 TBN,
	vec2 uv)
{
	Material m;

	// Base color and opacity
	vec4 baseOpacity = texture2D(texBaseOpacity, uv);
	m.Base = xGammaToLinear(baseOpacity.rgb);
	m.Opacity = baseOpacity.a;

	// Normal vector and smoothness
	vec4 normalSmoothness = texture2D(texNormalSmoothness, uv);
	m.Normal = normalize(TBN * (normalSmoothness.rgb * 2.0 - 1.0));
	m.Smoothness = normalSmoothness.a;

	// Specular color
	vec4 specularColor = texture2D(texSpecularColor, uv);
	m.Specular = xGammaToLinear(specularColor.rgb);

	return m;
}


////////////////////////////////////////////////////////////////////////////////
//
// Main
//
void main()
{
	Material material = UnpackMaterial(
		bbmod_BaseOpacity,
		bbmod_NormalSmoothness,
		bbmod_SpecularColor,
		v_mTBN,
		v_vTexCoord);

	if (material.Opacity < bbmod_AlphaTest)
	{
		discard;
	}
	gl_FragColor.a = material.Opacity;

	vec3 N = material.Normal;
	vec3 lightDiffuse = vec3(0.0);
	vec3 lightSpecular = vec3(0.0);

	// Ambient light
	vec3 ambientUp = xGammaToLinear(xDecodeRGBM(bbmod_LightAmbientUp));
	vec3 ambientDown = xGammaToLinear(xDecodeRGBM(bbmod_LightAmbientDown));
	lightDiffuse += mix(ambientDown, ambientUp, N.z * 0.5 + 0.5);
	// Shadow mapping
	float shadow = 0.0;
	// Directional light
	vec3 L = normalize(-bbmod_LightDirectionalDir);
	float NdotL = max(dot(N, L), 0.0);
	float specularPower = exp2(1.0 + (material.Smoothness * 10.0));
	vec3 V = vec3(0.0, 0.0, 1.0);
	vec3 f0 = material.Specular;
	vec3 H = normalize(L + V);
	float NdotH = max(dot(N, H), 0.0);
	float VdotH = max(dot(V, H), 0.0);
	vec3 fresnel = f0 + (1.0 - f0) * pow(1.0 - VdotH, 5.0);
	float visibility = 0.25;
	float A = specularPower / log(2.0);
	float blinnPhong = exp2(A * NdotH - A);
	float blinnNormalization = (specularPower + 8.0) / 8.0;
	float normalDistribution = blinnPhong * blinnNormalization;
	vec3 lightColor = xGammaToLinear(xDecodeRGBM(bbmod_LightDirectionalColor)) * NdotL * (1.0 - shadow);
	lightSpecular += lightColor * fresnel * visibility * normalDistribution;
	lightDiffuse += lightColor; // * (1.0 - fresnel);
	// Point lights
	for (int i = 0; i < MAX_POINT_LIGHTS; ++i)
	{
		vec4 positionRange = bbmod_LightPointData[i * 2];
		L = positionRange.xyz - v_vVertex;
		H = normalize(L + V);
		NdotH = max(dot(N, H), 0.0);
		VdotH = max(dot(V, H), 0.0);
		fresnel = f0 + (1.0 - f0) * pow(1.0 - VdotH, 5.0);
		float dist = length(L);
		float att = clamp(1.0 - (dist / positionRange.w), 0.0, 1.0);
		NdotL = max(dot(N, normalize(L)), 0.0);
		lightColor = xGammaToLinear(xDecodeRGBM(bbmod_LightPointData[(i * 2) + 1])) * NdotL * att;
		lightSpecular += lightColor * fresnel * visibility * normalDistribution;
		lightDiffuse += lightColor; // * (1.0 - fresnel);
	}
	// Diffuse
	gl_FragColor.rgb = material.Base * lightDiffuse;
	// Specular
	gl_FragColor.rgb += lightSpecular;
	// Fog
	vec3 fogColor = xGammaToLinear(xDecodeRGBM(bbmod_FogColor));
	float fogStrength = clamp((v_fDepth - bbmod_FogStart) * bbmod_FogRcpRange, 0.0, 1.0);
	gl_FragColor.rgb = mix(gl_FragColor.rgb, fogColor, fogStrength * bbmod_FogIntensity);
	// Exposure
	gl_FragColor.rgb = vec3(1.0) - exp(-gl_FragColor.rgb * bbmod_Exposure);
	// Gamma correction
	gl_FragColor.rgb = xLinearToGamma(gl_FragColor.rgb);
}
// include("Uber_PS.xsh")