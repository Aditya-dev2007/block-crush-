## BLOCK RUSH — RunState
## Tracks score, combo, tray and game status for one run.
## No Godot Node dependencies.

class_name RunState

enum Status {
	IDLE,       # No active run
	PLAYING,    # Run is in progress
	PAUSED,     # Run paused
	GAME_OVER,  # Run has ended
}

const TRAY_SIZE := 3

var score:       int    = 0
var best_score:  int    = 0
var combo_chain: int    = 0
var status:      Status = Status.IDLE

# Run statistics & Daily mode
var lines_cleared_total: int  = 0
var max_combo:           int  = 0
var is_daily_challenge:  bool = false
var daily_target_score:  int  = 500
var daily_completed:     bool = false

## Tray: Array of 3 piece ID strings. Empty string = slot used.
var tray: Array = ["", "", ""]

## Index of the currently selected piece (-1 = none selected).
var selected_piece_index: int = -1

func _init() -> void:
	pass

## Starts a fresh run.
func start_new_run(saved_best_score: int = 0) -> void:
	score                = 0
	best_score           = saved_best_score
	combo_chain          = 0
	lines_cleared_total  = 0
	max_combo            = 0
	is_daily_challenge   = false
	daily_target_score   = 500
	daily_completed      = false
	status               = Status.PLAYING
	selected_piece_index = -1
	tray                 = ["", "", ""]

## Returns true when every tray slot has been used.
func is_tray_empty() -> bool:
	for slot in tray:
		if slot != "":
			return false
	return true

## Fills the tray with three new piece IDs from the bag.
func fill_tray(piece_ids: Array) -> void:
	for i in range(TRAY_SIZE):
		tray[i] = piece_ids[i] if i < piece_ids.size() else ""

## Marks a tray slot as used.
func consume_piece(index: int) -> void:
	if index >= 0 and index < TRAY_SIZE:
		tray[index] = ""

## Returns the piece IDs currently still in the tray (non-empty).
func active_tray_pieces() -> Array:
	var result: Array = []
	for slot in tray:
		if slot != "":
			result.append(slot)
	return result

## Applies a resolved score result.
func apply_score(score_data: Dictionary) -> void:
	score       += score_data.get("total", 0)
	combo_chain  = score_data.get("new_chain", 0)
	if combo_chain > max_combo:
		max_combo = combo_chain
	var cleared_cells: int = score_data.get("cleared_cell_count", 0)
	if cleared_cells > 0:
		lines_cleared_total += int(ceil(float(cleared_cells) / 8.0))
	if score > best_score:
		best_score = score

## Serialises to a dictionary for saving.
func to_dict() -> Dictionary:
	return {
		"score":         score,
		"best_score":    best_score,
		"combo_chain":   combo_chain,
		"status":        status,
		"tray":          tray.duplicate(),
		"selected":      selected_piece_index,
		"lines_cleared": lines_cleared_total,
		"max_combo":     max_combo,
		"is_daily":      is_daily_challenge,
		"daily_target":  daily_target_score,
		"daily_won":     daily_completed,
	}

## Restores from a dictionary. Returns false on bad input.
func from_dict(d: Dictionary) -> bool:
	if not d is Dictionary:
		return false
	score        = int(d.get("score",       0))
	best_score   = int(d.get("best_score",  0))
	combo_chain  = int(d.get("combo_chain", 0))
	status       = int(d.get("status",      Status.IDLE))
	selected_piece_index = int(d.get("selected", -1))
	lines_cleared_total  = int(d.get("lines_cleared", 0))
	max_combo            = int(d.get("max_combo", combo_chain))
	is_daily_challenge   = bool(d.get("is_daily", false))
	daily_target_score   = int(d.get("daily_target", 500))
	daily_completed      = bool(d.get("daily_won", false))
	var saved_tray = d.get("tray", ["", "", ""])
	if saved_tray is Array and saved_tray.size() == TRAY_SIZE:
		tray = saved_tray.duplicate()
	else:
		tray = ["", "", ""]
	return true

