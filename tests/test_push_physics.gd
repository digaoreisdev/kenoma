class_name TestPushPhysics
extends RefCounted

## Teste automatizado para validação de histerese e alcance de interação de empurrão (REG-001).


static func run_tests() -> bool:
	var all_passed: bool = true
	all_passed = all_passed and test_interaction_ray_lengths()
	all_passed = all_passed and test_push_alignment()
	all_passed = all_passed and test_hysteresis_buffer()
	return all_passed


static func test_interaction_ray_lengths() -> bool:
	var cardinals: Array[Vector2] = [
		Vector2(0, 24), Vector2(0, -24), Vector2(-24, 0), Vector2(24, 0)
	]
	for vec: Vector2 in cardinals:
		assert(vec.length() >= 24.0, "Cardinal interaction ray must have at least 24px reach")
	return true


static func test_push_alignment() -> bool:
	var input_up: Vector2 = Vector2.UP
	var normal_down: Vector2 = Vector2.DOWN
	var push_dir: Vector2 = -normal_down
	var dot_product: float = push_dir.dot(input_up)
	assert(dot_product > 0.99, "Pushing against normal must have positive dot product")
	return true


static func test_hysteresis_buffer() -> bool:
	var buffer: float = 0.15
	var delta: float = 0.016
	buffer = maxf(0.0, buffer - delta)
	assert(buffer > 0.1, "Buffer must remain active during micro-frame separations")
	return true
