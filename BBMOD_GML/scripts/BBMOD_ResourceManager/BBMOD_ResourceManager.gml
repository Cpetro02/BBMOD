/// @func BBMOD_ResourceManager()
///
/// @extends BBMOD_Class
///
/// @desc Using this struct you can easily load, retrieve and free from memory
/// any BBMOD resources.
///
/// @example
/// Create a resource manager in `OMain`:
/// ```gml
/// /// @desc Create event
/// resourceManager = new BBMOD_ResourceManager();
///
/// /// @desc Clean Up event
/// resourceManager.destroy();
///
/// /// @desc Async - Image Loaded event
/// resourceManager.async_image_loaded_update(async_load);
///
/// /// @desc Async - Save/Load event
/// resourceManager.async_save_load_update(async_load);
/// ```
///
/// Use the resource manager in another object to load its model or just retrieve
/// a reference to it, if it is already loaded.
/// ```gml
/// /// @desc Create event
/// model = OMain.resourceManager.load("Data/Model.bbmod");
///
/// /// @desc Clean Up event
/// // Free the reference. This is not necessary if you do not want to unload the
/// // model when all instances are destroyed. It will always be unloaded when the
/// // resource manager is destroyed.
/// model.free();
///
/// /// @desc Draw event
/// matrix_set(matrix_world, matrix_build(x, y, z, 0, 0, 0, 1, 1, 1));
/// model.render();
/// ```
function BBMOD_ResourceManager()
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Super_Class = {
		destroy: destroy,
	};

	/// @var {ds_map<string, BBMOD_Resource>}
	/// @private
	Resources = ds_map_create();

	/// @var {uint} Number of resources that are currently loading.
	/// @readonly
	Loading = 0;

	/// @func add(_uniqueName, _resource)
	/// @desc Adds a resource to the resource manager.
	/// @param {string} _uniqueName The name of the resource. Must be unique!
	/// @param {BBMOD_Resource} _resource The resource to add.
	/// @return {BBMOD_ResourceManager} Returns `self`.
	/// @throws {BBMOD_Exception} If the resource is already added to a manager.
	static add = function (_uniqueName, _resource) {
		gml_pragma("forceinline");
		if (_resource.Manager != undefined)
		{
			throw new BBMOD_Exception("Resource is already added to a manager!");
		}
		Resources[? _uniqueName] = _resource;
		_resource.Manager = self;
		return self;
	};

	/// @func has(_pathOrUniqueName)
	/// @desc Checks if the resource manager has a resource.
	/// @param {string} _pathOrUniqueName The path to the resource file or
	/// unique name of the resource.
	/// @return {bool} Returns `true` if the resource manager has the resource.
	static has = function (_pathOrUniqueName) {
		gml_pragma("forceinline");
		return ds_map_exists(Resources, _pathOrUniqueName);
	};

	/// @func get(_pathOrUniqueName)
	/// @desc Retrieves a reference to a resource.
	/// @param {string} _pathOrUniqueName The path to the resource file or
	/// unique name of the resource.
	/// @return {BBMOD_Resource} The resource.
	/// @see BBMOD_ResourceManager.has
	/// @throws {BBMOD_Exception} If the resource manager does not have such
	/// resource.
	static get = function (_pathOrUniqueName) {
		gml_pragma("forceinline");
		if (!ds_map_exists(Resources, _pathOrUniqueName))
		{
			throw new BBMOD_Exception("Resource not found!");
		}
		return Resources[? _pathOrUniqueName].ref();
	};

	/// @func get_or_add(_uniqueName, _onAdd)
	///
	/// @desc Retrieves a reference to a resource. If the resource does not
	/// exist yet, then it is added.
	///
	/// @param {string} _uniqueName The name of the resource. Must be unique!
	/// @param {func} _onAdd A function which creates the resource if it
	/// does not exist yet. Must take no arguments and must return the created
	/// resource.
	///
	/// @example
	/// Following code shows Create event of an object, where it assings its
	/// material using this method. When the first instance is created, it
	/// creates the material and adds it to the resource manager. When other
	/// instances are created, the material already exists and so they only
	/// get a reference to it.
	///
	/// ```gml
	/// /// @desc Create event
	/// material = resourceManager.get_or_add("material", function () {
	///     var _mat = BBMOD_MATERIAL_DEFAULT.clone();
	///     _mat.BaseOpacity = sprite_get_texture(SprBaseOpacity, 0);
	///     return _mat;
	/// });
	/// ```
	static get_or_add = function (_uniqueName, _onAdd) {
		gml_pragma("forceinline");
		if (ds_map_exists(Resources, _uniqueName))
		{
			return Resources[? _uniqueName].ref();
		}
		var _res = _onAdd();
		add(_uniqueName, _res);
		return _res;
	};

	/// @func load(_path[, _sha1[, _onLoad]])
	///
	/// @desc Asynchronnously loads a resource from a file or retrieves
	/// a reference to it, if it is already loaded.
	///
	/// @param {string} _path The path to the resource.
	/// @param {string/undefined} [_sha1] Expected SHA1 of the file. If the
	/// actual one does not match with this, then the resource will not be loaded.
	/// @param {func/undefined} [_onLoad] A function to execute when the
	/// resource is loaded or if an error occurs while loading it. It must take
	/// the error as the first argument and the resource as the second argument.
	/// If no error occurs, then `undefined` is passed. If the resource was
	/// already loaded when calling this function, then this callback is not executed.
	///
	/// @return {BBMOD_Resource/undefined} The resource.
	///
	/// @note Currently supported files formats are `*.bbmod` for {@link BBMOD_Model},
	/// `*.bbanim` for {@link BBMOD_Animation} and `*.png`, `*.gif`, `*.jpg/jpeg`
	/// for {@link BBMOD_Sprite}.
	static load = function (_path, _sha1=undefined, _onLoad=undefined) {
		var _resources = Resources;

		if (ds_map_exists(_resources, _path))
		{
			return _resources[? _path].ref();
		}

		var _ext = filename_ext(_path);
		var _res;
		switch (_ext)
		{
		case ".bbmod":
			_res = new BBMOD_Model();
			break;

		case ".bbanim":
			_res = new BBMOD_Animation();
			break;

		case ".png":
		case ".gif":
		case ".jpg":
		case ".jpeg":
			_res = new BBMOD_Sprite();
			break;

		default:
			_onLoad(new BBMOD_Exception("Invalid file extension '" + _ext + "'!"));
			return undefined;
		}


		_res.Manager = self;
		var _manager = self;
		var _struct = {
			Manager: _manager,
			Callback: _onLoad,
		};
		++Loading;
		_res.from_file_async(_path, _sha1, method(_struct, function (_err, _res) {
			--Manager.Loading;
			if (Callback != undefined)
			{
				Callback(_err, _res);
			}
		}));
		_resources[? _path] = _res;

		return _res;
	};

	/// @func free(_resourceOrPath)
	/// @desc Frees a reference to the resource. When there are no other no other
	/// references, the resource is destroyed.
	/// @param {BBMOD_Resource/string} _resourceOrPath
	/// @return {BBMOD_ResourceManager} Returns `self`.
	static free = function (_resourceOrPath) {
		// Note: Resource removes itself from the map
		var _resources = Resources;
		if (is_struct(_resourceOrPath))
		{
			_resourceOrPath.free();
		}
		else
		{
			_resources[? _resourceOrPath].free();
		}
		return self;
	};

	/// @func async_image_loaded_update(_asyncLoad)
	/// @desc Must be executed in the "Async - Image Loaded" event!
	/// @param {ds_map} _asyncLoad The `async_load` map.
	/// @return {BBMOD_ResourceManager} Returns `self`.
	/// @note This calls {@link bbmod_async_image_loaded_update}, so you do not
	/// need to call it again!
	/// @see bbmod_async_image_loaded_update
	static async_image_loaded_update = function (_asyncLoad) {
		gml_pragma("forceinline");
		bbmod_async_image_loaded_update(_asyncLoad);
		return self;
	};

	/// @func async_save_load_update(_asyncLoad)
	/// @desc Must be executed in the "Async - Save/Load" event!
	/// @param {ds_map} _asyncLoad The `async_load` map.
	/// @return {BBMOD_ResourceManager} Returns `self`.
	/// @note This calls {@link bbmod_async_image_loaded_update}, so you do not
	/// need to call it again!
	/// @see bbmod_async_image_loaded_update
	static async_save_load_update = function (_asyncLoad) {
		gml_pragma("forceinline");
		bbmod_async_save_load_update(_asyncLoad);
		return self;
	};

	static destroy = function () {
		method(self, Super_Class.destroy)();
		var _resources = Resources;
		var _key = ds_map_find_first(_resources);
		repeat (ds_map_size(_resources))
		{
			var _res = _resources[? _key];
			_res.Manager = undefined; // Do not remove from the map, we destroy it anyways
			_res.Counter = 0; // Otherwise we could call destroy multiple times
			_res.destroy();
			_key = ds_map_find_next(_resources, _key);
		}
		ds_map_destroy(_resources);
	};
}