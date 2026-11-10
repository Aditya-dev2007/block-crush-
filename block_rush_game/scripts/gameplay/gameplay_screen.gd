## BLOCK RUSH — Gameplay Screen (Full Controller)
## Delivers high-level game juice: tactile drag-and-drop, screen shake,
## floating combo text, pentatonic sound feedback, and daily challenge progression.

extends Control

# ---- Node references ----
@onready var score_label:        Label          = $VBox/TopBar/ScoreColumn/ScoreLabel
@onready var best_label:         Label          = $VBox/TopBar/BestColumn/BestLabel
@onready var combo_label:        Label          = $VBox/TopBar/RightColumn/ComboLabel
@onready var pause_button:       Button         = $VBox/TopBar/RightColumn/PauseButton
@onready var board_control:      Control        = $VBox/BoardArea/BoardControl
@onready var tray_hbox:          HBoxContainer  = $VBox/TrayArea/TrayHBox
@onready var pause_overlay:      Control        = $PauseOverlay
@onready var game_over_overlay:  Control        = $GameOverOverlay
@onready var resume_button:      Button         = $PauseOverlay/PausePanel/ResumeButton
@onready var restart_button:     Button         = $PauseOverlay/PausePanel/RestartButton
@onready var home_button:        Button         = $PauseOverlay/PausePanel/HomeButton
@onready var play_again_button:  Button         = $GameOverOverlay/GOPanel/PlayAgainButton
@onready var go_home_button:     Button         = $GameOverOverlay/GOPanel/GOHomeButton
@onready var go_score_label:     Label          = $GameOverOverlay/GOPanel/GOScoreLabel
@onready var go_best_label:      Label          = $GameOverOverlay/GOPanel/GOBestLabel
@onready var go_new_record:      Label          = $GameOverOverlay/GOPanel/GONewRecord

# Board draw node
var _board_draw: BoardDisplayNode = null

# Drag & Selection state
var _drag_index:      int        = -1
var _drag_id:         String     = ""
var _drag_slot:       Control    = null
var _drag_preview:    Control    = null
var _drag_offset:     Vector2    = Vector2.ZERO
var _drag_start_pos:  Vector2    = Vector2.ZERO
var _has_dragged:     bool       = false
var _is_touch:        bool       = false

var _selected_index:  int        = -1
var _selected_id:     String     = ""
var _selected_slot:   Control    = null

# Daily challenge mode banner
var _daily_banner: Label = null

# Block colours (index → Color)
const BLOCK_COLORS: Array[Color] = [
	Color(1.0,   0.388, 0.278),  # 0 Coral Red
	Color(0.0,   0.898, 1.0),    # 1 Cyan
	Color(0.467, 1.0,   0.0),    # 2 Electric Lime
	Color(0.72,  0.22,  1.0),    # 3 Purple
	Color(1.0,   0.843, 0.0),    # 4 Gold
]

# Combo compliment phrases
const COMBO_PHRASES: Array[String] = [
	"",
	"GOOD!",
	"GREAT! 🔥",
	"AMAZING! ⚡",
	"SUPERB! 💥",
	"INCREDIBLE! 🌟",
	"UNSTOPPABLE! 👑"
]

func _ready() -> void:
	# Configure board control & attach draw node
	board_control.mouse_filter = Control.MOUSE_FILTER_PASS
	board_control.gui_input.connect(_on_board_input)

	_board_draw = BoardDisplayNode.new()
	_board_draw.set_anchors_preset(Control.PRESET_FULL_RECT)
	_board_draw.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_control.add_child(_board_draw)

	# Daily challenge banner setup
	_setup_daily_banner()

	# Connect GameState signals
	GameState.score_updated.connect(_on_score_updated)
	GameState.tray_updated.connect(_on_tray_updated)
	GameState.game_over.connect(_on_game_over)
	GameState.pause_changed.connect(_on_pause_changed)
	GameState.run_started.connect(_on_run_started)
	GameState.daily_goal_reached.connect(_on_daily_goal_reached)

	# Connect buttons
	pause_button.pressed.connect(_on_pause_pressed)
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	home_button.pressed.connect(_on_home_pressed)
	play_again_button.pressed.connect(_on_play_again_pressed)
	go_home_button.pressed.connect(_on_home_pressed)

	# If no run is actively playing, start or restore
	if GameState.run.status != RunState.Status.PLAYING:
		var restored: bool = GameState.restore_run()
		if not restored:
			GameState.start_new_run()
	else:
		_on_run_started()
		_on_tray_updated(GameState.run.tray.duplicate())
		_on_score_updated(GameState.run.score, GameState.run.best_score, GameState.run.combo_chain)

