## BLOCK RUSH — BoardDisplayNode
## A Control that draws the board grid, occupied cells, and placement preview.
## Attached to the BoardControl node inside the gameplay scene.

extends Control

class_name BoardDisplayNode

const BOARD_SIZE    := 8
const BG_COLOR      := Color(0.06, 0.09, 0.18, 1.0)
const GRID_EMPTY    := Color(0.08, 0.14, 0.26, 1.0)
const GRID_LINE     := Color(0.12, 0.2, 0.36, 0.9)
const CORNER_RADIUS := 4.0

# Block colours indexed by piece color index
const BLOCK_COLORS: Array = [
	Color(1.0,   0.388, 0.278),  # 0 Coral
	Color(0.0,   0.898, 1.0),    # 1 Cyan
	Color(0.467, 1.0,   0.0),    # 2 Lime
	Color(0.698, 0.133, 1.0),    # 3 Violet
	Color(1.0,   0.843, 0.0),    # 4 Gold
]

# Preview
var _preview_cells: Array   = []  # Array of Vector2i (col, row)
var _preview_valid: bool    = false

# Cell colour map: Vector2i(row,col) → Color (populated from board_updated signal)
var _cell_colors: Dictionary = {}

# Clear animation cells: Vector2i(row,col) → alpha 0..1
var _clearing_alphas: Dictionary = {}

var _cell_size:    float   = 0.0
var _board_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	GameState.board_updated.connect(_on_board_updated)
	GameState.piece_placed.connect(_on_piece_placed)
	GameState.lines_cleared.connect(_on_lines_cleared)
	_recalculate_layout()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_recalculate_layout()

func _recalculate_layout() -> void:
	var side: float = minf(size.x, size.y)
	_cell_size    = side / float(BOARD_SIZE)
	_board_offset = Vector2(
		(size.x - _cell_size * BOARD_SIZE) * 0.5,
		(size.y - _cell_size * BOARD_SIZE) * 0.5
	)

func get_cell_size() -> float:
	if _cell_size <= 0.0:
		_recalculate_layout()
	return _cell_size

func get_board_offset() -> Vector2:
	return _board_offset

## Converts a global pixel coordinate to board cell (col, row).
func global_to_cell(global_pos: Vector2) -> Vector2i:
	if _cell_size <= 0.0:
		_recalculate_layout()
	if _cell_size <= 0.0:
		return Vector2i(-1, -1)
	var local: Vector2 = global_pos - global_position - _board_offset
	var col: int = int(floorf(local.x / _cell_size))
	var row: int = int(floorf(local.y / _cell_size))
	return Vector2i(col, row)

## Called by gameplay_screen.gd to update the placement preview.
func set_preview(piece_id: String, anchor_row: int, anchor_col: int, valid: bool) -> void:
	_preview_valid = valid
	_preview_cells = GameState.get_preview_cells(piece_id, anchor_row, anchor_col)
	queue_redraw()

## Clears the preview.
func clear_preview() -> void:
	_preview_cells = []
	queue_redraw()

