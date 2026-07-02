class_name WaveConfig
extends Resource

@export var min_enemy_count: int = 10
@export var max_enemy_count: int = 20
@export var base_weights: Array[EnemyWeight] = []
@export var milestone_weights: Array[EnemyWeight] = []
@export var duration: float = 60.0
@export var arena_radius: float = 10.0

func get_weights(is_milestone: bool) -> Dictionary[Enums.EnemyType, float]:
	var dict: Dictionary[Enums.EnemyType, float] = {}
	var target_list: Array[EnemyWeight] = milestone_weights if is_milestone else base_weights
	for entry: EnemyWeight in target_list:
		dict[entry.type] = entry.weight
	
	return dict