func _setup_daily_banner() -> void:
	_daily_banner = Label.new()
	_daily_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_daily_banner.add_theme_font_size_override("font_size", 13)
	_daily_banner.add_theme_color_override("font_color", Color(1.0, 0.88, 0.3))
	_daily_banner.visible = false
	var vbox := $VBox
	vbox.add_child(_daily_banner)
	vbox.move_child(_daily_banner, 1)

# ---- GameState Signal Handlers ----

func _on_run_started() -> void:
	pause_overlay.hide()
	game_over_overlay.hide()
	_clear_selection()
	_update_daily_banner()

func _update_daily_banner() -> void:
	if _daily_banner == null:
		return
	if GameState.run.is_daily_challenge:
		_daily_banner.visible = true
		if GameState.run.daily_completed:
			_daily_banner.text = "⭐ DAILY CHALLENGE COMPLETE! ⭐"
			_daily_banner.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
		else:
			_daily_banner.text = "📅 DAILY GOAL: %d / %d PTS" % [GameState.run.score, GameState.run.daily_target_score]
			_daily_banner.add_theme_color_override("font_color", Color(1.0, 0.88, 0.3))
	else:
		_daily_banner.visible = false

func _on_score_updated(score: int, best: int, combo: int) -> void:
	score_label.text = str(score)
	best_label.text  = str(best)
	_update_daily_banner()

	if combo >= 2:
		var phrase_idx := clampi(combo, 0, COMBO_PHRASES.size() - 1)
		var phrase: String = COMBO_PHRASES[phrase_idx]
		combo_label.text    = "x%d %s" % [combo, phrase]
		combo_label.visible = true
		_animate_combo_label()
	else:
		combo_label.visible = false

func _on_tray_updated(tray: Array) -> void:
	_clear_selection()
	_rebuild_tray(tray)

func _on_daily_goal_reached(streak: int) -> void:
	AudioManager.play_celebration()
	_update_daily_banner()
	_spawn_confetti(board_control.global_position + board_control.size * 0.5)
	spawn_floating_text("🌟 CHALLENGE WON! STREAK: %d DAYS! 🌟" % streak, board_control.global_position + Vector2(board_control.size.x * 0.5, 40.0), Color(1.0, 0.9, 0.2), 24)

func _on_game_over() -> void:
	_cancel_drag(false)
	_clear_selection()
	AudioManager.play_game_over()
	var score: int = GameState.run.score
	var best: int  = GameState.run.best_score
	go_score_label.text = str(score)
	go_best_label.text  = "BEST: " + str(best)

	var is_new_record := (score >= best and score > 0)
	go_new_record.visible = is_new_record
	if is_new_record:
		AudioManager.play_celebration()
		_spawn_confetti(size * 0.5)

	game_over_overlay.show()
	var mod := game_over_overlay.modulate
	game_over_overlay.modulate = Color(mod.r, mod.g, mod.b, 0.0)
	var tween := create_tween()
	tween.tween_property(game_over_overlay, "modulate:a", 1.0, 0.4)

func _on_pause_changed(paused: bool) -> void:
	if paused:
		_cancel_drag(true)
		_clear_selection()
	pause_overlay.visible = paused

# ---- Button Handlers ----

func _on_pause_pressed() -> void:
	AudioManager.play_button_tap()
	GameState.set_paused(true)

func _on_resume_pressed() -> void:
	AudioManager.play_button_tap()
	GameState.set_paused(false)