func _draw() -> void:
	# Background
	draw_rect(Rect2(Vector2.ZERO, size), BG_COLOR)

	var cs := _cell_size
	var pad := 2.5

	for row in range(BOARD_SIZE):
		for col in range(BOARD_SIZE):
			var rect := _cell_rect(row, col).grow(-pad)
			var key  := Vector2i(row, col)

			if not _cell_colors.has(key):
				# Recessed empty grid cell
				draw_rect(rect, Color(0.07, 0.11, 0.22, 1.0), true)
				# Inner top/left inset shadow
				draw_rect(Rect2(rect.position, Vector2(rect.size.x, 2.0)), Color(0.03, 0.05, 0.11, 0.7), true)
				draw_rect(Rect2(rect.position, Vector2(2.0, rect.size.y)), Color(0.03, 0.05, 0.11, 0.7), true)
				draw_rect(rect, GRID_LINE, false, 0.75)
			else:
				var col_color: Color = _cell_colors[key]
				var alpha: float = 1.0
				var is_clearing := false
				if _clearing_alphas.has(key):
					alpha = _clearing_alphas[key]
					col_color.a = alpha
					is_clearing = true

				# When clearing, flash bright white/gold
				if is_clearing and alpha > 0.5:
					col_color = col_color.lerp(Color(1.0, 1.0, 0.8, alpha), (alpha - 0.5) * 1.6)

				# Main block body
				draw_rect(rect, col_color, true)

				# 3D bevel top & left highlights
				draw_rect(Rect2(rect.position, Vector2(rect.size.x, 3.0)), Color(1.0, 1.0, 1.0, 0.4 * alpha), true)
				draw_rect(Rect2(rect.position, Vector2(3.0, rect.size.y)), Color(1.0, 1.0, 1.0, 0.25 * alpha), true)

				# 3D bevel bottom & right shadows
				var bot_y := rect.position.y + rect.size.y - 3.5
				var right_x := rect.position.x + rect.size.x - 3.0
				draw_rect(Rect2(Vector2(rect.position.x, bot_y), Vector2(rect.size.x, 3.5)), Color(0.0, 0.0, 0.0, 0.35 * alpha), true)
				draw_rect(Rect2(Vector2(right_x, rect.position.y), Vector2(3.0, rect.size.y)), Color(0.0, 0.0, 0.0, 0.22 * alpha), true)

				# Glassy gloss reflection on top 35%
				var gloss_rect := Rect2(rect.position + Vector2(3.0, 3.0), Vector2(rect.size.x - 6.0, (rect.size.y - 6.0) * 0.35))
				draw_rect(gloss_rect, Color(1.0, 1.0, 1.0, 0.16 * alpha), true)

				# Outer rim
				draw_rect(rect, Color(col_color.r * 1.15, col_color.g * 1.15, col_color.b * 1.15, 0.7 * alpha), false, 1.0)

	# Preview overlay with glowing borders
	for cell_pos: Vector2i in _preview_cells:
		var row := cell_pos.y
		var col := cell_pos.x
		if row >= 0 and row < BOARD_SIZE and col >= 0 and col < BOARD_SIZE:
			var rect := _cell_rect(row, col).grow(-pad)
			if _preview_valid:
				draw_rect(rect, Color(0.0, 0.92, 1.0, 0.45), true)
				draw_rect(rect, Color(0.0, 0.96, 1.0, 0.95), false, 2.0)
				# Gloss on preview
				draw_rect(Rect2(rect.position + Vector2(2.0, 2.0), Vector2(rect.size.x - 4.0, 3.0)), Color(1.0, 1.0, 1.0, 0.6), true)
			else:
				draw_rect(rect, Color(1.0, 0.25, 0.3, 0.42), true)
				draw_rect(rect, Color(1.0, 0.35, 0.35, 0.85), false, 1.5)

func _cell_rect(row: int, col: int) -> Rect2:
	return Rect2(
		_board_offset + Vector2(col * _cell_size, row * _cell_size),
		Vector2(_cell_size, _cell_size)
	)

func _on_board_updated(board: BoardState) -> void:
	# Prune cells that are no longer occupied
	var to_remove: Array = []
	for key in _cell_colors.keys():
		if board.is_empty(key.x, key.y):
			to_remove.append(key)
	for key in to_remove:
		_cell_colors.erase(key)

	for row in range(BOARD_SIZE):
		for col in range(BOARD_SIZE):
			if not board.is_empty(row, col):
				var key := Vector2i(row, col)
				if not _cell_colors.has(key):
					_cell_colors[key] = BLOCK_COLORS[0]
	queue_redraw()

func _on_piece_placed(piece_id: String, anchor: Vector2i, _cleared_cells: Array) -> void:
	# Paint the piece cells with its colour
	var cells: Array      = PieceDefinitions.get_cells(piece_id)
	var color_idx: int    = PieceDefinitions.PIECE_COLORS.get(piece_id, 0)
	var block_color: Color = BLOCK_COLORS[color_idx % BLOCK_COLORS.size()]
	for offset: Vector2i in cells:
		var r := anchor.y + offset.y
		var c := anchor.x + offset.x
		_cell_colors[Vector2i(r, c)] = block_color
	queue_redraw()

func _on_lines_cleared(result: Dictionary) -> void:
	var cleared: Array = result.get("cleared_cells", [])
	if cleared.is_empty():
		return
	# Animate alpha down then remove
	if GameState.reduced_motion:
		for pos: Vector2i in cleared:
			_cell_colors.erase(pos)
		queue_redraw()
		return

	# Set all clearing cells to alpha 1.0
	for pos: Vector2i in cleared:
		_clearing_alphas[pos] = 1.0

	var tween := create_tween()
	tween.tween_method(_animate_clear.bind(cleared), 1.0, 0.0, 0.3)
	tween.tween_callback(func():
		for pos: Vector2i in cleared:
			_cell_colors.erase(pos)
			_clearing_alphas.erase(pos)
		queue_redraw()
	)

func _animate_clear(alpha: float, cleared: Array) -> void:
	for pos: Vector2i in cleared:
		_clearing_alphas[pos] = alpha
	queue_redraw()

