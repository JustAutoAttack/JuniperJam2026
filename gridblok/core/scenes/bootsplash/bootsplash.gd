class_name Bootsplash
extends Node

# TODO Bootsplash

# ===
# Built-In
# ===

func _ready() -> void:
	EventBus.emit(
		MainEvent.BootsplashLoaded.new()
	)
	Session.did_bootsplash = true
