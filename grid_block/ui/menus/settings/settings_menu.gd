class_name UISettingsMenu
extends UIMenu

@onready var master_volume_control: UISettingsMenuVolumeControl = %MasterVolumeControl
@onready var music_volume_control: UISettingsMenuVolumeControl = %MusicVolumeControl
@onready var sfx_volume_control: UISettingsMenuVolumeControl = %SFXVolumeControl

func _ready() -> void:
	_sync_ui_from_context()
	
	visibility_changed.connect(func(): if visible: _sync_ui_from_context())
	
	master_volume_control.mute_toggled.connect(_on_mute_toggled.bind(Enums.AudioBusType.MASTER))
	music_volume_control.mute_toggled.connect(_on_mute_toggled.bind(Enums.AudioBusType.MUSIC))
	sfx_volume_control.mute_toggled.connect(_on_mute_toggled.bind(Enums.AudioBusType.SFX))

	master_volume_control.ratio_changed.connect(_on_volume_slider_changed.bind(Enums.AudioBusType.MASTER))
	music_volume_control.ratio_changed.connect(_on_volume_slider_changed.bind(Enums.AudioBusType.MUSIC))
	sfx_volume_control.ratio_changed.connect(_on_volume_slider_changed.bind(Enums.AudioBusType.SFX))

func _sync_ui_from_context() -> void:
	var s_pro: SettingsProvider = Session.settings_provider
	var s_ctx: SettingsContext = Session.settings_context
	
	master_volume_control.ratio = s_ctx.master_volume
	master_volume_control.is_muted = s_pro.is_bus_muted(Enums.AudioBusType.MASTER)
	
	music_volume_control.ratio = s_ctx.music_volume
	music_volume_control.is_muted = s_pro.is_bus_muted(Enums.AudioBusType.MUSIC)
	
	sfx_volume_control.ratio = s_ctx.sfx_volume
	sfx_volume_control.is_muted = s_pro.is_bus_muted(Enums.AudioBusType.SFX)

func _emit_action(action: Enums.SettingsMenuAction) -> void:
	EventBus.emit(
		UIEvent.SettingsMenu.new(
			action
		)
	)

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
