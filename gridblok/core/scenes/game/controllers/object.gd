class_name GameObjectController
extends Node

signal setup_complete

@export_category("Pool Sizes")
@export var debris_pool_size: int = 40
@export var enemy_pool_size: int = 40
@export var xp_pool_size: int = 40
@export var popup_labels_pool_size: int = 40
@export var burster_projectiles_pool_size: int = 20

@onready var enemies_container: Node = %Enemies
@onready var xp_container: Node = %XP
@onready var popup_labels_container: Node = %PopupLabels
@onready var debris_container: Node = %Debris
@onready var projectiles_container: Node = %Projectiles

var is_setup: bool = false

# ===
# Built-In
# ===

func _ready() -> void:
	_subscribe()

func _exit_tree() -> void:
	_unsubscribe()

# ===
# Private
# ===

func _subscribe() -> void:
	EventBus.subscribe(GameEvent.RecycleEnemy, _handle_recycle_enemy)
	EventBus.subscribe(GameEvent.RecycleXPItem, _handle_recycle_xp_item)
	EventBus.subscribe(GameEvent.RecycleDebris, _handle_recycle_debris)
	EventBus.subscribe(GameEvent.RecyclePopupLabel, _handle_recycle_popup_label)
	EventBus.subscribe(GameEvent.RecycleBursterProjectile, _handle_recycle_burster_projectile)

func _unsubscribe() -> void:
	EventBus.unsubscribe(GameEvent.RecycleEnemy, _handle_recycle_enemy)
	EventBus.unsubscribe(GameEvent.RecycleXPItem, _handle_recycle_xp_item)
	EventBus.unsubscribe(GameEvent.RecycleDebris, _handle_recycle_debris)
	EventBus.unsubscribe(GameEvent.RecyclePopupLabel, _handle_recycle_popup_label)
	EventBus.unsubscribe(GameEvent.RecycleBursterProjectile, _handle_recycle_burster_projectile)

# ===
# Public
# ===

func setup_pools() -> void:
	is_setup = false
	
	# Debris
	Session.game_provider.create_debris_pool(
		debris_container,
		debris_pool_size
	)
	
	# Enemies
	Session.game_provider.create_enemy_pools(
		enemies_container,
		enemy_pool_size
	)
	
	# XP
	Session.game_provider.create_xp_item_pool(
		xp_container,
		xp_pool_size
	)
	
	# Popup Labels
	Session.game_provider.create_popup_label_pool(
		popup_labels_container,
		popup_labels_pool_size
	)
	
	# Projectiles
	Session.game_provider.create_burster_projectile_pool(
		projectiles_container,
		burster_projectiles_pool_size
	)
	
	is_setup = true
	setup_complete.emit()

func deactivate_all_pools() -> void:
	for pool: ObjectPool in Session.game_context.enemy_pools.values():
		for enemy: Enemy in pool.get_active_instances():
			enemy.deactivate()
			pool.return_instance(enemy)
	
	var pools = [
		Session.game_context.xp_item_pool,
		Session.game_context.popup_label_pool,
		Session.game_context.debris_pool,
		Session.game_context.burster_projectile_pool
	]
	
	for pool: ObjectPool in pools:
		for instance: Node in pool.get_active_instances():
			pool.return_instance(instance)

# ===
# Private
# ===

# ===
# Events
# ===

func _handle_recycle_debris(event: GameEvent.RecycleDebris) -> void:
	var pool: ObjectPool = Session.game_context.debris_pool
	if pool:
		pool.return_instance(
			event.debris
		)

func _handle_recycle_enemy(event: GameEvent.RecycleEnemy) -> void:
	var enemy: Enemy = event.enemy
	enemy.deactivate()
	
	var pool: ObjectPool = Session.game_context.enemy_pools.get(
		enemy.type
	)
	if pool:
		pool.return_instance(
			enemy
		)

func _handle_recycle_xp_item(event: GameEvent.RecycleXPItem) -> void:
	var pool: ObjectPool = Session.game_context.xp_item_pool
	if pool:
		pool.return_instance(
			event.xp_item
		)

func _handle_recycle_popup_label(event: GameEvent.RecyclePopupLabel) -> void:
	var pool: ObjectPool = Session.game_context.popup_label_pool
	if pool:
		pool.return_instance(
			event.popup_label
		)

func _handle_recycle_burster_projectile(event: GameEvent.RecycleBursterProjectile) -> void:
	var pool: ObjectPool = Session.game_context.burster_projectile_pool
	if pool:
		pool.return_instance(
			event.burster_projectile
		)
