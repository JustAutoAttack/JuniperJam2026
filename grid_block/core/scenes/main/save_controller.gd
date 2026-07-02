class_name SaveController
extends Node

var settings_data: SettingsSaveData
var game_data: GameSaveData

# ===
# Built-In
# ===

func _ready() -> void:
	# Load Settings
	settings_data = Session.save_provider.load_settings(
		Constants.DataPaths.USER_SETTINGS_SAVE
	)

	_subscribe()

func _exit_tree() -> void:
	_unsubscribe()

# ===
# Public
# ===

# ===
# Private
# ===

func _subscribe() -> void:
	EventBus.subscribe(GameEvent.SaveSettings, _handle_save_settings)
	EventBus.subscribe(GameEvent.SaveGame, _handle_save_game)
	EventBus.subscribe(GameEvent.GameLoaded, _handle_game_loaded)

func _unsubscribe() -> void:
	EventBus.unsubscribe(GameEvent.SaveSettings, _handle_save_settings)
	EventBus.unsubscribe(GameEvent.SaveGame, _handle_save_game)
	EventBus.unsubscribe(GameEvent.GameLoaded, _handle_game_loaded)

func _save_game() -> void:
	print_debug("saving game")
	EventBus.emit(
		UIEvent.StartSaving.new()
	)
	Session.save_provider.save_game(
		game_data, 
		true
	)
	get_tree().create_timer(3.0).timeout.connect(
		func():
			EventBus.emit(
				UIEvent.StopSaving.new()
			)
	)


# ===
# Events
# ===

func _handle_save_settings(_event: GameEvent.SaveSettings) -> void:
	print_debug("saving settings")
	Session.save_provider.save_settings(settings_data)

func _handle_save_game(_event: GameEvent.SaveGame) -> void:
	_save_game()

func _handle_game_loaded(event: GameEvent.GameLoaded) -> void:
	game_data = event.data.duplicate(true)

# ===
# Signals
# ===
