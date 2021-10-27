varying vec3 v_vVertex;
//varying vec4 v_vColor;
varying vec2 v_vTexCoord;
varying mat3 v_mTBN;
varying float v_fDepth;

#if PBR
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
#endif

#if OUTPUT_DEPTH
// Distance to the camera's far clipping plane.
uniform float bbmod_ClipFar;
#endif

// Pixels with alpha less than this value will be discarded.
uniform float bbmod_AlphaTest;

// TODO: Fix Xpanda's include
// #if OUTPUT_DEPTH
#pragma include("DepthEncoding.xsh", "glsl")
// #endif

#if PBR
#pragma include("BRDF.xsh", "glsl")

#pragma include("OctahedronMapping.xsh", "glsl")

#pragma include("RGBM.xsh", "glsl")

#pragma include("IBL.xsh")

#pragma include("Color.xsh", "glsl")

#pragma include("CheapSubsurface.xsh", "glsl")

#pragma include("Material.xsh", "glsl")

#pragma include("ShadowMapping.xsh", "glsl")
#endif

void main()
{
#if PBR
	Material material = UnpackMaterial(
		bbmod_BaseOpacity,
		bbmod_NormalRoughness,
		bbmod_MetallicAO,
		bbmod_Subsurface,
		bbmod_Emissive,
		v_mTBN,
		v_vTexCoord);

	if (material.Opacity < bbmod_AlphaTest)
	{
		discard;
	}
	gl_FragColor.a = material.Opacity;

	vec3 N = material.Normal;
	vec3 V = normalize(bbmod_CamPos - v_vVertex);
	vec3 lightColor = xDiffuseIBL(bbmod_IBL, bbmod_IBLTexel, N);

	float bias = 1.5;
	vec3 posShadowMap = (bbmod_ShadowmapMatrix * vec4(v_vVertex + N * bias, 1.0)).xyz * 0.5 + 0.5;
	posShadowMap.y = 1.0 - posShadowMap.y;
	float shadow = xShadowMapPCF(bbmod_Shadowmap, bbmod_ShadowmapTexel, posShadowMap.xy, posShadowMap.z);

	// Diffuse
	gl_FragColor.rgb = material.Base * lightColor;
	// Specular
	gl_FragColor.rgb += xSpecularIBL(bbmod_IBL, bbmod_IBLTexel, bbmod_BRDF, material.Specular, material.Roughness, N, V);
	// Ambient occlusion
	gl_FragColor.rgb *= material.AO;
	// Emissive
	gl_FragColor.rgb += material.Emissive;
	// Subsurface scattering
	gl_FragColor.rgb += xCheapSubsurface(material.Subsurface, -V, N, N, lightColor);
	// Exposure
	gl_FragColor.rgb = vec3(1.0) - exp(-gl_FragColor.rgb * bbmod_Exposure);
	// Gamma correction
	gl_FragColor.rgb = xLinearToGamma(gl_FragColor.rgb);
#else
	Vec4 baseOpacity = Sample(gm_BaseTexture, v_vTexCoord);
	if (baseOpacity.a < bbmod_AlphaTest)
	{
		discard;
	}
	#if OUTPUT_DEPTH
	gl_FragColor.rgb = xEncodeDepth(v_fDepth / bbmod_ClipFar);
	gl_FragColor.a = 1.0;
	#else
	gl_FragColor = baseOpacity;
	#endif
#endif
}
