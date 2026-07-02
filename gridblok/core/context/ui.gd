class_name UIContext
extends Context

# ===
# Runtime
# ===

# --- Screen Resolution ---
signal screen_resolution_updated(value: Vector2)
var _screen_resolution: Vector2
var screen_resolution: Vector2:
	get: return _screen_resolution
	set(value):
		if _authorize_write():
			_screen_resolution = value
			screen_resolution_updated.emit(value)

# --- Open Menus ---
signal open_menus_updated(value: Enums.MenuType)
var _open_menus: Array[Enums.MenuType] = []
var open_menus: Array[Enums.MenuType]:
	get: return _open_menus
	set(value):
		if _authorize_write():
			_open_menus = value
			open_menus_updated.emit(value)

# --- HUD Visibility ---
signal hud_visibility_updated(value: bool)
var _is_hud_visible: bool
var is_hud_visible: bool:
	get: return _is_hud_visible
	set(value):
		_is_hud_visible = value
		hud_visibility_updated.emit(value)

# --- Loading ---
signal loading_updated(value: bool)
var _is_loading: bool
var is_loading: bool:
	get: return _is_loading
	set(value):
		_is_loading = value
		loading_updated.emit(value)

# --- Saving ---
signal saving_updated(value: bool)
var _is_saving: bool
var is_saving: bool:
	get: return _is_saving
	set(value):
		_is_saving = value
		saving_updated.emit(value)

# ===
# Persistent
# ===

# ===
# Built-In
# ===

func _init() -> void:
	reset()

func reset() -> void:
	_screen_resolution = Vector2.ZERO
	_open_menus.clear()
	open_menus_updated.emit(open_menus)
	_is_loading = false
	_is_saving = false
	_is_hud_visible = false
