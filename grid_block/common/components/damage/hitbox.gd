class_name Hitbox
extends Area3D

enum CheckType {
	ON_ENTER,
	ON_INTERVAL,
	BOTH
}

signal hit_landed(
	hurtbox: Hurtbox, 
	collision_point: Vector3
)

@export var hurtbox_blacklist: Array[Hurtbox] = []
@export var class_blacklist: Array[Script] = []

@export_category("Detection")
@export var check_type: CheckType = CheckType.ON_ENTER
@export_range(0.0, 1.0, 0.05) var check_hit_every: float = 0.0
@export var max_collision_position_check_attempts: int = 20

var _timer: float = 0.0

# ===
# Built-In
# ===

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	if (
		check_type != CheckType.ON_ENTER and 
		check_hit_every > 0.0
	):
		_timer += delta
		if _timer >= check_hit_every:
			_timer = 0.0
			_check_overlapping_hits()

# ===
# Private
# ===

func _check_overlapping_hits() -> void:
	var areas: Array[Area3D] = get_overlapping_areas()
	for area in areas:
		if _is_valid_hurtbox(area):
			var hurtbox: Hurtbox = area as Hurtbox
			hit_landed.emit(
				hurtbox,
				_get_collision_point(
					hurtbox, 
					max_collision_position_check_attempts
				)
			)

func _get_collision_point(hurtbox: Hurtbox, max_attempts: int) -> Vector3:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var exclude_rids: Array[RID] = [self.get_rid()]
	
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		global_position, 
		hurtbox.global_position, 
		Constants.PhysicsLayer.DAMAGE_MASK, 
		exclude_rids
	)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	
	var result: Dictionary = space_state.intersect_ray(query)
	var attempts: int = 0
	
	while (
		not result.is_empty() and 
		result.collider_id != hurtbox.get_instance_id() and 
		attempts < max_attempts
	):
		exclude_rids.append(result.collider.get_rid())
		query.exclude = exclude_rids
		result = space_state.intersect_ray(query)
		attempts += 1
	
	var found_hurtbox: bool = (
		not result.is_empty() and 
		result.get("collider_id") == hurtbox.get_instance_id()
	)
	
	if found_hurtbox: return result.position
	
	return hurtbox.global_position

func _is_valid_hurtbox(area: Area3D) -> bool:
	if not area is Hurtbox: return false
	if area in hurtbox_blacklist: return false
	
	var owner_node: Node = area.get_owner()
	
	if owner_node:
		for script in class_blacklist:
			if _is_script_or_inherits(
				owner_node.get_script(), 
				script
			): return false
	
	return true

func _is_script_or_inherits(
	target_script: Script, 
	base_class_script: Script
) -> bool:
	var current_script: Script = target_script
	
	while current_script:
		if current_script == base_class_script: return true
		
		current_script = current_script.get_base_script()
	
	return false

# ===
# Signals
# ===

func _on_area_entered(area: Area3D) -> void:
	if check_type == CheckType.ON_INTERVAL: return
	if not _is_valid_hurtbox(area): return
	
	var hurtbox: Hurtbox = area as Hurtbox
	hit_landed.emit(
		hurtbox,
		_get_collision_point(
			hurtbox, 
			max_collision_position_check_attempts
		)
	)
