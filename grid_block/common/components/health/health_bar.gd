class_name HealthBarComponent
extends Control

@export var tween_duration: float = 0.3
@export var fill_color: Color = Color.WHITE

@onready var under_bar: ProgressBar = %Under
@onready var current_bar: ProgressBar = %Current

var _tween: Tween

# ===
# Built-In
# ===

func _ready() -> void:
	_apply_color(
		current_bar, 
		fill_color
	)
	_apply_color(
		under_bar, 
		fill_color * Color(1, 1, 1, 0.5)
	)

# ===
# Public
# ===

func update_value(
	current: float, 
	maximum: float
) -> void:
	if not current_bar: return
	
	current_bar.max_value = maximum
	current_bar.value = current
	
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.tween_property(
		under_bar, 
		"value", 
		current, 
		tween_duration
	).from(under_bar.value)
	
	visible = current < maximum

# ===
# Private
# ===

func _apply_color(
	bar: ProgressBar, 
	color: Color
) -> void:
	var style_box: StyleBoxFlat = bar.get_theme_stylebox("fill").duplicate()
	style_box.bg_color = color
	bar.add_theme_stylebox_override(
		"fill", 
		style_box
	)
