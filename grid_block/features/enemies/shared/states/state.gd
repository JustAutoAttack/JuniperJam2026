class_name EnemyState
extends State

enum StateName { 
	CHASE, 
	PATROL,
	ATTACK 
}

var _owner: Enemy
var _owner_data: EnemyData
var _player: Player

# ===
# Built-In
# ===

func _ready() -> void:
	_owner = get_owner() as Enemy

# ===
# Public
# ===

func get_player() -> Player:
	if (
		not _player and
		Session.player_context.player_instance
	):
		_player = Session.player_context.player_instance
	
	return _player

func get_owner_data() -> EnemyData:
	if (
		not _owner_data and 
		_owner
	):
		_owner_data = _owner._data
	
	return _owner_data

func get_state_name(state: StateName) -> String:
	return StateName.keys()[state].capitalize()

# ===
# Private
# ===

func _transition_to(state: StateName, data: Object) -> void:
	finished.emit(get_state_name(state), data)
