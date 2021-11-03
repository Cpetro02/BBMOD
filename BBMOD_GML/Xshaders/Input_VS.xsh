#if XGLSL
attribute vec4 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord0;
//attribute vec4 in_Color;
attribute vec4 in_TangentW;

#if ANIMATED
attribute vec4 in_BoneIndex;
attribute vec4 in_BoneWeight;
#endif

#if BATCHED
attribute float in_Id;
#endif

#else
//
#endif
