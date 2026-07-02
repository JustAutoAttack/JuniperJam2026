@tool
class_name PlayerCollectionArea
extends Area3D

@export var radius: float = 5.0:
	set(value):
		radius = value
		if is_node_ready():
			_update_size()
@export var height: float = 5.0:
	set(value):
		height = value
		if is_node_ready():
			_update_size()

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

# ===
# Built-In
# ===

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	var mat = mesh_instance.get_active_material(0)
	if mat is ShaderMaterial:
		mat.set_shader_parameter(
			"glow_color", 
			Constants.SynthColors.NEON_GREEN
		)
	
	if Engine.is_editor_hint(): return
	
	_update_values()
	Session.player_context.owned_upgrades_updated.connect(
		func(_value):
			_update_values()
	)

# ===
# Public
# ===

func _update_values() -> void:
	# Radius
	var target_radius: float = Session.player_provider.get_total_stat(Enums.StatType.COLLECT_RANGE)
	var tween: Tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "radius", target_radius, 0.5)

# ===
# Private
# ===

func _update_size() -> void:
	if not mesh_instance: return
		
	# Scale the visual mesh
	mesh_instance.scale = Vector3(
		radius, 
		height, 
		radius
	)
	mesh_instance.position.y = height / 2.0
	_update_collider()

func _update_collider() -> void:
	if mesh_instance.mesh:
		var shape = mesh_instance.mesh.create_trimesh_shape()
		shape.backface_collision = true
		collision_shape.shape = shape
		collision_shape.scale = Vector3(radius, height, radius)
		collision_shape.position = mesh_instance.position

# ===
# Signals
# ===

func _on_area_entered(area: Area3D) -> void:
	var area_parent: Node = area.get_parent()
	if area_parent is XPItem:
		EventBus.emit(
			WorldEvent.XPItemCollected.new(
				area_parent.value
			)
		)
		EventBus.emit(
			GameEvent.RecycleXPItem.new(
				area_parent as XPItem
			)
		)
