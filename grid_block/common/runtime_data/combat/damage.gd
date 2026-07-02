class_name DamageData
extends RefCounted

var sender: Node3D
var receiver: Node3D
var amount: float
var is_crit: bool
var collision_position: Vector3

static func create_from_sender(
	p_sender: Node3D,
	p_collision_position: Vector3,
	p_amount: float,
	p_is_crit: bool
) -> DamageData:
	var data: DamageData = DamageData.new()
	data.sender = p_sender
	data.collision_position = p_collision_position
	data.amount = p_amount
	data.is_crit = p_is_crit
	return data
