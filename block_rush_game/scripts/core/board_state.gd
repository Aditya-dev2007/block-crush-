## BLOCK RUSH — BoardState
## Pure data class: 8×8 occupancy grid. No Godot Node dependencies.
## Rows index from top (0) to bottom (7).
## Columns index from left (0) to right (7).

class_name BoardState

const BOARD_SIZE := 8

# 2-D array [row][col]: 0 = empty, 1 = occupied.
var cells: Array = []

func _init() -> void:
	_reset()

## Resets the board to fully empty.
func _reset() -> void:
	cells = []
	for _r in range(BOARD_SIZE):
		var row: Array = []
		for _c in range(BOARD_SIZE):
			row.append(0)
		cells.append(row)

## Returns true if (row, col) is inside the grid.
func in_bounds(row: int, col: int) -> bool:
	return row >= 0 and row < BOARD_SIZE and col >= 0 and col < BOARD_SIZE

## Returns true if cell is empty (and in bounds).
func is_empty(row: int, col: int) -> bool:
	if not in_bounds(row, col):
		return false
	return cells[row][col] == 0

## Occupies a cell. Caller must validate legality first.
func occupy(row: int, col: int) -> void:
	if in_bounds(row, col):
		cells[row][col] = 1

## Clears a cell (used when clearing completed lines).
func clear_cell(row: int, col: int) -> void:
	if in_bounds(row, col):
		cells[row][col] = 0

## Returns true if the entire row is filled.
func is_row_complete(row: int) -> bool:
	if not (row >= 0 and row < BOARD_SIZE):
		return false
	for col in range(BOARD_SIZE):
		if cells[row][col] == 0:
			return false
	return true

## Returns true if the entire column is filled.
func is_col_complete(col: int) -> bool:
	if not (col >= 0 and col < BOARD_SIZE):
		return false
	for row in range(BOARD_SIZE):
		if cells[row][col] == 0:
			return false
	return true

## Returns a list of completed row indices.
func get_complete_rows() -> Array:
	var result: Array = []
	for row in range(BOARD_SIZE):
		if is_row_complete(row):
			result.append(row)
	return result

## Returns a list of completed column indices.
func get_complete_cols() -> Array:
	var result: Array = []
	for col in range(BOARD_SIZE):
		if is_col_complete(col):
			result.append(col)
	return result

## Collects the unique set of cells covered by completed rows and columns.
## Intersections are counted once only.
func get_clear_cells(complete_rows: Array, complete_cols: Array) -> Array:
	var unique: Dictionary = {}
	for row in complete_rows:
		for col in range(BOARD_SIZE):
			var key := Vector2i(row, col)
			if not unique.has(key):
				unique[key] = true
	for col in complete_cols:
		for row in range(BOARD_SIZE):
			var key := Vector2i(row, col)
			if not unique.has(key):
				unique[key] = true
	return unique.keys()

## Clears all cells in completed rows and columns. Returns count of unique cells cleared.
func clear_lines(complete_rows: Array, complete_cols: Array) -> int:
	var cells_to_clear := get_clear_cells(complete_rows, complete_cols)
	for pos: Vector2i in cells_to_clear:
		clear_cell(pos.x, pos.y)
	return cells_to_clear.size()

## Serialises the board to a flat 64-element array for saving.
func to_array() -> Array:
	var flat: Array = []
	for row in range(BOARD_SIZE):
		for col in range(BOARD_SIZE):
			flat.append(cells[row][col])
	return flat

## Restores the board from a flat 64-element array. Returns false on bad input.
func from_array(flat: Array) -> bool:
	if flat.size() != BOARD_SIZE * BOARD_SIZE:
		return false
	for row in range(BOARD_SIZE):
		for col in range(BOARD_SIZE):
			var v = flat[row * BOARD_SIZE + col]
			cells[row][col] = 1 if v == 1 else 0
	return true

## Deep copies this board state.
func duplicate_state() -> BoardState:
	var copy := BoardState.new()
	copy.from_array(to_array())
	return copy

## Debug helper: prints board to console.
func debug_print() -> void:
	for row in range(BOARD_SIZE):
		var line := ""
		for col in range(BOARD_SIZE):
			line += "█" if cells[row][col] == 1 else "·"
		print(line)

