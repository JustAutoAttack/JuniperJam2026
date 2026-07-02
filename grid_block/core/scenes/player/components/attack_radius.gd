@tool
class_name PlayerAttackRadius
extends MeshInstance3D

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


# ===
# Built-In
# ===

func _ready() -> void:
	var mat = get_active_material(0)
	if mat is ShaderMaterial:
		mat.set_shader_parameter(
			"glow_color", 
			Constants.SynthColors.CYBER_RED
		)
	
	if Engine.is_editor_hint(): return
	
	_update_values()
	
	Session.player_context.owned_upgrades_updated.connect(
		func(_value):
			_update_values()
	)

# ===
# Private
# ===

func _update_values() -> void:
	# Radius
	var target_radius: float = Session.player_provider.get_total_stat(Enums.StatType.ORBIT_RADIUS)
	var tween: Tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "radius", target_radius, 0.5)
	
func _update_size() -> void:
	scale = Vector3(
		radius, 
		height, 
		radius
	)
	position.y = height / 2.0
