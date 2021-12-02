#pragma include("Uber_VS.xsh", "glsl")
#define MUL(m, v) ((m) * (v))
#define IVec4 ivec4

#define MAX_BONES 64


attribute vec4 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord0;
//attribute vec4 in_Color;
attribute vec4 in_TangentW;

attribute vec4 in_BoneIndex;
attribute vec4 in_BoneWeight;



varying vec3 v_vVertex;
//varying vec4 v_vColor;
varying vec2 v_vTexCoord;
varying mat3 v_mTBN;
varying vec4 v_vPosition;

uniform vec2 bbmod_TextureOffset;

uniform vec2 bbmod_TextureScale;

uniform vec4 bbmod_Bones[2 * MAX_BONES];


vec3 xQuaternionRotate(vec4 q, vec3 v)
{
	return (v + 2.0 * cross(q.xyz, cross(q.xyz, v) + q.w * v));
}

vec3 xDualQuaternionTransform(vec4 real, vec4 dual, vec3 v)
{
	return (xQuaternionRotate(real, v)
		+ 2.0 * (real.w * dual.xyz - dual.w * real.xyz + cross(real.xyz, dual.xyz)));
}

void main()
{
	// Source:
	// https://www.cs.utah.edu/~ladislav/kavan07skinning/kavan07skinning.pdf
	// https://www.cs.utah.edu/~ladislav/dq/dqs.cg
	IVec4 i = IVec4(in_BoneIndex) * 2;
	IVec4 j = i + 1;

	vec4 real0 = bbmod_Bones[i.x];
	vec4 real1 = bbmod_Bones[i.y];
	vec4 real2 = bbmod_Bones[i.z];
	vec4 real3 = bbmod_Bones[i.w];

	vec4 dual0 = bbmod_Bones[j.x];
	vec4 dual1 = bbmod_Bones[j.y];
	vec4 dual2 = bbmod_Bones[j.z];
	vec4 dual3 = bbmod_Bones[j.w];

	if (dot(real0, real1) < 0.0) { real1 *= -1.0; dual1 *= -1.0; }
	if (dot(real0, real2) < 0.0) { real2 *= -1.0; dual2 *= -1.0; }
	if (dot(real0, real3) < 0.0) { real3 *= -1.0; dual3 *= -1.0; }

	vec4 blendReal =
		  real0 * in_BoneWeight.x
		+ real1 * in_BoneWeight.y
		+ real2 * in_BoneWeight.z
		+ real3 * in_BoneWeight.w;

	vec4 blendDual =
		  dual0 * in_BoneWeight.x
		+ dual1 * in_BoneWeight.y
		+ dual2 * in_BoneWeight.z
		+ dual3 * in_BoneWeight.w;

	float len = length(blendReal);
	blendReal /= len;
	blendDual /= len;

	vec4 position = vec4(xDualQuaternionTransform(blendReal, blendDual, in_Position.xyz), 1.0);
	vec4 normal = vec4(xQuaternionRotate(blendReal, in_Normal), 0.0);

	gl_Position = MUL(gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION], position);
	v_vPosition = MUL(gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION], position);
	v_vVertex = MUL(gm_Matrices[MATRIX_WORLD], position).xyz;
	//v_vColor = in_Color;
	v_vTexCoord = bbmod_TextureOffset + in_TextureCoord0 * bbmod_TextureScale;

	vec4 tangent = vec4(in_TangentW.xyz, 0.0);
	vec4 bitangent = vec4(cross(in_Normal, in_TangentW.xyz) * in_TangentW.w, 0.0);
	vec3 N = MUL(gm_Matrices[MATRIX_WORLD], normal).xyz;
	vec3 T = MUL(gm_Matrices[MATRIX_WORLD], tangent).xyz;
	vec3 B = MUL(gm_Matrices[MATRIX_WORLD], bitangent).xyz;
	v_mTBN = mat3(T, B, N);
}
// include("Uber_VS.xsh")
