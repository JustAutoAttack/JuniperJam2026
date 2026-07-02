class_name UIMenu
extends Control

@export var type: Enums.MenuType

func _emit_press_sfx() -> void:
	EventBus.emit(
		AudioEvent.PlaySFX.new(
			Enums.SFXType.UI_SELECT_ONE
		)
	)
