/// @func b_bbmod_model_load(buffer, version)
/// @param {real} buffer
/// @param {real} version
/// @return {array}
var _buffer = argument0;
var _version = argument1;
var _vformat = undefined;

var _bbmod = array_create(B_EBBMODModel.SIZE);

// Header
_bbmod[@ B_EBBMODModel.Version] = _version;

var _has_vertices = buffer_read(_buffer, buffer_bool);
_bbmod[@ B_EBBMODModel.HasVertices] = _has_vertices;

var _has_normals = buffer_read(_buffer, buffer_bool);
_bbmod[@ B_EBBMODModel.HasNormals] = _has_normals;

var _has_uvs = buffer_read(_buffer, buffer_bool);
_bbmod[@ B_EBBMODModel.HasTextureCoords] = _has_uvs;

var _has_colors = buffer_read(_buffer, buffer_bool);
_bbmod[@ B_EBBMODModel.HasColors] = _has_colors;

var _has_tangentw = buffer_read(_buffer, buffer_bool);
_bbmod[@ B_EBBMODModel.HasTangentW] = _has_tangentw;

var _has_bones = buffer_read(_buffer, buffer_bool);
_bbmod[@ B_EBBMODModel.HasBones] = _has_bones;

// Global inverse transform matrix
_bbmod[@ B_EBBMODModel.InverseTransformMatrix] = b_bbmod_load_matrix(_buffer);

// Vertex format
var _mask = (0
	| (_has_vertices << B_BBMOD_VFORMAT_VERTEX)
	| (_has_normals << B_BBMOD_VFORMAT_NORMAL)
	| (_has_uvs << B_BBMOD_VFORMAT_TEXCOORD)
	| (_has_colors << B_BBMOD_VFORMAT_COLOR)
	| (_has_tangentw << B_BBMOD_VFORMAT_TANGENTW)
	| (_has_bones << B_BBMOD_VFORMAT_BONES));

if (is_undefined(_vformat))
{
	_vformat = b_bbmod_get_vertex_format(
		_has_vertices,
		_has_normals,
		_has_uvs,
		_has_colors,
		_has_tangentw,
		_has_bones);
}

// Root node
_bbmod[@ B_EBBMODModel.RootNode] = b_bbmod_node_load(_buffer, _vformat, _mask);

// Skeleton
var _bone_count = buffer_read(_buffer, buffer_u32);
_bbmod[@ B_EBBMODModel.BoneCount] = _bone_count;

if (_bone_count > 0)
{
	_bbmod[@ B_EBBMODModel.Skeleton] = b_bbmod_bone_load(_buffer);
}

// Materials
var _material_count = buffer_read(_buffer, buffer_u32);
_bbmod[@ B_EBBMODModel.Materials] = array_create(_material_count, global.__b_bbmod_material_default);

return _bbmod;