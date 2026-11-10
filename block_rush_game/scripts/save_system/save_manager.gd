## BLOCK RUSH — SaveManager (Autoload Singleton)
## Handles all local persistence using ConfigFile.
## Recovers gracefully from missing or malformed data.

extends Node

const SAVE_PATH        := "user://block_rush_save.cfg"
const SECTION_SCORES   := "scores"
const SECTION_RUN      := "run"
const SECTION_SETTINGS := "settings"
const SECTION_DAILY    := "daily"
const SECTION_STATS    := "stats"

var _config: ConfigFile

func _ready() -> void:
	_config = ConfigFile.new()
	_load_file()

## ---- Best Score ----

func save_best_score(value: int) -> void:
	_config.set_value(SECTION_SCORES, "best_score", value)
	_save_file()

func load_best_score() -> int:
	if not _config.has_section_key(SECTION_SCORES, "best_score"):
		return 0
	return int(_config.get_value(SECTION_SCORES, "best_score", 0))

## ---- Daily Challenge & Streaks ----

func get_daily_streak() -> int:
	var today := Time.get_date_string_from_system()
	var last_date := str(_config.get_value(SECTION_DAILY, "last_date", ""))
	var streak: int = int(_config.get_value(SECTION_DAILY, "streak", 0))
	if last_date == "" or streak == 0:
		return 0
	if last_date == today:
		return streak
	var last_unix: int = int(_config.get_value(SECTION_DAILY, "last_unix", 0))
	var now_unix: int = int(Time.get_unix_time_from_system())
	if now_unix - last_unix < 172800:
		return streak
	return 0

func is_daily_completed_today() -> bool:
	var today := Time.get_date_string_from_system()
	var last_date := str(_config.get_value(SECTION_DAILY, "last_date", ""))
	return last_date == today

func record_daily_win() -> int:
	var today := Time.get_date_string_from_system()
	if is_daily_completed_today():
		return get_daily_streak()
	var current_streak := get_daily_streak()
	var new_streak := current_streak + 1
	var now_unix: int = int(Time.get_unix_time_from_system())
	_config.set_value(SECTION_DAILY, "last_date", today)
	_config.set_value(SECTION_DAILY, "last_unix", now_unix)
	_config.set_value(SECTION_DAILY, "streak", new_streak)
	var best_streak: int = int(_config.get_value(SECTION_DAILY, "best_streak", 0))
	if new_streak > best_streak:
		_config.set_value(SECTION_DAILY, "best_streak", new_streak)
	_save_file()
	return new_streak

## ---- Career Stats ----

func get_stat(key: String, default_val: int = 0) -> int:
	if _config.has_section_key(SECTION_STATS, key):
		return int(_config.get_value(SECTION_STATS, key, default_val))
	return default_val

func set_stat(key: String, val: int) -> void:
	_config.set_value(SECTION_STATS, key, val)
	_save_file()

func increment_stat(key: String, amount: int = 1) -> int:
	var current := get_stat(key, 0)
	var next := current + amount
	set_stat(key, next)
	return next

## ---- Active Run State ----

func save_run_state(data: Dictionary) -> void:
	_config.set_value(SECTION_RUN, "data", var_to_str(data))
	_save_file()

## Returns the saved run Dictionary, or null on failure.
func load_run_state() -> Variant:
	if not _config.has_section_key(SECTION_RUN, "data"):
		return null
	var raw = _config.get_value(SECTION_RUN, "data", "")
	if raw == null or raw == "":
		return null
	var parsed = str_to_var(raw)
	if not parsed is Dictionary:
		return null
	return parsed

func clear_run_state() -> void:
	_config.erase_section_key(SECTION_RUN, "data")
	_save_file()

## ---- Settings ----

func save_settings(data: Dictionary) -> void:
	for key in data:
		_config.set_value(SECTION_SETTINGS, key, data[key])
	_save_file()

func load_settings() -> Dictionary:
	var defaults := {
		"sound":          true,
		"music":          true,
		"haptics":        true,
		"reduced_motion": false,
	}
	var result: Dictionary = {}
	for key in defaults:
		if _config.has_section_key(SECTION_SETTINGS, key):
			result[key] = _config.get_value(SECTION_SETTINGS, key, defaults[key])
		else:
			result[key] = defaults[key]
	return result

## ---- Internal ----

func _save_file() -> void:
	var err := _config.save(SAVE_PATH)
	if err != OK:
		push_error("SaveManager: failed to save config: " + str(err))

func _load_file() -> void:
	var err := _config.load(SAVE_PATH)
	if err != OK and err != ERR_FILE_NOT_FOUND:
		push_warning("SaveManager: could not load save file (err " + str(err) + "), starting fresh.")
		_config = ConfigFile.new()

