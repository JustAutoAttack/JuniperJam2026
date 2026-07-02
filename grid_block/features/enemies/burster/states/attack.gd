# Attack
extends EnemyState

@export var mesh_instance: MeshInstance3D
@export_category("Configs")
@export var long_windup: float = 0.8
@export var short_windup: float = 0.3
@export var recovery_time: float = 0.4
@export var total_shots: int = 3

# ===
# Built-In
# ===

func enter(_prev_state_path: String, _data: Object) -> void:
	_owner.disable_movement()
	_perform_attack_sequence()

# ===
# Private
# ===

func _perform_attack_sequence() -> void:
	var data: EnemyData = get_owner_data()
	if not data: return
	
	# Long Prep
	await _squish_tween(
		Vector3(
			1.2, 
			0.4, 
			1.2
		), 
		long_windup
	)
	
	# Fire shots with short prep/reset in between
	for i: int in range(total_shots):
		_fire_projectile()
		
		if i < total_shots - 1:
			if not _is_player_in_range(data): break
			
			await _squish_tween(
				Vector3(
					1.1, 
					0.7, 
					1.1
				), 
				short_windup / 2
			)
			await _squish_tween(
				Vector3.ONE, 
				short_windup / 2
			)
	
	# Recovery
	await _squish_tween(
		Vector3.ONE, 
		recovery_time
	)

	# Chase
	_transition_to(
		StateName.CHASE, 
		null
	)

func _squish_tween(
	target_scale: Vector3, 
	duration: float
) -> Signal:
	var tween: Tween = create_tween()
	tween.tween_property(
		mesh_instance, 
		"scale", 
		target_scale, 
		duration
	).set_trans(
		Tween.TRANS_SINE
	)
	
	return tween.finished

func _fire_projectile() -> void:
	var player: Player = get_player()
	if not player: return
	
	EventBus.emit(
		AudioEvent.PlaySFX.new(
			Enums.SFXType.BURSTER_SHOT
		)
	)
	EventBus.emit(
		WorldEvent.SpawnBursterProjectile.new(
			_owner.global_position,
			player.global_position,
			_owner.scaled_attack_damage
		)
	)

func _is_player_in_range(data: EnemyData) -> bool:
	var player: Player = get_player()
	if not player: return false
	
	return _owner.global_position.distance_to(player.global_position) <= data.attack_radius
