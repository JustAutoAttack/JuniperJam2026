class_name UIGameOverMenu
extends UIMenu

@onready var score_label: Label = %Score
@onready var erased_label: Label = %Erased
@onready var respin_button: Button = %RespinButton
@onready var main_menu_button: Button = %MainMenuButton

# ===
# Built-In
# ===

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)

# ===
# Private
# ===

func _emit_action(action: Enums.GameOverMenuAction) -> void:
	EventBus.emit(
		UIEvent.GameOverMenu.new(
			action
		)
	)

# ===
# Signals
# ===

func _on_visibility_changed() -> void:
	if not visible: return
	
	var p_context: PlayerContext = Session.player_context
	var w_context: WorldContext = Session.world_context
	
	score_label.text = str(w_context.score)
	erased_label.text = str(w_context.enemies_killed)

func _on_respin() -> void:
	_emit_press_sfx()
	_emit_action(Enums.GameOverMenuAction.RESPIN)

func _on_main_menu() -> void:
	_emit_press_sfx()
	_emit_action(Enums.GameOverMenuAction.TO_MAIN_MENU)
