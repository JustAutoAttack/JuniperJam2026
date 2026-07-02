class_name SettingsContext
extends Context

# ===
# Persistent
# ===

# --- Master Volume ---
signal master_volume_updated(value: float)
var _master_volume: float
var master_volume: float:
	get: return _master_volume
	set(value):
		if _authorize_write():
			_master_volume = value
			master_volume_updated.emit(value)

# --- Music Volume ---
signal music_volume_updated(value: float)
var _music_volume: float
var music_volume: float:
	get: return _music_volume
	set(value):
		if _authorize_write():
			_music_volume = value
			music_volume_updated.emit(value)

# --- SFX Volume ---
signal sfx_volume_updated(value: float)
var _sfx_volume: float
var sfx_volume: float:
	get: return _sfx_volume
	set(value):
		if _authorize_write():
			_sfx_volume = value
			sfx_volume_updated.emit(value)

# --- Muted Buses ---
signal muted_buses_updated(value: int)
var _muted_buses: int
var muted_buses: int:
	get: return _muted_buses
	set(value):
		if _authorize_write():
			_muted_buses = value
			muted_buses_updated.emit(value)

# --- Controller Sensitivity X ---
signal controller_sensitivity_x_updated(value: float)
var _controller_sensitivity_x: float
var controller_sensitivity_x: float:
	get: return _controller_sensitivity_x
	set(value):
		if _authorize_write():
			_controller_sensitivity_x = value
			controller_sensitivity_x_updated.emit(value)

# --- Controller Sensitivity Y ---
signal controller_sensitivity_y_updated(value: float)
var _controller_sensitivity_y: float
var controller_sensitivity_y: float:
	get: return _controller_sensitivity_y
	set(value):
		if _authorize_write():
			_controller_sensitivity_y = value
			controller_sensitivity_y_updated.emit(value)

# ===
# Built-In
# ===

func _init() -> void:
	reset()

func reset() -> void:
	# Audio
	_master_volume = 1.0
	_music_volume = 1.0
	_sfx_volume = 1.0
	_muted_buses = 0

	# Controls
	_controller_sensitivity_x = 1.0
	_controller_sensitivity_y = 1.0
