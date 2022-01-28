/// @func BBMOD_OBBCollider()
/// @extends BBMOD_Collider
function BBMOD_OBBCollider()
	: BBMOD_Collider() constructor
{
	/// @var {BBMOD_Vec3}
	Position = new BBMOD_Vec3();

	/// @var {BBMOD_Vec3}
	Size = new BBMOD_Vec3(1.0);

	/// @var {BBMOD_Matrix}
	Orientation = new BBMOD_Matrix();

	static GetClosestPoint = function (_point) {
		gml_pragma("forceinline");
		var _result = Position;
		var _dir = _point.Sub(Position);
		var _index = 0;
		repeat (3)
		{
			var _index4 = _index * 4;
			var _axis = new BBMOD_Vec3(
				Orientation.Raw[_index4],
				Orientation.Raw[_index4 + 1],
				Orientation.Raw[_index4 + 2],
			);
			var _size = Size.Get(_index);
			var _distance = clamp(_dir.Dot(_axis), -_size, _size);
			_result = _result.Add(_axis.Scale(_distance));
			++_index;
		}
		return _result;
	};

	static TestPoint = function (_point) {
		gml_pragma("forceinline");
		var _dir = _point.Sub(Position);
		var _index = 0;
		repeat (3)
		{
			var _index4 = _index * 4;
			var _axis = new BBMOD_Vec3(
				Orientation.Raw[_index4],
				Orientation.Raw[_index4 + 1],
				Orientation.Raw[_index4 + 2],
			);
			var _distance = _dir.Dot(_axis);
			var _size = Size.Get(_index);
			if (_distance > _size)
			{
				return false;
			}
			if (_distance < -_size)
			{
				return false;
			}
			++_index;
		}
		return true;
	};
}