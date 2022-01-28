/// @func bbmod_cmp(_a, _b)
/// @desc
/// @param {real} _a
/// @param {real} _b
/// @return {bool}
function bbmod_cmp(_a, _b)
{
	gml_pragma("forceinline");
	return (abs(_a - _b) <= math_get_epsilon() * max(1.0, abs(_a), abs(_b)));
}