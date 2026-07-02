class_name GameSaveData
extends Resource

@export_category("Player")
@export var player_world_location: Vector3 = Vector3.ZERO
@export var player_current_health: float = 0.0
@export var player_xp: float = 0.0
@export var player_level: int = 1
@export var player_pending_upgrades: int = 0
@export var player_owned_upgrades: Dictionary[Enums.UpgradeType, int] = {} 

@export_category("World")
@export_range(0.0, 1.0, 0.01) var world_time: float = 0.0
@export var world_cpu_time: float = 0.0
@export var world_wave: int = 0
@export var world_total_enemies: int = 0
