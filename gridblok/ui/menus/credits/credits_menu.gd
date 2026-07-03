@tool
class_name UICreditsMenu
extends UIMenu

@onready var scroll_container: UIAutoScrollContainer = %ScrollContainer

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)

# ===
# Signals
# ===

func _on_visibility_changed() -> void:
	if visible:
		scroll_container.reset_scroll()

func _on_done() -> void:
	EventBus.emit(
		UIEvent.CreditsMenu.new(
			Enums.CreditsMenuAction.DONE
		)
	)
