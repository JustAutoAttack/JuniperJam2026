class_name UIMainMenu
extends UIMenu

@onready var version_label: Label = %VersionLabel
@onready var insert_coin_label: Label = %InsertCoin
@onready var credits_label: Label = %Credits

var pulse_tween: Tween

# ===
# Built-In
# ===

func _ready() -> void:
	version_label.text = Session.full_version_string

# ===
# Private
# ===

func _emit_action(action: Enums.MainMenuAction) -> void:
	EventBus.emit(
		UIEvent.MainMenu.new(
			action
		)
	)

# ===
# Signals
# ===

func _on_visibility_changed() -> void:
	if visible:
		
		credits_label.text = "(0)"
		# Animate insert coin to slowly pulse
		pulse_tween = create_tween().set_loops()
		pulse_tween.tween_property(insert_coin_label, "modulate:a", 0.2, 1.0)
		pulse_tween.tween_property(insert_coin_label, "modulate:a", 1.0, 1.0)

func _on_spin() -> void:
	_emit_press_sfx()
	if pulse_tween:
		pulse_tween.kill()
		insert_coin_label.modulate.a = 1.0
	
	await get_tree().create_timer(0.5).timeout
	EventBus.emit(
			AudioEvent.PlaySFX.new(
				Enums.SFXType.CREDIT_INSERTED
			)
		)
	
	credits_label.text = "(1)"
	
	await get_tree().create_timer(0.5).timeout
	
	_emit_action(Enums.MainMenuAction.SPIN)

func _on_settings() -> void:
	_emit_press_sfx()
	_emit_action(Enums.MainMenuAction.SETTINGS)

func _on_quit() -> void:
	_emit_press_sfx()
	_emit_action(Enums.MainMenuAction.QUIT)
