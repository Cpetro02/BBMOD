/// @func bbmod_array_from_buffer(_buffer, _type, _size)
/// @desc Creates an array with values from a buffer.
/// @param {buffer} _buffer The buffer to load the data from.
/// @param {uint} _type The value type. Use one of the `buffer_` constants,
/// e.g. `buffer_f32`.
/// @param {uint} _size The number of values to load.
/// @return {array} The created array.
/// @private
function bbmod_array_from_buffer(_buffer, _type, _size)
{
	var _array = array_create(_size, 0);
	var i = 0;
	repeat (_size)
	{
		_array[@ i++] = buffer_read(_buffer, buffer_f32);
	}
	return _array;
}

/// @func bbmod_surface_check(_surface, _width, _height)
/// @desc Checks whether the surface exists and if it has correct size. Broken
/// surfaces are recreated. Surfaces of wrong size are resized.
/// @param {surface} _surface The surface to check.
/// @param {real} _width The desired width of the surface.
/// @param {real} _height The desired height of the surface.
/// @return {surface} The surface.
function bbmod_surface_check(_surface, _width, _height)
{
	_width = max(round(_width), 1);
	_height = max(round(_height), 1);

	if (!surface_exists(_surface))
	{
		return surface_create(_width, _height);
	}

	if (surface_get_width(_surface) != _width
		|| surface_get_height(_surface) != _height)
	{
		surface_resize(_surface, _width, _height);
	}

	return _surface;
}