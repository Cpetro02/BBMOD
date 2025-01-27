/// @macro Must be the first line when defining a custom class!
/// @example
/// ```gml
/// function CSurface(_width, _height)
///     : BBMOD_Class() constructor
/// {
///     BBMOD_CLASS_GENERATED_BODY;
///
///     static Super_Class = {
///         destroy: destroy,
///     };
///
///     Surface = surface_create(_width, _height);
///
///     static destroy = function () {
///         method(self, Super_Class.destroy)();
///         surface_free(Surface);
///     };
/// }
/// ```
#macro BBMOD_CLASS_GENERATED_BODY \
	static __ClassName = bbmod_get_calling_function_name(); \
	array_push(__Inheritance, __ClassName)

/// @func BBMOD_Class()
/// @desc Base for BBMOD structs that require more OOP functionality.
function BBMOD_Class() constructor
{
	/// @var {string[]} An array of names of inherited classes.
	/// @private
	__Inheritance = [];

	BBMOD_CLASS_GENERATED_BODY;

	/// @var {func[]} An array of implemented interfaces.
	/// @private
	__Interfaces = [];

	/// @var {func[]} An array of functions executed when the destroy method
	/// is called.
	/// @private
	__DestroyActions = [];

	/// @func is_instance(_class)
	/// @desc Checks if the struct inherits from given class.
	/// @param {typeof BBMOD_Class} _class The class type.
	/// @return {bool} Returns `true` if the struct inherits from the class.
	static is_instance = function (_class) {
		gml_pragma("forceinline");
		var _className = bbmod_class_get_name(_class);
		var i = 0;
		repeat (array_length(__Inheritance))
		{
			if (__Inheritance[i++] == _className)
			{
				return true;
			}
		}
		return false;
	};

	/// @func implement(_interface)
	/// @desc Implements an interface into the struct.
	/// @return {BBMOD_Class} Returns `self`.
	/// @throws {BBMOD_Exception} If the struct already implements the interface.
	static implement = function (_interface) {
		gml_pragma("forceinline");
		if (implements(_interface))
		{
			throw new BBMOD_Exception("Interface already implemented!");
			return self;
		}
		array_push(__Interfaces, _interface);
		method(self, _interface)();
		return self;
	};

	/// @func implements(_interface)
	/// @desc Checks whether the struct implements an interface.
	/// @param {func} _interface The interface to check.
	/// @return {bool} Returns `true` if the struct implements the interface.
	static implements = function (_interface) {
		gml_pragma("forceinline");
		var i = 0;
		repeat (array_length(__Interfaces))
		{
			if (__Interfaces[i++] == _interface)
			{
				return true;
			}
		}
		return false;
	};

	/// @func destroy()
	/// @desc Frees resources used by the struct from memory.
	static destroy = function () {
		var i = 0;
		repeat (array_length(__DestroyActions))
		{
			method(self, __DestroyActions[i++])();
		}
	};
}

/// @func bbmod_is_class(_value)
/// @desc Checks if a value is an instance of `BBMOD_Class`.
/// @param {any} _value The value to check.
/// @return {bool} Returns `true` if the value is an instance of `BBMOD_Class`.
/// @see BBMOD_Class
function bbmod_is_class(_value)
{
	gml_pragma("forceinline");
	return (is_struct(_value)
		&& variable_struct_exists(_value, "__ClassName"));
}

/// @func bbmod_class_get_name(_class)
/// @desc Retrieves class name from class instance or class type.
/// @param {typeof BBMOD_Class/BBMOD_Class} _class The class instance or the
/// class type.
/// @return {string} The name of the class.
function bbmod_class_get_name(_class)
{
	gml_pragma("forceinline");
	return is_struct(_class)
		? _class.__ClassName
		: script_get_name(_class);
}