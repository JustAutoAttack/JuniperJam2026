class_name Constants
extends RefCounted

const MOUSE_INPUT_COEFFICIENT: float = 0.005

const BASE_STATS: Dictionary[Enums.StatType, float] = {
	# Offense
	Enums.StatType.DAMAGE: 35.0,
	Enums.StatType.BLADE_SPEED: 1.0,
	Enums.StatType.BLADE_COUNT: 1.0,
	Enums.StatType.BLADE_SIZE: 1.0,
	Enums.StatType.CRIT_CHANCE: 0.25,
	Enums.StatType.ORBIT_VELOCITY: 1.0,
	Enums.StatType.ORBIT_RADIUS: 3.0,
	
	# Defense
	Enums.StatType.MAX_HEALTH: 100.0,
	Enums.StatType.HEALTH_REGEN: 0.0,
	Enums.StatType.EVASION: 0.0,
	Enums.StatType.LIFESTEAL_AMOUNT: 0.0,
	Enums.StatType.LIFESTEAL_CHANCE: 0.05,
	Enums.StatType.SHIELD_COUNT: 0.0,
	Enums.StatType.SHIELD_REGEN: 0.25,
	Enums.StatType.KNOCKBACK_FORCE: 0.0,
	Enums.StatType.KNOCKBACK_CHANCE: 0.01,
	
	# Utility
	Enums.StatType.MOVE_SPEED: 1.0,
	Enums.StatType.COLLECT_RANGE: 2.0,
	Enums.StatType.XP_GAIN: 0.0,
	Enums.StatType.XP_DOUBLE_CHANCE: 0.0,
}

class AudioPaths:
	
	const AUDIO_VOLUME_COEFFICIENT: float= 1.0
	const BASE_SFX_PATH: String = "res://assets/audio/sfx/"
	const SFX_PATHS: Dictionary[Enums.SFXType, String] = {
		Enums.SFXType.BLADE_HIT: BASE_SFX_PATH + "blade_hit.mp3",
		Enums.SFXType.BLADE_ROTATION: BASE_SFX_PATH + "blade_rotation.mp3",
		Enums.SFXType.BLOCKER_ATTACK_IMPACT: BASE_SFX_PATH + "blocker_attack-impact.mp3",
		Enums.SFXType.BLOCKER_ATTACK_PREPARE: BASE_SFX_PATH + "blocker_attack-prepare.mp3",
		Enums.SFXType.BURSTER_SHOT: BASE_SFX_PATH + "burster_shot.mp3",
		Enums.SFXType.CHARGER_ATTACK: BASE_SFX_PATH + "charger_attack.mp3",
		Enums.SFXType.CREDIT_INSERTED: BASE_SFX_PATH + "credit_inserted.mp3",
		Enums.SFXType.PLAYER_DAMAGED: BASE_SFX_PATH + "player_damaged.mp3",
		Enums.SFXType.PLAYER_DIED: BASE_SFX_PATH + "player_died.mp3",
		Enums.SFXType.SEEKER_EXPLOSION: BASE_SFX_PATH + "seeker_explosion.mp3",
		Enums.SFXType.UI_DENIED: BASE_SFX_PATH + "ui_denied.mp3",
		Enums.SFXType.UI_MENU_OPENED: BASE_SFX_PATH + "ui_menu_opened.mp3",
		Enums.SFXType.UI_MENU_CLOSED: BASE_SFX_PATH + "ui_menu_closed.mp3",
		Enums.SFXType.UI_NOTIFICATION: BASE_SFX_PATH + "ui_notification.mp3",
		Enums.SFXType.UI_SELECT_ONE: BASE_SFX_PATH + "ui_select_1.mp3",
		Enums.SFXType.UI_SELECT_TWO: BASE_SFX_PATH + "ui_select_2.mp3",
		Enums.SFXType.UPGRADE_AQCUIRED: BASE_SFX_PATH + "upgrade_aqcuired.mp3",
		Enums.SFXType.XP_COLLECTED: BASE_SFX_PATH + "xp_collected.mp3",
	}

class SynthColors:

	# --- Neon/Light (Primary/Accents) ---
	const NEON_PINK: Color   = Color("#ff00cc") # Iconic Synthwave Pink
	const NEON_CYAN: Color   = Color("#00f3ff") # Electric Cyan
	const NEON_YELLOW: Color = Color("#f4ff00") # Acid Yellow
	const NEON_PURPLE: Color = Color("#bd00ff") # Deep Neon Violet
	const NEON_GREEN: Color  = Color("#39ff14") # CRT Green
	const CYBER_RED: Color    = Color("#d3095f") # The "Error/Critical" Red
	const SYNTH_ORANGE: Color = Color("#ff6600") # High-energy, glowing Orange
	
	# --- Dark/Muted (Backgrounds/UI Panels) ---
	const DEEP_VOID: Color    = Color("#05050a") # Almost black
	const DARK_PURPLE: Color  = Color("#1a0b2e") # Dark backdrop purple
	const TECH_GREY: Color    = Color("#2a2a35") # Muted industrial grey
	const MIDNIGHT_BLUE: Color = Color("#0a0a1e") # Deep navy base

