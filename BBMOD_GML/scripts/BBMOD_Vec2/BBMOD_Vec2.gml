/// @func BBMOD_Vec2([_x[, _y]])
/// @desc A 2D vector.
/// @param {real} [_x] The first component of the vector. Defaults to 0.
/// @param {real/undefined} [_y] The second component of the vector. Defaults to `_x`.
/// @see BBMOD_Vec3
/// @see BBMOD_Vec4
function BBMOD_Vec2(_x=0.0, _y=undefined) constructor
{
	/// @var {real} The first component of the vector.
	X = _x;

	/// @var {real} The second component of the vector.
	Y = _y ?? X;

	/// @func Abs()
	/// @desc Creates a new vector where each component is equal to the absolute
	/// value of the original component.
	/// @return {BBMOD_Vec2} The created vector.
	/// @example
	/// ```gml
	/// new BBMOD_Vec2(-1.0, 2.0).Abs() // => BBMOD_Vec2(1.0, 2.0)
	/// ```
	static Abs = function () {
		gml_pragma("forceinline");
		return new BBMOD_Vec2(
			abs(X),
			abs(Y),
		);
	};

	/// @func Add(_v)
	/// @desc Adds vectors and returns the result as a new vector.
	/// @param {BBMOD_Vec2} _v The other vector.
	/// @return {BBMOD_Vec2} The created vector.
	static Add = function (_v) {
		gml_pragma("forceinline");
		return new BBMOD_Vec2(
			X + _v.X,
			Y + _v.Y,
		);
	};

	/// @func Ceil()
	/// @desc Applies function `ceil` to each component of the vector and returns
	/// the result as a new vector.
	/// @return {BBMOD_Vec2} The created vector.
	/// @example
	/// ```gml
	/// new BBMOD_Vec2(0.2, 1.6).Ceil() // => BBMOD_Vec2(1.0, 2.0)
	/// ```
	static Ceil = function () {
		gml_pragma("forceinline");
		return new BBMOD_Vec2(
			ceil(X),
			ceil(Y),
		);
	};

	/// @func Clamp(_min, _max)
	/// @desc Clamps each component of the vector between corresponding
	/// components of `_min` and `_max` and returns the result as a new vector.
	/// @param {BBMOD_Vec2} _min A vector with minimum components.
	/// @param {BBMOD_Vec2} _max A vector with maximum components.
	/// @return {BBMOD_Vec2} The resulting vector.
	static Clamp = function (_min, _max) {
		gml_pragma("forceinline");
		return new BBMOD_Vec2(
			clamp(X, _min.X, _max.X),
			clamp(Y, _min.Y, _max.Y),
		);
	};

	/// @func ClampLength(_min, _max)
	/// @desc Clamps the length of the vector between `_min` and `_max` and
	/// returns the result as a new vector.
	/// @param {real} _min The minimum length of the vector.
	/// @param {real} _max The maximum length of the vector.
	/// @return {BBMOD_Vec2} The created vector.
	/// @example
	/// ```gml
	/// new BBMOD_Vec2(3.0, 0.0).ClampLength(1.0, 5.0) // => BBMOD_Vec2(3.0, 0.0)
	/// new BBMOD_Vec2(3.0, 0.0).ClampLength(4.0, 5.0) // => BBMOD_Vec2(4.0, 0.0)
	/// new BBMOD_Vec2(3.0, 0.0).ClampLength(1.0, 2.0) // => BBMOD_Vec2(2.0, 0.0)
	/// ```
	static ClampLength = function (_min, _max) {
		gml_pragma("forceinline");
		var _length = sqrt(
			  X * X
			+ Y * Y
		);
		var _newLength = clamp(_length, _min, _max);
		return new BBMOD_Vec2(
			(X / _length) * _newLength,
			(Y / _length) * _newLength,
		);
	};

	/// @func Clone()
	/// @desc Creates a clone of the vector.
	/// @return {BBMOD_Vec2} The creted vector.
	static Clone = function () {
		gml_pragma("forceinline");
		return new BBMOD_Vec2(
			X,
			Y,
		);
	};

	/// @func Copy(_dest)
	/// @desc Copies components of the vector to the `_dest` vector.
	/// @param {BBMOD_Vec2} _dest The destination vector.
	/// @return {BBMOD_Vec2} Returns `self`.
	/// @example
	/// ```gml
	/// var _v1 = new BBMOD_Vec2(1.0, 2.0);
	/// var _v2 = new BBMOD_Vec2(3.0, 4.0);
	/// show_debug_message(_v2) // Prints { X: 3.0, Y: 4.0 }
	/// _v1.Copy(_v2);
	/// show_debug_message(_v2) // Prints { X: 1.0, Y: 2.0 }
	/// ```
	static Copy = function (_dest) {
		gml_pragma("forceinline");
		_dest.X = X;
		_dest.Y = Y;
		return self;
	};

	/// @func Dot(_v)
	/// @desc Computes the dot product of this vector and vector `_v`.
	/// @param {BBMOD_Vec2} _v The other vector.
	/// @return {real} The dot product of this vector and vector `_v`.
	static Dot = function (_v) {
		gml_pragma("forceinline");
		return (
			  X * _v.X
			+ Y * _v.Y
		);
	};

	/// @func Equals(_v)
	/// @desc Checks whether this vectors equals to vector `_v`.
	/// @param {BBMOD_Vec2} _v The vector to compare to.
	/// @return {bool} Returns `true` if the two vectors are equal.
	static Equals = function (_v) {
		gml_pragma("forceinline");
		return (
			   X == _v.X
			&& Y == _v.Y
		);
	};

	/// @func Floor()
	/// @desc Applies function `floor` to each component of the vector and returns
	/// the result as a new vector.
	/// @return {BBMOD_Vec2} The created vector.
	/// @example
	/// ```gml
	/// new BBMOD_Vec2(0.2, 1.6).Floor() // => BBMOD_Vec2(0.0, 1.0)
	/// ```
	static Floor = function () {
		gml_pragma("forceinline");
		return new BBMOD_Vec2(
			floor(X),
			floor(Y),
		);
	};

	/// @func Frac()
	/// @desc Applies function `frac` to each component of the vector and returns
	/// the result as a new vector.
	/// @return {BBMOD_Vec2} The created vector.
	/// @example
	/// ```gml
	/// new BBMOD_Vec2(0.2, 1.6).Frac() // => BBMOD_Vec2(0.2, 0.6)
	/// ```
	static Frac = function () {
		gml_pragma("forceinline");
		return new BBMOD_Vec2(
			frac(X),
			frac(Y),
		);
	};

	/// @func FromArray(_array[, _index])
	/// @desc Loads vector components from an array.
	/// @param {real[]} _array The array to read the components from.
	/// @param {uint} [_index] The index to start reading the vector components
	/// from. Defaults to 0.
	/// @return {BBMOD_Vec2} Returns `self`.
	static FromArray = function (_array, _index=0) {
		gml_pragma("forceinline");
		X = _array[_index];
		Y = _array[_index + 1];
		return self;
	};

	/// @func FromBarycentric(_v1, _v2, _v3, _f, _g)
	/// @desc Computes the vector components using a formula
	/// `_v1 + _f * (_v2 - _v1) + _g * (_v3 - _v1)`.
	/// @param {BBMOD_Vec2} _v1 The first point of a triangle.
	/// @param {BBMOD_Vec2} _v2 The second point of a triangle.
	/// @param {BBMOD_Vec2} _v3 The third point of a triangle.
	/// @param {real} _f The weighting factor between `_v1` and `_v2`.
	/// @param {real} _g The weighting factor between `_v1` and `_v3`.
	/// @return {BBMOD_Vec2} Returns `self`.
	static FromBarycentric = function (_v1, _v2, _v3, _f, _g) {
		gml_pragma("forceinline");
		var _v1X = _v1.X;
		var _v1Y = _v1.Y;
		X = _v1X + _f * (_v2.X - _v1X) + _g * (_v3.X - _v1X);
		Y = _v1Y + _f * (_v2.Y - _v1Y) + _g * (_v3.Y - _v1Y);
		return self;
	};

	/// @func FromBuffer(_buffer, _type)
	/// @desc Loads vector components from a buffer.
	/// @param {buffer} _buffer The buffer to read the components from.
	/// @param {int} _type The type of each component. Use one of the `buffer_`
	/// constants, e.g. `buffer_f32`.
	/// @return {BBMOD_Vec2} Returns `self`.
	static FromBuffer = function (_buffer, _type) {
		gml_pragma("forceinline");
		X = buffer_read(_buffer, _type);
		Y = buffer_read(_buffer, _type);
		return self;
	};

	/// @func Length()
	/// @desc Computes the length of the vector.
	/// @return {real} The length of the vector.
	static Length = function () {
		gml_pragma("forceinline");
		return sqrt(
			  X * X
			+ Y * Y
		);
	};

	/// @func LengthSqr()
	/// @desc Computes a squared length of the vector.
	/// @return {real} The squared length of the vector.
	static LengthSqr = function () {
		gml_pragma("forceinline");
		return (
			  X * X
			+ Y * Y
		);
	};

	/// @func Lerp(_v, _amount)
	/// @desc Linearly interpolates between vector `_v` by the given amount.
	/// @param {BBMOD_Vec2} _v The vector to interpolate with.
	/// @param {real} _amount The interpolation factor.
	static Lerp = function (_v, _amount) {
		gml_pragma("forceinline");
		return new BBMOD_Vec2(
			lerp(X, _v.X, _amount),
			lerp(Y, _v.Y, _amount),
		);
	};

	/// @func MaxComponent()
	/// @desc Computes the greatest component of the vector.
	/// @return {real} The greates component of the vector.
	static MaxComponent = function () {
		gml_pragma("forceinline");
		return max(
			X,
			Y,
		);
	};

	/// @func Maximize(_v)
	/// @desc Creates a new vector where each component is the maximum component
	/// from this vector and vector `_v`.
	/// @param {BBMOD_Vec2} _v The other vector.
	/// @return {BBMOD_Vec2} The created vector.
	/// @example
	/// ```gml
	/// var _v1 = new BBMOD_Vec2(1.0, 4.0);
	/// var _v2 = new BBMOD_Vec2(2.0, 3.0);
	/// var _vMax = _v1.Maximize(_v2); // Equals to BBMOD_Vec2(2.0, 4.0)
	/// ```
	static Maximize = function (_v) {
		gml_pragma("forceinline");
		return new BBMOD_Vec2(
			max(X, _v.X),
			max(Y, _v.Y),
		);
	};

	/// @func MinComponent()
	/// @desc Computes the smallest component of the vector.
	/// @return {real} The smallest component of the vector.
	static MinComponent = function () {
		gml_pragma("forceinline");
		return min(
			X,
			Y,
		);
	};

	/// @func Minimize(_v)
	/// @desc Creates a new vector where each component is the minimum component
	/// from this vector and vector `_v`.
	/// @param {BBMOD_Vec2} _v The other vector.
	/// @return {BBMOD_Vec2} The created vector.
	/// @example
	/// ```gml
	/// var _v1 = new BBMOD_Vec2(1.0, 4.0);
	/// var _v2 = new BBMOD_Vec2(2.0, 3.0);
	/// var _vMin = _v1.Minimize(_v2); // Equals to BBMOD_Vec2(1.0, 3.0)
	/// ```
	static Minimize = function (_v) {
		gml_pragma("forceinline");
		return new BBMOD_Vec2(
			min(X, _v.X),
			min(Y, _v.Y),
		);
	};

	/// @func Mul(_v)
	/// @desc Multiplies the vector with vector `_v` and returns the result
	/// as a new vector.
	/// @param {BBMOD_Vec2} _v The other vector.
	/// @return {BBMOD_Vec2} The created vector.
	static Mul = function (_v) {
		gml_pragma("forceinline");
		return new BBMOD_Vec2(
			X * _v.X,
			Y * _v.Y,
		);
	};

	/// @func Normalize()
	/// @desc Normalizes the vector and returns the result as a new vector.
	/// @return {BBMOD_Vec2} The created vector.
	static Normalize = function () {
		gml_pragma("forceinline");
		var _lengthSqr = (
			  X * X
			+ Y * Y
		);
		if (_lengthSqr >= math_get_epsilon())
		{
			var _n = 1.0 / sqrt(_lengthSqr);
			return new BBMOD_Vec2(
				X * _n,
				Y * _n,
			);
		}
		return new BBMOD_Vec2(
			X,
			Y,
		);
	};

	/// @func Reflect(_v)
	/// @desc Reflects the vector from vector `_v` and returns the result
	/// as a new vector.
	/// @param {BBMOD_Vec2} _v The vector to reflect from.
	/// @return {BBMOD_Vec2} The created vector.
	static Reflect = function (_v) {
		gml_pragma("forceinline");
		var _dot2 = (
			  X * _v.X
			+ Y * _v.Y
		) * 2.0;
		return new BBMOD_Vec2(
			X - (_dot2 * _v.X),
			Y - (_dot2 * _v.Y),
		);
	};

	/// @func Round()
	/// @desc Applies function `round` to each component of the vector and returns
	/// the result as a new vector.
	/// @return {BBMOD_Vec2} The created vector.
	/// @example
	/// ```gml
	/// new BBMOD_Vec2(0.2, 1.6).Round() // => BBMOD_Vec2(0.0, 2.0)
	/// ```
	static Round = function () {
		gml_pragma("forceinline");
		return new BBMOD_Vec2(
			round(X),
			round(Y),
		);
	};

	/// @func Scale(_s)
	/// @desc Scales each component of the vector by `_s` and returns the result
	/// as a new vector.
	/// @param {real} _s The value to scale the components by.
	/// @return {BBMOD_Vec2} The created vector.
	/// @example
	/// ```gml
	/// new BBMOD_Vec2(1.0, 2.0).Scale(2.0) // => BBMOD_Vec2(2.0, 4.0)
	/// ```
	static Scale = function (_s) {
		gml_pragma("forceinline")
		return new BBMOD_Vec2(
			X * _s,
			Y * _s,
		);
	};

	/// @func Get(_index)
	/// @desc Retrieves vector component at given index (0 is X, 1 is Y, etc.).
	/// @param {uint} _index The index of the component.
	/// @return {real} The value of the vector component at given index.
	/// @throws {BBMOD_OutOfRangeException} If an invalid index is passed.
	static Get = function (_index) {
		gml_pragma("forceinline");
		switch (_index)
		{
		case 0:
			return X;

		case 1:
			return Y;
		}
		throw new BBMOD_OutOfRangeException();
	};

	/// @func Set([_x[, _y]])
	/// @desc Sets vector components in-place.
	/// @param {real} [_x] The new value of the first component. Defaults to 0.
	/// @param {real/undefined} [_y] The new value of the second component. Defaults to `_x`.
	/// @return {BBMOD_Vec2} Returns `self`.
	static Set = function (_x=0.0, _y=undefined) {
		gml_pragma("forceinline");
		X = _x;
		Y = _y ?? X;
		return self;
	};

	/// @func SetIndex(_index, _value)
	/// @desc Sets vector component in-place.
	/// @param {uint} _index The index of the component, starting at 0.
	/// @param {real} _value The new value of the component.
	/// @return {BBMOD_Vec2} Returns `self`.
	/// @throws {BBMOD_OutOfRangeException} If the given index is out of range
	/// of possible values.
	static SetIndex = function (_index, _value) {
		gml_pragma("forceinline");
		switch (_index)
		{
		case 0:
			X = _value;
			break;

		case 1:
			Y = _value;
			break;

		default:
			throw new BBMOD_OutOfRangeException();
			break;
		}
		return self;
	};

	/// @func Sub(_v)
	/// @desc Subtracts vector `_v` from this vector and returns the result
	/// as a new vector.
	/// @param {BBMOD_Vec2} _v The vector to subtract from this one.
	/// @return {BBMOD_Vec2} The created vector.
	/// @example
	/// ```gml
	/// var _v1 = new BBMOD_Vec2(1.0, 2.0);
	/// var _v2 = new BBMOD_Vec2(3.0, 4.0);
	/// var _v3 = _v1.Sub(_v); // Equals to BBMOD_Vec2(-2.0, -2.0)
	/// ```
	static Sub = function (_v) {
		gml_pragma("forceinline")
		return new BBMOD_Vec2(
			X - _v.X,
			Y - _v.Y,
		);
	};

	/// @func ToArray([_array[, _index]])
	/// @desc Writes the components of the vector into the target array.
	/// @param {real[]/undefined} [_array] The array to write to. If `undefined`,
	/// a new one of required size is created.
	/// @param {uint} [_index] The starting index within the target array.
	/// Defaults to 0.
	/// @return {real[]} The target array.
	static ToArray = function (_array=undefined, _index=0) {
		gml_pragma("forceinline");
		_array ??= array_create(2, 0.0);
		_array[@ _index]     = X;
		_array[@ _index + 1] = Y;
		return _array;
	};

	/// @func ToBuffer(_buffer, _type)
	/// @desc Writes the components of the vector into the buffer.
	/// @param {buffer} _buffer The buffer to write to.
	/// @param {int} _type The type of the components. Use one of the `buffer_`
	/// constants, e.g. `buffer_f32`.
	/// @return {BBMOD_Vec2} Returns `self`.
	static ToBuffer = function (_buffer, _type) {
		gml_pragma("forceinline");
		buffer_write(_buffer, _type, X);
		buffer_write(_buffer, _type, Y);
		return self;
	};

	/// @func Transform(_matrix)
	/// @desc Transforms vector `[X, Y, 0.0, 1.0]` by a matrix and returns the result
	/// as a new vector.
	/// @param {real[16]} _matrix The matrix to transform the vector by.
	/// @return {BBMOD_Vec2} The created vector.
	static Transform = function (_matrix) {
		gml_pragma("forceinline")
		var _res = matrix_transform_vertex(_matrix, X, Y, 0.0);
		return new BBMOD_Vec2(
			_res[0],
			_res[1],
		);
	};
}