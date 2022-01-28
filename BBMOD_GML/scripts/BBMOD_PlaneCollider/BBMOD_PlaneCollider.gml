/// @func BBMOD_PlaneCollider()
/// @extends BBMOD_Collider
function BBMOD_PlaneCollider()
	: BBMOD_Collider() constructor
{
	/// @var {BBMOD_Vec3}
	Normal = BBMOD_VEC3_UP;

	/// @var {real}
	Distance = 0.0;

	/// @func GetPointDistance(_point)
	/// @desc
	/// @param {BBMOD_Vec3} _point
	/// @return {real}
	static GetPointDistance = function (_point) {
		gml_pragma("forceinline");
		return (_point.Dot(Normal) - Distance);
	};

	static GetClosestPoint = function (_point) {
		gml_pragma("forceinline");
		return _point.Sub(Normal.Scale(GetPointDistance(_point)));
	};

	static TestPoint = function (_point) {
		gml_pragma("forceinline");
		return bbmod_cmp(GetPointDistance(_point), 0.0);
	};
}