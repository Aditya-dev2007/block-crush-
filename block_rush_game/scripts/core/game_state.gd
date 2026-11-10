## BLOCK RUSH — GameState (Autoload Singleton)
## Central game state coordinator. Owns BoardState and RunState.
## Emits signals that the UI observes.

extends Node

signal board_updated(board: BoardState)
signal score_updated(score: int, best_score: int, combo: int)
signal tray_updated(tray: Array)
signal lines_cleared(result: Dictionary)
signal game_over()
signal run_started()
signal piece_placed(piece_id: String, anchor: Vector2i, cleared_cells: Array)
signal pause_changed(paused: bool)
signal daily_goal_reached(streak: int)

# Core data
var board:    BoardState
var run:      RunState
var bag:      PieceBag

# Settings (synced from SaveManager on load)
var sound_enabled:   bool = true
var music_enabled:   bool = true
var haptics_enabled: bool = true
var reduced_motion:  bool = false

# Input lock: true while animations are playing.
var input_locked: bool = false

func _ready() -> void:
	board = BoardState.new()
	run   = RunState.new()
	bag   = PieceBag.new()

## Starts a fresh game run.
func start_new_run() -> void:
	board = BoardState.new()
	var saved_best: int = SaveManager.load_best_score()
	run.start_new_run(saved_best)
	_deal_tray()
	emit_signal("run_started")
	emit_signal("board_updated", board)
	emit_signal("score_updated", run.score, run.best_score, run.combo_chain)
	emit_signal("tray_updated", run.tray.duplicate())

## Starts a deterministic Daily Challenge run.
func start_daily_run() -> void:
	board = BoardState.new()
	var saved_best: int = SaveManager.load_best_score()
	var date_dict := Time.get_date_dict_from_system()
	var seed_val: int = int(date_dict["year"]) * 10000 + int(date_dict["month"]) * 100 + int(date_dict["day"])
	bag.seed_rng(seed_val)
	run.start_new_run(saved_best)
	run.is_daily_challenge = true
	run.daily_target_score = 500
	run.daily_completed    = SaveManager.is_daily_completed_today()
	_deal_tray()
	emit_signal("run_started")
	emit_signal("board_updated", board)
	emit_signal("score_updated", run.score, run.best_score, run.combo_chain)
	emit_signal("tray_updated", run.tray.duplicate())

## Attempts to restore a saved run. Returns true on success.
func restore_run() -> bool:
	var saved = SaveManager.load_run_state()
	if saved == null or not (saved is Dictionary):
		return false
	board = BoardState.new()
	var board_ok: bool = board.from_array(saved.get("board", []))
	var run_ok: bool   = run.from_dict(saved.get("run", {}))
	if not board_ok or not run_ok:
		return false
	if run.status != RunState.Status.PLAYING and run.status != RunState.Status.PAUSED:
		return false
	run.status = RunState.Status.PLAYING
	emit_signal("run_started")
	emit_signal("board_updated", board)
	emit_signal("score_updated", run.score, run.best_score, run.combo_chain)
	emit_signal("tray_updated", run.tray.duplicate())
	return true

## Called when the player attempts to place a piece.
## Returns the placement result dict or null if illegal/locked.
func try_place_piece(
		piece_index: int,
		anchor_row: int,
		anchor_col: int) -> Variant:

	if input_locked:
		return null
	if run.status != RunState.Status.PLAYING:
		return null
	if piece_index < 0 or piece_index >= RunState.TRAY_SIZE:
		return null

	var piece_id: String = run.tray[piece_index]
	if piece_id == "":
		return null

	var result = GameRules.resolve_placement(board, piece_id, anchor_row, anchor_col, run.combo_chain)
	if result == null:
		return null  # Illegal — no mutation

	# Update run state
	run.consume_piece(piece_index)
	run.apply_score(result["score_data"])
	run.selected_piece_index = -1

	# Emit events
	emit_signal("board_updated", board)
	emit_signal("score_updated", run.score, run.best_score, run.combo_chain)
	emit_signal("piece_placed", piece_id, result["anchor"], result["cleared_cells"])

	if result["cleared_cells"].size() > 0:
		emit_signal("lines_cleared", result)

	# Check Daily Challenge goal
	if run.is_daily_challenge and not run.daily_completed:
		if run.score >= run.daily_target_score:
			run.daily_completed = true
			var streak: int = SaveManager.record_daily_win()
			emit_signal("daily_goal_reached", streak)

	# Refill tray if all pieces used
	if run.is_tray_empty():
		_deal_tray()
	else:
		emit_signal("tray_updated", run.tray.duplicate())

	# Check game over
	if GameRules.is_game_over(board, run.active_tray_pieces()):
		run.status = RunState.Status.GAME_OVER
		SaveManager.save_best_score(run.best_score)
		SaveManager.clear_run_state()
		SaveManager.increment_stat("games_played", 1)
		SaveManager.increment_stat("lines_cleared", run.lines_cleared_total)
		if run.max_combo > SaveManager.get_stat("highest_combo", 0):
			SaveManager.set_stat("highest_combo", run.max_combo)
		emit_signal("game_over")
	else:
		_save_run()

	return result

## Sets pause state.
func set_paused(paused: bool) -> void:
	if paused and run.status == RunState.Status.PLAYING:
		run.status = RunState.Status.PAUSED
		_save_run()
		emit_signal("pause_changed", true)
	elif not paused and run.status == RunState.Status.PAUSED:
		run.status = RunState.Status.PLAYING
		emit_signal("pause_changed", false)

## Checks if a placement would be legal (for preview only, no mutation).
func is_legal_preview(piece_index: int, anchor_row: int, anchor_col: int) -> bool:
	if piece_index < 0 or piece_index >= RunState.TRAY_SIZE:
		return false
	var piece_id: String = run.tray[piece_index]
	if piece_id == "":
		return false
	return GameRules.is_placement_legal(board, piece_id, anchor_row, anchor_col)

## Returns the cells for a piece at a given anchor (for preview display).
func get_preview_cells(piece_id: String, anchor_row: int, anchor_col: int) -> Array:
	var cells: Array = PieceDefinitions.get_cells(piece_id)
	var result: Array = []
	for offset: Vector2i in cells:
		result.append(Vector2i(anchor_col + offset.x, anchor_row + offset.y))
	return result

## Saves current settings.
func save_settings() -> void:
	SaveManager.save_settings({
		"sound":   sound_enabled,
		"music":   music_enabled,
		"haptics": haptics_enabled,
		"reduced_motion": reduced_motion,
	})

## Loads settings from SaveManager.
func load_settings() -> void:
	var s: Dictionary = SaveManager.load_settings()
	sound_enabled   = s.get("sound",   true)
	music_enabled   = s.get("music",   true)
	haptics_enabled = s.get("haptics", true)
	reduced_motion  = s.get("reduced_motion", false)

## ---- Private helpers ----

func _deal_tray() -> void:
	var new_pieces: Array = bag.deal(RunState.TRAY_SIZE)
	run.fill_tray(new_pieces)
	emit_signal("tray_updated", run.tray.duplicate())

func _save_run() -> void:
	SaveManager.save_run_state({
		"board": board.to_array(),
		"run":   run.to_dict(),
	})

