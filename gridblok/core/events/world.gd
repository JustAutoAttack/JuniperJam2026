class_name WorldEvent
extends Event

# --- Player ---
class SpawnPlayer extends WorldEvent:
	
	var world_location: Vector3
	var rotation: Vector3
	
	func _init(
		p_world_location: Vector3, 
		p_rotation: Vector3
	) -> void:
		world_location = p_world_location
		rotation = p_rotation

class PlayerSpawned extends WorldEvent: 
	
	var player: Player
	
	func _init(
		p_player: Player
	) -> void:
		player = p_player

class PlayerLeveled extends WorldEvent:
	
	var new_level: int
	
	func _init(
		p_new_level: int
	) -> void:
		new_level = p_new_level

class PlayerDied extends WorldEvent:
	
	var killer: Node3D
	
	func _init(
		p_killer: Node3D
	) -> void:
		killer = p_killer

# --- Enemy ---
class SpawnEnemy extends WorldEvent:
	
	var enemy_type: Enums.EnemyType
	var world_location: Vector3
	
	func _init(
		p_enemy_type: Enums.EnemyType,
		p_world_location: Vector3
	) -> void:
		enemy_type = p_enemy_type
		world_location = p_world_location

class EnemySpawned extends WorldEvent:
	
	var enemy_type: Enums.EnemyType
	
	func _init(
		p_enemy_type: Enums.EnemyType,
	) -> void:
		enemy_type = p_enemy_type

class EnemyDied extends WorldEvent:
	
	var enemy_type: Enums.EnemyType
	var world_location: Vector3
	
	func _init(
		p_enemy_type: Enums.EnemyType,
		p_world_location: Vector3
	) -> void:
		enemy_type = p_enemy_type
		world_location = p_world_location

# --- Burster Projectile ---
class SpawnBursterProjectile extends WorldEvent:
	
	var origin: Vector3
	var destination: Vector3
	var damage: float
	
	func _init(
		p_origin: Vector3,
		p_destination: Vector3,
		p_damage: float
	) -> void:
		origin = p_origin
		destination = p_destination
		damage = p_damage

# --- XP ---
class SpawnXPItem extends WorldEvent:
	
	var value: float
	var world_location: Vector3
	
	func _init(
		p_value: float, 
		p_world_location: Vector3
	) -> void:
		value = p_value
		world_location = p_world_location

class XPItemCollected extends WorldEvent:
	
	var value: float
	
	func _init(
		p_value: float
	) -> void:
		value = p_value

# --- Debris ---
class SpawnDebris extends WorldEvent:
	
	var material: StandardMaterial3D
	var world_location: Vector3
	
	func _init(
		p_material: StandardMaterial3D,
		p_world_location: Vector3
	) -> void:
		material = p_material
		world_location = p_world_location

# --- Popup Label ---
class SpawnPopupLabel extends WorldEvent:
	
	var popup_type: Enums.PopupType
	var message: String
	var location: Vector3
	
	func _init(
		p_popup_type: Enums.PopupType,
		p_message: String,
		p_location: Vector3
	) -> void:
		popup_type = p_popup_type
		message = p_message
		location = p_location

# --- Wave ---
class StartNextWave extends WorldEvent: pass

class WaveStarted extends WorldEvent: 
	
	var count: int
	
	func _init(
		p_count: int
	) -> void:
		count = p_count

class WaveEnded extends WorldEvent:
	
	var count: int
	
	func _init(
		p_count: int
	) -> void:
		count = p_count
