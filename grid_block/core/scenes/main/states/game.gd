# Game
extends MainState

# ===
# Built-In
# ===

func enter(_prev_state_path: String, _data: Object) -> void:
	print_debug("Main: Enter GAME")
	
	_subscribe_events()
	EventBus.emit(
		MainEvent.LoadGame.new()
	)

func exit() -> void:
	_unsubscribe_events()
	print_debug("Main: Exit GAME")

func _subscribe_events() -> void:
	EventBus.subscribe(MainEvent.GameLoaded, _handle_game_loaded)
	EventBus.subscribe(UIEvent.SettingsMenu, _handle_ui_settings_menu)

func _unsubscribe_events() -> void:
	EventBus.unsubscribe(MainEvent.GameLoaded, _handle_game_loaded)
	EventBus.unsubscribe(UIEvent.SettingsMenu, _handle_ui_settings_menu)

# ===
# Events
# ===

func _handle_game_loaded(_event: MainEvent.GameLoaded) -> void:
	print_debug("Main: Game Loaded")

func _handle_ui_settings_menu(event: UIEvent.SettingsMenu) -> void:
	match event.action:
		Enums.SettingsMenuAction.SAVE:
			EventBus.emit(
				GameEvent.SaveSettings.new()
			)