class PhysicsLayer:
	
	# Index
	const WORLD_INDEX: int = 1
	const PLAYER_INDEX: int = 2
	const ENEMY_INDEX: int = 3
	const ITEM_INDEX: int = 4
	const DAMAGE_INDEX: int = 5
	const DEBRIS_INDEX: int = 6
	const ARENA_WALLS_INDEX: int = 7

	# Mask
	const WORLD_MASK: int = 1 << 0
	const PLAYER_MASK: int = 1 << 1
	const ENEMY_MASK: int = 1 << 2
	const ITEM_MASK: int = 1 << 3
	const DAMAGE_MASK: int = 1 << 4
	const DEBRIS_MASK: int = 1 << 5
	const ARENA_WALLS_MASK: int = 1 << 6

class ScenePaths:
	
	# --- Base ---
	const CORE_DIR: String = "res://core/scenes/"
	const FEATURES_DIR: String = "res://features/"
	
	# --- Core ---
	const BOOTSPLASH: String = CORE_DIR + "bootsplash/bootsplash.tscn"
	const GAME: String = CORE_DIR + "game/game.tscn"
	const TITLE: String = CORE_DIR + "title/title.tscn"
	const WORLD: String = CORE_DIR + "world/world.tscn"
	const PLAYER: String = CORE_DIR + "player/player.tscn"
	
	# --- Features ---
	
	# Base
	const PROJECTILES_DIR: String = FEATURES_DIR + "projectiles/"
	
	# Single
	const XP_ITEM: String = FEATURES_DIR + "xp_item/xp_item.tscn"
	const DEBRIS: String = FEATURES_DIR + "debris/debris.tscn"
	const POPUP_LABEL: String = FEATURES_DIR + "popup_label/popup_label.tscn"
	
	# Projectiles
	const BURSTER_PROJECTILE: String = PROJECTILES_DIR + "burster/burster.tscn"
	
	# Enemies
	const ENEMIES_DIR: String = FEATURES_DIR + "enemies/"
	const ENEMIES_TABLE: Dictionary[Enums.EnemyType, String] = {
		Enums.EnemyType.BLOCKER: ENEMIES_DIR + "blocker/blocker.tscn",
		Enums.EnemyType.BURSTER: ENEMIES_DIR + "burster/burster.tscn",
		Enums.EnemyType.CHARGER: ENEMIES_DIR + "charger/charger.tscn",
		Enums.EnemyType.SEEKER: ENEMIES_DIR + "seeker/seeker.tscn",
	}
	

