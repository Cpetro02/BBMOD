#if OUTPUT_DEPTH || PBR
// TODO: Fix Xpanda's include
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

#pragma include("ShadowMapping.xsh")
#endif

#if GBUFFER
#pragma include("EncodeDepth20Normal12.xsh")
#endif
