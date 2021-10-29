function bbmod_entity_init()
{
	Components = ds_map_create();
}

function bbmod_entity_add_component(_component)
{
	gml_pragma("forceinline");
	var _index = bbmod_component_get_name(_component);
	if (!ds_map_exists(Components, _index))
	{
		Components[? _index] = [];
	}
	array_push(Components[? _index], _component);
	return self;
}

function bbmod_entity_has_component(_component)
{
	gml_pragma("forceinline");
	var _index = bbmod_component_get_name(_component);
	return ds_map_exists(Components, _index);
}

function bbmod_entity_get_components(_component)
{
	gml_pragma("forceinline");
	var _index = bbmod_component_get_name(_component);
	return Components[? _index];
}

function bbmod_entity_remove_component(_component)
{
	gml_pragma("forceinline");

	var _index = bbmod_component_get_name(_component);
	var _components = Components[? _index];

	if (is_struct(_component))
	{
		var i = 0;
		repeat (array_length(_components))
		{
			var _instance = _components[i];
			if (_instance == _component)
			{
				_instance.destroy();
				array_delete(_components, i, 1);
				break;
			}
			++i;
		}

		if (array_length(_components) == 0)
		{
			ds_map_delete(Components, _index);
		}
	}
	else
	{
		var i = 0;
		repeat (array_length(_components))
		{
			_components[i++].destroy();
		}
		ds_map_delete(Components, _index);
	}

	return self;
}

function bbmod_entity_destroy()
{
	gml_pragma("forceinline");
	ds_map_destroy(Components);
}

/// @func BBMOD_Entity()
/// @extends BBMOD_Class
function BBMOD_Entity()
	: BBMOD_Class() constructor
{
	static Super_Class = {
		destroy: destroy,
	};

	/// @var {ds_map<string, BBMOD_Component>} A map of entity's components.
	/// @private
	Components = ds_map_create();

	static add_component = function (_component) {
		gml_pragma("forceinline");
		return bbmod_entity_add_component(_component);
	};

	static has_component = function (_component) {
		gml_pragma("forceinline");
		return bbmod_entity_has_component(_component);
	};

	static get_components = function (_component) {
		gml_pragma("forceinline");
		return bbmod_entity_get_components(_component);
	};

	static remove_component = function (_component) {
		gml_pragma("forceinline");
		return bbmod_entity_remove_component(_component);
	};

	static destroy = function() {
		method(self, Super_Class.destroy)();
		bbmod_entity_destroy();
	};
}

////////////////////////////////////////////////////////////////////////////////
// Tests
function BBMOD_TransformComponent(_position=undefined, _rotation=undefined, _scale=undefined)
	: BBMOD_Component() constructor
{
	static Name = bbmod_component_get_name(BBMOD_TransformComponent);

	Position = (_position != undefined) ? _position : new BBMOD_Vec3();

	Rotation = (_rotation != undefined) ? _rotation : new BBMOD_Quaternion();

	Scale = (_scale != undefined) ? _scale : new BBMOD_Vec3(1.0);
}

var _e = new BBMOD_Entity();
var _transform = new BBMOD_TransformComponent();

show_debug_message(_e.add_component(_transform));
show_debug_message(_e.has_component(BBMOD_TransformComponent));
show_debug_message(_e.get_components(BBMOD_TransformComponent));
show_debug_message(_e.remove_component(_transform));
show_debug_message(_e.has_component(BBMOD_TransformComponent));