@tool
class_name AssetProvider
extends RefCounted

# Scenes
static var _bootsplash: PackedScene = null
static var _game: PackedScene = null
static var _title: PackedScene = null
static var _world: PackedScene = null
static var _player: PackedScene = null
static var _xp: PackedScene = null
static var _blocker_enemy: PackedScene = null
static var _burster_enemy: PackedScene = null
static var _charger_enemy: PackedScene = null
static var _seeker_enemy: PackedScene = null
static var _debris_scene: PackedScene = null
static var _popup_label_scene: PackedScene = null
static var _burster_projectile_scene: PackedScene = null

# Data
static var _new_game_save_data: GameSaveData = null
static var _default_settings_save_data: SettingsSaveData = null
static var _enemy_data: Dictionary[Enums.EnemyType, EnemyData] = {}
static var _stat_data: Dictionary[Enums.StatType, StatData] = {}
static var _upgrade_data: Dictionary[Enums.UpgradeType, UpgradeData] = {}
static var _popup_data: Dictionary[Enums.PopupType, PopupData] = {}

# Materials
static var _player_debris_material: StandardMaterial3D = null
static var _enemy_debris_materials: Dictionary[Enums.EnemyType, StandardMaterial3D] = {}

static func setup_cache() -> void:
	clear_cache()
	
	# Scenes
	_cache_bootsplash_scene()
	_cache_game_scene()
	_cache_title_scene()
	_cache_world_scene()
	_cache_player_scene()
	_cache_xp_scene()
	_cache_enemy_scenes()
	_cache_debris_scene()
	_cache_popup_label_scene()
	_cache_burster_projectile_scene()
	
	# Data
	_cache_default_settings_save_data()
	_cache_new_game_save_data()
	_cache_stat_data()
	_cache_upgrade_data()
	_cache_popup_data()
	_cache_enemy_data()
	
	# Material
	_cache_player_debris_material()
	_cache_enemy_debris_materials()

static func clear_cache() -> void:
	# Scenes
	_bootsplash = null
	_game = null
	_title = null
	_world = null
	_player = null
	_xp = null
	_blocker_enemy = null
	_burster_enemy = null
	_charger_enemy = null
	_seeker_enemy = null
	_debris_scene = null
	_popup_label_scene = null
	_burster_projectile_scene = null
	
	# Data
	_new_game_save_data = null
	_default_settings_save_data = null
	_enemy_data.clear()
	_stat_data.clear()
	_upgrade_data.clear()
	_popup_data.clear()
	
	# Materials
	_player_debris_material = null
	_enemy_debris_materials.clear()

# ===
# Scenes
# ===

# --- Bootsplash ---
static func _cache_bootsplash_scene() -> void:
	_bootsplash = AssetLoader.load_packed_scene(
		Constants.ScenePaths.BOOTSPLASH, 
	)

static func get_bootsplash_scene() -> Bootsplash:
	if _bootsplash:
		return _bootsplash.instantiate() as Bootsplash
	return null

# --- Game ---
static func _cache_game_scene() -> void:
	_game = AssetLoader.load_packed_scene(
		Constants.ScenePaths.GAME, 
	)

static func get_game_scene() -> Game:
	if _game:
		return _game.instantiate() as Game
	return null

# --- Title ---
static func _cache_title_scene() -> void:
	_title = AssetLoader.load_packed_scene(
		Constants.ScenePaths.TITLE, 
	)

static func get_title_scene() -> Title:
	if _title:
		return _title.instantiate() as Title
	return null

# --- World ---
static func _cache_world_scene() -> void:
	_world = AssetLoader.load_packed_scene(
		Constants.ScenePaths.WORLD, 
	)

static func get_world_scene() -> World:
	if _world:
		return _world.instantiate() as World
	return null

# --- Player ---
static func _cache_player_scene() -> void:
	_player = AssetLoader.load_packed_scene(
		Constants.ScenePaths.PLAYER, 
	)

static func get_player_scene() -> Player:
	if _player:
		return _player.instantiate() as Player
	return null

# --- XP ---
static func _cache_xp_scene() -> void:
	_xp = AssetLoader.load_packed_scene(
		Constants.ScenePaths.XP_ITEM
	)

static func get_xp_scene() -> PackedScene:
	return _xp

# --- Enemy ---
static func _cache_enemy_scenes() -> void:
	_blocker_enemy = AssetLoader.load_packed_scene(
		Constants.ScenePaths.ENEMIES_TABLE.get(Enums.EnemyType.BLOCKER)
	) as PackedScene
	_burster_enemy = AssetLoader.load_packed_scene(
		Constants.ScenePaths.ENEMIES_TABLE.get(Enums.EnemyType.BURSTER)
	) as PackedScene
	_charger_enemy = AssetLoader.load_packed_scene(
		Constants.ScenePaths.ENEMIES_TABLE.get(Enums.EnemyType.CHARGER)
	) as PackedScene
	_seeker_enemy = AssetLoader.load_packed_scene(
		Constants.ScenePaths.ENEMIES_TABLE.get(Enums.EnemyType.SEEKER)
	) as PackedScene

