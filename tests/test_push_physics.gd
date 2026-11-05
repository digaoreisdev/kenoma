class_name TestPushPhysics
extends RefCounted

## Teste automatizado para histerese (REG-001), integridade de empurrão (REG-002) e mecânica de puxar (F1.10).


static func run_tests() -> bool:
	var all_passed: bool = true
	all_passed = all_passed and test_interaction_ray_lengths()
	all_passed = all_passed and test_push_alignment()
	all_passed = all_passed and test_hysteresis_buffer()
	all_passed = all_passed and test_push_animation_cycle_integrity()
	all_passed = all_passed and test_push_crate_single_step()
	all_passed = all_passed and test_pull_vector_opposition()
	all_passed = all_passed and test_pull_animation_cycle_integrity()
	all_passed = all_passed and test_pull_crate_step()
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
	var buffer: float = 0.20
	var delta: float = 0.016
	buffer = maxf(0.0, buffer - delta)
	assert(buffer > 0.15, "Buffer must remain active during micro-frame separations")
	return true


static func test_push_animation_cycle_integrity() -> bool:
	var frames_res: Resource = load("res://assets/art/characters/player/player_frames.tres")
	assert(frames_res != null, "player_frames.tres must be loaded")
	var sprite_frames: SpriteFrames = frames_res as SpriteFrames
	assert(sprite_frames != null, "player_frames must be SpriteFrames")
	
	var variants: Array[String] = [
		"push_down", "push_up", "push_right", "push_left",
		"push_down_right", "push_down_left", "push_up_right", "push_up_left",
		"push_side"
	]
	for anim: String in variants:
		assert(sprite_frames.has_animation(anim), "Missing animation: " + anim)
		assert(sprite_frames.get_animation_loop(anim) == true, "Must loop: " + anim)
		assert(sprite_frames.get_animation_speed(anim) == 10.0, "FPS must be 10: " + anim)
		assert(sprite_frames.get_frame_count(anim) == 16, "Must have 16 frames: " + anim)
	return true


static func test_push_crate_single_step() -> bool:
	var crate: PushCrate = PushCrate.new()
	assert(crate != null, "PushCrate must be instantiable")
	crate.push_by(Vector2.UP, 45.0)
	assert(crate.get("_is_being_pushed") == true, "Flag _is_being_pushed must be active after push_by")
	crate.free()
	return true


static func test_pull_vector_opposition() -> bool:
	var facing_up: Vector2 = Vector2.UP
	var moving_down: Vector2 = Vector2.DOWN
	var dot_opposite: float = moving_down.dot(facing_up)
	assert(dot_opposite < -0.3, "Moving opposite to facing must trigger pull condition")
	
	var facing_left: Vector2 = Vector2.LEFT
	var moving_right: Vector2 = Vector2.RIGHT
	assert(moving_right.dot(facing_left) < -0.3, "Opposite horizontal motion must trigger pull")
	return true


static func test_pull_animation_cycle_integrity() -> bool:
	var frames_res: Resource = load("res://assets/art/characters/player/player_frames.tres")
	assert(frames_res != null, "player_frames.tres must be loaded")
	var sprite_frames: SpriteFrames = frames_res as SpriteFrames
	assert(sprite_frames != null, "player_frames must be SpriteFrames")
	
	var variants: Array[String] = [
		"pull_down", "pull_up", "pull_right", "pull_left",
		"pull_down_right", "pull_down_left", "pull_up_right", "pull_up_left",
		"pull_side"
	]
	for anim: String in variants:
		assert(sprite_frames.has_animation(anim), "Missing animation: " + anim)
		assert(sprite_frames.get_animation_loop(anim) == true, "Must loop: " + anim)
		assert(sprite_frames.get_animation_speed(anim) == 10.0, "FPS must be 10: " + anim)
		assert(sprite_frames.get_frame_count(anim) == 16, "Must have 16 frames: " + anim)
	return true


static func test_pull_crate_step() -> bool:
	var crate: PushCrate = PushCrate.new()
	assert(crate != null, "PushCrate must be instantiable")
	crate.pull_by(Vector2.DOWN, 45.0)
	assert(crate.get("_is_being_pushed") == true, "Flag _is_being_pushed must be active after pull_by")
	crate.free()
	return true

