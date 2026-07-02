class_name GameSceneController
extends Node

var current_scene: Node

# ===
# Built-In
# ===

func _ready() -> void:
	_subscribe()

func _exit_tree() -> void:
	_unsubscribe()

# ===
# Private
# ===

func _subscribe() -> void:
	EventBus.subscribe(GameEvent.LoadTitle, _handle_load_title_scene)
	EventBus.subscribe(GameEvent.LoadWorld, _handle_load_world_scene)

func _unsubscribe() -> void:
	EventBus.unsubscribe(GameEvent.LoadTitle, _handle_load_title_scene)
	EventBus.unsubscribe(GameEvent.LoadWorld, _handle_load_world_scene)

func _replace_current(new: Node) -> void:
	if current_scene:
		current_scene.queue_free()
		current_scene = null
	
	current_scene = new
	add_child(current_scene)

# ===
# Events
# ===

func _handle_load_title_scene(_event: GameEvent.LoadTitle) -> void:
	var scene: Title = AssetProvider.get_title_scene()
	_replace_current(scene)

func _handle_load_world_scene(_event: GameEvent.LoadWorld) -> void:
	var scene: World = AssetProvider.get_world_scene()
	_replace_current(scene)
