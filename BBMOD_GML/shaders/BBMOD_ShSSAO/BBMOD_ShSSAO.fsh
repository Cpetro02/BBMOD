// Source: https://john-chapman-graphics.blogspot.cz/2013/01/ssao-tutorial.html

//> Must be the same values as in the xSsaoInit script!
#define X_SSAO_KERNEL_SIZE 8

varying vec2 v_vTexCoord;

uniform sampler2D u_texNoise;
uniform vec2  u_vTexel;                            //< (1/screenWidth,1/screenHeight)
uniform vec2  u_vTanAspect;                        //< (dtan(fov/2)*(screenWidth/screenHeight),-dtan(fov/2))
uniform float u_fClipFar;                          //< Distance to the far clipping plane.
uniform vec2  u_vSampleKernel[X_SSAO_KERNEL_SIZE]; //< Kernel of random vectors.
uniform vec2  u_vNoiseScale;                       //< (screenWidth,screenHeight)/X_SSAO_NOISE_TEXTURE_SIZE
uniform float u_fPower;                            //< Strength of the occlusion effect.
uniform float u_fRadius;                           //< Radius of the occlusion effect.
uniform float u_fBias;                             //< Depth bias of the occlusion effect.

#pragma include("DepthEncoding.xsh", "glsl")
/// @param d Linearized depth to encode.
/// @return Encoded depth.
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
vec3 xEncodeDepth(float d)
{
	const float inv255 = 1.0 / 255.0;
	vec3 enc;
	enc.x = d;
	enc.y = d * 255.0;
	enc.z = enc.y * 255.0;
	enc = fract(enc);
	float temp = enc.z * inv255;
	enc.x -= enc.y * inv255;
	enc.y -= temp;
	enc.z -= temp;
	return enc;
}

/// @param c Encoded depth.
/// @return Docoded linear depth.
/// @source http://aras-p.info/blog/2009/07/30/encoding-floats-to-rgba-the-final/
float xDecodeDepth(vec3 c)
{
	const float inv255 = 1.0 / 255.0;
	return c.x + (c.y * inv255) + (c.z * inv255 * inv255);
}
// include("DepthEncoding.xsh")

#pragma include("Projecting.xsh", "glsl")
/// @param tanAspect (tanFovY*(screenWidth/screenHeight),-tanFovY), where
///                  tanFovY = dtan(fov*0.5)
/// @param texCoord  Sceen-space UV.
/// @param depth     Scene depth at texCoord.
/// @return Point projected to view-space.
vec3 xProject(vec2 tanAspect, vec2 texCoord, float depth)
{
	return vec3(tanAspect * (texCoord * 2.0 - 1.0) * depth, depth);
}

/// @param p A point in clip space (transformed by projection matrix, but not
///          normalized).
/// @return P's UV coordinates on the screen.
vec2 xUnproject(vec4 p)
{
	vec2 uv = p.xy / p.w;
	uv = uv * 0.5 + 0.5;
	uv.y = 1.0 - uv.y;
	return uv;
}
// include("Projecting.xsh")

#pragma include("Math.xsh", "glsl")
#define X_PI   3.14159265359
#define X_2_PI 6.28318530718

/// @return x^2
#define xPow2(x) ((x) * (x))

/// @return x^3
#define xPow3(x) ((x) * (x) * (x))

/// @return x^4
#define xPow4(x) ((x) * (x) * (x) * (x))

/// @return x^5
#define xPow5(x) ((x) * (x) * (x) * (x) * (x))

/// @return arctan2(x,y)
#define xAtan2(x, y) atan(y, x)

/// @return Direction from point `from` to point `to` in degrees (0-360 range).
float xPointDirection(vec2 from, vec2 to)
{
	float x = xAtan2(from.x - to.x, from.y - to.y);
	return ((x > 0.0) ? x : (2.0 * X_PI + x)) * 180.0 / X_PI;
}
// include("Math.xsh")

#define xGetAngle(a, b) acos(dot(a, b) / (length(a) * length(b)))

void main()
{
	vec4 base = texture2D(gm_BaseTexture, v_vTexCoord);

	// Origin
	float depth = xDecodeDepth(base.rgb);
	float depthLinear = depth;
	if (depth == 0.0 || depth == 1.0)
	{
		gl_FragColor = vec4(1.0);
		return;
	}

	depth *= u_fClipFar;
	vec3 origin = xProject(u_vTanAspect, v_vTexCoord, depth);

	vec2 noise = texture2D(u_texNoise, v_vTexCoord * u_vNoiseScale).xy * 2.0 - 1.0;

	mat2 rot = mat2(
		noise.x, -noise.y,
		noise.y, noise.x
	);

	// Occlusion
	float occlusion = 0.0;

	for (int i = 0; i < X_SSAO_KERNEL_SIZE; ++i)
	{
		vec2 dir = (rot * u_vSampleKernel[i].xy) * 48.0 * (1.0 - depthLinear);

		vec2 sampleLeftUV = v_vTexCoord + dir * u_vTexel;
		vec2 sampleRightUV = v_vTexCoord - dir * u_vTexel;

		float sampleLeftDepth = xDecodeDepth(texture2D(gm_BaseTexture, sampleLeftUV).rgb) * u_fClipFar;
		float sampleRightDepth = xDecodeDepth(texture2D(gm_BaseTexture, sampleRightUV).rgb) * u_fClipFar;

		vec3 sampleLeftPos = xProject(u_vTanAspect, sampleLeftUV, sampleLeftDepth);
		vec3 sampleRightPos = xProject(u_vTanAspect, sampleRightUV, sampleRightDepth);

		vec3 diffLeft = sampleLeftPos - origin;
		vec3 diffRight = sampleRightPos - origin;

		float angle = acos(dot(diffLeft, diffRight) / (length(diffLeft) * length(diffRight))) / X_PI;

		if (-diffLeft.z - diffRight.z < 0.4)
		{
			angle = 1.0;
		}

		float att = ((abs(diffLeft.z) + abs(diffRight.z)) * 0.5) / 5.0;
		att = clamp(att * att, 0.0, 1.0);

		angle = mix(angle, 1.0, att);

		if (
			sampleLeftUV.x < 0.0 || sampleLeftUV.x > 1.0
			|| sampleLeftUV.y < 0.0 || sampleLeftUV.y > 1.0
			|| sampleRightUV.x < 0.0 || sampleRightUV.x > 1.0
			|| sampleRightUV.y < 0.0 || sampleRightUV.y > 1.0
		)
		{
			angle = 1.0;
		}

		occlusion += 1.0 - angle;
	}

	occlusion /= float(X_SSAO_KERNEL_SIZE);
	occlusion = clamp(1.0 - occlusion, 0.0, 1.0);
	occlusion = pow(occlusion, 4.0/*u_fPower*/);

	// Output
	gl_FragColor.rgb = vec3(occlusion);
	gl_FragColor.a   = 1.0;
}