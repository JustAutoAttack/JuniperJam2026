class_name World
extends Node3D

@onready var player_spawn: Marker3D = %PlayerSpawn
@onready var instances_controller: WorldInstancesController = %InstancesController

# ===
# Built-In
# ===

func _ready() -> void:
	_subscribe()

	# Spawn Player
	EventBus.emit(
		WorldEvent.SpawnPlayer.new(
			player_spawn.global_position,
			player_spawn.global_rotation
		)
	)

func _exit_tree() -> void:
	_unsubscribe()
	
# ===
# Private
# ===

func _subscribe() -> void:
	EventBus.subscribe(WorldEvent.PlayerSpawned, _handle_player_spawned)
	EventBus.subscribe(WorldEvent.PlayerDied, _handle_player_died)
	EventBus.subscribe(WorldEvent.WaveEnded, _handle_wave_ended)
	EventBus.subscribe(WorldEvent.EnemyDied, _handle_enemy_died)
	EventBus.subscribe(WorldEvent.XPItemCollected, _handle_xp_collected)

func _unsubscribe() -> void:
	EventBus.unsubscribe(WorldEvent.PlayerSpawned, _handle_player_spawned)
	EventBus.unsubscribe(WorldEvent.WaveEnded, _handle_wave_ended)
	EventBus.unsubscribe(WorldEvent.EnemyDied, _handle_enemy_died)
	EventBus.unsubscribe(WorldEvent.XPItemCollected, _handle_xp_collected)

# ===
# Events
# ===

func _handle_player_spawned(_event: WorldEvent.PlayerSpawned) -> void:
	# Notify World Loaded
	EventBus.emit(
		GameEvent.WorldLoaded.new()
	)

func _handle_player_died(_event: WorldEvent.PlayerDied) -> void:
	# Play SFX
	EventBus.emit(
		AudioEvent.PlaySFX.new(
			Enums.SFXType.PLAYER_DIED
		)
	)
	
	# Spawn Debris
	var debris_material: StandardMaterial3D = AssetProvider.get_player_debris_material()
	var player_position: Vector3 = Session.player_context.world_location
	EventBus.emit(
		WorldEvent.SpawnDebris.new(
			debris_material,
			player_position
		)
	)
	
	# Let that sink in
	# MAYBE Slow time somehow?
	get_tree().create_timer(2.0).timeout.connect(
		func():
			EventBus.emit(
				GameEvent.GameOver.new()
			)
	)

func _handle_wave_ended(_event: WorldEvent.WaveEnded) -> void:
	if not Session.is_in_world: return
	
	# Update Session
	Session.world_provider.set_wave(
		Session.world_context.wave + 1
	)
	
	# Start Next
	EventBus.emit(
		WorldEvent.StartNextWave.new()
	)

func _handle_enemy_died(event: WorldEvent.EnemyDied) -> void:
	var enemy_data: EnemyData = AssetProvider.get_enemy_data(
		event.enemy_type
	)
	
	# Update Session
	Session.world_provider.update_score(
		enemy_data.points
	)
	Session.world_provider.update_enemies_killed(
		1
	)
	
	# Play SFX
	#EventBus.emit(
		#AudioEvent.PlaySFX.new(
			#Enums.SFXType.ENEMY_DIED
		#)
	#)
	
	# Spawn XP
	EventBus.emit(
		WorldEvent.SpawnXPItem.new(
			enemy_data.get_scaled_xp(Session.world_context.wave),
			Vector3(
				event.world_location.x,
				0.0,
				event.world_location.z
			)
		)
	)
	
	# Spawn Debris
	var debris_material: StandardMaterial3D = AssetProvider.get_enemy_debris_material(
		event.enemy_type
	)
	EventBus.emit(
		WorldEvent.SpawnDebris.new(
			debris_material,
			event.world_location
		)
	)

func _handle_xp_collected(event: WorldEvent.XPItemCollected) -> void:
	var base_value: float = event.value
	var final_value: float = base_value
	
	# Percentage Gain
	var xp_gain_mult: float = Session.player_provider.get_total_stat(Enums.StatType.XP_GAIN)
	final_value *= (1.0 + xp_gain_mult)
	
	# Double Chance
	var double_chance: float = Session.player_provider.get_total_stat(Enums.StatType.XP_DOUBLE_CHANCE)
	if randf() <= double_chance:
		final_value *= 2.0
	
	# Update Session
	Session.player_provider.update_xp(
		final_value
	)
	
	EventBus.emit(
		AudioEvent.PlaySFX.new(
			Enums.SFXType.XP_COLLECTED
		)
	)
