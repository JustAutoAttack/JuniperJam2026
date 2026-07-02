class_name GameProvider
extends ContextProvider

var context: GameContext

# ===
# Built-In
# ===

func _init(
	p_context: GameContext
) -> void:
	context = p_context

# ===
# Public
# ===

func create_debris_pool(
	parent: Node, 
	size: int
) -> void:
	if context.debris_pool: return
	
	context.debris_pool = ObjectPool.new(
		AssetProvider.get_debris_scene(), 
		parent,
		size
	)

func create_enemy_pools(
	parent: Node, 
	size: int
) -> void:
	if not context.enemy_pools.is_empty(): return
	
	var pools: Dictionary[Enums.EnemyType, ObjectPool] = {}
	
	for enemy_type in Enums.EnemyType.values():
		var packed_scene: PackedScene = AssetProvider.get_enemy_scene(enemy_type)
		pools[enemy_type] = ObjectPool.new(
			packed_scene,
			parent,
			size
		)
	
	context.enemy_pools = pools

func create_popup_label_pool(
	parent: Node, 
	size: int
) -> void:
	if context.popup_label_pool: return
	
	context.popup_label_pool = ObjectPool.new(
		AssetProvider.get_popup_label_scene(), 
		parent,
		size
	)

func create_xp_item_pool(
	parent: Node, 
	size: int
) -> void:
	if context.xp_item_pool: return
	
	context.xp_item_pool = ObjectPool.new(
		AssetProvider.get_xp_scene(), 
		parent,
		size
	)

func create_burster_projectile_pool(
	parent: Node,
	size: int
) -> void:
	if context.burster_projectile_pool: return
	
	context.burster_projectile_pool = ObjectPool.new(
		AssetProvider.get_burster_projectile_scene(), 
		parent,
		size
	)
