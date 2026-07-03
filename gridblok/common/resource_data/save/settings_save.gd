class_name SettingsSaveData
extends Resource

@export_category("Audio")
@export_range(0.0, 1.0, 0.01) var master_volume: float = 1.0
@export_range(0.0, 1.0, 0.01) var music_volume: float = 1.0
@export_range(0.0, 1.0, 0.01) var sfx_volume: float = 1.0
@export_range(0, 2, 1) var muted_buses: int = 0

@export_category("Controls")
@export_range(0.0, 1.0, 0.01) var controller_sensitivity_x: float = 1.0
@export_range(0.0, 1.0, 0.01) var controller_sensitivity_y: float = 1.0

@export_category("Gameplay")
@export var death_particles: bool = true
@export var auto_open_upgrade: bool = true
@export var damage_flash: bool = true
