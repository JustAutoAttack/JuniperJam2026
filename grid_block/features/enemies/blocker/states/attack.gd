extends EnemyState

@export_group("Nodes")
@export var aoe_area: Area3D
@export var aoe_indicator: MeshInstance3D

@export_group("Timing")
@export var lift_duration: float = 0.75
@export var slam_duration: float = 0.1
@export var linger_duration: float = 0.2
@export var fade_duration: float = 0.2

@export_group("Movement")
@export var lift_height: float = 2.0
@export var area_offset_y: float = -2.0

# ===
# Built-In
# ===

func enter(_prev_state_path: String, _data: Object) -> void:
	_owner.is_attacking = true
	_owner.disable_movement()
	_run_slam_sequence()

func exit() -> void:
	_owner.is_attacking = false

# ===
# Private
# ===

func _run_slam_sequence() -> void:
	aoe_indicator.show()
	var mat = aoe_indicator.get_active_material(0)
	mat.set_shader_parameter("alpha_override", 1.0)
	mat.set_shader_parameter("animation_progress", 0.0)
	
	var tween = create_tween().set_parallel(true)
	
	# Lift
	EventBus.emit(
		AudioEvent.PlaySFX.new(
			Enums.SFXType.BLOCKER_ATTACK_PREPARE
		)
	)
	tween.tween_property(_owner, "position:y", lift_height, lift_duration)
	tween.tween_property(aoe_area, "position:y", area_offset_y, lift_duration)
	tween.tween_property(mat, "shader_parameter/animation_progress", 1.0, lift_duration)
	
	tween.set_parallel(false)
	
	# Impact
	tween.tween_property(_owner, "position:y", 0.0, slam_duration)
	tween.tween_property(aoe_area, "position:y", 0.0, slam_duration)
	tween.tween_callback(_on_impact)
	
	# Lingering & Fade
	tween.tween_interval(linger_duration) 
	tween.tween_property(mat, "shader_parameter/alpha_override", 0.0, fade_duration)
	
	tween.tween_callback(func(): _transition_to(StateName.CHASE, null))
	tween.tween_callback(aoe_indicator.hide)

func _on_impact() -> void:
	EventBus.emit(
		AudioEvent.PlaySFX.new(
			Enums.SFXType.BLOCKER_ATTACK_IMPACT
		)
	)
	aoe_area.monitoring = true
	await get_tree().physics_frame
	await get_tree().physics_frame
	aoe_area.monitoring = false
