## BLOCK RUSH — Unit Tests for GameRules and BoardState
## Run via: Godot scene with this script attached to a Node.
## Results print to the Output panel.

extends Node

var _pass_count := 0
var _fail_count := 0

func _ready() -> void:
	print("=== BLOCK RUSH Unit Tests ===")
	_run_all_tests()
	print("")
	print("RESULTS: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count == 0:
		print("✅ ALL TESTS PASSED")
	else:
		print("❌ SOME TESTS FAILED — see above")
	if DisplayServer.get_name() == "headless":
		get_tree().quit(0 if _fail_count == 0 else 1)

func _run_all_tests() -> void:
	_test_board_in_bounds()
	_test_board_occupy_and_clear()
	_test_row_complete()
	_test_col_complete()
	_test_simultaneous_clear_no_double_count()
	_test_placement_legal_basic()
	_test_placement_illegal_out_of_bounds()
	_test_placement_illegal_overlap()
	_test_score_basic()
	_test_score_clear_bonus()
	_test_score_combo()
	_test_combo_reset()
	_test_game_over_detection()
	_test_board_serialise_roundtrip()
	_test_run_state_roundtrip()
	_test_resolve_placement_full()

## ---- Helpers ----

func _assert(condition: bool, test_name: String) -> void:
	if condition:
		print("  ✓ " + test_name)
		_pass_count += 1
	else:
		print("  ✗ FAIL: " + test_name)
		_fail_count += 1

func _make_full_row_board(row: int) -> BoardState:
	var b := BoardState.new()
	for col in range(BoardState.BOARD_SIZE):
		b.occupy(row, col)
	return b

func _make_full_col_board(col: int) -> BoardState:
	var b := BoardState.new()
	for row in range(BoardState.BOARD_SIZE):
		b.occupy(row, col)
	return b

## ---- Tests ----

func _test_board_in_bounds() -> void:
	print("Board bounds:")
	var b := BoardState.new()
	_assert(b.in_bounds(0, 0),   "top-left corner is in-bounds")
	_assert(b.in_bounds(7, 7),   "bottom-right corner is in-bounds")
	_assert(not b.in_bounds(-1, 0), "row -1 is out-of-bounds")
	_assert(not b.in_bounds(0, -1), "col -1 is out-of-bounds")
	_assert(not b.in_bounds(8, 0),  "row 8 is out-of-bounds")
	_assert(not b.in_bounds(0, 8),  "col 8 is out-of-bounds")

func _test_board_occupy_and_clear() -> void:
	print("Board occupy/clear:")
	var b := BoardState.new()
	_assert(b.is_empty(3, 3), "cell empty before occupy")
	b.occupy(3, 3)
	_assert(not b.is_empty(3, 3), "cell occupied after occupy")
	b.clear_cell(3, 3)
	_assert(b.is_empty(3, 3), "cell empty after clear")

func _test_row_complete() -> void:
	print("Row completion:")
	var b := _make_full_row_board(4)
	_assert(b.is_row_complete(4), "full row 4 is complete")
	_assert(not b.is_row_complete(3), "empty row 3 is not complete")
	var complete_rows := b.get_complete_rows()
	_assert(complete_rows.size() == 1 and complete_rows[0] == 4, "get_complete_rows returns [4]")

func _test_col_complete() -> void:
	print("Column completion:")
	var b := _make_full_col_board(2)
	_assert(b.is_col_complete(2), "full col 2 is complete")
	_assert(not b.is_col_complete(1), "empty col 1 is not complete")
	var complete_cols := b.get_complete_cols()
	_assert(complete_cols.size() == 1 and complete_cols[0] == 2, "get_complete_cols returns [2]")

func _test_simultaneous_clear_no_double_count() -> void:
	print("Simultaneous row+col clear (no double-count):")
	var b := BoardState.new()
	# Fill row 0 and col 0
	for col in range(BoardState.BOARD_SIZE):
		b.occupy(0, col)
	for row in range(BoardState.BOARD_SIZE):
		b.occupy(row, 0)
	var rows := b.get_complete_rows()
	var cols := b.get_complete_cols()
	var cleared := b.get_clear_cells(rows, cols)
	# 8 cells in row 0 + 8 cells in col 0 - 1 intersection = 15
	_assert(cleared.size() == 15, "15 unique cells cleared (no double-count at [0,0])")

func _test_placement_legal_basic() -> void:
	print("Legal placement:")
	var b := BoardState.new()
	_assert(GameRules.is_placement_legal(b, "monomino", 0, 0), "monomino at 0,0 is legal on empty board")
	_assert(GameRules.is_placement_legal(b, "tetro_o", 3, 3),  "2×2 at 3,3 is legal on empty board")

func _test_placement_illegal_out_of_bounds() -> void:
	print("Illegal placement (out of bounds):")
	var b := BoardState.new()
	_assert(not GameRules.is_placement_legal(b, "tetro_i_h", 0, 5), "4-wide piece at col 5 extends to col 8 — illegal")
	_assert(not GameRules.is_placement_legal(b, "monomino", -1, 0),  "negative row — illegal")
	_assert(not GameRules.is_placement_legal(b, "monomino", 8, 0),   "row 8 — illegal")

func _test_placement_illegal_overlap() -> void:
	print("Illegal placement (overlap):")
	var b := BoardState.new()
	b.occupy(0, 0)
	_assert(not GameRules.is_placement_legal(b, "monomino", 0, 0),  "monomino on occupied cell — illegal")
	_assert(not GameRules.is_placement_legal(b, "domino_h", 0, 0),  "domino_h starting on occupied cell — illegal")
	_assert(GameRules.is_placement_legal(b, "monomino", 0, 1), "monomino on empty adjacent cell — legal")

func _test_score_basic() -> void:
	print("Score — placement only:")
	var sd := GameRules.calculate_score("tetro_o", 0, 0)
	# tetro_o has 4 cells → 4 pts, no clears
	_assert(sd["total"] == 4,         "4 blocks placed → 4 points")
	_assert(sd["clear_points"] == 0,  "no clear bonus")
	_assert(sd["combo_points"] == 0,  "no combo bonus")
	_assert(sd["new_chain"] == 0,     "chain resets to 0")

func _test_score_clear_bonus() -> void:
	print("Score — clear bonus:")
	# 8 cells cleared in one move, combo_chain was 0 before move
	var sd := GameRules.calculate_score("monomino", 8, 0)
	# 1 (block) + 8*10 (clear) + 5*1 (combo chain becomes 1) = 86
	_assert(sd["clear_points"] == 80,  "8 cleared cells → 80 clear points")
	_assert(sd["new_chain"]    == 1,   "chain increments to 1")
	_assert(sd["combo_points"] == 5,   "combo bonus = 5×1 = 5")
	_assert(sd["total"]        == 86,  "total = 1 + 80 + 5 = 86")

func _test_score_combo() -> void:
	print("Score — combo chain:")
	# Chain was 2, now clear again → chain becomes 3
	var sd := GameRules.calculate_score("monomino", 8, 2)
	_assert(sd["new_chain"]    == 3,   "chain: 2→3")
	_assert(sd["combo_points"] == 15,  "combo bonus = 5×3 = 15")

func _test_combo_reset() -> void:
	print("Score — combo reset:")
	var sd := GameRules.calculate_score("monomino", 0, 3)
	_assert(sd["new_chain"]    == 0,  "no clears → chain resets to 0")
	_assert(sd["combo_points"] == 0,  "no combo bonus when chain resets")

func _test_game_over_detection() -> void:
	print("Game-over detection:")
	# Fill the board almost completely, leave no room for even monomino
	var b := BoardState.new()
	for row in range(BoardState.BOARD_SIZE):
		for col in range(BoardState.BOARD_SIZE):
			b.occupy(row, col)
	var tray := ["monomino"]
	_assert(GameRules.is_game_over(b, tray), "fully occupied board → game over")

	var b2 := BoardState.new()
	_assert(not GameRules.is_game_over(b2, tray), "empty board → not game over")

func _test_board_serialise_roundtrip() -> void:
	print("Board serialise round-trip:")
	var b := BoardState.new()
	b.occupy(0, 0)
	b.occupy(7, 7)
	b.occupy(3, 4)
	var flat := b.to_array()
	var b2   := BoardState.new()
	var ok   := b2.from_array(flat)
	_assert(ok,                      "from_array returns true")
	_assert(not b2.is_empty(0, 0),   "cell (0,0) restored")
	_assert(not b2.is_empty(7, 7),   "cell (7,7) restored")
	_assert(not b2.is_empty(3, 4),   "cell (3,4) restored")
	_assert(b2.is_empty(0, 1),       "unset cell (0,1) still empty")

func _test_run_state_roundtrip() -> void:
	print("RunState serialise round-trip:")
	var r := RunState.new()
	r.start_new_run(500)
	r.score = 123
	r.combo_chain = 2
	r.tray = ["monomino", "tetro_o", ""]
	var d  := r.to_dict()
	var r2 := RunState.new()
	var ok := r2.from_dict(d)
	_assert(ok,              "from_dict returns true")
	_assert(r2.score == 123, "score restored")
	_assert(r2.best_score == 500, "best_score restored")
	_assert(r2.combo_chain == 2,  "combo_chain restored")
	_assert(r2.tray[0] == "monomino", "tray[0] restored")
	_assert(r2.tray[2] == "",         "tray[2] empty string restored")

func _test_resolve_placement_full() -> void:
	print("GameRules.resolve_placement full flow:")
	var b := BoardState.new()
	# Fill row 0 except col 7 with 7 blocks, then place monomino to complete the row
	for col in range(7):
		b.occupy(0, col)
	var result = GameRules.resolve_placement(b, "monomino", 0, 7, 0)
	_assert(result != null,                          "legal placement returns result")
	_assert(result["complete_rows"].size() == 1,     "one row completed")
	_assert(result["complete_rows"][0] == 0,         "row 0 completed")
	_assert(result["score_data"]["new_chain"] == 1,  "chain becomes 1")

	# Verify illegal move returns null and board is unchanged
	var b2    := BoardState.new()
	b2.occupy(0, 0)
	var null_result = GameRules.resolve_placement(b2, "monomino", 0, 0, 0)
	_assert(null_result == null,       "illegal placement returns null")
	_assert(not b2.is_empty(0, 0),    "board not changed by illegal move")
	_assert(b2.is_empty(0, 1),        "adjacent cell still empty")

