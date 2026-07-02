class_name HealthComponent
extends Node

signal health_changed(
	new_current: float, 
	new_maximum: float
)

@export var maximum: float = 10.0:
	set(value):
		maximum = max(
			1.0, 
			value
		)
		current = clamp(
			current, 
			0, 
			maximum
		)
		_update_bar()
@export var current: float = 10.0:
	set(value):
		current = clamp(
			value, 
			0, 
			maximum
		)
		health_changed.emit(
			current, 
			maximum
		)
		_update_bar()

@export var health_bar: HealthBarComponent
@export var regen_rate: float = 0.0
@export var can_regen: bool = true

# ===
# Built-In
# ===

func _ready() -> void:
	_update_bar()

# ===
# Public
# ===

# ===
# Private
# ===

func _update_bar() -> void:
	if health_bar:
		health_bar.update_value(
			current, 
			maximum
		)
