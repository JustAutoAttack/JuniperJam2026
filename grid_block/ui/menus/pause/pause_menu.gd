class_name UIPauseMenu
extends UIMenu


# ===
# Private
# ===

func _emit_action(action: Enums.PauseMenuAction) -> void:
	EventBus.emit(
		UIEvent.PauseMenu.new(
			action
		)
	)

# ===
# Signalsw
# ===

func _on_resume() -> void:
	_emit_press_sfx()
	_emit_action(Enums.PauseMenuAction.RESUME)

func _on_settings() -> void:
	_emit_press_sfx()
	_emit_action(Enums.PauseMenuAction.SETTINGS)

func _on_main_menu() -> void:
	_emit_press_sfx()
	_emit_action(Enums.PauseMenuAction.EXIT)

func _on_quit() -> void:
	_emit_press_sfx()
	_emit_action(Enums.PauseMenuAction.QUIT)
