class_name WorldWaveController
extends Node

@export var arena_ring: WorldArenaRing

@export_category("Configs")
@export var wave_configs: Array[WaveConfig] = []
@export var max_active_enemies: int = 100

var _current_active_enemies: int = 0
var _current_wave_index: int = 0
var _timer: float = 0.0
var _spawn_interval: float = 0.0
var _remaining_budget: int = 0
var _active_weights: Dictionary[Enums.EnemyType, float] = {}

# ===
# Built-In
# ===

func _ready() -> void:
	_subscribe()

func _process(delta: float) -> void:
	# Handle active spawning phase
	if _remaining_budget > 0:
		var new_wave_time: float = Session.world_context.wave_time - delta
		
		# If timer hits zero, force-end the spawning phase
		if new_wave_time <= 0.0:
			Session.world_provider.set_wave_time(0.0)
			_remaining_budget = 0
		else:
			Session.world_provider.set_wave_time(new_wave_time)
			
			_timer += delta
			if _timer >= _spawn_interval:
				_timer = 0.0
				_spawn_enemy()
	
	# Handle wave end transition
	elif _remaining_budget <= 0 and _timer != -1.0:
		_timer = -1.0
		EventBus.emit(
			WorldEvent.WaveEnded.new(
				_current_wave_index + 1
			)
		)

func _exit_tree() -> void:
	_unsubscribe()

# ===
# Private
# ===

func _subscribe() -> void:
	EventBus.subscribe(WorldEvent.StartNextWave, _handle_start_next_wave)
	EventBus.subscribe(WorldEvent.EnemyDied, _handle_enemy_died)

func _unsubscribe() -> void:
	EventBus.unsubscribe(WorldEvent.StartNextWave, _handle_start_next_wave)
	EventBus.unsubscribe(WorldEvent.EnemyDied, _handle_enemy_died)

func _start_wave(index: int) -> void:
	_current_wave_index = index
	var wave_num: int = index + 1
	
	var milestone_index: int = (wave_num - 1) / 5
	var config_idx = clamp(milestone_index, 0, wave_configs.size() - 1)
	var config: WaveConfig = wave_configs[config_idx]
	
	# Calculate target enemy count based on progress within the 5-wave block
	var wave_in_block: float = float((wave_num - 1) % 5)
	var progress: float = wave_in_block / 4.0
	
	_remaining_budget = int(lerp(
		float(config.min_enemy_count), 
		float(config.max_enemy_count), 
		progress
	))
	
	# Calculate spawn interval (Duration / total enemies to spawn)
	_spawn_interval = config.duration / max(float(_remaining_budget), 1.0)
	
	# Setup state
	var is_milestone: bool = (wave_num % 5 == 0)
	_active_weights = config.get_weights(is_milestone)
	arena_ring.radius = config.arena_radius
	Session.world_provider.set_arena_radius(config.arena_radius)
	
	# Reset timers and state
	_timer = 0.0
	Session.world_provider.set_wave_time(config.duration)
	
	EventBus.emit(
		WorldEvent.WaveStarted.new(
			wave_num
		)
	)

func _spawn_enemy() -> void:
	if _current_active_enemies >= max_active_enemies: return
		
	_remaining_budget -= 1 
	_current_active_enemies += 1
	
	var enemy_type: Enums.EnemyType = _select_enemy_by_weight(_active_weights)
	
	var config: WaveConfig = wave_configs[min(
		_current_wave_index / 5,
		wave_configs.size() - 1
	)]
	
	var angle: float = randf() * TAU
	var spawn_pos: Vector3 = Vector3(
		cos(angle), 
		0, 
		sin(angle)
	) * config.arena_radius
	
	EventBus.emit(
		WorldEvent.SpawnEnemy.new(
			enemy_type, 
			spawn_pos
		)
	)

func _select_enemy_by_weight(weights: Dictionary) -> Enums.EnemyType:
	var total_weight: float = 0.0
	for w in weights.values(): 
		total_weight += w
		
	var roll: float = randf() * total_weight
	var current: float = 0.0
	
	for type in weights:
		current += weights[type]
		if roll <= current: 
			return type as Enums.EnemyType
			
	return Enums.EnemyType.BLOCKER

# ===
# Events
# ===

func _handle_start_next_wave(_event: WorldEvent.StartNextWave) -> void:
	var next_wave_count: int = Session.world_context.wave
	_start_wave(next_wave_count - 1)

func _handle_enemy_died(_event: WorldEvent.EnemyDied) -> void:
	_current_active_enemies -= 1
