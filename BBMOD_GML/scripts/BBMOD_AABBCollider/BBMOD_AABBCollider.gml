/// @func BBMOD_AABBCollider([_position[, _size]])
/// @extends BBMOD_Collider
/// @param {BBMOD_Vec3} [_position]
/// @param {BBMOD_Vec3} [_size]
function BBMOD_AABBCollider(_position=undefined, _size=undefined)
	: BBMOD_Collider() constructor
{
	/// @var {BBMOD_Vec3}
	Position = _position ?? new BBMOD_Vec3();

	/// @var {BBMOD_Vec3}
	Size = _size ?? new BBMOD_Vec3(1.0);

	/// @func FromMinMax(_min, _max)
	/// @desc
	/// @param {BBMOD_Vec3} _min
	/// @param {BBMOD_Vec3} _max
	/// @return {BBMOD_AABBCollider} Returns `self`.
	static FromMinMax = function (_min, _max) {
		gml_pragma("forceinline");
		Position = _min.Add(_max).Scale(0.5);
		Size = _max.Sub(_min).Scale(0.5);
		return self;
	};

	/// @func GetMin()
	/// @desc
	/// @return {BBMOD_Vec3}
	static GetMin = function () {
		gml_pragma("forceinline");
		var _p1 = Position.Add(Size);
		var _p2 = Position.Sub(Size);
		return _p1.Minimize(_p2);
	};

	/// @func GetMax()
	/// @desc
	/// @return {BBMOD_Vec3}
	static GetMax = function () {
		gml_pragma("forceinline");
		var _p1 = Position.Add(Size);
		var _p2 = Position.Sub(Size);
		return _p1.Maximize(_p2);
	};

	static GetClosestPoint = function (_point) {
		gml_pragma("forceinline");
		return _point.Clamp(GetMin(), GetMax());
	};

	static TestAABB = function (_aabb) {
		gml_pragma("forceinline");

		var _aMin = GetMin();
		var _aMax = GetMax();
		var _bMin = _aabb.GetMin();
		var _bMax = _aabb.GetMax();

		return ((_aMin.X <= _bMax.X && _aMax.X >= _bMin.X)
			&& (_aMin.Y <= _bMax.Y && _aMax.Y >= _bMin.Y)
			&& (_aMin.Z <= _bMax.Z && _aMax.Z >= _bMin.Z));
	};

	static TestOBB = function (_obb) {
		// https://github.com/gszauer/GamePhysicsCookbook/blob/master/Code/Geometry3D.cpp
		// 351
	};

	static TestPoint = function (_point) {
		gml_pragma("forceinline");
		var _min = GetMin();
		var _max = GetMax();

		if (_point.X < _min.X || _point.Y < _min.Y || _point.Z < _min.Z)
		{
			return false;
		}

		if (_point.X > _max.X || _point.Y > _max.Y || _point.Z > _max.Z)
		{
			return false;
		}

		return true;
	};
}