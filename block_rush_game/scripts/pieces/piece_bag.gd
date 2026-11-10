## BLOCK RUSH — PieceBag
## Generates balanced random piece sequences.
## Uses a seeded RandomNumberGenerator for reproducibility.

class_name PieceBag

var rng: RandomNumberGenerator

func _init() -> void:
	rng = RandomNumberGenerator.new()
	rng.randomize()

## Returns an Array of TRAY_SIZE distinct piece IDs, weighted by WEIGHTS.
## Guarantees all three pieces are different when possible.
func deal(count: int = 3) -> Array:
	var result: Array = []
	var attempts := 0
	while result.size() < count and attempts < 1000:
		attempts += 1
		var candidate: String = PieceDefinitions.weighted_random(rng)
		if not result.has(candidate):
			result.append(candidate)
	# Safety fallback: fill with any pieces if we ran out of unique candidates
	while result.size() < count:
		result.append(PieceDefinitions.weighted_random(rng))
	return result

## Seeds the RNG (used for Daily Challenge).
func seed_rng(seed_value: int) -> void:
	rng.seed = seed_value

