#if ANIMATED
Vec3 xQuaternionRotate(Vec4 q, Vec3 v)
{
	return (v + 2.0 * cross(q.xyz, cross(q.xyz, v) + q.w * v));
}

Vec3 xDualQuaternionTransform(Vec4 real, Vec4 dual, Vec3 v)
{
	return (xQuaternionRotate(real, v)
		+ 2.0 * (real.w * dual.xyz - dual.w * real.xyz + cross(real.xyz, dual.xyz)));
}
#elif BATCHED
#pragma include("Quaternion.xsh", "glsl")
#endif
