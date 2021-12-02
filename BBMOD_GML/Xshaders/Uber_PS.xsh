#pragma include("Compatibility.xsh")

#pragma include("Defines_PS.xsh")

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
	Vec3 lightDiffuse = Vec3(0.0);
	Vec3 lightSpecular = Vec3(0.0);
	Vec3 lightSubsurface = Vec3(0.0);

	////////////////////////////////////////////////////////////////////////////
	// SSAO
	float ssao = Sample(bbmod_SSAO, xUnproject(v_vPosition)).r;

	////////////////////////////////////////////////////////////////////////////
	// IBL
	lightDiffuse += xDiffuseIBL(bbmod_IBL, bbmod_IBLTexel, N);
	lightSpecular += xSpecularIBL(bbmod_IBL, bbmod_IBLTexel, material.Specular, material.Roughness, N, V);

	////////////////////////////////////////////////////////////////////////////
	// Directional light
	Vec3 L = normalize(-bbmod_LightDirectionalDir);
	float NdotL = max(dot(N, L), 0.0);
	Vec3 lightColor = xGammaToLinear(xDecodeRGBM(bbmod_LightDirectionalColor));
	lightSubsurface += xCheapSubsurface(material.Subsurface, V, N, L, lightColor);

	Vec3 posShadowMap = (bbmod_ShadowmapMatrix * vec4(v_vVertex + N * bbmod_ShadowmapNormalOffset, 1.0)).xyz;
	posShadowMap.xy = posShadowMap.xy * 0.5 + 0.5;
	posShadowMap.y = 1.0 - posShadowMap.y;
	posShadowMap.z /= bbmod_ShadowmapArea;
	float shadow = xShadowMapPCF(bbmod_Shadowmap, bbmod_ShadowmapTexel, posShadowMap.xy, posShadowMap.z);

	lightColor *= NdotL * (1.0 - shadow);
	Vec3 H = normalize(L + V);
	float NdotV = max(dot(N, V), 0.0);
	float NdotH = max(dot(N, H), 0.0);
	float VdotH = max(dot(V, H), 0.0);
	lightDiffuse += lightColor;
	lightSpecular += lightColor * xBRDF(material.Specular, material.Roughness, NdotL, NdotV, NdotH, VdotH);

	lightDiffuse *= ssao;
	lightSpecular *= ssao;

	////////////////////////////////////////////////////////////////////////////
	// Point lights
	for (int i = 0; i < MAX_LIGHTS; ++i)
	{
		Vec4 positionRange = bbmod_LightPointData[i * 2];
		lightColor = xGammaToLinear(xDecodeRGBM(bbmod_LightPointData[(i * 2) + 1]));
		L = positionRange.xyz - v_vVertex;
		float dist = length(L);
		float att = pow(clamp(1.0 - pow(dist / positionRange.w, 4.0), 0.0, 1.0), 2.0) / (pow(dist, 2.0) + 1.0);
		NdotL = max(dot(N, L), 0.0);
		lightColor *= NdotL * att;
		H = normalize(L + V);
		NdotV = max(dot(N, V), 0.0);
		NdotH = max(dot(N, H), 0.0);
		VdotH = max(dot(V, H), 0.0);
		lightDiffuse += lightColor;
		lightSpecular += lightColor * xBRDF(material.Specular, material.Roughness, NdotL, NdotV, NdotH, VdotH);
	}

	////////////////////////////////////////////////////////////////////////////
	// Compose into resulting color
	gl_FragColor.rgb = material.Base * lightDiffuse;
	gl_FragColor.rgb += lightSpecular;
	gl_FragColor.rgb += lightSubsurface;
	gl_FragColor.rgb *= material.AO;
	gl_FragColor.rgb += material.Emissive;
	gl_FragColor.rgb = Vec3(1.0) - exp(-gl_FragColor.rgb * bbmod_Exposure);
	gl_FragColor.rgb = xLinearToGamma(gl_FragColor.rgb);
#else
	Vec4 baseOpacity = Sample(gm_BaseTexture, v_vTexCoord);
	if (baseOpacity.a < bbmod_AlphaTest)
	{
		discard;
	}
	#if OUTPUT_DEPTH
	gl_FragColor.rgb = xEncodeDepth(v_vPosition.z / bbmod_ClipFar);
	gl_FragColor.a = 1.0;
	#else
	gl_FragColor = baseOpacity;
	#endif
#endif
}
