class_name UIProvider
extends ContextProvider

var context: UIContext

# ===
# Built-In
# ===

func _init(
	p_context: UIContext
) -> void:
	context = p_context

# ===
# Public
# ===

func toggle_menu(
	menu_type: Enums.MenuType, 
	is_visible: bool
) -> void:
	if is_visible:
		if not context.open_menus.has(menu_type):
			context.open_menus.append(menu_type)
	else:
		context.open_menus.erase(menu_type)
	
	context.open_menus_updated.emit(menu_type)

func set_open_menus(
	value: Array[Enums.MenuType]
) -> void:
	context.open_menus = value

func is_menu_open(
	menu_type: Enums.MenuType
) -> bool:
	return (menu_type in context.open_menus)
