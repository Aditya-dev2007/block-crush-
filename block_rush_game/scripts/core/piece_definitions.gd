## BLOCK RUSH — Piece Definitions
## Pure data: no Godot Node dependencies.
## Each piece is an Array of Vector2i cell offsets relative to anchor (0,0).

class_name PieceDefinitions

# --- Piece IDs (string keys) ---
# Used for serialization and color assignment.

const SHAPES: Dictionary = {

	# Single
	"monomino": [Vector2i(0, 0)],

	# Dominoes
	"domino_h": [Vector2i(0, 0), Vector2i(1, 0)],
	"domino_v": [Vector2i(0, 0), Vector2i(0, 1)],

	# Trominoes
	"tromino_i_h": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)],
	"tromino_i_v": [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2)],
	"tromino_l":   [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1)],
	"tromino_j":   [Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1)],

	# Tetrominoes
	"tetro_i_h": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)],
	"tetro_i_v": [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3)],
	"tetro_o":   [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)],
	"tetro_l":   [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(1, 2)],
	"tetro_j":   [Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(0, 2)],
	"tetro_s":   [Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)],
	"tetro_z":   [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)],
	"tetro_t":   [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1)],

	# Pentominoes (selected balanced shapes)
	"pento_plus": [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)],
	"pento_l":    [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3), Vector2i(1, 3)],
	"pento_j":    [Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3), Vector2i(0, 3)],
	"pento_i_h":  [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0)],
	"pento_i_v":  [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3), Vector2i(0, 4)],
	"pento_2x3_tl": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)],
	"pento_2x3_tr": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)],

	# 2×2 square
	"square_2x2": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)],

	# 3×3 square
	"square_3x3": [
		Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0),
		Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1),
		Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2),
	],

	# Corner pieces
	"corner_tl": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)],
	"corner_tr": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1)],
	"corner_bl": [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1)],
	"corner_br": [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)],

	# Big L shapes
	"big_l_tl": [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(1, 0), Vector2i(2, 0)],
	"big_l_tr": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2)],
	"big_l_bl": [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2)],
	"big_l_br": [Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(2, 1), Vector2i(2, 0)],
}

# Piece weights for balanced random selection.
# Higher = more likely to appear. Large pieces are less frequent.
const WEIGHTS: Dictionary = {
	"monomino":       3,
	"domino_h":       5,
	"domino_v":       5,
	"tromino_i_h":    7,
	"tromino_i_v":    7,
	"tromino_l":      6,
	"tromino_j":      6,
	"tetro_i_h":      6,
	"tetro_i_v":      6,
	"tetro_o":        7,
	"tetro_l":        5,
	"tetro_j":        5,
	"tetro_s":        4,
	"tetro_z":        4,
	"tetro_t":        5,
	"pento_plus":     2,
	"pento_l":        2,
	"pento_j":        2,
	"pento_i_h":      1,
	"pento_i_v":      1,
	"pento_2x3_tl":   2,
	"pento_2x3_tr":   2,
	"square_2x2":     7,
	"square_3x3":     1,
	"corner_tl":      5,
	"corner_tr":      5,
	"corner_bl":      5,
	"corner_br":      5,
	"big_l_tl":       2,
	"big_l_tr":       2,
	"big_l_bl":       2,
	"big_l_br":       2,
}

# Color palette assignment by piece family (block color index 0–4)
const PIECE_COLORS: Dictionary = {
	"monomino":       0,  # Coral
	"domino_h":       1,  # Cyan
	"domino_v":       1,
	"tromino_i_h":    2,  # Lime
	"tromino_i_v":    2,
	"tromino_l":      3,  # Violet
	"tromino_j":      3,
	"tetro_i_h":      0,
	"tetro_i_v":      0,
	"tetro_o":        1,
	"tetro_l":        2,
	"tetro_j":        3,
	"tetro_s":        4,  # Gold
	"tetro_z":        4,
	"tetro_t":        0,
	"pento_plus":     1,
	"pento_l":        2,
	"pento_j":        3,
	"pento_i_h":      4,
	"pento_i_v":      4,
	"pento_2x3_tl":   0,
	"pento_2x3_tr":   1,
	"square_2x2":     2,
	"square_3x3":     3,
	"corner_tl":      0,
	"corner_tr":      1,
	"corner_bl":      2,
	"corner_br":      3,
	"big_l_tl":       4,
	"big_l_tr":       0,
	"big_l_bl":       1,
	"big_l_br":       2,
}

# Color palette — indices map to block colours
static func get_block_color(color_index: int) -> Color:
	match color_index:
		0: return Color(1.0, 0.388, 0.278)   # Electric Coral   #FF6347
		1: return Color(0.0, 0.898, 1.0)     # Electric Cyan    #00E5FF
		2: return Color(0.467, 1.0, 0.0)     # Neon Lime        #77FF00
		3: return Color(0.698, 0.133, 1.0)   # Deep Violet      #B222FF
		4: return Color(1.0, 0.843, 0.0)     # Golden Yellow    #FFD700
		_: return Color(1.0, 1.0, 1.0)

# Returns a weighted random piece ID using the provided RNG.
static func weighted_random(rng: RandomNumberGenerator) -> String:
	var keys := WEIGHTS.keys()
	var total := 0
	for k in keys:
		total += WEIGHTS[k]
	var roll := rng.randi_range(0, total - 1)
	var cumulative := 0
	for k in keys:
		cumulative += WEIGHTS[k]
		if roll < cumulative:
			return k
	return keys[0]

# Returns the cells for a named piece.
static func get_cells(piece_id: String) -> Array:
	if SHAPES.has(piece_id):
		return SHAPES[piece_id].duplicate()
	push_error("PieceDefinitions: unknown piece id: " + piece_id)
	return [Vector2i(0, 0)]

# Returns the bounding size (cols, rows) of a piece.
static func get_bounding_size(piece_id: String) -> Vector2i:
	var cells: Array = get_cells(piece_id)
	var max_c := 0
	var max_r := 0
	for c: Vector2i in cells:
		if c.x > max_c:
			max_c = c.x
		if c.y > max_r:
			max_r = c.y
	return Vector2i(max_c + 1, max_r + 1)

# Returns all piece IDs in the pool.
static func all_piece_ids() -> Array:
	return SHAPES.keys()

