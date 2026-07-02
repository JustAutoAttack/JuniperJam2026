extends ScrollContainer

@export var scroll_speed: float = 200.0
@export var target_container: BoxContainer

# Keep a float accumulator to avoid integer truncation
var _scroll_accumulator: float = 0.0

# ===
# Built-In
# ===

func _ready() -> void:
	# Hide scrollbars by setting their width to 0 in theme constants
	add_theme_constant_override("scroll_bar_vertical_width", 0)
	add_theme_constant_override("scroll_bar_horizontal_width", 0)

func _process(delta: float) -> void:
	if not target_container: return
	
	var separation: int = target_container.get_theme_constant("separation")
	var first_child: Control = target_container.get_child(0)
	var threshold: float = first_child.size.y + separation
	
	# Accumulate speed as a float
	_scroll_accumulator += scroll_speed * delta
	
	# Apply to scroll_vertical
	scroll_vertical = int(_scroll_accumulator)
	
	# Check threshold using the integer-casted value
	if scroll_vertical >= threshold:
		target_container.move_child(first_child, -1)
		_scroll_accumulator -= threshold
		scroll_vertical = int(_scroll_accumulator)
