class_name Enums
extends RefCounted

# ===
# UI
# ===

enum MenuType {
	MAIN,
	PAUSE,
	SETTINGS,
	UPGRADE,
	CREDITS,
	GAME_OVER
}

enum HUDAction {
	UPGRADE_MENU,
	PAUSE
}

enum MainMenuAction { 
	SPIN, 
	SETTINGS,
	CREDITS,
	QUIT
}

enum PauseMenuAction { 
	RESUME, 
	SETTINGS,
	SAVE,
	EXIT, 
	QUIT
}

enum SettingsMenuAction {
	SAVE,
	DEFAULT_ALL
}

enum CreditsMenuAction {
	DONE
}

enum GameOverMenuAction {
	RESPIN,
	TO_MAIN_MENU,
	CREDITS,
	QUIT
}

# ===
# Audio
# ===

enum AudioBusType {
	MASTER,
	MUSIC,
	SFX
}

enum SFXType {
	BLADE_HIT,
	BLADE_ROTATION,
	BLOCKER_ATTACK_IMPACT,
	BLOCKER_ATTACK_PREPARE,
	BURSTER_SHOT,
	CHARGER_ATTACK,
	CREDIT_INSERTED,
	PLAYER_DAMAGED,
	PLAYER_DIED,
	SEEKER_EXPLOSION,
	UI_DENIED,
	UI_MENU_OPENED,
	UI_MENU_CLOSED,
	UI_NOTIFICATION,
	UI_SELECT_ONE,
	UI_SELECT_TWO,
	UPGRADE_AQCUIRED,
	XP_COLLECTED
}

# ===
# Gameplay
# ===

# --- Popups ---
enum PopupType {
	NORMAL_DAMAGE,
	CRIT_DAMAGE,
	HEAL,
	EVADED,
	SHIELD_DAMAGED
}

# --- Enemy ---
enum EnemyType {
	BLOCKER,
	BURSTER,
	CHARGER,
	SEEKER
}

# --- Stats ---
enum StatType {
	# Offense
	DAMAGE,
	BLADE_SPEED,
	BLADE_COUNT,
	BLADE_SIZE,
	CRIT_CHANCE,
	ORBIT_VELOCITY,
	ORBIT_RADIUS,
	
	# Defense
	MAX_HEALTH,
	HEALTH_REGEN,
	EVASION,
	LIFESTEAL_AMOUNT,
	LIFESTEAL_CHANCE,
	SHIELD_COUNT,
	SHIELD_REGEN,
	KNOCKBACK_FORCE,
	KNOCKBACK_CHANCE,
	
	# Utility
	MOVE_SPEED,
	COLLECT_RANGE,
	XP_GAIN,
	XP_DOUBLE_CHANCE,
}

# --- Status Effect ---
enum StatusEffectType {
	SLOW,
	KNOCKBACK
}

# --- Upgrades ---
enum UpgradeCategory {
	OFFENSE,
	DEFENSE,
	UTILITY
}

enum UpgradeTierLevel {
	TIER_1,
	TIER_2,
	TIER_3,
	TIER_4,
	TIER_5
}

enum UpgradeType {
	# --- Offense ---
	BLADE_SHARPNESS,    # Damage
	BLADE_VELOCITY,     # Blade Speed
	BLADE_MULTIPLIER,   # Blade Count
	BLADE_MAGNITUDE,    # Blade Size
	BLADE_PRECISION,    # Crit Chance
	ORBIT_RADIUS,       # Attack Range
	ORBIT_VELOCITY,     # Spin Speed
	
	# --- Defense ---
	VITALITY_BOOST,       # Max Health
	REGENERATION,         # Health Regen
	DODGE_CHANCE,         # Evasion
	VAMPRISM,             # Lifesteal Amount
	VAMPRISM_CHANCE,      # Lifesteal Chance
	SHIELD_ARRAY,         # Shield Count
	SHIELD_REPAIR,        # Shield Count
	REPULSION_FIELD,      # Knockback Force
	REPULSION_RATE,       # Knockback Chance
	
	# --- Utility ---
	AGILITY,              # Move Speed
	GRAVITY_WELL,         # Collect Range
	XP_GAIN,              # + Percentage Amount
	XP_DOUBLE_RATE,       # Chance to Double Amount
}
