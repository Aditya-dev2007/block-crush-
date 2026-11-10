## BLOCK RUSH — GameRules
## Pure logic: validates moves, computes scores, checks game over.
## No Godot Node dependencies.

class_name GameRules

## --- Scoring constants (match SPEC.md exactly) ---
const POINTS_PER_BLOCK   := 1    # Per placed block cell
const POINTS_PER_CLEARED := 10   # Per unique cleared cell
const COMBO_BONUS_STEP   := 5    # Multiplied by chain count

## --- Placement validation ---

## Returns true if placing piece_id at (anchor_row, anchor_col) on board is legal.
## Legal = all piece cells in-bounds AND empty.
static func is_placement_legal(
		board: BoardState,
		piece_id: String,
		anchor_row: int,
		anchor_col: int) -> bool:
	var cells: Array = PieceDefinitions.get_cells(piece_id)
	for offset: Vector2i in cells:
		var r := anchor_row + offset.y
		var c := anchor_col + offset.x
		if not board.in_bounds(r, c):
			return false
		if not board.is_empty(r, c):
			return false
	return true

## Commits a legal placement on the board (mutates board in place).
## Caller MUST verify legality before calling.
static func commit_placement(
		board: BoardState,
		piece_id: String,
		anchor_row: int,
		anchor_col: int) -> void:
	var cells: Array = PieceDefinitions.get_cells(piece_id)
	for offset: Vector2i in cells:
		board.occupy(anchor_row + offset.y, anchor_col + offset.x)

## --- Score calculation ---

## Calculates the score delta for one placement + optional line clears.
## combo_chain: current consecutive-clear count BEFORE this move.
## Returns a dictionary: { placement_points, clear_points, combo_points, total, cleared_cell_count, new_chain }
static func calculate_score(
		piece_id: String,
		cleared_cells_count: int,
		combo_chain: int) -> Dictionary:

	var placed_count: int = PieceDefinitions.get_cells(piece_id).size()
	var placement_pts := placed_count * POINTS_PER_BLOCK
	var clear_pts     := cleared_cells_count * POINTS_PER_CLEARED
	var new_chain     := combo_chain + 1 if cleared_cells_count > 0 else 0
	var combo_pts     := COMBO_BONUS_STEP * new_chain if cleared_cells_count > 0 else 0
	var total         := placement_pts + clear_pts + combo_pts

	return {
		"placement_points": placement_pts,
		"clear_points":     clear_pts,
		"combo_points":     combo_pts,
		"total":            total,
		"cleared_cell_count": cleared_cells_count,
		"new_chain":        new_chain,
	}

## --- Game-over detection ---

## Returns true if at least one piece in the tray has a legal placement somewhere.
static func has_any_legal_move(board: BoardState, tray_piece_ids: Array) -> bool:
	for piece_id in tray_piece_ids:
		if piece_id == "":
			continue
		for anchor_row in range(BoardState.BOARD_SIZE):
			for anchor_col in range(BoardState.BOARD_SIZE):
				if is_placement_legal(board, piece_id, anchor_row, anchor_col):
					return true
	return false

## Returns true if the game is over (no legal moves for any tray piece).
static func is_game_over(board: BoardState, tray_piece_ids: Array) -> bool:
	return not has_any_legal_move(board, tray_piece_ids)

## --- Full placement resolution ---
## Applies a placement, clears lines, and returns the result.
## Does NOT mutate board if placement is illegal.
## Returns null if placement is illegal; otherwise returns result dict.
static func resolve_placement(
		board: BoardState,
		piece_id: String,
		anchor_row: int,
		anchor_col: int,
		combo_chain: int) -> Variant:

	if not is_placement_legal(board, piece_id, anchor_row, anchor_col):
		return null

	commit_placement(board, piece_id, anchor_row, anchor_col)

	var complete_rows := board.get_complete_rows()
	var complete_cols := board.get_complete_cols()
	var cleared_cells := board.get_clear_cells(complete_rows, complete_cols)
	board.clear_lines(complete_rows, complete_cols)

	var score_data := calculate_score(piece_id, cleared_cells.size(), combo_chain)

	return {
		"score_data":     score_data,
		"complete_rows":  complete_rows,
		"complete_cols":  complete_cols,
		"cleared_cells":  cleared_cells,  # Array of Vector2i
		"anchor":         Vector2i(anchor_col, anchor_row),
		"piece_id":       piece_id,
	}

