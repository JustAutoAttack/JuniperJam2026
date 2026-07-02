class_name PlayerContext
extends Context

# ===
# Runtime
# ===

# --- Player Instance ---
signal player_insance_updated(value: Player)
var _player_instance: Player
var player_instance: Player:
	get: return _player_instance
	set(value):
		if _authorize_write():
			_player_instance = value
			player_insance_updated.emit(value)

# ===
# Persistent
# ===

# --- World Location ---
signal world_location_updated(value: Vector3)
var _world_location: Vector3
var world_location: Vector3:
	get: return _world_location
	set(value):
		if _authorize_write():
			_world_location = value
			world_location_updated.emit(value)

# --- Combat ---
signal current_health_updated(value: float)
var _current_health: float
var current_health: float:
	get: return _current_health
	set(value):
		if _authorize_write():
			_current_health = value
			current_health_updated.emit(value)

signal current_shield_count_updated(value: int)
var _current_shield_count: int
var current_shield_count: int:
	get: return _current_shield_count
	set(value):
		if _authorize_write():
			_current_shield_count = value
			current_shield_count_updated.emit(value)

signal current_shield_regen_updated(value: float)
var _current_shield_regen: float
var current_shield_regen: float:
	get: return _current_shield_regen
	set(value):
		if _authorize_write():
			_current_shield_regen = value
			current_shield_regen_updated.emit(value)

# --- XP & Level ---
signal xp_updated(value: float)
var _xp: float
var xp: float: 
	get: return _xp
	set(value): 
		if _authorize_write():
			_xp = value
			xp_updated.emit(value)

signal level_updated(value: int)
var _level: int
var level: int: 
	get: return _level
	set(value): 
		if _authorize_write():
			_level = value
			level_updated.emit(value)

# --- Upgrades ---
signal pending_upgrades_updated(value: int)
var _pending_upgrades: int
var pending_upgrades: int: 
	get: return _pending_upgrades
	set(value): 
		if _authorize_write():
			_pending_upgrades = value
			pending_upgrades_updated.emit(value)

signal owned_upgrades_updated(upgrades: Dictionary[Enums.UpgradeType, Enums.UpgradeTierLevel])
var _owned_upgrades: Dictionary[Enums.UpgradeType, Enums.UpgradeTierLevel] = {}
var owned_upgrades: Dictionary[Enums.UpgradeType, Enums.UpgradeTierLevel]:
	get: return _owned_upgrades
	set(value):
		if _authorize_write():
			_owned_upgrades = value
			owned_upgrades_updated.emit(value)

# ===
# Built-In
# ===

func _init() -> void:
	reset()

func reset() -> void:
	_player_instance = null
	player_insance_updated.emit(player_instance)
	
	_world_location = Vector3.ZERO
	world_location_updated.emit(world_location)
	
	_current_health = 0.0
	world_location_updated.emit(world_location)
	
	_current_shield_count = 0
	current_shield_count_updated.emit(current_shield_count)
	
	_current_shield_regen = 0
	current_shield_regen_updated.emit(current_shield_regen)
	
	_xp = 0.0
	xp_updated.emit(xp)
	
	_level = 1
	level_updated.emit(level)
	
	_pending_upgrades = 0
	pending_upgrades_updated.emit(pending_upgrades)
	
	reset_owned_upgrades()

func reset_owned_upgrades() -> void:
	_owned_upgrades = {}
	owned_upgrades_updated.emit(_owned_upgrades)
