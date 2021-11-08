#pragma include("Uber_PS.xsh", "glsl")
#define MUL(m, v) ((m) * (v))
#define IVec4 ivec4

varying vec3 v_vVertex;
//varying vec4 v_vColor;
varying vec2 v_vTexCoord;
varying mat3 v_mTBN;
varying float v_fDepth;



// Pixels with alpha less than this value will be discarded.
uniform float bbmod_AlphaTest;





void main()
{
	vec4 baseOpacity = texture2D(gm_BaseTexture, v_vTexCoord);
	if (baseOpacity.a < bbmod_AlphaTest)
	{
		discard;
	}
	gl_FragColor = baseOpacity;
}
// include("Uber_PS.xsh")
