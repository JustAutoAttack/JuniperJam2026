@tool
class_name PopupLabel
extends Node3D

@onready var label: Label3D = $Label3D

func activate(
	type: Enums.PopupType, 
	message: String, 
	location: Vector3
) -> void:
	global_position = location
	reset_physics_interpolation()
	visible = true
	_setup(
		type, 
		message
	)

func _setup(
	type: Enums.PopupType, 
	message: String
) -> void:
	var data: PopupData = AssetProvider.get_popup_data(type)
	if not data: return
	
	label.text = message
	label.modulate = data.color
	label.outline_modulate = data.outline
	label.pixel_size = data.size
	
	_animate_pop(data.scale)
	_play_floating_animation()

func _animate_pop(
	multiplier: float
) -> void:
	label.scale = Vector3.ZERO
	var tween: Tween = create_tween()
	tween.set_trans(
		Tween.TRANS_BACK
	)
	
	# Scale
	tween.tween_property(
		label, 
		"scale", 
		Vector3.ONE * multiplier, 
		0.15
	)

func _play_floating_animation() -> void:
	var drift: float = randf_range(-0.2, 0.2)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	
	# Position
	tween.tween_property(
		self, 
		"position:y", 
		position.y + 0.6, 
		0.7
	).set_trans(
		Tween.TRANS_QUAD
	)
	tween.tween_property(
		self, 
		"position:x", 
		position.x + drift, 
		0.7
	)
	
	# Modulate
	tween.tween_property(
		label, 
		"modulate:a", 
		0.0, 
		0.3
	).set_delay(
		0.4
	)
	tween.tween_property(
		label, 
		"outline_modulate:a", 
		0.0, 
		0.3
	).set_delay(
		0.4
	)
	
	# Kill when finished
	tween.chain(
	).tween_callback(
		_reset
	)

func _reset() -> void:
	if Engine.is_editor_hint():
		position = Vector3.ZERO
		label.modulate.a = 0.0
		label.outline_modulate.a = 0.0
	else:
		visible = false
		EventBus.emit(
			GameEvent.RecyclePopupLabel.new(
				self
			)
		)
