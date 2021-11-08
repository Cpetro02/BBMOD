#if OUTPUT_DEPTH || PBR
#pragma include("DepthEncoding.xsh")
#endif

#if PBR || GBUFFER
#pragma include("Material.xsh")
#endif

#if PBR
#pragma include("BRDF.xsh")

#pragma include("OctahedronMapping.xsh")

#pragma include("RGBM.xsh")

#pragma include("IBL.xsh")

#pragma include("Color.xsh")

#pragma include("CheapSubsurface.xsh")

// #pragma include("ShadowMapping.xsh")
/// @source https://iquilezles.org/www/articles/hwinterpolation/hwinterpolation.htm
float xShadowMapCompare(sampler2D shadowMap, vec2 texel, vec2 uv, float compareZ)
{
	if (uv.x < 0.0 || uv.y < 0.0
		|| uv.x > 1.0 || uv.y > 1.0)
	{
		return 0.0;
	}
	vec2 res = 1.0 / texel;
	vec2 st = uv*res - 0.5;
	vec2 iuv = floor(st);
	vec2 fuv = fract(st);
	vec3 s = texture2D(shadowMap, (iuv+vec2(0.5,0.5))/res).rgb;
	if (s == vec3(1.0, 0.0, 0.0))
	{
		return 0.0;
	}
	float a = (xDecodeDepth(s) < compareZ - 0.002) ? 1.0 : 0.0;
	float b = (xDecodeDepth(texture2D(shadowMap, (iuv+vec2(1.5,0.5))/res).rgb) < compareZ - 0.002) ? 1.0 : 0.0;
	float c = (xDecodeDepth(texture2D(shadowMap, (iuv+vec2(0.5,1.5))/res).rgb) < compareZ - 0.002) ? 1.0 : 0.0;
	float d = (xDecodeDepth(texture2D(shadowMap, (iuv+vec2(1.5,1.5))/res).rgb) < compareZ - 0.002) ? 1.0 : 0.0;
	return mix(
		mix(a, b, fuv.x),
		mix(c, d, fuv.x),
		fuv.y);
}

/// @source https://learnopengl.com/Advanced-Lighting/Shadows/Shadow-Mapping
float xShadowMapPCF(sampler2D shadowMap, vec2 texel, vec2 uv, float compareZ)
{
#if 0
	// Variable penumbra shadows
	const float size = 2.0;
	const float texelScale = 3.0;
	float d = 0.0;
	float i = 0.0;
	for (float x = -1.0; x <= 1.0; x += 1.0)
	{
		for (float y = -1.0; y <= 1.0; y += 1.0)
		{
			float depth = xDecodeDepth(texture2D(shadowMap, uv + size * vec2(x, y) * texel * texelScale).rgb);
			float j = (depth <= compareZ) ? 1.0 : 0.0;
			d += depth * j;
			i += j;
		}
	}
	d /= i;
	float dd = clamp(abs(d - compareZ) / 0.1, 0.0, 1.0);
#else
	const float size = 2.0;
	const float texelScale = 1.0;
	const float dd = 1.0;
#endif
	const float samples = (size * 2.0 + 1.0) * (size * 2.0 + 1.0);
	float shadow = 0.0;
	for (float x = -size; x <= size; x += 1.0)
	{
		for (float y = -size; y <= size; y += 1.0)
		{
			vec2 uv2 = uv + vec2(x, y) * texel * mix(1.5 / size, texelScale, dd);
			shadow += xShadowMapCompare(shadowMap, texel, uv2, compareZ);
		}
	}
	shadow /= samples;
	return shadow;
}
#endif

#if GBUFFER
#pragma include("EncodeDepth20Normal12.xsh")
#endif
