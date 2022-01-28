/// @func BBMOD_RayCollider(_origin, _direction)
/// @extends BBMOD_Collider
/// @param {BBMOD_Vec3} _origin
/// @param {BBMOD_Vec3} _direction
function BBMOD_RayCollider(_origin, _direction)
	: BBMOD_Collider() constructor
{
	/// @var {BBMOD_Vec3}
	Origin = _origin;

	/// @var {BBMOD_Vec3}
	Direction = _direction;

	static GetClosestPoint = function (_point) {
		gml_pragma("forceinline");
		var _t = _point.Sub(Origin).Dot(Direction);
		_t = max(_t, 0.0);
		return Origin.Add(Direction.Scale(_t));
	};

	static TestPoint = function (_point) {
		gml_pragma("forceinline");
		if (_point.Equals(Origin))
		{
			return true;
		}
		var _norm = _point.Sub(Origin)
			.Normalize();
		var _diff = _norm.Dot(Direction);
		return bbmod_cmp(_diff, 1.0);
	};
}