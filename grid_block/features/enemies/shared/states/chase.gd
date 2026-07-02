# Chase
extends EnemyState

# ===
# Built-In
# ===

func enter(_prev_state_path: String, _data: Object) -> void:
	_owner.enable_movement()

func physics_update(delta: float) -> void:
	var player: Player = get_player()
	if not player: return
	
	var data: EnemyData = get_owner_data()
	if not data: return
	
	var distance_to_player: float = _owner.global_position.distance_to(player.global_position)
	
	# Attack
	if distance_to_player <= data.attack_radius:
		_transition_to(
			StateName.ATTACK, 
			null
		)
		return
	
	# Too far, so move closer
	if distance_to_player > data.attack_radius:
		_owner.move_towards_player(
			data.movement_speed, 
			delta
		)
	
	# Too close, so back up
	elif distance_to_player < (data.attack_radius * 0.5):
		_owner.move_away_from_player(
			data.movement_speed * 0.5, 
			delta
		)
