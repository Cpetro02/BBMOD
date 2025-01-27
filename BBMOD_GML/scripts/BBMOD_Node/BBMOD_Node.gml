/// @var {ds_stack} A stack used when rendering nodes to avoid recursion.
/// @private
global.__bbmodRenderStack = ds_stack_create();

/// @func BBMOD_Node(_model)
/// @implements {BBMOD_IRenderable}
/// @desc A node struct.
/// @param {BBMOD_Model} _model The model which contains this node.
/// @see BBMOD_Model.RootNode
function BBMOD_Node(_model) constructor
{
	/// @var {BBMOD_Model} The model which contains this node.
	/// @readonly
	Model = _model;

	/// @var {string} The name of the node.
	/// @readonly
	Name = "";

	/// @var {int} The node index.
	/// @readonly
	Index = 0;

	/// @var {BBMOD_Node/undefined} The parent of this node or `undefined`
	/// if it is the root node.
	/// @readonly
	Parent = undefined;

	/// @var {bool} If `true` then the node is a bone.
	/// @readonly
	IsBone = false;

	/// @var {bool} If `true` then the node is part of a skeleton node chain.
	/// @readonly
	IsSkeleton = false;

	/// @var {bool} Set to `false` to disable rendering of the node and its
	/// child nodes.
	Visible = true;

	/// @var {BBMOD_DualQuaternion} The transformation of the node.
	/// @readonly
	Transform = new BBMOD_DualQuaternion();

	/// @var {int[]} An array of meshes indices.
	/// @readonly
	Meshes = [];

	/// @var {bool} If true then the node or a node down the chain has a mesh.
	/// @readonly
	IsRenderable = false;

	/// @var {BBMOD_Node[]} An array of child nodes.
	/// @see BBMOD_Node
	/// @readonly
	Children = [];

	/// @func add_child(_node)
	/// @desc Adds a child node.
	/// @param {BBMOD_Node} The child node to add.
	/// @return {BBMOD_Node} Returns `self`.
	static add_child = function (_node) {
		gml_pragma("forceinline");
		array_push(Children, _node);
		_node.Parent = self;
		return self;
	};

	/// @func set_renderable()
	/// @desc Marks the node and nodes up the chain as renderable.
	/// @return {BBMOD_Node} Returns `self`.
	static set_renderable = function () {
		gml_pragma("forceinline");
		var _current = self;
		while (_current)
		{
			//if (_current.IsRenderable)
			//{
			//	return;
			//}
			_current.IsRenderable = true;
			_current = _current.Parent;
		}
		return self;
	};

	/// @func set_skeleton()
	/// @desc Marks the node and nodes up the chain as nodes required for
	/// animation playback.
	/// @retrun {BBMOD_Node} Returns `self`.
	static set_skeleton = function () {
		gml_pragma("forceinline");
		var _current = self;
		while (_current)
		{
			//if (_current.IsSkeleton)
			//{
			//	return;
			//}
			_current.IsSkeleton = true;
			_current = _current.Parent;
		}
		return self;
	};

	/// @func from_buffer(_buffer)
	/// @desc Loads node data from a buffer.
	/// @param {buffer} _buffer The buffer to load the data from.
	/// @return {BBMOD_Node} Returns `self`.
	/// @private
	static from_buffer = function (_buffer) {
		var i;

		Name = buffer_read(_buffer, buffer_string);
		Index = buffer_read(_buffer, buffer_f32);
		IsBone = buffer_read(_buffer, buffer_bool);
		IsSkeleton = IsBone;
		Visible = true;
		Transform = Transform.FromBuffer(_buffer, buffer_f32);

		// Meshes
		var _meshCount = buffer_read(_buffer, buffer_u32);
		var _meshes = array_create(_meshCount, undefined);
		Meshes = _meshes;
		IsRenderable = (_meshCount > 0);

		i = 0;
		repeat (_meshCount)
		{
			_meshes[@ i++] = buffer_read(_buffer, buffer_u32);
		}

		// Child nodes
		var _childCount = buffer_read(_buffer, buffer_u32);
		Children = [];

		repeat (_childCount)
		{
			var _child = new BBMOD_Node(Model).from_buffer(_buffer);
			add_child(_child);
			if (_child.IsRenderable)
			{
				set_renderable();
			}
			if (_child.IsSkeleton)
			{
				set_skeleton();
			}
		}

		return self;
	};

	/// @func submit(_materials, _transform)
	/// @desc Immediately submits the node for rendering.
	/// @param {BBMOD_BaseMaterial[]} _materials An array of materials, one for
	/// each material slot of the model.
	/// @param {real[]/undefined} _transform An array of transformation matrices
	/// (for animated models) or `undefined`.
	/// @private
	static submit = function (_materials, _transform) {
		var _meshes = Model.Meshes;
		var _renderStack = global.__bbmodRenderStack;
		var _node = self;

		ds_stack_push(_renderStack, _node);

		while (!ds_stack_empty(_renderStack))
		{
			_node = ds_stack_pop(_renderStack);

			if (!_node.IsRenderable || !_node.Visible)
			{
				continue;
			}

			var _meshIndices = _node.Meshes;
			var _children = _node.Children;
			var i = 0;

			repeat (array_length(_meshIndices))
			{
				var _mesh = _meshes[_meshIndices[i++]];
				var _materialIndex = _mesh.MaterialIndex;
				var _material = _materials[_materialIndex];

				_mesh.submit(_material, _transform);
			}

			i = 0;
			repeat (array_length(_children))
			{
				ds_stack_push(_renderStack, _children[i++]);
			}
		}
	};

	/// @func render(_materials, _transform)
	/// @desc Enqueues the node for rendering.
	/// @param {BBMOD_BaseMaterial[]} _materials An array of materials, one for
	/// each material slot of the model.
	/// @param {real[]/undefined} _transform An array of transformation matrices
	/// (for animated models) or `undefined`.
	/// @private
	static render = function (_materials, _transform, _matrix) {
		var _meshes = Model.Meshes;
		var _renderStack = global.__bbmodRenderStack;
		var _node = self;

		ds_stack_push(_renderStack, _node);

		while (!ds_stack_empty(_renderStack))
		{
			_node = ds_stack_pop(_renderStack);

			if (!_node.IsRenderable || !_node.Visible)
			{
				continue;
			}

			var _meshIndices = _node.Meshes;
			var _children = _node.Children;
			var i = 0;

			repeat (array_length(_meshIndices))
			{
				var _mesh = _meshes[_meshIndices[i++]];
				var _materialIndex = _mesh.MaterialIndex;
				var _material = _materials[_materialIndex];

				_mesh.render(_material, _transform, _matrix);
			}

			i = 0;
			repeat (array_length(_children))
			{
				ds_stack_push(_renderStack, _children[i++]);
			}
		}
	};
}