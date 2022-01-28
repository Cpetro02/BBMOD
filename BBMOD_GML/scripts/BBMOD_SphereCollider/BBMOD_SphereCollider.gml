/// @func BBMOD_SphereCollider()
/// @extends BBMOD_Collider
function BBMOD_SphereCollider()
	: BBMOD_Collider() constructor
{
	/// @var BBMOD_Vec3()
	Position = new BBMOD_Vec3();

	/// @var {real}
	Radius = 1.0;

	static GetClosestPoint = function (_point) {
		gml_pragma("forceinline");
		var _sphereToPoint = _point.Sub(Position).Normalize()
			.Scale(Radius);
		return Position.Add(_sphereToPoint);
	};

	static _TestImpl = function (_collider) {
		gml_pragma("forceinline");
		var _closestPoint = _collider.GetClosestPoint(Position);
		return (Position.Sub(_closestPoint).Length() < Radius);
	};

	static TestAABB = _TestImpl;

	static TestPlane = _TestImpl;

	static TestPoint = function (_point) {
		gml_pragma("forceinline");
		return (_point.Sub(Position).Length() < Radius);
	};

	static TestOBB = _TestImpl;

	static TestSphere = function (_sphere) {
		gml_pragma("forceinline");
		return (Position.Sub(_sphere.Position).Length() < Radius + _sphere.Radius);
	};
}