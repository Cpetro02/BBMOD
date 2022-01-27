/// @func BBMOD_Matrix()
/// @desc
function BBMOD_Matrix() constructor
{
	/// @var {real[16]} A raw GameMaker matrix.
	Raw = matrix_build_identity();

	/// @func Copy(_dest)
	/// @desc
	/// @param {BBMOD_Matrix} _dest
	/// @return {BBMOD_Matrix} Returns `self`.
	static Copy = function (_dest) {
		gml_pragma("forceinline");
		array_copy(_dest.Raw, 0, Raw, 0, 16);
		return self;
	};

	/// @func Clone()
	/// @desc
	/// @return {BBMOD_Matrix} The clone of the matrix.
	static Clone = function () {
		var _clone = new BBMOD_Matrix();
		Copy(_clone);
		return _clone;
	};

	/// @func SetIndex(_index, _value)
	/// @desc
	/// @param {uint} _index
	/// @param {real} _value
	/// @return {BBMOD_Matrix} Returns `self`.
	static SetIndex = function (_index, _value) {
		gml_pragma("forceinline");
		Raw[@ _index] = _value;
		return self;
	};

	/// @func FromArray(_array[, _index])
	/// @desc
	/// @param {real[]} _array
	/// @param {uint} [_index] Defaults to 0.
	/// @return {BBMOD_Matrix} Returns `self`.
	static FromArray = function (_array, _index=0) {
		gml_pragma("forceinline");
		array_copy(Raw, 0, _array, _index, 16);
		return self;
	};

	/// @func ToArray([_array[, _index]])
	/// @desc
	/// @param {real[]/undefined} [_array]
	/// @param {uint} [_index]
	/// @return {real[]}
	static ToArray = function (_array=undefined, _index=0) {
		gml_pragma("forceinline");
		_array ??= array_create(16, 0.0);
		array_copy(_array, _index, Raw, 0, 16);
		return _array;
	};

	/// @func FromBuffer(_buffer, _type)
	/// @desc
	/// @param {buffer} _buffer
	/// @param {uint} _type
	/// @return {BBMOD_Matrix} Returns `self`.
	static FromBuffer = function (_buffer, _type) {
		gml_pragma("forceinline");
		var _index = 0;
		repeat (16)
		{
			Raw[_index++] = buffer_read(_buffer, _type);
		}
		return self;
	};

	/// @func ToBuffer(_buffer, _type)
	/// @desc
	/// @param {buffer} _buffer
	/// @param {uint} _type
	/// @return {BBMOD_Matrix} Returns `self`.
	static ToBuffer = function (_buffer, _type) {
		gml_pragma("forceinline");
		var _index = 0;
		repeat (16)
		{
			buffer_write(_buffer, _type, Raw[_index++]);
		}
		return self;
	};

	/// @func FromColumns(_c1, _c2, _c3, _c4)
	/// @desc
	/// @param {BBMOD_Vec4} _c1
	/// @param {BBMOD_Vec4} _c2
	/// @param {BBMOD_Vec4} _c3
	/// @param {BBMOD_Vec4} _c4
	/// @return {BBMOD_Matrix} Returns `self`.
	static FromColumns = function (_c1, _c2, _c3, _c4) {
		gml_pragma("forceinline");
		Raw = [
			_c1.X, _c2.X, _c3.X, _c4.X,
			_c1.Y, _c2.Y, _c3.Y, _c4.Y,
			_c1.Z, _c2.Z, _c3.Z, _c4.Z,
			_c1.W, _c2.W, _c3.W, _c4.W,
		];
		return self;
	};

	/// @func FromRows(_r1, _r2, _r3, _r4)
	/// @desc
	/// @param {BBMOD_Vec4} _r1
	/// @param {BBMOD_Vec4} _r2
	/// @param {BBMOD_Vec4} _r3
	/// @param {BBMOD_Vec4} _r4
	/// @return {BBMOD_Matrix} Returns `self`.
	static FromRows = function (_r1, _r2, _r3, _r4) {
		gml_pragma("forceinline");
		Raw = [
			_r1.X, _r1.Y, _r1.Z, _r1.W,
			_r2.X, _r2.Y, _r2.Z, _r2.W,
			_r3.X, _r3.Y, _r3.Z, _r3.W,
			_r4.X, _r4.Y, _r4.Z, _r4.W,
		];
		return self;
	};

	/// @func FromLookAt(_from, _to, _up)
	/// @desc
	/// @param {BBMOD_Vec3} _from
	/// @param {BBMOD_Vec3} _to
	/// @param {BBMOD_Vec3} _up
	/// @return {BBMOD_Matrix} Returns `self`.
	static FromLookAt = function (_from, _to, _up) {
		gml_pragma("forceinline");
		Raw = matrix_build_lookat(
			_from.X, _from.Y, _from.Z,
			_to.X, _to.Y, _to.Z,
			_up.X, _up.Y, _up.Z);
		return self;
	};

	/// @func ToEuler([_array[, _index]])
	/// @desc
	/// @param {real[]/undefined} [_array]
	/// @parma {uint} [_index]
	/// @return {real[]}
	static ToEuler = function (_array=undefined, _index=0) {
		gml_pragma("forceinline");

		_array ??= array_create(3, 0.0);

		var _thetaX, _thetaY, _thetaZ;
		var _m = Raw;
		var _m6 = _m[6];

		if (_m6 < 1.0)
		{
			if (_m6 > -1.0)
			{
				_thetaX = arcsin(-_m6);
				_thetaY = arctan2(_m[2], _m[10]);
				_thetaZ = arctan2(_m[4], _m[5]);
			}
			else
			{
				_thetaX = pi * 0.5;
				_thetaY = -arctan2(-_m[1], _m[0]);
				_thetaZ = 0.0;
			}
		}
		else
		{
			_thetaX = -pi * 0.5;
			_thetaY = arctan2(-_m[1], _m[0]);
			_thetaZ = 0.0;
		}

		_array[@ _index]     = (360.0 + radtodeg(_thetaX)) mod 360.0;
		_array[@ _index + 1] = (360.0 + radtodeg(_thetaY)) mod 360.0;
		_array[@ _index + 2] = (360.0 + radtodeg(_thetaZ)) mod 360.0;

		return _array;
	};

	/// @func Determinant()
	/// @desc
	/// @return {real}
	static Determinant = function () {
		gml_pragma("forceinline");
		var _m   = Raw;
		var _m0  = _m[ 0];
		var _m1  = _m[ 1];
		var _m2  = _m[ 2];
		var _m3  = _m[ 3];
		var _m4  = _m[ 4];
		var _m5  = _m[ 5];
		var _m6  = _m[ 6];
		var _m7  = _m[ 7];
		var _m8  = _m[ 8];
		var _m9  = _m[ 9];
		var _m10 = _m[10];
		var _m11 = _m[11];
		var _m12 = _m[12];
		var _m13 = _m[13];
		var _m14 = _m[14];
		var _m15 = _m[15];
		return (0.0
			+ (_m3 * _m6 *  _m9 * _m12) - (_m2 * _m7 *  _m9 * _m12) - (_m3 * _m5 * _m10 * _m12) + (_m1 * _m7 * _m10 * _m12)
			+ (_m2 * _m5 * _m11 * _m12) - (_m1 * _m6 * _m11 * _m12) - (_m3 * _m6 *  _m8 * _m13) + (_m2 * _m7 *  _m8 * _m13)
			+ (_m3 * _m4 * _m10 * _m13) - (_m0 * _m7 * _m10 * _m13) - (_m2 * _m4 * _m11 * _m13) + (_m0 * _m6 * _m11 * _m13)
			+ (_m3 * _m5 *  _m8 * _m14) - (_m1 * _m7 *  _m8 * _m14) - (_m3 * _m4 *  _m9 * _m14) + (_m0 * _m7 *  _m9 * _m14)
			+ (_m1 * _m4 * _m11 * _m14) - (_m0 * _m5 * _m11 * _m14) - (_m2 * _m5 *  _m8 * _m15) + (_m1 * _m6 *  _m8 * _m15)
			+ (_m2 * _m4 *  _m9 * _m15) - (_m0 * _m6 *  _m9 * _m15) - (_m1 * _m4 * _m10 * _m15) + (_m0 * _m5 * _m10 * _m15));
	};

	/// @func Inverse()
	/// @desc
	/// @return {BBMOD_Matrix} The inverse matrix.
	static Inverse = function () {
		gml_pragma("forceinline");

		var _res = new BBMOD_Matrix();
		var _m   = Raw;
		var _m0  = _m[ 0];
		var _m1  = _m[ 1];
		var _m2  = _m[ 2];
		var _m3  = _m[ 3];
		var _m4  = _m[ 4];
		var _m5  = _m[ 5];
		var _m6  = _m[ 6];
		var _m7  = _m[ 7];
		var _m8  = _m[ 8];
		var _m9  = _m[ 9];
		var _m10 = _m[10];
		var _m11 = _m[11];
		var _m12 = _m[12];
		var _m13 = _m[13];
		var _m14 = _m[14];
		var _m15 = _m[15];

		var _determinant = (0.0
			+ (_m3 * _m6 *  _m9 * _m12) - (_m2 * _m7 *  _m9 * _m12) - (_m3 * _m5 * _m10 * _m12) + (_m1 * _m7 * _m10 * _m12)
			+ (_m2 * _m5 * _m11 * _m12) - (_m1 * _m6 * _m11 * _m12) - (_m3 * _m6 *  _m8 * _m13) + (_m2 * _m7 *  _m8 * _m13)
			+ (_m3 * _m4 * _m10 * _m13) - (_m0 * _m7 * _m10 * _m13) - (_m2 * _m4 * _m11 * _m13) + (_m0 * _m6 * _m11 * _m13)
			+ (_m3 * _m5 *  _m8 * _m14) - (_m1 * _m7 *  _m8 * _m14) - (_m3 * _m4 *  _m9 * _m14) + (_m0 * _m7 *  _m9 * _m14)
			+ (_m1 * _m4 * _m11 * _m14) - (_m0 * _m5 * _m11 * _m14) - (_m2 * _m5 *  _m8 * _m15) + (_m1 * _m6 *  _m8 * _m15)
			+ (_m2 * _m4 *  _m9 * _m15) - (_m0 * _m6 *  _m9 * _m15) - (_m1 * _m4 * _m10 * _m15) + (_m0 * _m5 * _m10 * _m15));

		var _s = 1.0 / _determinant;

		_res.Raw = [
			_s * ((_m6 * _m11 * _m13) - (_m7 * _m10 * _m13) + (_m7 * _m9 * _m14) - (_m5 * _m11 * _m14) - (_m6 * _m9 * _m15) + (_m5 * _m10 * _m15)),
			_s * ((_m3 * _m10 * _m13) - (_m2 * _m11 * _m13) - (_m3 * _m9 * _m14) + (_m1 * _m11 * _m14) + (_m2 * _m9 * _m15) - (_m1 * _m10 * _m15)),
			_s * ((_m2 *  _m7 * _m13) - (_m3 *  _m6 * _m13) + (_m3 * _m5 * _m14) - (_m1 *  _m7 * _m14) - (_m2 * _m5 * _m15) + (_m1 *  _m6 * _m15)),
			_s * ((_m3 *  _m6 *  _m9) - (_m2 *  _m7 *  _m9) - (_m3 * _m5 * _m10) + (_m1 *  _m7 * _m10) + (_m2 * _m5 * _m11) - (_m1 *  _m6 * _m11)),
			_s * ((_m7 * _m10 * _m12) - (_m6 * _m11 * _m12) - (_m7 * _m8 * _m14) + (_m4 * _m11 * _m14) + (_m6 * _m8 * _m15) - (_m4 * _m10 * _m15)),
			_s * ((_m2 * _m11 * _m12) - (_m3 * _m10 * _m12) + (_m3 * _m8 * _m14) - (_m0 * _m11 * _m14) - (_m2 * _m8 * _m15) + (_m0 * _m10 * _m15)),
			_s * ((_m3 *  _m6 * _m12) - (_m2 *  _m7 * _m12) - (_m3 * _m4 * _m14) + (_m0 *  _m7 * _m14) + (_m2 * _m4 * _m15) - (_m0 *  _m6 * _m15)),
			_s * ((_m2 *  _m7 *  _m8) - (_m3 *  _m6 *  _m8) + (_m3 * _m4 * _m10) - (_m0 *  _m7 * _m10) - (_m2 * _m4 * _m11) + (_m0 *  _m6 * _m11)),
			_s * ((_m5 * _m11 * _m12) - (_m7 *  _m9 * _m12) + (_m7 * _m8 * _m13) - (_m4 * _m11 * _m13) - (_m5 * _m8 * _m15) + (_m4 *  _m9 * _m15)),
			_s * ((_m3 *  _m9 * _m12) - (_m1 * _m11 * _m12) - (_m3 * _m8 * _m13) + (_m0 * _m11 * _m13) + (_m1 * _m8 * _m15) - (_m0 *  _m9 * _m15)),
			_s * ((_m1 *  _m7 * _m12) - (_m3 *  _m5 * _m12) + (_m3 * _m4 * _m13) - (_m0 *  _m7 * _m13) - (_m1 * _m4 * _m15) + (_m0 *  _m5 * _m15)),
			_s * ((_m3 *  _m5 *  _m8) - (_m1 *  _m7 *  _m8) - (_m3 * _m4 *  _m9) + (_m0 *  _m7 *  _m9) + (_m1 * _m4 * _m11) - (_m0 *  _m5 * _m11)),
			_s * ((_m6 *  _m9 * _m12) - (_m5 * _m10 * _m12) - (_m6 * _m8 * _m13) + (_m4 * _m10 * _m13) + (_m5 * _m8 * _m14) - (_m4 *  _m9 * _m14)),
			_s * ((_m1 * _m10 * _m12) - (_m2 *  _m9 * _m12) + (_m2 * _m8 * _m13) - (_m0 * _m10 * _m13) - (_m1 * _m8 * _m14) + (_m0 *  _m9 * _m14)),
			_s * ((_m2 *  _m5 * _m12) - (_m1 *  _m6 * _m12) - (_m2 * _m4 * _m13) + (_m0 *  _m6 * _m13) + (_m1 * _m4 * _m14) - (_m0 *  _m5 * _m14)),
			_s * ((_m1 *  _m6 *  _m8) - (_m2 *  _m5 *  _m8) + (_m2 * _m4 *  _m9) - (_m0 *  _m6 *  _m9) - (_m1 * _m4 * _m10) + (_m0 *  _m5 * _m10)),
		];

		return _res;
	};

	/// @func Mul(_matrix, ...)
	/// @desc
	/// @param {BBMOD_Matrix} _matrix
	/// @return {BBMOD_Matrix} The resulting matrix.
	static Mul = function (_matrix) {
		gml_pragma("forceinline");
		var _res = BBMOD_Matrix();
		var _raw = matrix_multiply(Raw, _matrix.Raw);
		var _index = 1;
		repeat (argument_count - 1)
		{
			_raw = matrix_multiply(_raw, argument[_index++]);
		}
		_res.Raw = _raw;
		return _res;
	};

	/// @func MulComponentwise(_matrix)
	/// @desc
	/// @param {BBMOD_Matrix} _matrix
	/// @return {BBMOD_Matrix} The resulting matrix.
	static MulComponentwise = function (_matrix) {
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		var _selfRaw = Raw;
		var _otherRaw = _matrix.Raw;
		var _index = 0;
		repeat (16)
		{
			_res[@ _index] = _selfRaw[_index] * _otherRaw[_index];
			++_index;
		}
		return _res;
	};

	/// @func AddComponentwise(_matrix)
	/// @desc
	/// @param {BBMOD_Matrix} _matrix
	/// @return {BBMOD_Matrix} The resulting matrix.
	static AddComponentwise = function (_matrix) {
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		var _selfRaw = Raw;
		var _otherRaw = _matrix.Raw;
		var _index = 0;
		repeat (16)
		{
			_res[@ _index] = _selfRaw[_index] + _otherRaw[_index];
			++_index;
		}
		return _res;
	};

	/// @func SubComponentwise(_matrix)
	/// @desc
	/// @param {BBMOD_Matrix} _matrix
	/// @return {BBMOD_Matrix} The resulting matrix.
	static SubComponentwise = function (_matrix) {
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		var _selfRaw = Raw;
		var _otherRaw = _matrix.Raw;
		var _index = 0;
		repeat (16)
		{
			_res[@ _index] = _selfRaw[_index] - _otherRaw[_index];
			++_index;
		}
		return _res;
	};

	/// @func Transpose()
	/// @desc
	/// @return {BBMOD_Matrix} The transposed matrix.
	static Transpose = function () {
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		var _m = Raw;
		_res.Raw = [
			_m[0], _m[4], _m[ 8], _m[12],
			_m[1], _m[5], _m[ 9], _m[13],
			_m[2], _m[6], _m[10], _m[14],
			_m[3], _m[7], _m[11], _m[15],
		];
		return _res;
	};

	/// @func Translate(_x[, _y, _z])
	/// @desc
	/// @param {BBMOD_Vec3/real} _x
	/// @param {real/undefined} [_y]
	/// @param {real/undefined} [_z]
	/// @return {BBMOD_Matrix}
	static Translate = function (_x, _y=undefined, _z=undefined) {
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		_res.Raw = matrix_multiply(Raw,
			is_struct(_x)
				? matrix_build(_x.X, _x.Y, _x.Z, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0)
				: matrix_build(_x, _y, _z, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0));
		return _res;
	};

	/// @func TranslateX(_x)
	/// @desc
	/// @param {real} _x
	/// @return {BBMOD_Matrix}
	static TranslateX = function (_x) {
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		_res.Raw = matrix_multiply(Raw,
			matrix_build(_x, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0));
		return _res;
	};

	/// @func TranslateX(_y)
	/// @desc
	/// @param {real} _y
	/// @return {BBMOD_Matrix}
	static TranslateY = function (_y) {
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		_res.Raw = matrix_multiply(Raw,
			matrix_build(0.0, _y, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0));
		return _res;
	};

	/// @func TranslateZ(_z)
	/// @desc
	/// @param {real} _z
	/// @return {BBMOD_Matrix}
	static TranslateZ = function (_z) {
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		_res.Raw = matrix_multiply(Raw,
			matrix_build(0.0, 0.0, _z, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0));
		return _res;
	};

	/// @func RotateEuler(_x[, _y, _z])
	/// @desc
	/// @param {BBMOD_Vec3/real} _x
	/// @param {real/undefined} [_y]
	/// @param {real/undefined} [_z]
	/// @return {BBMOD_Matrix}
	static RotateEuler = function (_x, _y=undefined, _z=undefined) {
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		_res.Raw = matrix_multiply(Raw,
			is_struct(_x)
				? matrix_build(0.0, 0.0, 0.0, _x.X, _x.Y, _x.Z, 1.0, 1.0, 1.0)
				: matrix_build(0.0, 0.0, 0.0, _x, _y, _z, 1.0, 1.0, 1.0));
		return _res;
	};

	/// @func RotateQuat(_quat)
	/// @desc
	/// @param {BBMOD_Quaternion} _quat
	/// @return {BBMOD_Matrix}
	static RotateQuat = function (_quat) {
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		_res.Raw = matrix_multiply(Raw, _quat.ToMatrix());
		return _res;
	};

	/// @func RotateX(_x)
	/// @desc
	/// @param {real} _x
	/// @return {BBMOD_Matrix}
	static RotateX = function (_x) {
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		_res.Raw = matrix_multiply(Raw,
			matrix_build(0.0, 0.0, 0.0, _x, 0.0, 0.0, 1.0, 1.0, 1.0));
		return _res;
	};

	/// @func RotateY(_y)
	/// @desc
	/// @param {real} _y
	/// @return {BBMOD_Matrix}
	static RotateY = function (_y) {
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		_res.Raw = matrix_multiply(Raw,
			matrix_build(0.0, 0.0, 0.0, 0.0, _y, 0.0, 1.0, 1.0, 1.0));
		return _res;
	};

	/// @func RotateZ(_z)
	/// @desc
	/// @param {real} _z
	/// @return {BBMOD_Matrix}
	static RotateZ = function (_z) {
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		_res.Raw = matrix_multiply(Raw,
			matrix_build(0.0, 0.0, 0.0, 0.0, 0.0, _z, 1.0, 1.0, 1.0));
		return _res;
	};

	/// @func Scale(_x[, _y, _z])
	/// @desc
	/// @param {BBMOD_Vec3/real} _x
	/// @param {real/undefined} [_y]
	/// @param {real/undefined} [_z]
	/// @return {BBMOD_Matrix}
	static Scale = function (_x, _y=undefined, _z=undefined) {
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		_res.Raw = matrix_multiply(Raw,
			is_struct(_x)
				? matrix_build(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, _x.X, _x.Y, _x.Z)
				: matrix_build(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, _x, _y, _z));
		return _res;
	};

	/// @func ScaleComponentwise(_s)
	/// @desc
	/// @param {real} _s
	/// @return {BBMOD_Matrix} The resulting matrix.
	static ScaleComponentwise = function (_s) {
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		var _selfRaw = Raw;
		var _index = 0;
		repeat (16)
		{
			_res[@ _index] = _selfRaw[_index] * _s;
			++_index;
		}
		return _res;
	};

	/// @func ScaleX(_x)
	/// @desc
	/// @param {real} _x
	/// @return {BBMOD_Matrix}
	static ScaleX = function (_x) {
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		_res.Raw = matrix_multiply(Raw,
			matrix_build(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, _x, 1.0, 1.0));
		return _res;
	};

	/// @func ScaleY(_y)
	/// @desc
	/// @param {real} _y
	/// @return {BBMOD_Matrix}
	static ScaleY = function (_y) {
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		_res.Raw = matrix_multiply(Raw,
			matrix_build(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, _y, 1.0));
		return _res;
	};

	/// @func ScaleZ(_z)
	/// @desc
	/// @param {real} _z
	/// @return {BBMOD_Matrix}
	static ScaleZ = function (_z) {
		gml_pragma("forceinline");
		var _res = new BBMOD_Matrix();
		_res.Raw = matrix_multiply(Raw,
			matrix_build(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, _z));
		return _res;
	};
}