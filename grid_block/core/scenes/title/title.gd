class_name Title
extends Node3D

# ===
# Built-In
# ===

func _ready() -> void:
	EventBus.emit(
		GameEvent.TitleLoaded.new()
	)
