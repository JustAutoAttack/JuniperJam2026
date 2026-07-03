class_name SettingsProvider
extends ContextProvider

var context: SettingsContext

const BusMuteFlag := {
	Enums.AudioBusType.MASTER: 1 << 0,
	Enums.AudioBusType.MUSIC: 1 << 1,
	Enums.AudioBusType.SFX: 1 << 2,
}

# ===
# Built-In
# ===

func _init(p_context: SettingsContext) -> void:
	context = p_context

# ===
# Public
# ===

# --- Audio ---
func set_volume(bus: Enums.AudioBusType, value: float) -> void:
	value = clampf(value, 0.0, 1.0)
	
	match bus:
		Enums.AudioBusType.MASTER:
			context.master_volume = value
		Enums.AudioBusType.MUSIC:
			context.music_volume = value
		Enums.AudioBusType.SFX:
			context.sfx_volume = value

func set_bus_mute(bus: Enums.AudioBusType, value: bool) -> void:
	var flags := context.muted_buses
	var mask: int = BusMuteFlag[bus]

	if value:
		flags |= mask
	else:
		flags &= ~mask

	context.muted_buses = flags

func is_bus_muted(bus: Enums.AudioBusType) -> bool:
	var mask: int = BusMuteFlag[bus]
	return (context.muted_buses & mask) != 0

# --- Controls ---
func set_controller_sensitivity(value: Vector2) -> void:
	context.controller_sensitivity_x = clampf(value.x, 0.0, 1.0)
	context.controller_sensitivity_y = clampf(value.y, 0.0, 1.0)

func get_controller_sensitivity() -> Vector2:
	return Vector2(
		context.controller_sensitivity_x,
		context.controller_sensitivity_y
	)

# --- Toggles ---
func set_death_particles(value: bool) -> void:
	context.death_particles = value

func set_auto_open_upgrade(value: bool) -> void:
	context.auto_open_upgrade = value

func set_damage_flash(value: bool) -> void:
	context.damage_flash = value
