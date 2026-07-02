@tool
class_name WorldArenaRing
extends StaticBody3D

@export var glow_color: Color = Color(0.0, 1.0, 2.0):
	set(value):
		glow_color = value
		if is_node_ready(): 
			_update_glow_color()

@export var radius_growth_speed: float = 2.0

@export var radius: float = 5.0:
	set(value):
		if radius == value: return
		var old_radius = radius
		radius = value
		if is_node_ready():
			_start_radius_tween(old_radius, value)

@export var height: float = 5.0:
	set(value):
		height = value
		if is_node_ready(): _update_size()

var _current_display_radius: float = 5.0

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	_current_display_radius = radius
	_update_glow_color()
	_update_size()

func _start_radius_tween(from: float, to: float) -> void:
	var tween = create_tween()
	var duration = abs(to - from) / radius_growth_speed
	
	tween.tween_method(
		func(val): 
			_current_display_radius = val
			_update_size(), 
		from, 
		to, 
		duration
	).set_trans(
		Tween.TRANS_CUBIC
	).set_ease(
		Tween.EASE_OUT
	)

func _update_size() -> void:
	if not mesh_instance: return
	
	mesh_instance.scale = Vector3(
		_current_display_radius, 
		height, 
		_current_display_radius
	)
	mesh_instance.position.y = height / 2.0
	_update_collider()

func _update_collider() -> void:
	if mesh_instance.mesh:
		var shape = mesh_instance.mesh.create_trimesh_shape()
		shape.backface_collision = true
		collision_shape.shape = shape
		collision_shape.scale = Vector3(
			_current_display_radius, 
			height, 
			_current_display_radius
		)
		collision_shape.position = mesh_instance.position

func _update_glow_color() -> void:
	var mat = mesh_instance.get_active_material(0)
	if mat is ShaderMaterial:
		mat.set_shader_parameter(
			"glow_color", 
			glow_color
		)
