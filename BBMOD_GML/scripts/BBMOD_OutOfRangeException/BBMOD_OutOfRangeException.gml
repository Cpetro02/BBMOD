/// @func BBMOD_OutOfRangeException()
/// @extends BBMOD_Exception
/// @desc An exception thrown for example when argument passed to a function is
/// out of range of possible values, or when trying to access a data structure
/// at index outside of its range.
function BBMOD_OutOfRangeException()
	: BBMOD_Exception("Value out of range!") constructor
{
}