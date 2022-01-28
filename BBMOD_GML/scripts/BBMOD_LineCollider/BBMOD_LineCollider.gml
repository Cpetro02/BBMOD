/// @func BBMOD_LineCollider(_start, _end)
/// @extends BBMOD_Collider
/// @param {BBMOD_Vec3} _start
/// @param {BBMOD_Vec3} _end
function BBMOD_LineCollider(_start, _end)
	: BBMOD_Collider() constructor
{
	/// @var {BBMOD_Vec3}
	Start = _start;

	/// @var {BBMOD_Vec3}
	End = _end

	static GetClosestPoint = function (_point) {
		gml_pragma("forceinline");
		var _start = Start;
		var _vec = End.Sub(_start);
		var _t = _point.Sub(_start).Dot(_vec) / _vec.Dot(_vec);
		_t = clamp(_t, 0.0, 1.0);
		return _start.Add(_vec.Scale(_t));
	};

	static TestPoint = function (_point) {
		gml_pragma("forceinline");
		return bbmod_cmp(GetClosestPoint(_point).Sub(_point).Length(), 0.0);
	};
}