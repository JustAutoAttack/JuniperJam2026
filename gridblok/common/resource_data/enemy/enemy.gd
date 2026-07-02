class_name EnemyData
extends Resource

@export_category("Identity")
@export var type: Enums.EnemyType
@export var display_name: String = ""
@export var primary_color: Color = Color.WHITE
@export var secondary_color: Color = Color.WHITE

@export_category("Rewards")
@export var points: int = 0
@export var xp: float = 0.0

@export_category("Combat")
@export var movement_speed: float = 0.0
@export var attack_radius: float = 0.0
@export var attack_damage: float = 0.0
@export var attack_speed: float = 1.0
@export var health: float = 0.0
@export var body_damage: float = 0.0

func get_scaled(
	base_value: float, 
	wave: int
) -> float:
	return base_value * (1.0 + (wave * 0.1))

func get_scaled_xp(
	wave: int
) -> float:
	return xp * (1.0 + (wave * 0.05))
