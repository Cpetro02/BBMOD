#pragma include("Compatibility.xsh")

#pragma include("Defines_VS.xsh")

#pragma include("Input_VS.xsh")

#pragma include("Output_VS.xsh")

#pragma include("Uniforms_VS.xsh")

#pragma include("Includes_VS.xsh")

void main()
{
#if ANIMATED
	// Source:
	// https://www.cs.utah.edu/~ladislav/kavan07skinning/kavan07skinning.pdf
	// https://www.cs.utah.edu/~ladislav/dq/dqs.cg
	IVec4 i = IVec4(in_BoneIndex) * 2;
	IVec4 j = i + 1;

	Vec4 real0 = bbmod_Bones[i.x];
	Vec4 real1 = bbmod_Bones[i.y];
	Vec4 real2 = bbmod_Bones[i.z];
	Vec4 real3 = bbmod_Bones[i.w];

	Vec4 dual0 = bbmod_Bones[j.x];
	Vec4 dual1 = bbmod_Bones[j.y];
	Vec4 dual2 = bbmod_Bones[j.z];
	Vec4 dual3 = bbmod_Bones[j.w];

	if (dot(real0, real1) < 0.0) { real1 *= -1.0; dual1 *= -1.0; }
	if (dot(real0, real2) < 0.0) { real2 *= -1.0; dual2 *= -1.0; }
	if (dot(real0, real3) < 0.0) { real3 *= -1.0; dual3 *= -1.0; }

	Vec4 blendReal =
		  real0 * in_BoneWeight.x
		+ real1 * in_BoneWeight.y
		+ real2 * in_BoneWeight.z
		+ real3 * in_BoneWeight.w;

	Vec4 blendDual =
		  dual0 * in_BoneWeight.x
		+ dual1 * in_BoneWeight.y
		+ dual2 * in_BoneWeight.z
		+ dual3 * in_BoneWeight.w;

	float len = length(blendReal);
	blendReal /= len;
	blendDual /= len;

	Vec4 position = Vec4(xDualQuaternionTransform(blendReal, blendDual, in_Position.xyz), 1.0);
	Vec4 normal = Vec4(xQuaternionRotate(blendReal, in_Normal), 0.0);
#elif BATCHED
	int idx = int(in_Id) * 2;
	Vec4 posScale = bbmod_BatchData[idx];
	Vec4 rot = bbmod_BatchData[idx + 1];
	Vec4 position = Vec4(posScale.xyz + (xQuaternionRotate(rot, in_Position).xyz * posScale.w), in_Position.w);
	Vec4 normal = Vec4(in_Normal, 0.0);
	normal = xQuaternionRotate(rot, normal);
#else
	Vec4 position = in_Position;
	Vec4 normal = Vec4(in_Normal, 0.0);
#endif

	gl_Position = MUL(gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION], position);
	v_vPosition = MUL(gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION], position);
	v_vVertex = MUL(gm_Matrices[MATRIX_WORLD], position).xyz;
	//v_vColor = in_Color;
	v_vTexCoord = bbmod_TextureOffset + in_TextureCoord0 * bbmod_TextureScale;

	Vec4 tangent = Vec4(in_TangentW.xyz, 0.0);
	Vec4 bitangent = Vec4(cross(in_Normal, in_TangentW.xyz) * in_TangentW.w, 0.0);
	Vec3 N = MUL(gm_Matrices[MATRIX_WORLD], normal).xyz;
	Vec3 T = MUL(gm_Matrices[MATRIX_WORLD], tangent).xyz;
	Vec3 B = MUL(gm_Matrices[MATRIX_WORLD], bitangent).xyz;
	v_mTBN = Mat3(T, B, N);
}
