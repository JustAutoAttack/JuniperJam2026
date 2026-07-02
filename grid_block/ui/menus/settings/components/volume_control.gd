@tool
class_name UISettingsMenuVolumeControl
extends HBoxContainer

signal ratio_changed(new_ratio: float)
signal mute_toggled(is_muted: bool)

@export var title: String = "":
	set(value):
		title = value
		if is_node_ready():
			_update_title()

@export_range(0.0, 1.0, 0.01) var ratio: float = 1.0:
	set(value):
		ratio = clamp(value, 0.0, 1.0)
		_update_slider()
		_update_percentage()
		# Emit signal when ratio changes
		ratio_changed.emit(ratio)

@export var is_muted: bool = false:
	set(value):
		is_muted = value
		_update_mute_button()
		# Emit signal when mute state changes
		mute_toggled.emit(is_muted)

@onready var mute_button: Button = $MuteButton
@onready var title_label: Label = $Title
@onready var slider: HSlider = $Slider
@onready var percentage_label: Label = $Percentage

# ===
# Built-In
# ===

func _ready() -> void:
	slider.value_changed.connect(_on_slider_value_changed)
	mute_button.toggled.connect(_on_mute_toggled)
	
	_update_title()
	_update_slider()
	_update_percentage()
	_update_mute_button()

# ===
# Private
# ===

func _update_title() -> void:
	if title_label:
		title_label.text = title

func _update_slider() -> void:
	if slider and slider.value != ratio:
		slider.value = ratio

func _update_percentage() -> void:
	if percentage_label:
		var percent = int(round(ratio * 100))
		percentage_label.text = str(percent) + "%"

func _update_mute_button() -> void:
	if mute_button:
		mute_button.button_pressed = is_muted
		mute_button.text = "UNMUTE" if is_muted else "MUTE"
	if slider:
		slider.editable = not is_muted

# ===
# Signals
# ===

func _on_slider_value_changed(value: float) -> void:
	ratio = value

func _on_mute_toggled(toggled_on: bool) -> void:
	is_muted = toggled_on
