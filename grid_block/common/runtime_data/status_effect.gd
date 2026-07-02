class_name StatusEffectData
extends RefCounted

var type: Enums.StatusEffectType
var value: float
var duration: float
var direction: Vector3

func _init(
	p_type: Enums.StatusEffectType,
	p_value: float,
	p_duration: float,
	p_direction: Vector3 = Vector3.ZERO
) -> void:
	type = p_type
	value = p_value
	duration = p_duration
	direction = p_direction
