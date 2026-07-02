class_name SaveProvider
extends ContextProvider

var settings_context: SettingsContext
var player_context: PlayerContext
var world_context: WorldContext

# ===
# Built-In
# ===

func _init(
	p_settings: SettingsContext,
	p_player: PlayerContext, 
	p_world: WorldContext,
) -> void:
	settings_context = p_settings
	player_context = p_player
	world_context = p_world
	ensure_settings_file_exists()

# ===
# Public
# ===

# --- Game ---
func save_game(data: GameSaveData, is_autosave: bool) -> void:
	# Update
	_game_to_data(data)
	
	# Write
	var dir: String = Constants.DataPaths.USER_GAME_AUTOSAVES_DIR if is_autosave else Constants.DataPaths.USER_GAME_SAVES_DIR
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	var filename: String = _current_timestamp() + ".tres"
	var path: String = dir + filename
	var error: int = ResourceSaver.save(data, path)
	
	# Notify
	if error != OK:
		_error_failed_to_save(error)

func load_new_game() -> GameSaveData:
	return load_game(Constants.DataPaths.NEW_GAME_SAVE)

func load_game(path: String) -> GameSaveData:
	# Read
	var data: GameSaveData = AssetLoader.load_resource(
		path, 
		GameSaveData
	) as GameSaveData
	
	# Contingency
	if not data:
		_warn_no_save_at_path(path)
		data = AssetProvider.get_new_game_save_data()
		_game_to_data(data)
		save_game(data, false)
	
	# Update
	_data_to_game(data)
	return data
	
# --- Settings ---
func ensure_settings_file_exists() -> void:
	if FileAccess.file_exists(Constants.DataPaths.USER_SETTINGS_SAVE):
		return

	var data: SettingsSaveData = AssetProvider.get_default_settings_save_data()
	_settings_to_data(data)

	var dir: String = Constants.DataPaths.USER_SETTINGS_SAVE.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)

	var error: int = ResourceSaver.save(
		data, 
		Constants.DataPaths.USER_SETTINGS_SAVE
	)
	if error != OK:
		push_error("SaveProvider: Failed to create default settings file.")

func save_settings(data: SettingsSaveData) -> void:
	# Update
	_settings_to_data(data)

	# Write
	var error: int = ResourceSaver.save(
		data,
		Constants.DataPaths.USER_SETTINGS_SAVE
	)
	
	# Notify
	if error != OK:
		_error_failed_to_save(error)

func load_settings(path: String) -> SettingsSaveData:
	var data: SettingsSaveData = AssetLoader.load_resource(
		path,
		SettingsSaveData
	) as SettingsSaveData

	if not data:
		_warn_no_save_at_path(path)
		data = AssetProvider.get_default_settings_save_data()
		_settings_to_data(data)
		save_settings(data)

	_data_to_settings(data)
	return data

# ===
# Private
# ===

func _game_to_data(data: GameSaveData) -> void:
	# --- Player ---
	data.player_world_location = player_context.world_location
	data.player_current_health = player_context.current_health
	data.player_xp = player_context.xp
	data.player_level = player_context.level
	data.player_pending_upgrades = player_context.pending_upgrades
	data.player_owned_upgrades = player_context.owned_upgrades.duplicate(true)
	
	# --- World ---
	data.world_time = world_context.time
	data.world_cpu_time = world_context.cpu_time
	data.world_wave = world_context.wave
	data.world_total_enemies = world_context.total_enemies

func _data_to_game(data: GameSaveData) -> void:
	# --- Player ---
	player_context.world_location = data.player_world_location
	player_context.current_health = data.player_current_health
	player_context.xp = data.player_xp
	player_context.level = data.player_level
	player_context.pending_upgrades = data.player_pending_upgrades
	player_context.owned_upgrades = data.player_owned_upgrades.duplicate(true)
	
	# --- World ---
	world_context.time = data.world_time
	world_context.cpu_time = data.world_cpu_time
	world_context.wave = data.world_wave
	world_context.total_enemies = data.world_total_enemies

func _settings_to_data(data: SettingsSaveData) -> void:
	# Audio
	data.master_volume = settings_context.master_volume
	data.music_volume = settings_context.music_volume
	data.sfx_volume = settings_context.sfx_volume
	data.muted_buses = settings_context.muted_buses
	
	# Controls
	data.controller_sensitivity_x = settings_context.controller_sensitivity_x
	data.controller_sensitivity_y = settings_context.controller_sensitivity_y

func _data_to_settings(data: SettingsSaveData) -> void:
	# Audio
	settings_context.master_volume = data.master_volume
	settings_context.music_volume = data.music_volume
	settings_context.sfx_volume = data.sfx_volume
	settings_context.muted_buses = data.muted_buses
	
	# Controls
	settings_context.controller_sensitivity_x = data.controller_sensitivity_x
	settings_context.controller_sensitivity_y = data.controller_sensitivity_y

func _current_timestamp() -> String:
	var dt: Dictionary = Time.get_datetime_dict_from_system(true)
	
	return (
		"%04d%02d%02d_%02d%02d%02d_%03d"
		% [
			dt.year,
			dt.month,
			dt.day,
			dt.hour,
			dt.minute,
			dt.second,
			Time.get_ticks_msec() % 1000
		]
	)

func _warn_no_save_at_path(path: String) -> void:
	push_warning(
		"Save Provider: No save data found at path ({0}). Creating new entry."
		.format([path])
	)

func _error_failed_to_save(error: int) -> void:
	push_error(
		"SaveProvider: Failed to save. \nError: {0}"
		.format([error_string(error)])
	)

func _error_failed_to_load(path: String) -> void:
	push_error("SaveProvider: Failed to load. Path: %s" % path)
