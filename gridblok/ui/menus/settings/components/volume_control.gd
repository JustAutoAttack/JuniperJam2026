@tool
class_name UISettingsMenuVolumeControl
extends HBoxContainer

enum VolumeLevel { MUTED, LOW, MID, HIGH }

signal ratio_changed(new_ratio: float)
signal mute_toggled(is_muted: bool)

@export var title: String = "":
	set(value):
		title = value
		if is_node_ready(): _update_title()

@export_range(0.0, 1.0, 0.01) var ratio: float = 1.0:
	set(value):
		ratio = clamp(value, 0.0, 1.0)
		_update_slider_visuals()
		_update_percentage()
		_update_volume_level()
		if is_node_ready(): 
			ratio_changed.emit(ratio)

@export var is_muted: bool = false:
	set(value):
		is_muted = value
		_update_mute_button()
		_update_volume_level()
		if is_node_ready(): 
			mute_toggled.emit(is_muted)

@onready var muted_icon: TextureRect = %MutedIcon
@onready var unmuted_low_icon: TextureRect = %UnmutedLowIcon
@onready var unmuted_mid_icon: TextureRect = %UnmutedMidIcon
@onready var unmuted_high_icon: TextureRect = %UnmutedHighIcon
@onready var mute_button: TextureButton = %MuteButton
@onready var title_label: Label = %Title
@onready var slider_container: MarginContainer = %SliderContainer
@onready var slider_bar: TextureProgressBar = %SliderBar
@onready var slider_thumb_icon: TextureRect = %SliderThumbIcon
@onready var percentage_label: Label = %Percentage

var volume_level: VolumeLevel
var is_dragging: bool = false

# === Built-In ===

func _ready() -> void:
	mute_button.toggled.connect(_on_mute_toggled)
	slider_container.gui_input.connect(_on_slider_gui_input)
	
	_update_title()
	_update_slider_visuals()
	_update_percentage()
	_update_volume_level()
	_update_mute_button()

# === Private ===

func _update_volume_level() -> void:
	if is_muted: volume_level = VolumeLevel.MUTED
	elif ratio <= 0.33: volume_level = VolumeLevel.LOW
	elif ratio <= 0.66: volume_level = VolumeLevel.MID
	else: volume_level = VolumeLevel.HIGH
		
	muted_icon.visible = (volume_level == VolumeLevel.MUTED)
	unmuted_low_icon.visible = (volume_level == VolumeLevel.LOW)
	unmuted_mid_icon.visible = (volume_level == VolumeLevel.MID)
	unmuted_high_icon.visible = (volume_level == VolumeLevel.HIGH)

func _update_slider_visuals() -> void:
	if not is_node_ready(): return
	slider_bar.value = ratio * 100
	# Center thumb on the progress edge
	slider_thumb_icon.position.x = (ratio * slider_container.size.x) - (slider_thumb_icon.size.x / 2.0)

func _update_title() -> void:
	if title_label: title_label.text = title

func _update_percentage() -> void:
	if percentage_label: percentage_label.text = str(int(round(ratio * 100))) + "%"

func _update_mute_button() -> void:
	if mute_button:
		mute_button.button_pressed = is_muted
	if slider_container:
		slider_container.mouse_filter = Control.MOUSE_FILTER_IGNORE if is_muted else Control.MOUSE_FILTER_STOP
		
		# Dim the slider visuals when muted
		if is_muted:
			slider_container.modulate = Color(0.5, 0.5, 0.5, 1.0) # Darken/Grey out
			percentage_label.modulate = Color(0.5, 0.5, 0.5, 1.0)
		else:
			slider_container.modulate = Color.WHITE
			percentage_label.modulate = Color.WHITE

# === Signals ===

func _on_slider_gui_input(event: InputEvent) -> void:
	if is_muted: return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Check if click started on the thumb
				var thumb_rect = Rect2(slider_thumb_icon.position, slider_thumb_icon.size)
				if thumb_rect.has_point(event.position):
					is_dragging = true
			else:
				is_dragging = false
				
	elif event is InputEventMouseMotion and is_dragging:
		# Update ratio while dragging
		ratio = clamp(event.position.x / slider_container.size.x, 0.0, 1.0)

func _on_mute_toggled(toggled_on: bool) -> void:
	is_muted = toggled_on
