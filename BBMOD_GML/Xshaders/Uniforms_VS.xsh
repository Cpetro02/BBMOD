uniform Vec2 bbmod_TextureOffset;

uniform Vec2 bbmod_TextureScale;

#if ANIMATED
uniform Vec4 bbmod_Bones[2 * MAX_BONES];
#endif

#if BATCHED
uniform Vec4 bbmod_BatchData[MAX_BATCH_DATA_SIZE];
#endif