func _on_restart_pressed() -> void:
	AudioManager.play_button_tap()
	if GameState.run.score > 0:
		var d := ConfirmationDialog.new()
		d.title       = "Restart?"
		d.dialog_text = "Start a new game? Current score will be reset."
		d.confirmed.connect(_do_restart)
		add_child(d)
		d.popup_centered()
	else:
		_do_restart()

func _do_restart() -> void:
	if GameState.run.is_daily_challenge:
		GameState.start_daily_run()
	else:
		GameState.start_new_run()

func _on_home_pressed() -> void:
	AudioManager.play_button_tap()
	GameState.set_paused(false)
	get_tree().change_scene_to_file("res://scenes/home/home_screen.tscn")

func _on_play_again_pressed() -> void:
	AudioManager.play_button_tap()
	game_over_overlay.hide()
	if GameState.run.is_daily_challenge:
		GameState.start_daily_run()
	else:
		GameState.start_new_run()

# ---- Tray ----

func _rebuild_tray(tray: Array) -> void:
	for child in tray_hbox.get_children():
		tray_hbox.remove_child(child)
		child.queue_free()

	for i in range(tray.size()):
		var piece_id: String = tray[i]
		var slot := _make_tray_slot(i, piece_id)
		tray_hbox.add_child(slot)

func _make_tray_slot(index: int, piece_id: String) -> Control:
	var container := Control.new()
	container.custom_minimum_size = Vector2(110, 110)
	container.set_meta("piece_index", index)
	container.set_meta("piece_id",    piece_id)

	# Slot background (recessed dark glass)
	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.13, 0.24, 0.85)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.offset_left   = 4.0
	bg.offset_right  = -4.0
	bg.offset_top    = 4.0
	bg.offset_bottom = -4.0
	bg.mouse_filter  = Control.MOUSE_FILTER_IGNORE
	container.add_child(bg)

	# Selection highlight border (shown when tapped)
	var sel_border := ReferenceRect.new()
	sel_border.name = "SelectionBorder"
	sel_border.set_anchors_preset(Control.PRESET_FULL_RECT)
	sel_border.offset_left   = 2.0
	sel_border.offset_right  = -2.0
	sel_border.offset_top    = 2.0
	sel_border.offset_bottom = -2.0
	sel_border.border_color  = Color(0.0, 0.898, 1.0, 0.95)
	sel_border.border_width  = 3.0
	sel_border.editor_only   = false
	sel_border.visible       = (index == _selected_index)
	sel_border.mouse_filter  = Control.MOUSE_FILTER_IGNORE
	container.add_child(sel_border)

	if piece_id == "":
		return container

	# Draw mini piece with 3D bevel and specular gloss
	var cells: Array       = PieceDefinitions.get_cells(piece_id)
	var color_idx: int     = PieceDefinitions.PIECE_COLORS.get(piece_id, 0)
	var block_color: Color = BLOCK_COLORS[color_idx % BLOCK_COLORS.size()]
	var bound: Vector2i    = PieceDefinitions.get_bounding_size(piece_id)
	var max_dim: float     = maxf(bound.x, bound.y)
	var cell_px: float     = minf(84.0 / max_dim, 28.0)
	var pad_x: float       = (102.0 - cell_px * float(bound.x)) * 0.5 + 4.0
	var pad_y: float       = (102.0 - cell_px * float(bound.y)) * 0.5 + 4.0

	for offset: Vector2i in cells:
		var cr := ColorRect.new()
		cr.color        = block_color
		cr.size         = Vector2(cell_px - 2.0, cell_px - 2.0)
		cr.position     = Vector2(pad_x + offset.x * cell_px, pad_y + offset.y * cell_px)
		cr.mouse_filter = Control.MOUSE_FILTER_IGNORE

		# Top highlight bevel
		var hi := ColorRect.new()
		hi.color        = Color(1.0, 1.0, 1.0, 0.35)
		hi.size         = Vector2(cell_px - 2.0, (cell_px - 2.0) * 0.35)
		hi.position     = Vector2.ZERO
		hi.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cr.add_child(hi)

		# Bottom shadow bevel
		var sh := ColorRect.new()
		sh.color        = Color(0.0, 0.0, 0.0, 0.3)
		sh.size         = Vector2(cell_px - 2.0, 2.5)
		sh.position     = Vector2(0, cell_px - 4.5)
		sh.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cr.add_child(sh)

		container.add_child(cr)

	container.mouse_filter = Control.MOUSE_FILTER_STOP
	container.gui_input.connect(_on_slot_input.bind(index, piece_id, container))
	return container

