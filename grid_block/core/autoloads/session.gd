extends Node

# Runtime
var game_version: String = ""
var build_type: String = ""
var full_version_string: String = ""
var did_bootsplash: bool = false
var is_in_world: bool = false

# Context
var settings_context: SettingsContext
var game_context: GameContext
var ui_context: UIContext
var world_context: WorldContext
var player_context: PlayerContext

# Providers
var save_provider: SaveProvider
var settings_provider: SettingsProvider
var game_provider: GameProvider
var ui_provider: UIProvider
var world_provider: WorldProvider
var player_provider: PlayerProvider

# ===
# Built-In
# ===

func _init() -> void:
	AssetProvider.setup_cache()
	_setup_version()
	_setup_context()
	_setup_providers()

# ===
# Public
# ===

## For reseting the session as if we just opened the client
func reset() -> void:
	AssetProvider.clear_cache()
	AssetProvider.setup_cache()
	did_bootsplash = false
	is_in_world = false
	_setup_version()
	_setup_context()
	_setup_providers()

## For reseting the gameplay states
func reset_game() -> void:
	world_provider.reset()
	player_provider.reset()

# ===
# Private
# ===

func _setup_version() -> void:
	game_version = ProjectSettings.get_setting("application/config/version", "0.0.1")
	build_type = "development" if OS.has_feature("editor") else "release"
	full_version_string = "v%s_%s" % [game_version, build_type]

func _setup_context() -> void:
	settings_context = SettingsContext.new()
	game_context = GameContext.new()
	ui_context = UIContext.new()
	world_context = WorldContext.new()
	player_context = PlayerContext.new()

func _setup_providers() -> void:
	save_provider = SaveProvider.new(
		settings_context,
		player_context, 
		world_context,
	)
	
	settings_provider = SettingsProvider.new(
		settings_context
	)
	
	game_provider = GameProvider.new(
		game_context
	)

	ui_provider = UIProvider.new(
		ui_context
	)
	
	world_provider = WorldProvider.new(
		world_context
	)
	
	player_provider = PlayerProvider.new(
		player_context
	)