class DataPaths:
	
	# --- Base ---
	const BASE_DIR: String = "res://assets/data/"
	
	# --- Saves ---
	const SAVES_DIR: String = BASE_DIR + "saves/"
	
	const NEW_GAME_SAVE: String = SAVES_DIR + "new_game.tres"
	const DEFAULT_SETTINGS_SAVE: String = SAVES_DIR + "default_settings.tres"
	
	# --- User Saves ---
	const USER_SAVES_DIR: String = "user://saves/"
	const USER_GAME_SAVES_DIR: String = USER_SAVES_DIR + "games/"
	const USER_GAME_AUTOSAVES_DIR: String = USER_SAVES_DIR + "games/autosave/"
	const USER_SETTINGS_SAVE: String = USER_SAVES_DIR + "settings.tres"
	
	# --- Enemies ---
	const ENEMIES_DIR: String = BASE_DIR + "enemies/"
	const ENEMIES_TABLE: Dictionary[Enums.EnemyType, String] = {
		Enums.EnemyType.BLOCKER: ENEMIES_DIR + "blocker.tres",
		Enums.EnemyType.BURSTER: ENEMIES_DIR + "burster.tres",
		Enums.EnemyType.CHARGER: ENEMIES_DIR + "charger.tres",
		Enums.EnemyType.SEEKER: ENEMIES_DIR + "seeker.tres",
	}
	
	# --- Upgrades ---
	const UPGRADES_DIR: String = BASE_DIR + "upgrades/"
	const UPGRADES_TABLE: Dictionary[Enums.UpgradeType, String] = {
		# Offense
		Enums.UpgradeType.BLADE_SHARPNESS: UPGRADES_DIR + "blade_sharpness.tres",
		Enums.UpgradeType.BLADE_VELOCITY: UPGRADES_DIR + "blade_velocity.tres",
		Enums.UpgradeType.BLADE_MULTIPLIER: UPGRADES_DIR + "blade_multiplier.tres",
		Enums.UpgradeType.BLADE_MAGNITUDE: UPGRADES_DIR + "blade_magnitude.tres",
		Enums.UpgradeType.BLADE_PRECISION: UPGRADES_DIR + "blade_precision.tres",
		Enums.UpgradeType.ORBIT_RADIUS: UPGRADES_DIR + "orbit_radius.tres",
		Enums.UpgradeType.ORBIT_VELOCITY: UPGRADES_DIR + "orbit_velocity.tres",
		
		# Defense
		Enums.UpgradeType.VITALITY_BOOST: UPGRADES_DIR + "vitality_boost.tres",
		Enums.UpgradeType.REGENERATION: UPGRADES_DIR + "regeneration.tres",
		Enums.UpgradeType.DODGE_CHANCE: UPGRADES_DIR + "dodge_chance.tres",
		Enums.UpgradeType.VAMPRISM: UPGRADES_DIR + "vamprism.tres",
		Enums.UpgradeType.VAMPRISM_CHANCE: UPGRADES_DIR + "vamprism_chance.tres",
		Enums.UpgradeType.SHIELD_ARRAY: UPGRADES_DIR + "shield_array.tres",
		Enums.UpgradeType.SHIELD_REPAIR: UPGRADES_DIR + "shield_repair.tres",
		Enums.UpgradeType.REPULSION_FIELD: UPGRADES_DIR + "repulsion_field.tres",
		Enums.UpgradeType.REPULSION_RATE: UPGRADES_DIR + "repulsion_rate.tres",
		
		# Utility
		Enums.UpgradeType.AGILITY: UPGRADES_DIR + "agility.tres",
		Enums.UpgradeType.GRAVITY_WELL: UPGRADES_DIR + "gravity_well.tres",
		Enums.UpgradeType.XP_GAIN: UPGRADES_DIR + "xp_gain.tres",
		Enums.UpgradeType.XP_DOUBLE_RATE: UPGRADES_DIR + "xp_double_rate.tres",
	}
	
	# --- Stats ---
	const STATS_DIR: String = BASE_DIR + "stats/"
	const STATS_TABLE: Dictionary[Enums.StatType, String] = {
		# Offense
		Enums.StatType.DAMAGE: STATS_DIR + "damage.tres",
		Enums.StatType.BLADE_SPEED: STATS_DIR + "blade_speed.tres",
		Enums.StatType.BLADE_COUNT: STATS_DIR + "blade_count.tres",
		Enums.StatType.BLADE_SIZE: STATS_DIR + "blade_size.tres",
		Enums.StatType.CRIT_CHANCE: STATS_DIR + "crit_chance.tres",
		Enums.StatType.ORBIT_VELOCITY: STATS_DIR + "orbit_velocity.tres",
		Enums.StatType.ORBIT_RADIUS: STATS_DIR + "orbit_radius.tres",
		
		# Defense
		Enums.StatType.MAX_HEALTH: STATS_DIR + "max_health.tres",
		Enums.StatType.HEALTH_REGEN: STATS_DIR + "health_regen.tres",
		Enums.StatType.EVASION: STATS_DIR + "evasion.tres",
		Enums.StatType.LIFESTEAL_AMOUNT: STATS_DIR + "lifesteal_amount.tres",
		Enums.StatType.LIFESTEAL_CHANCE: STATS_DIR + "lifesteal_chance.tres",
		Enums.StatType.SHIELD_COUNT: STATS_DIR + "shield_count.tres",
		Enums.StatType.SHIELD_REGEN: STATS_DIR + "shield_regen.tres",
		Enums.StatType.KNOCKBACK_FORCE: STATS_DIR + "knockback_force.tres",
		Enums.StatType.KNOCKBACK_CHANCE: STATS_DIR + "knockback_chance.tres",
		
		# Utility
		Enums.StatType.MOVE_SPEED: STATS_DIR + "move_speed.tres",
		Enums.StatType.COLLECT_RANGE: STATS_DIR + "collect_range.tres",
		Enums.StatType.XP_GAIN: STATS_DIR + "xp_gain.tres",
		Enums.StatType.XP_DOUBLE_CHANCE: STATS_DIR + "xp_double_chance.tres",
	}
	
	# --- Popups ---
	const POPUPS_DIR: String = BASE_DIR + "popups/"
	const POPUPS_TABLE: Dictionary[Enums.PopupType, String] = {
		Enums.PopupType.NORMAL_DAMAGE: POPUPS_DIR + "normal_damage.tres",
		Enums.PopupType.CRIT_DAMAGE: POPUPS_DIR + "crit_damage.tres",
		Enums.PopupType.HEAL: POPUPS_DIR + "heal.tres",
		Enums.PopupType.EVADED: POPUPS_DIR + "evaded.tres",
		Enums.PopupType.SHIELD_DAMAGED: POPUPS_DIR + "shield_damage.tres",
	}

class MaterialPaths:
	
	const BASE_DIR: String = "res://assets/materials/"
	const DEBRIS_DIR: String = BASE_DIR + "debris/"
	
	# --- Debris ---
	const PLAYER_DEBRIS: String = DEBRIS_DIR + "player.material"
	
	const ENEMY_DEBRIS_DIR: String = DEBRIS_DIR + "enemy/"
	const ENEMY_DEBRIS_TABLE: Dictionary[Enums.EnemyType, String] = {
		Enums.EnemyType.BLOCKER: ENEMY_DEBRIS_DIR + "blocker.material",
		Enums.EnemyType.BURSTER: ENEMY_DEBRIS_DIR + "burster.material",
		Enums.EnemyType.CHARGER: ENEMY_DEBRIS_DIR + "charger.material",
		Enums.EnemyType.SEEKER: ENEMY_DEBRIS_DIR + "seeker.material",
	}
