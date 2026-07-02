class_name WorldContext
extends Context

# ===
# Runtime
# ===

# ===
# Persistent
# ===

# --- Time ---
signal time_updated(value: float)
var _time: float
var time: float:
	get: return _time
	set(value):
		if _authorize_write():
			_time = value
			time_updated.emit(value)

# --- CPU Time ---
signal cpu_time_updated(value: float)
var _cpu_time: float
var cpu_time: float:
	get: return _cpu_time
	set(value):
		if _authorize_write():
			_cpu_time = value
			cpu_time_updated.emit(value)

# --- Wave ---
signal wave_updated(value: int)
var _wave: int
var wave: int:
	get: return _wave
	set(value):
		if _authorize_write():
			_wave = value
			print_debug(value)
			wave_updated.emit(value)

signal wave_time_updated(value: float)
var _wave_time: float
var wave_time: float:
	get: return _wave_time
	set(value):
		if _authorize_write():
			_wave_time = value
			wave_time_updated.emit(value)

signal arena_radius_updated(value: float)
var _arena_radius: float
var arena_radius: float:
	get: return _arena_radius
	set(value):
		if _authorize_write():
			_arena_radius = value
			arena_radius_updated.emit(value)

signal arena_center_updated(value: Vector3)
var _arena_center: Vector3
var arena_center: Vector3:
	get: return _arena_center
	set(value):
		if _authorize_write():
			_arena_center = value
			arena_center_updated.emit(value)

# --- Total Enemies --- # FIXME EnemyType : Array[Vector3]
signal total_enemies_updated(value: int)
var _total_enemies: int
var total_enemies: int:
	get: return _total_enemies
	set(value):
		if _authorize_write():
			_total_enemies = value
			total_enemies_updated.emit(value)

# --- Ratings ---
signal score_updated(value: int)
var _score: int
var score: int:
	get: return _score
	set(value):
		if _authorize_write():
			_score = value
			score_updated.emit(value)

signal enemies_killed_updated(value: int)
var _enemies_killed: int
var enemies_killed: int:
	get: return _enemies_killed
	set(value):
		if _authorize_write():
			_enemies_killed = value
			enemies_killed_updated.emit(value)

# ===
# Built-In
# ===

func _init() -> void:
	reset()

func reset() -> void:
	_time = 0.0
	_cpu_time = 0.0
	
	_wave = 0
	wave_updated.emit(wave)
	
	_wave_time = 0.0
	wave_time_updated.emit(wave_time)
	
	_arena_radius = 0.0
	_arena_center = Vector3.ZERO
	
	_total_enemies = 0
	_score = 0
	score_updated.emit(score)
	
	_enemies_killed = 0
	enemies_killed_updated.emit(enemies_killed)
