class_name ObjectPool
extends RefCounted

var scene: PackedScene
var parent_node: Node
var min_size: int = 20

var _pool: Array[Node] = []
var _active: Array[Node] = []

# ===
# Built-In
# ===

func _init(
	p_scene: PackedScene, 
	p_parent_node: Node, 
	p_min_size: int = 20
) -> void:
	scene = p_scene
	parent_node = p_parent_node
	min_size = p_min_size
	print_debug(scene, parent_node, min_size)
	
	for i in range(p_min_size):
		_add_to_pool()
	

# ===
# Public
# ===

func get_active_instances() -> Array[Node]:
	return _active.duplicate()

func get_instance() -> Node:
	if _pool.is_empty():
		_add_to_pool()
	
	var instance: Node = _pool.pop_back()
	instance.process_mode = Node.PROCESS_MODE_INHERIT
	instance.visible = true
	_active.append(instance)
	
	return instance

func return_instance(instance: Node) -> void:
	if _active.has(instance):
		_active.erase(instance)
	
	instance.process_mode = Node.PROCESS_MODE_DISABLED
	instance.visible = false
	_pool.append(instance)

func clear() -> void:
	for node: Node in _pool:
		if is_instance_valid(node):
			node.queue_free()
	_pool.clear()
	_active.clear()

func cleanup_unused_objects() -> void:
	if _pool.size() <= min_size:
		return
		
	while _pool.size() > min_size:
		print_debug(_pool.size())
		var node: Node = _pool.pop_back()
		if is_instance_valid(node):
			node.queue_free()

# ===
# Private
# ===

func _add_to_pool() -> void:
	var instance: Node = scene.instantiate()
	instance.process_mode = Node.PROCESS_MODE_DISABLED
	instance.visible = false
	parent_node.add_child(instance)
	if instance.has_method("deactivate"):
		instance.deactivate()

	_pool.append(instance)
