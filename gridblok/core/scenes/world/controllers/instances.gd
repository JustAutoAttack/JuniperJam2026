class_name WorldInstancesController
extends Node


@export var debris_material: StandardMaterial3D
@export var min_debris_spawned: int = 8
@export var max_debris_spawned: int = 12

@onready var player_container: Node = %Player

# ===
# Built-In
# ==

func _ready() -> void:
	_subscribe()

func _exit_tree() -> void:
	_unsubscribe()

# ===
# Private
# ===

func _subscribe() -> void:
	EventBus.subscribe(WorldEvent.SpawnPlayer, _handle_spawn_player)
	EventBus.subscribe(WorldEvent.SpawnEnemy, _handle_spawn_enemy)
	EventBus.subscribe(WorldEvent.SpawnXPItem, _handle_spawn_xp_item)
	EventBus.subscribe(WorldEvent.SpawnDebris, _handle_spawn_debris)
	EventBus.subscribe(WorldEvent.SpawnPopupLabel, _handle_spawn_popup_label)
	EventBus.subscribe(WorldEvent.SpawnBursterProjectile, _handle_spawn_burster_projectile)

func _unsubscribe() -> void:
	EventBus.unsubscribe(WorldEvent.SpawnPlayer, _handle_spawn_player)
	EventBus.unsubscribe(WorldEvent.SpawnEnemy, _handle_spawn_enemy)
	EventBus.unsubscribe(WorldEvent.SpawnXPItem, _handle_spawn_xp_item)
	EventBus.unsubscribe(WorldEvent.SpawnDebris, _handle_spawn_debris)
	EventBus.unsubscribe(WorldEvent.SpawnPopupLabel, _handle_spawn_popup_label)
	EventBus.unsubscribe(WorldEvent.SpawnBursterProjectile, _handle_spawn_burster_projectile)

# ===
# Events
# ===

func _handle_spawn_player(event: WorldEvent.SpawnPlayer) -> void:
	var player: Player = AssetProvider.get_player_scene()
	player_container.add_child(player)
	player.global_position = event.world_location
	player.global_rotation = event.rotation
	
	await get_tree().process_frame
	
	Session.player_provider.set_player_instance(
		player
	)
	
	EventBus.emit(
		WorldEvent.PlayerSpawned.new(
			player
		)
	)

func _handle_spawn_enemy(event: WorldEvent.SpawnEnemy) -> void:
	var pool: ObjectPool = Session.game_context.enemy_pools.get(event.enemy_type)
	if not pool: return
	
	var enemy: Enemy = pool.get_instance() as Enemy
	enemy.activate(event.world_location)
	
	# Session Update
	Session.world_provider.update_total_enemies(
		1
	)
	
	# Notify
	EventBus.emit(
		WorldEvent.EnemySpawned.new(
			event.enemy_type
		)
	)

func _handle_spawn_xp_item(event: WorldEvent.SpawnXPItem) -> void:
	var pool: ObjectPool = Session.game_context.xp_item_pool
	if not pool: return
	
	var xp: XPItem = pool.get_instance() as XPItem
	xp.activate(
		event.world_location, 
		event.value
	)

func _handle_spawn_debris(event: WorldEvent.SpawnDebris) -> void:
	var pool: ObjectPool = Session.game_context.debris_pool
	if not pool: return
	
	var spawn_count: int = randi_range(
		min_debris_spawned, 
		max_debris_spawned
	)
	for i in range(spawn_count):
		var debris: DebrisCube = pool.get_instance() as DebrisCube
		if debris:
			var force: Vector3 = Vector3(
				randf_range(-1, 1), 
				randf_range(0.5, 1.5), 
				randf_range(-1, 1)
			).normalized() * randf_range(3.0, 7.0)
			
			debris.activate(
				event.world_location, 
				force, 
				event.material
			)

func _handle_spawn_popup_label(event: WorldEvent.SpawnPopupLabel) -> void:
	var pool: ObjectPool = Session.game_context.popup_label_pool
	if not pool: return
	
	var popup_label: PopupLabel = pool.get_instance() as PopupLabel
	
	if popup_label:
		popup_label.activate(
			event.popup_type, 
			event.message,
			event.location
		)

func _handle_spawn_burster_projectile(event: WorldEvent.SpawnBursterProjectile) -> void:
	var pool: ObjectPool = Session.game_context.burster_projectile_pool
	if not pool: return
	
	var burster_projectile: BursterProjectile = pool.get_instance() as BursterProjectile
	
	if burster_projectile:
		burster_projectile.damage = event.damage
		burster_projectile.activate(
			event.origin,
			event.destination
		)
