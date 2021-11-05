#pragma include("Compatibility.xsh")

#pragma include("Output_VS.xsh")

#pragma include("Output_PS.xsh")

#pragma include("Uniforms_PS.xsh")

#pragma include("Includes_PS.xsh")


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

	Vec3 N = material.Normal;
	Vec3 V = normalize(bbmod_CamPos - v_vVertex);
	Vec3 lightColor = xDiffuseIBL(bbmod_IBL, bbmod_IBLTexel, N);

	float bias = 1.0;
	Vec3 posShadowMap = (bbmod_ShadowmapMatrix * vec4(v_vVertex + N * bias, 1.0)).xyz;
	posShadowMap.xy = posShadowMap.xy * 0.5 + 0.5;
	posShadowMap.y = 1.0 - posShadowMap.y;
	float shadow = xShadowMapPCF(bbmod_Shadowmap, bbmod_ShadowmapTexel, posShadowMap.xy, posShadowMap.z);

	Vec3 L = normalize(Vec3(1.0, 0.0, 1.0));
	float NdotL = max(dot(N, L), 0.0);
	lightColor += xGammaToLinear(Vec3(1.0)) * NdotL * (1.0 - shadow);

	Vec3 H = normalize(L + V);
	float NdotV = max(dot(N, V), 0.0);
	float NdotH = max(dot(N, H), 0.0);
	float VdotH = max(dot(V, H), 0.0);

	// Diffuse
	gl_FragColor.rgb = material.Base * lightColor;
	// Specular
	gl_FragColor.rgb += xSpecularIBL(bbmod_IBL, bbmod_IBLTexel, bbmod_BRDF, material.Specular, material.Roughness, N, V)
		+ (xGammaToLinear(vec3(1.0)) * NdotL * (1.0 - shadow) * xBRDF(material.Specular, material.Roughness, NdotL, NdotV, NdotH, VdotH));
	// // Ambient occlusion
	// gl_FragColor.rgb *= material.AO;
	// // Emissive
	// gl_FragColor.rgb += material.Emissive;
	// // Subsurface scattering
	// gl_FragColor.rgb += xCheapSubsurface(material.Subsurface, -V, N, N, lightColor);
	// Exposure
	gl_FragColor.rgb = Vec3(1.0) - exp(-gl_FragColor.rgb * bbmod_Exposure);
	// Gamma correction
	gl_FragColor.rgb = xLinearToGamma(gl_FragColor.rgb);
#else
	Vec4 baseOpacity = Sample(gm_BaseTexture, v_vTexCoord);
	if (baseOpacity.a < bbmod_AlphaTest)
	{
		discard;
	}
	#if OUTPUT_DEPTH
	gl_FragColor.rgb = xEncodeDepth(v_fDepth);
	gl_FragColor.a = 1.0;
	#elif GBUFFER
	Material material = UnpackMaterial(
		bbmod_BaseOpacity,
		bbmod_NormalRoughness,
		bbmod_MetallicAO,
		bbmod_Subsurface,
		bbmod_Emissive,
		v_mTBN,
		v_vTexCoord);
	Vec3 N = material.Normal;
	gl_FragColor = xEncodeDepth20Normal12(v_fDepth, N);
	#else
	gl_FragColor = baseOpacity;
	#endif
#endif
}
