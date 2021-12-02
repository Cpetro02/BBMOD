#pragma include("Uber_VS.xsh", "glsl")
#define MUL(m, v) ((m) * (v))
#define IVec4 ivec4



attribute vec4 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord0;
//attribute vec4 in_Color;
attribute vec4 in_TangentW;




varying vec3 v_vVertex;
//varying vec4 v_vColor;
varying vec2 v_vTexCoord;
varying mat3 v_mTBN;
varying vec4 v_vPosition;

uniform vec2 bbmod_TextureOffset;

uniform vec2 bbmod_TextureScale;




void main()
{
	vec4 position = in_Position;
	vec4 normal = vec4(in_Normal, 0.0);

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
