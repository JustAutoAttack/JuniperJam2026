# Unused
extends EnemyState

@export var default_state: EnemyState.StateName

func enter(_prev_state_path: String, _data: Object) -> void:
	_transition_to(
		default_state,
		null
	)
