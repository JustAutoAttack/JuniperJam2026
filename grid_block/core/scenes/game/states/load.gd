# Load
extends GameState

@export var object_controller: GameObjectController

var _is_first_load: bool = true
var _data: GameLoadStateData

# ===
# Built-In
# ===

func _ready() -> void:
	super()
	if not object_controller:
		push_error("Game: LOAD -> GameObjectController not assigned!")
		return

func enter(_prev_state_path: String, data: Object) -> void:
	print_debug("Game: Enter LOAD")
	_subscribe()
	EventBus.emit(
		UIEvent.StartLoading.new()
	)
	
	# Standardize data
	if _is_first_load:
		_is_first_load = false
		_data = GameLoadStateData.new(
			GameState.StateName.TITLE, 
			false, 
			""
		)
	elif data is GameLoadStateData:
		_data = data
	else:
		push_error("Game: LOAD - Invalid enter data. Going to TITLE.")
		_transition_to(
			StateName.TITLE,
			null
		)
		return
	
	_route_load()

func exit() -> void:
	_data = null
	EventBus.emit(
		UIEvent.StopLoading.new()
	)
	_unsubscribe()
	print_debug("Game: Exit LOAD")

func _subscribe() -> void:
	# Events
	EventBus.subscribe(GameEvent.TitleLoaded, _handle_scene_loaded)
	EventBus.subscribe(GameEvent.WorldLoaded, _handle_scene_loaded)
	
	# Signals
	object_controller.setup_complete.connect(_on_object_controller_setup_complete)

func _unsubscribe() -> void:
	EventBus.unsubscribe(GameEvent.TitleLoaded, _handle_scene_loaded)
	EventBus.unsubscribe(GameEvent.WorldLoaded, _handle_scene_loaded)
	object_controller.setup_complete.disconnect(_on_object_controller_setup_complete)

# ===
# Private
# ===

func _route_load() -> void:
	match _data.target_state:
		GameState.StateName.TITLE: 
			_load_title_sequence()
		GameState.StateName.WORLD: 
			if not object_controller.is_setup:
				_load_objects()
				return
			
			object_controller.deactivate_all_pools()
			_load_world_sequence()

func _load_objects() -> void:
	if not object_controller.is_node_ready():
		await object_controller.ready
		
	object_controller.setup_pools()

func _load_title_sequence() -> void:
	EventBus.emit(
		GameEvent.LoadTitle.new()
	)

func _load_world_sequence() -> void:
	# Game Save
	var game_save_data: GameSaveData
	if _data.is_new_game:
		game_save_data = Session.save_provider.load_new_game()
	else:
		game_save_data = Session.save_provider.load_game(
			_data.save_game_file_path
		)
	
	if not game_save_data:
		push_error("Game: LOAD - No save data. Loading Title")
		EventBus.emit(
			GameEvent.LoadTitle.new()
		)
		return
	
	# Finalize Loading
	EventBus.emit(
		GameEvent.GameLoaded.new(
			game_save_data
		)
	)
	
	await get_tree().process_frame
	EventBus.emit(
		GameEvent.LoadWorld.new()
	)

# ===
# Events
# ===

func _handle_scene_loaded(_event: GameEvent) -> void:
	_transition_to(
		_data.target_state, 
		null
	)

# ===
# Signals
# ===

func _on_object_controller_setup_complete() -> void:
	_route_load()
