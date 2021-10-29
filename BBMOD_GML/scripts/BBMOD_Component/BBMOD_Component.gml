function bbmod_component_get_name(_component)
{
	gml_pragma("forceinline");
	return is_struct(_component)
		? _component.Name
		: script_get_name(_component);
}

/// @func BBMOD_Component()
/// @extends BBMOD_Class
function BBMOD_Component()
	: BBMOD_Class() constructor
{
	/// @var {string} The name of the component.
	/// @readonly
	static Name = bbmod_component_get_name(BBMOD_Component);
}