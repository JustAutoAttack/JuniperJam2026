class_name UISettingsMenu
extends UIMenu

# Volume
@onready var master_volume_control: UISettingsMenuVolumeControl = %MasterVolumeControl
@onready var music_volume_control: UISettingsMenuVolumeControl = %MusicVolumeControl
@onready var sfx_volume_control: UISettingsMenuVolumeControl = %SFXVolumeControl

# Toggles
@onready var death_particles: UISettingsMenuToggleItem = %DeathParticles
@onready var auto_open_upgrade: UISettingsMenuToggleItem = %AutoOpenUpgrade
@onready var damage_flash: UISettingsMenuToggleItem = %DamageFlash

# ===
# Built-In
# ===

func _ready() -> void:
	_sync_ui_from_context()
	_setup_volume()
	_setup_toggles()
	visibility_changed.connect(_on_visibility_changed)

# ===
# Private
# ===

func _setup_volume() -> void:
	master_volume_control.mute_toggled.connect(_on_mute_toggled.bind(Enums.AudioBusType.MASTER))
	music_volume_control.mute_toggled.connect(_on_mute_toggled.bind(Enums.AudioBusType.MUSIC))
	sfx_volume_control.mute_toggled.connect(_on_mute_toggled.bind(Enums.AudioBusType.SFX))

	master_volume_control.ratio_changed.connect(_on_volume_slider_changed.bind(Enums.AudioBusType.MASTER))
	music_volume_control.ratio_changed.connect(_on_volume_slider_changed.bind(Enums.AudioBusType.MUSIC))
	sfx_volume_control.ratio_changed.connect(_on_volume_slider_changed.bind(Enums.AudioBusType.SFX))

func _setup_toggles() -> void:
	death_particles.toggled.connect(_on_death_particles_toggled)
	auto_open_upgrade.toggled.connect(_on_auto_open_upgrade_toggled)
	damage_flash.toggled.connect(_on_damage_flash_toggled)

func _sync_ui_from_context() -> void:
	var s_pro: SettingsProvider = Session.settings_provider
	var s_ctx: SettingsContext = Session.settings_context
	
	master_volume_control.ratio = s_ctx.master_volume
	master_volume_control.is_muted = s_pro.is_bus_muted(Enums.AudioBusType.MASTER)
	
	music_volume_control.ratio = s_ctx.music_volume
	music_volume_control.is_muted = s_pro.is_bus_muted(Enums.AudioBusType.MUSIC)
	
	sfx_volume_control.ratio = s_ctx.sfx_volume
	sfx_volume_control.is_muted = s_pro.is_bus_muted(Enums.AudioBusType.SFX)
	
	death_particles.toggle(s_ctx.death_particles)
	auto_open_upgrade.toggle(s_ctx.auto_open_upgrade)
	damage_flash.toggle(s_ctx.damage_flash)

func _emit_action(action: Enums.SettingsMenuAction) -> void:
	EventBus.emit(
		UIEvent.SettingsMenu.new(
			action
		)
	)

# ===
# Signals
# ===

func _on_visibility_changed() -> void:
	_sync_ui_from_context()

func _on_save() -> void:
	_emit_press_sfx()
	_emit_action(Enums.SettingsMenuAction.SAVE)

func _on_mute_toggled(
	value: bool,
	bus: Enums.AudioBusType
) -> void:
	Session.settings_provider.set_bus_mute(bus, value)

func _on_volume_slider_changed(
	value: float,
	bus: Enums.AudioBusType
) -> void:
	Session.settings_provider.set_volume(bus, value)

func _on_death_particles_toggled(toggled_on: bool) -> void:
	_emit_press_sfx()
	Session.settings_provider.set_death_particles(toggled_on)

func _on_auto_open_upgrade_toggled(toggled_on: bool) -> void:
	_emit_press_sfx()
	Session.settings_provider.set_auto_open_upgrade(toggled_on)

func _on_damage_flash_toggled(toggled_on: bool) -> void:
	_emit_press_sfx()
	Session.settings_provider.set_damage_flash(toggled_on)
