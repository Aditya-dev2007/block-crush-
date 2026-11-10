## BLOCK RUSH — BoardNode (Legacy reference — superseded by BoardDisplayNode)
## This file is kept for reference. The active board rendering is in board_display_node.gd
## which is instantiated dynamically by gameplay_screen.gd.

extends Control

## DEPRECATED: Use BoardDisplayNode instead.

const BOARD_SIZE    := 8
const GRID_COLOR    := Color(0.1, 0.18, 0.3, 1.0)
const LINE_COLOR    := Color(0.15, 0.25, 0.4, 0.8)
const PREVIEW_VALID := Color(0.0, 0.898, 1.0, 0.45)   # Cyan tint
const PREVIEW_INVALID := Color(1.0, 0.2, 0.2, 0.35)   # Red tint

var cell_size:     float = 0.0
var board_offset:  Vector2 = Vector2.ZERO

# Preview state
var preview_anchor: Vector2i = Vector2i(-1, -1)   # (col, row)
var preview_valid:  bool     = false
var preview_cells:  Array    = []   # Array of Vector2i (col, row)

# Drag state
var dragging_piece_index: int    = -1
var dragging_piece_id:    String = ""
var drag_pos:             Vector2 = Vector2.ZERO

# Cell animations: key=Vector2i(row,col), value=float scale 0..1 (for clear animation)
var _cell_scales: Dictionary = {}

signal piece_dropped(piece_index: int, board_col: int, board_row: int)
signal drag_started(piece_index: int)
signal drag_ended()

func _ready() -> void:
	set_process(true)
	GameState.board_updated.connect(_on_board_updated)
	GameState.lines_cleared.connect(_on_lines_cleared)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_recalculate_layout()

func _recalculate_layout() -> void:
	var available: float = minf(size.x, size.y)
	cell_size     = available / float(BOARD_SIZE)
	board_offset  = Vector2(
		(size.x - cell_size * BOARD_SIZE) * 0.5,
		(size.y - cell_size * BOARD_SIZE) * 0.5
	)
	queue_redraw()

func _draw() -> void:
	# Background
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.07, 0.11, 0.2, 1.0))

	# Grid cells
	for row in range(BOARD_SIZE):
		for col in range(BOARD_SIZE):
			var rect := _cell_rect(row, col)
			# Cell background
			var cell_col := GRID_COLOR
			if GameState.board != null and not GameState.board.is_empty(row, col):
				# Get piece colour from board (we store colour index separately in gameplay screen)
				cell_col = Color(0.2, 0.5, 0.9, 1.0)   # Placeholder occupied colour
			draw_rect(rect.grow(-1.5), cell_col, true)
			# Grid lines
			draw_rect(rect.grow(-1.5), LINE_COLOR, false, 0.5)

	# Preview overlay
	if preview_cells.size() > 0:
		var pcolor := PREVIEW_VALID if preview_valid else PREVIEW_INVALID
		for cell_pos: Vector2i in preview_cells:
			var row := cell_pos.y
			var col := cell_pos.x
			if row >= 0 and row < BOARD_SIZE and col >= 0 and col < BOARD_SIZE:
				var rect := _cell_rect(row, col)
				draw_rect(rect.grow(-1.5), pcolor, true)

func _cell_rect(row: int, col: int) -> Rect2:
	return Rect2(
		board_offset + Vector2(col * cell_size, row * cell_size),
		Vector2(cell_size, cell_size)
	)

## Returns (col, row) for a screen position, or (-1,-1) if outside board.
func screen_pos_to_cell(pos: Vector2) -> Vector2i:
	var local_pos := pos - board_offset
	var col := int(local_pos.x / cell_size)
	var row := int(local_pos.y / cell_size)
	if col < 0 or col >= BOARD_SIZE or row < 0 or row >= BOARD_SIZE:
		return Vector2i(-1, -1)
	return Vector2i(col, row)

## Returns the screen center of a cell.
func cell_center(row: int, col: int) -> Vector2:
	return board_offset + Vector2((col + 0.5) * cell_size, (row + 0.5) * cell_size)

## Called from parent to begin a drag from tray.
func begin_drag(piece_index: int, piece_id: String, start_pos: Vector2) -> void:
	dragging_piece_index = piece_index
	dragging_piece_id    = piece_id
	drag_pos             = start_pos
	emit_signal("drag_started", piece_index)

## Called each frame with current finger/pointer position.
func update_drag(pos: Vector2) -> void:
	if dragging_piece_index < 0:
		return
	drag_pos = pos
	# Compute anchor: top-left corner of piece relative to finger
	var center_cell := screen_pos_to_cell(pos)
	if center_cell.x < 0:
		preview_cells = []
		preview_valid = false
		queue_redraw()
		return
	# Snap so finger is roughly at top-left of piece
	var anchor_row := center_cell.y
	var anchor_col := center_cell.x
	preview_anchor = Vector2i(anchor_col, anchor_row)
	preview_valid  = GameState.is_legal_preview(dragging_piece_index, anchor_row, anchor_col)
	preview_cells  = GameState.get_preview_cells(dragging_piece_id, anchor_row, anchor_col)
	queue_redraw()

## Called when the finger lifts.
func end_drag(pos: Vector2) -> void:
	if dragging_piece_index < 0:
		return
	var cell := screen_pos_to_cell(pos)
	if cell.x >= 0:
		emit_signal("piece_dropped", dragging_piece_index, cell.x, cell.y)
	else:
		emit_signal("drag_ended")
	_clear_drag()

func _clear_drag() -> void:
	dragging_piece_index = -1
	dragging_piece_id    = ""
	preview_cells        = []
	preview_valid        = false
	queue_redraw()

func _on_board_updated(_board: BoardState) -> void:
	queue_redraw()

func _on_lines_cleared(result: Dictionary) -> void:
	# Animate cleared cells
	var cleared: Array = result.get("cleared_cells", [])
	if cleared.is_empty() or GameState.reduced_motion:
		queue_redraw()
		return
	# Flash animation via tween
	var tween := create_tween()
	tween.tween_method(_set_clear_alpha.bind(cleared), 1.0, 0.0, 0.25)
	tween.tween_callback(func(): queue_redraw())

func _set_clear_alpha(cells: Array, alpha: float) -> void:
	# Just trigger redraw; actual fade handled by cell_scales
	queue_redraw()
