/// @func BBMOD_VertexFormat([_vertices[, _normals[, _uvs[, _colors[, _tangentw[, _bones[, _ids]]]]]]])
/// @desc A wrapper of a raw GameMaker vertex format.
/// @param {bool} [_vertices] If `true` then the vertex format must have vertices. This should
/// always be `true`! Defaults to `true`.
/// @param {bool} [_normals] If `true` then the vertex format must have normal vectors.
/// Defaults to `false`.
/// @param {bool} [_uvs] If `true` then the vertex format must have texture coordinates.
/// Defaults to `false`.
/// @param {bool} [_colors] If `true` then the vertex format must have vertex colors.
/// Defaults to `false`.
/// @param {bool} [_tangentw] If `true` then the vertex format must have tangent vectors and
/// bitangent signs. Defaults to `false`.
/// @param {bool} [_bones] If `true` then the vertex format must have vertex weights and bone
/// indices. Defaults to `false`.
/// @param {bool} [_ids] If `true` then the vertex format must have ids for dynamic batching.
/// Defaults to `false`.
function BBMOD_VertexFormat(_vertices=true, _normals=false, _uvs=false, _colors=false, _tangentw=false, _bones=false, _ids=false) constructor
{
	/// @var {bool} If `true` then the vertex format has vertices.
	/// @readonly
	Vertices = _vertices;

	/// @var {bool} If `true` then the vertex format has normal vectors.
	/// @readonly
	Normals = _normals;

	/// @var {bool} If `true` then the vertex format has texture coordinates.
	/// @readonly
	TextureCoords = _uvs;

	/// @var {bool} If `true` then the vertex format has vertex colors.
	/// @readonly
	Colors = _colors;

	/// @var {bool} If `true` then the vertex format has tangent vectors and
	/// bitangent sign.
	/// @readonly
	TangentW = _tangentw;

	/// @var {bool} If `true` then the vertex format has vertex weights and bone
	/// indices.
	Bones = _bones;

	/// @var {bool} If `true` then the vertex format has ids for dynamic batching.
	/// @readonly
	Ids = _ids;

	/// @var {vertex_format} The raw vertex format.
	/// @readonly
	Raw = undefined;

	/// @var {ds_map<int, vertex_format>} A map of existing raw vertex formats.
	/// @private
	static Formats = ds_map_create();

	/// @func get_hash()
	/// @desc Makes a hash based on the vertex format properties. Vertex buffers
	/// with same propereties will have the same hash.
	/// @return {int} The hash.
	static get_hash = function () {
		return (0
			| (Vertices << 0)
			| (Normals << 1)
			| (TextureCoords << 2)
			| (Colors << 3)
			| (TangentW << 4)
			| (Bones << 5)
			| (Ids << 6)
			);
	};

	/// @func get_byte_size()
	/// @desc Retrieves the size of a single vertex using the vertex format in bytes.
	/// @return {uint} The byte size of a single vertex using the vertex format.
	static get_byte_size = function () {
		gml_pragma("forceinline");
		return (0
			+ (buffer_sizeof(buffer_f32) * 3 * Vertices)
			+ (buffer_sizeof(buffer_f32) * 3 * Normals)
			+ (buffer_sizeof(buffer_f32) * 2 * TextureCoords)
			+ (buffer_sizeof(buffer_u32) * 1 * Colors)
			+ (buffer_sizeof(buffer_f32) * 4 * TangentW)
			+ (buffer_sizeof(buffer_f32) * 8 * Bones)
			+ (buffer_sizeof(buffer_f32) * 1 * Ids)
		);
	};

	var _hash = get_hash();

	if (ds_map_exists(Formats, _hash))
	{
		Raw = Formats[? _hash];
	}
	else
	{
		vertex_format_begin();

		if (Vertices)
		{
			vertex_format_add_position_3d();
		}

		if (Normals)
		{
			vertex_format_add_normal();
		}

		if (TextureCoords)
		{
			vertex_format_add_texcoord();
		}

		if (Colors)
		{
			vertex_format_add_colour();
		}

		if (TangentW)
		{
			vertex_format_add_custom(vertex_type_float4, vertex_usage_texcoord);
		}

		if (Bones)
		{
			vertex_format_add_custom(vertex_type_float4, vertex_usage_texcoord);
			vertex_format_add_custom(vertex_type_float4, vertex_usage_texcoord);
		}

		if (Ids)
		{
			vertex_format_add_custom(vertex_type_float1, vertex_usage_texcoord);
		}

		Raw = vertex_format_end();
		Formats[? _hash] = Raw;
	}
}

/// @func bbmod_vertex_format_load(_buffer)
/// @desc Loads a vertex format from a buffer.
/// @param {buffer} _buffer The buffer to load the vertex format from.
/// @return {BBMOD_VertexFormat} The loaded vetex format.
/// @private
function bbmod_vertex_format_load(_buffer)
{
	var _vertices = buffer_read(_buffer, buffer_bool);
	var _normals = buffer_read(_buffer, buffer_bool);
	var _textureCoords = buffer_read(_buffer, buffer_bool);
	var _colors = buffer_read(_buffer, buffer_bool);
	var _tangentW = buffer_read(_buffer, buffer_bool);
	var _bones = buffer_read(_buffer, buffer_bool);
	var _ids = buffer_read(_buffer, buffer_bool);

	return new BBMOD_VertexFormat(
		_vertices,
		_normals,
		_textureCoords,
		_colors,
		_tangentW,
		_bones,
		_ids);
}