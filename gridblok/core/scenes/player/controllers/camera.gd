class_name PlayerCameraController
extends Node3D

@export var camera_coefficient: float = 3.0
@export var pitch_degrees_x: float = 30.0

@onready var yaw: Node3D = %Yaw
@onready var pitch: Node3D = %Pitch
@onready var boom: SpringArm3D = %Boom
@onready var camera: Camera3D = %Camera

var _current_tween: Tween

# ===
# Built-In
# ===

func _ready() -> void:
	_update_camera_distance()
	pitch.rotation_degrees.x = pitch_degrees_x
	
	Session.player_context.owned_upgrades_updated.connect(
		func(_value): _update_camera_distance()
	)

# ===
# Public
# ===

# ===
# Private
# ===

func _update_camera_distance() -> void:
	var orbit_radius: float = Session.player_provider.get_total_stat(Enums.StatType.ORBIT_RADIUS)
	var target_distance: float = orbit_radius * camera_coefficient
	
	if _current_tween:
		_current_tween.kill()
		
	_current_tween = create_tween()
	_current_tween.tween_property(
		boom, 
		"spring_length", 
		target_distance, 
		0.1
	).set_trans(
		Tween.TRANS_CUBIC
	).set_ease(
		Tween.EASE_OUT
	)
