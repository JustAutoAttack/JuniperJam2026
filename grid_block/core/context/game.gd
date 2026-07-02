class_name GameContext
extends Context

# ===
# Runtime
# ===

# --- Object Pools ---
signal debris_pool_updated(value: ObjectPool)
var _debris_pool: ObjectPool
var debris_pool: ObjectPool:
	get: return _debris_pool
	set(value):
		if _authorize_write():
			_debris_pool = value
			debris_pool_updated.emit(value)

signal enemy_pools_updated(value: Dictionary[Enums.EnemyType, ObjectPool])
var _enemy_pools: Dictionary[Enums.EnemyType, ObjectPool]
var enemy_pools: Dictionary[Enums.EnemyType, ObjectPool]:
	get: return _enemy_pools
	set(value):
		if _authorize_write():
			_enemy_pools = value
			enemy_pools_updated.emit(value)

signal popup_label_pool_updated(value: ObjectPool)
var _popup_label_pool: ObjectPool
var popup_label_pool: ObjectPool:
	get: return _popup_label_pool
	set(value):
		if _authorize_write():
			_popup_label_pool = value
			popup_label_pool_updated.emit(value)

signal xp_item_pool_updated(value: ObjectPool)
var _xp_item_pool: ObjectPool
var xp_item_pool: ObjectPool:
	get: return _xp_item_pool
	set(value):
		if _authorize_write():
			_xp_item_pool = value
			xp_item_pool_updated.emit(value)

signal burster_projectile_pool_updated(value: ObjectPool)
var _burster_projectile_pool: ObjectPool
var burster_projectile_pool: ObjectPool:
	get: return _burster_projectile_pool
	set(value):
		if _authorize_write():
			_burster_projectile_pool = value
			burster_projectile_pool_updated.emit(value)

# ===
# Persistent
# ===


# ===
# Built-In
# ===

func _init() -> void:
	reset()

func reset() -> void:
	reset_debris_pool()
	reset_enemy_pools()
	reset_popup_label_pool()
	reset_xp_item_pool()
	reset_burster_projectile_pool()

# ===
# Public
# ===

func reset_debris_pool() -> void:
	if _debris_pool:
		_debris_pool.clear()
	_debris_pool = null
	debris_pool_updated.emit(debris_pool)

func reset_enemy_pools() -> void:
	if not _enemy_pools.is_empty():
		for enemy_type: Enums.EnemyType in _enemy_pools.keys():
			_enemy_pools[enemy_type].clear()
	
	_enemy_pools.clear()
	enemy_pools_updated.emit(enemy_pools)

func reset_popup_label_pool() -> void:
	if _popup_label_pool:
		_popup_label_pool.clear()
	_popup_label_pool = null
	popup_label_pool_updated.emit(popup_label_pool)

func reset_xp_item_pool() -> void:
	if _xp_item_pool:
		_xp_item_pool.clear()
	_xp_item_pool = null
	xp_item_pool_updated.emit(xp_item_pool)

func reset_burster_projectile_pool() -> void:
	if _burster_projectile_pool:
		_burster_projectile_pool.clear()
	_burster_projectile_pool = null
	burster_projectile_pool_updated.emit(burster_projectile_pool)
