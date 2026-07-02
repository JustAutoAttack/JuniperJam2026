class_name AssetLoader
extends RefCounted

## Loads a resource and validates its type.
static func load_resource(
	path: String, 
	expected_type: Object
) -> Resource:
	if path.is_empty():
		push_warning(
			"AssetLoader: No path defined for type: {0}"
			.format([expected_type])
		)
		return null
	## Immediate path validation
	#if not OS.has_feature("web"):
		#if (
			#path.is_empty() or 
			#not FileAccess.file_exists(path)
		#):
			#push_error(
				#"AssetLoader: File does not exist at path: '{0}'"
				#.format([path])
			#)
			#return null

	# Attempt load
	var data: Variant = ResourceLoader.load(
		path, 
		"", 
		ResourceLoader.CACHE_MODE_REPLACE
	)
	
	# Type validation
	if not is_instance_of(data, expected_type):
		push_error(
			"AssetLoader: Type mismatch at '{0}'. Expected {1}."
			.format([path, expected_type])
		)
		return null
		
	return data

## Helper to fetch a path from a dictionary with validation.
static func get_path_from_table(
	type: int, 
	table: Dictionary, 
	enum_keys: Array
) -> String:
	var path: String = table.get(type, "")
	if path.is_empty():
		push_warning(
			"AssetLoader: No path defined for type: {0}"
			.format([enum_keys[type]])
		)
		return ""
	
	return path

## Loads a resource based on a type index from a dictionary.
static func load_resource_from_table(
	type: int, 
	table: Dictionary, 
	enum_keys: Array, 
	expected_type: Object
) -> Resource:
	var path: String = get_path_from_table(
		type, 
		table, 
		enum_keys
	)
	if path.is_empty(): return null
	
	return load_resource(
		path, 
		expected_type
	)

## Load the PackedScene directly without instantiating it.
static func load_packed_scene(path: String) -> PackedScene:
	var packed_scene: PackedScene = ResourceLoader.load(
		path
	) as PackedScene
	if not packed_scene:
		push_error("AssetLoader: Failed to load scene at: " + path)
		return null
	return packed_scene

## Instantiates a scene directly from a file path.
static func load_scene(
	path: String, 
	expected_base_class: Script
) -> Node:
	var packed_scene: PackedScene = load_resource(
		path, 
		PackedScene
	) as PackedScene
	if not packed_scene: return null
	
	var instance: Node = packed_scene.instantiate()
	
	if not is_instance_of(instance, expected_base_class):
		push_error(
			"AssetLoader: Scene at '{0}' does not inherit from expected class."
			.format([path])
		)
		instance.queue_free()
		return null
		
	return instance

## Instantiates a scene from a dictionary, ensuring it inherits from the expected class.
static func load_scene_from_table(
	type: int, 
	table: Dictionary, 
	enum_keys: Array, 
	expected_base_class: Script
) -> Node:
	var path: String = get_path_from_table(
		type, 
		table, 
		enum_keys
	)
	if path.is_empty(): return null
	
	return load_scene(
		path, 
		expected_base_class
	)