static func get_enemy_scene(enemy_type: Enums.EnemyType) -> PackedScene:
	match enemy_type:
		Enums.EnemyType.BLOCKER: return _blocker_enemy
		Enums.EnemyType.BURSTER: return _burster_enemy
		Enums.EnemyType.CHARGER: return _charger_enemy
		Enums.EnemyType.SEEKER: return _seeker_enemy
		_: return null

# --- Debris ---
static func _cache_debris_scene() -> void:
	_debris_scene = AssetLoader.load_packed_scene(
		Constants.ScenePaths.DEBRIS
	)

static func get_debris_scene() -> PackedScene:
	return _debris_scene

# --- Popup Label ---
static func _cache_popup_label_scene() -> void:
	_popup_label_scene = AssetLoader.load_packed_scene(
		Constants.ScenePaths.POPUP_LABEL
	)

static func get_popup_label_scene() -> PackedScene:
	return _popup_label_scene

# --- Projectiles ---
static func _cache_burster_projectile_scene() -> void:
	_burster_projectile_scene = AssetLoader.load_packed_scene(
		Constants.ScenePaths.BURSTER_PROJECTILE
	)

static func get_burster_projectile_scene() -> PackedScene:
	return _burster_projectile_scene

# ===
# Data 
# ===

# --- User Settings Save ---
static func get_settings_save_data() -> SettingsSaveData:
	return AssetLoader.load_resource(
		Constants.DataPaths.USER_SETTINGS_SAVE, 
		SettingsSaveData
	) as SettingsSaveData

# --- Default Settings Save ---
static func _cache_default_settings_save_data() -> void:
	_default_settings_save_data = AssetLoader.load_resource(
		Constants.DataPaths.DEFAULT_SETTINGS_SAVE, 
		SettingsSaveData
	) as SettingsSaveData

static func get_default_settings_save_data() -> SettingsSaveData:
	return _default_settings_save_data

# --- New Game Save ---
static func _cache_new_game_save_data() -> void:
	_new_game_save_data = AssetLoader.load_resource(
		Constants.DataPaths.NEW_GAME_SAVE, 
		GameSaveData
	) as GameSaveData

static func get_new_game_save_data() -> GameSaveData:
	return _new_game_save_data

# --- Enemy ---
static func _cache_enemy_data() -> void:
	for enemy_type: Enums.EnemyType in Enums.EnemyType.values():
		_enemy_data[enemy_type] = AssetLoader.load_resource_from_table(
			enemy_type,
			Constants.DataPaths.ENEMIES_TABLE,
			Enums.EnemyType.keys(),
			EnemyData
		) as EnemyData

static func get_enemy_data(enemy_type: Enums.EnemyType) -> EnemyData:
	return _enemy_data.get(enemy_type)

# --- Stats ---
static func _cache_stat_data() -> void:
	for stat_type: Enums.StatType in Enums.StatType.values():
		_stat_data[stat_type] = AssetLoader.load_resource_from_table(
			stat_type,
			Constants.DataPaths.STATS_TABLE,
			Enums.StatType.keys(),
			StatData
		) as StatData

static func get_stat_data(stat_type: Enums.StatType) -> StatData:
	return _stat_data.get(stat_type)

# --- Upgrades ---
static func _cache_upgrade_data() -> void:
	for upgrade_type: Enums.UpgradeType in Enums.UpgradeType.values():
		_upgrade_data[upgrade_type] = AssetLoader.load_resource_from_table(
			upgrade_type,
			Constants.DataPaths.UPGRADES_TABLE,
			Enums.UpgradeType.keys(),
			UpgradeData
		) as UpgradeData

static func get_upgrade_data(upgrade_type: Enums.UpgradeType) -> UpgradeData:
	return _upgrade_data.get(upgrade_type)

# --- Popups ---
static func _cache_popup_data() -> void:
	for popup_type: Enums.PopupType in Enums.PopupType.values():
		_popup_data[popup_type] = AssetLoader.load_resource_from_table(
			popup_type,
			Constants.DataPaths.POPUPS_TABLE,
			Enums.PopupType.keys(),
			PopupData
		) as PopupData

static func get_popup_data(popup_type: Enums.PopupType) -> PopupData:
	return _popup_data.get(popup_type)

# ===
# Materials
# ===

# --- Debris ---
static func _cache_enemy_debris_materials() -> void:
	for enemy_type: Enums.EnemyType in Enums.EnemyType.values():
		_enemy_debris_materials[enemy_type] = AssetLoader.load_resource_from_table(
			enemy_type,
			Constants.MaterialPaths.ENEMY_DEBRIS_TABLE,
			Enums.EnemyType.keys(),
			StandardMaterial3D
		) as StandardMaterial3D

static func get_enemy_debris_material(enemy_type: Enums.EnemyType) -> StandardMaterial3D:
	return _enemy_debris_materials.get(enemy_type)

static func _cache_player_debris_material() -> void:
	_player_debris_material = AssetLoader.load_resource(
		Constants.MaterialPaths.PLAYER_DEBRIS,
		StandardMaterial3D
	) as StandardMaterial3D

static func get_player_debris_material() -> StandardMaterial3D:
	return _player_debris_material
