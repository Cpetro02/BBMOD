/// @enum An enumeration of members of a BBMOD_ENode legacy struct.
enum BBMOD_ENode
{
	/// @member The name of the node.
	Name,
	/// @member An array of BBMOD_EMesh legacy structs.
	Meshes,
	/// @member An array of child BBMOD_ENode legacy structs.
	Children,
	/// @member The size of the BBMOD_ENode legacy struct.
	SIZE
};

/// @func bbmod_node_load(_buffer, _format, _format_mask)
/// @desc Loads a node from a buffer.
/// @param {real} _buffer The buffer to load the struct from.
/// @param {real} _format A vertex format for node's meshes.
/// @param {real} _format_mask A vertex format mask.
/// @return {BBMOD_ENode} The loaded node.
function bbmod_node_load(_buffer, _format, _format_mask)
{
	var i = 0;

	var _node = array_create(BBMOD_ENode.SIZE, 0);
	_node[@ BBMOD_ENode.Name] = buffer_read(_buffer, buffer_string);

	// Models
	var _model_count = buffer_read(_buffer, buffer_u32);
	var _models = array_create(_model_count, 0);

	_node[@ BBMOD_ENode.Meshes] = _models;

	//i = 0;
	repeat (_model_count)
	{
		_models[@ i++] = bbmod_mesh_load(_buffer, _format, _format_mask);
	}

	// Child nodes
	var _child_count = buffer_read(_buffer, buffer_u32);
	var _children = array_create(_child_count, 0);
	_node[@ BBMOD_ENode.Children] = _children;

	i = 0;
	repeat (_child_count)
	{
		_children[@ i++] = bbmod_node_load(_buffer, _format, _format_mask);
	}

	return _node;
}

/// @func bbmod_node_destroy(_node)
/// @desc Frees resources used by a node from memory.
/// @param {BBMOD_ENode} _node The node to destroy.
function bbmod_node_destroy(_node)
{
	var _meshes = _node[BBMOD_ENode.Meshes];
	var _children = _node[BBMOD_ENode.Children];
	var i = 0;

	//i = 0;
	repeat (array_length(_meshes))
	{
		bbmod_mesh_destroy(_meshes[i++]);
	}

	i = 0;
	repeat (array_length(_children))
	{
		bbmod_node_destroy(_children[i++]);
	}
}

/// @func bbmod_node_render(_model, _node, _materials, _transform)
/// @desc Submits a node for rendering.
/// @param {BBMOD_EModel} _model The model to which the node belongs.
/// @param {BBMOD_ENode} _node The node.
/// @param {BBMOD_EMaterial[]} _materials An array of materials, one for each
/// material slot of the model.
/// @param {array/undefined} _transform An array of transformation matrices
/// (for animated models) or `undefined`.
function bbmod_node_render(_model, _node, _materials, _transform)
{
	var _meshes = _node[BBMOD_ENode.Meshes];
	var _children = _node[BBMOD_ENode.Children];
	var _render_pass = global.bbmod_render_pass;
	var i = 0;

	repeat (array_length(_meshes))
	{
		var _mesh = _meshes[i++];
		var _material_index = _mesh[BBMOD_EMesh.MaterialIndex];
		var _material = _materials[_material_index];

		if ((_material[BBMOD_EMaterial.RenderPath] & _render_pass) == 0)
		{
			// Do not render the mesh if it doesn't use a material that can be used
			// in the current render path.
			continue;
		}

		if (bbmod_material_apply(_material) && !is_undefined(_transform))
		{
			shader_set_uniform_f_array(shader_get_uniform(shader_current(), "u_mBones"), _transform);
		}

		var _tex_base = _material[BBMOD_EMaterial.BaseOpacity];
		vertex_submit(_mesh[BBMOD_EMesh.VertexBuffer], pr_trianglelist, _tex_base);
	}

	i = 0;
	repeat (array_length(_children))
	{
		bbmod_node_render(_model, _children[i++], _materials, _transform);
	}
}

/// @func _bbmod_node_freeze(_node)
/// @param {BBMOD_ENode} _node
/// @private
function _bbmod_node_freeze(_node)
{
	var _meshes = _node[BBMOD_ENode.Meshes];
	var _children = _node[BBMOD_ENode.Children];

	var i = 0;
	repeat (array_length(_meshes))
	{
		_bbmod_mesh_freeze(_meshes[i++]);
	}

	i = 0;
	repeat (array_length(_children))
	{
		_bbmod_node_freeze(_children[i++]);
	}
}

/// @func _bbmod_node_to_dynamic_batch(_node, _dynamic_batch)
/// @param {BBMOD_ENode} _node
/// @param {BBMOD_EDynamicBatch} _dynamic_batch
/// @private
function _bbmod_node_to_dynamic_batch(_node, _dynamic_batch)
{
	var _meshes = _node[BBMOD_ENode.Meshes];
	var _children = _node[BBMOD_ENode.Children];
	var i = 0;

	repeat (array_length(_meshes))
	{
		_bbmod_mesh_to_dynamic_batch(_meshes[i++], _dynamic_batch);
	}

	i = 0;
	repeat (array_length(_children))
	{
		_bbmod_node_to_dynamic_batch(_children[i++], _dynamic_batch);
	}
}

/// @func _bbmod_node_to_static_batch(_model, _node, _static_batch, _transform)
/// @param {BBMOD_EModel} _model
/// @param {BBMOD_ENode} _node
/// @param {BBMOD_EStaticBatch} _static_batch
/// @param {array} _transform
/// @private
function _bbmod_node_to_static_batch(_model, _node, _static_batch, _transform)
{
	var _meshes = _node[BBMOD_ENode.Meshes];
	var _children = _node[BBMOD_ENode.Children];
	var i = 0;

	repeat (array_length(_meshes))
	{
		_bbmod_mesh_to_static_batch(_model, _meshes[i++], _static_batch, _transform);
	}

	i = 0;
	repeat (array_length(_children))
	{
		_bbmod_node_to_static_batch(_model, _children[i++], _static_batch, _transform);
	}
}