# ---- Drag & Drop & Selection ----

func _on_slot_input(event: InputEvent, piece_index: int, piece_id: String, slot: Control) -> void:
	if GameState.input_locked or piece_id == "" or GameState.run.status != RunState.Status.PLAYING:
		return

	var is_press  := false
	var is_touch  := false
	var touch_pos := Vector2.ZERO

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		is_press  = true
		is_touch  = false
		touch_pos = get_global_mouse_position()
	elif event is InputEventScreenTouch and event.pressed:
		is_press  = true
		is_touch  = true
		touch_pos = event.position

	if is_press and _drag_index < 0:
		_start_drag(piece_index, piece_id, slot, touch_pos, is_touch)

func _start_drag(piece_index: int, piece_id: String, slot: Control, touch_pos: Vector2, is_touch: bool) -> void:
	_drag_index     = piece_index
	_drag_id        = piece_id
	_drag_slot      = slot
	_drag_start_pos = touch_pos
	_has_dragged    = false
	_is_touch       = is_touch

	if _drag_slot != null and is_instance_valid(_drag_slot):
		_drag_slot.modulate.a = 0.3

	_create_drag_preview(piece_id, is_touch)
	_on_drag_move(touch_pos)

func _create_drag_preview(piece_id: String, is_touch: bool) -> void:
	if _drag_preview != null:
		_drag_preview.queue_free()
		_drag_preview = null

	var cells: Array       = PieceDefinitions.get_cells(piece_id)
	var color_idx: int     = PieceDefinitions.PIECE_COLORS.get(piece_id, 0)
	var block_color: Color = BLOCK_COLORS[color_idx % BLOCK_COLORS.size()]
	var bound: Vector2i    = PieceDefinitions.get_bounding_size(piece_id)

	var cs: float = _board_draw.get_cell_size()
	if cs <= 0.0:
		cs = 44.0

	var piece_w: float = float(bound.x) * cs
	var piece_h: float = float(bound.y) * cs

	# Desktop mouse centers piece; touch lifts piece above thumb
	if is_touch:
		_drag_offset = Vector2(-piece_w * 0.5, -piece_h - 48.0)
	else:
		_drag_offset = Vector2(-piece_w * 0.5, -piece_h * 0.5)

	_drag_preview = Control.new()
	_drag_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_drag_preview.z_index = 100

	# Scale pop effect on pickup
	_drag_preview.scale = Vector2(0.9, 0.9)
	var tw := create_tween()
	tw.tween_property(_drag_preview, "scale", Vector2(1.05, 1.05), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	for offset: Vector2i in cells:
		var block := ColorRect.new()
		block.color        = block_color
		block.size         = Vector2(cs - 2.5, cs - 2.5)
		block.position     = Vector2(offset.x * cs + 1.25, offset.y * cs + 1.25)
		block.mouse_filter = Control.MOUSE_FILTER_IGNORE

		# Glassy gloss
		var hi := ColorRect.new()
		hi.color        = Color(1.0, 1.0, 1.0, 0.35)
		hi.size         = Vector2(cs - 2.5, (cs - 2.5) * 0.35)
		hi.position     = Vector2.ZERO
		hi.mouse_filter = Control.MOUSE_FILTER_IGNORE
		block.add_child(hi)

		# Bottom bevel shadow
		var sh := ColorRect.new()
		sh.color        = Color(0.0, 0.0, 0.0, 0.35)
		sh.size         = Vector2(cs - 2.5, 3.5)
		sh.position     = Vector2(0, cs - 6.0)
		sh.mouse_filter = Control.MOUSE_FILTER_IGNORE
		block.add_child(sh)

		_drag_preview.add_child(block)

	add_child(_drag_preview)

func _input(event: InputEvent) -> void:
	if _drag_index < 0:
		return

	if event is InputEventMouseMotion:
		_on_drag_move(get_global_mouse_position())
	elif event is InputEventScreenDrag:
		_on_drag_move(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_on_drag_release(get_global_mouse_position())
	elif event is InputEventScreenTouch and not event.pressed:
		_on_drag_release(event.position)

func _on_drag_move(touch_pos: Vector2) -> void:
	if _drag_index < 0:
		return

	if (touch_pos - _drag_start_pos).length() > 6.0:
		_has_dragged = true

	# Smooth lerp floating piece to touch position
	if _drag_preview != null:
		_drag_preview.global_position = touch_pos + _drag_offset

	var cs: float = _board_draw.get_cell_size()
	if cs <= 0.0:
		return

	var piece_top_left: Vector2 = touch_pos + _drag_offset
	var anchor_cell: Vector2i   = _board_draw.global_to_cell(piece_top_left + Vector2(cs * 0.5, cs * 0.5))
	var anchor_col: int         = anchor_cell.x
	var anchor_row: int         = anchor_cell.y

	var cells: Array = PieceDefinitions.get_cells(_drag_id)
	var any_cell_on_board := false
	for offset: Vector2i in cells:
		var r: int = anchor_row + offset.y
		var c: int = anchor_col + offset.x
		if r >= 0 and r < 8 and c >= 0 and c < 8:
			any_cell_on_board = true
			break

	if any_cell_on_board:
		var valid: bool = GameState.is_legal_preview(_drag_index, anchor_row, anchor_col)
		_board_draw.set_preview(_drag_id, anchor_row, anchor_col, valid)
	else:
		_board_draw.clear_preview()

func _on_drag_release(touch_pos: Vector2) -> void:
	if _drag_index < 0:
		return

	if not _has_dragged:
		# Stationary tap: select slot for tap-to-place
		if _selected_index == _drag_index:
			_clear_selection()
		else:
			_select_slot(_drag_index, _drag_id, _drag_slot)
		_cancel_drag(false)
		return

	var cs: float = _board_draw.get_cell_size()
	var placed := false

	if cs > 0.0:
		var piece_top_left: Vector2 = touch_pos + _drag_offset
		var anchor_cell: Vector2i   = _board_draw.global_to_cell(piece_top_left + Vector2(cs * 0.5, cs * 0.5))
		var anchor_row: int         = anchor_cell.y
		var anchor_col: int         = anchor_cell.x

		if GameState.is_legal_preview(_drag_index, anchor_row, anchor_col):
			var result = GameState.try_place_piece(_drag_index, anchor_row, anchor_col)
			if result != null:
				placed = true
				_handle_successful_placement(result, piece_top_left)
				_clear_selection()

	_cancel_drag(not placed)

func _on_board_input(event: InputEvent) -> void:
	if _selected_index < 0 or GameState.input_locked or GameState.run.status != RunState.Status.PLAYING:
		return

	var is_click  := false
	var click_pos := Vector2.ZERO

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		is_click  = true
		click_pos = get_global_mouse_position()
	elif event is InputEventScreenTouch and event.pressed:
		is_click  = true
		click_pos = event.position

	if is_click:
		var cell: Vector2i = _board_draw.global_to_cell(click_pos)
		if cell.x >= 0 and cell.x < 8 and cell.y >= 0 and cell.y < 8:
			var bound: Vector2i = PieceDefinitions.get_bounding_size(_selected_id)
			var anchor_col: int = cell.x - int(bound.x / 2)
			var anchor_row: int = cell.y - int(bound.y / 2)
			if GameState.is_legal_preview(_selected_index, anchor_row, anchor_col):
				var result = GameState.try_place_piece(_selected_index, anchor_row, anchor_col)
				if result != null:
					_handle_successful_placement(result, click_pos)
					_clear_selection()

func _handle_successful_placement(result: Dictionary, spawn_pos: Vector2) -> void:
	AudioManager.play_placement()
	var cleared: Array = result.get("cleared_cells", [])
	var score_data: Dictionary = result.get("score_data", {})
	var pts: int = score_data.get("total", 0)

	# Floating score popup
	var popup_text := "+%d" % pts
	var popup_color := Color(1.0, 0.88, 0.2)
	var chain: int = score_data.get("new_chain", 0)

	if cleared.size() > 0:
		AudioManager.play_clear(chain - 1)
		shake_board(3.5 + float(chain) * 1.5)
		popup_color = Color(0.2, 0.95, 1.0)
		if chain >= 2:
			AudioManager.play_combo(chain)
			popup_text = "+%d COMBO x%d!" % [pts, chain]
			popup_color = Color(1.0, 0.5, 0.9)
	else:
		shake_board(1.5)

	spawn_floating_text(popup_text, spawn_pos, popup_color)

func shake_board(intensity: float = 3.0) -> void:
	if GameState.reduced_motion:
		return
	var tw := create_tween()
	var orig := board_control.position
	tw.tween_property(board_control, "position", orig + Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity)), 0.04)
	tw.tween_property(board_control, "position", orig + Vector2(randf_range(-intensity * 0.5, intensity * 0.5), randf_range(-intensity * 0.5, intensity * 0.5)), 0.05)
	tw.tween_property(board_control, "position", orig, 0.06)

func spawn_floating_text(text: String, global_pos: Vector2, color: Color, font_size: int = 24) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_font_size_override("font_size", font_size)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.z_index = 150
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.global_position = global_pos - Vector2(100.0, 20.0)
	lbl.custom_minimum_size = Vector2(200.0, 36.0)
	add_child(lbl)

	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(lbl, "global_position:y", lbl.global_position.y - 45.0, 0.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.35).set_delay(0.3)
	tw.chain().tween_callback(lbl.queue_free)

func _spawn_confetti(pos: Vector2) -> void:
	var p := CPUParticles2D.new()
	p.position = pos
	p.emitting = true
	p.one_shot = true
	p.explosiveness = 0.9
	p.amount = 45
	p.lifetime = 1.2
	p.spread = 180.0
	p.gravity = Vector2(0, 180)
	p.initial_velocity_min = 90.0
	p.initial_velocity_max = 220.0
	p.scale_amount_min = 3.0
	p.scale_amount_max = 7.0
	p.color = Color(1.0, 0.85, 0.2)
	add_child(p)
	get_tree().create_timer(1.5).timeout.connect(p.queue_free)

func _cancel_drag(restore_slot: bool = true) -> void:
	if _drag_preview != null:
		_drag_preview.queue_free()
		_drag_preview = null

	if _board_draw != null:
		_board_draw.clear_preview()

	if restore_slot and _drag_slot != null and is_instance_valid(_drag_slot):
		_drag_slot.modulate.a = 1.0

	_drag_index = -1
	_drag_id    = ""
	_drag_slot  = null

func _select_slot(index: int, piece_id: String, slot: Control) -> void:
	_clear_selection()
	_selected_index = index
	_selected_id    = piece_id
	_selected_slot  = slot
	if _selected_slot != null and is_instance_valid(_selected_slot):
		_selected_slot.modulate.a = 1.0
		var b := _selected_slot.get_node_or_null("SelectionBorder")
		if b != null:
			b.visible = true

func _clear_selection() -> void:
	if _selected_slot != null and is_instance_valid(_selected_slot):
		_selected_slot.modulate.a = 1.0
		var b := _selected_slot.get_node_or_null("SelectionBorder")
		if b != null:
			b.visible = false
	_selected_index = -1
	_selected_id    = ""
	_selected_slot  = null
	if _board_draw != null:
		_board_draw.clear_preview()

func _animate_combo_label() -> void:
	if GameState.reduced_motion:
		return
	var tween := create_tween()
	tween.tween_property(combo_label, "scale", Vector2(1.25, 1.25), 0.1)
	tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.15)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if game_over_overlay.visible:
			_on_home_pressed()
		elif pause_overlay.visible:
			_on_resume_pressed()
		else:
			_on_pause_pressed()
	elif what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		_cancel_drag(true)
