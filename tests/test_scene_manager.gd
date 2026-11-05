class_name TestSceneManager
extends RefCounted

## Testes automatizados para validação do SceneManager, transições de tela e doorways.


static func run_tests() -> bool:
	var all_passed: bool = true
	all_passed = all_passed and test_scene_manager_singleton_structure()
	all_passed = all_passed and test_spawn_point()
	all_passed = all_passed and test_doorway_trigger()
	all_passed = all_passed and test_player_transition_input_block()
	return all_passed


static func test_scene_manager_singleton_structure() -> bool:
	var sm: SceneManagerSingleton = SceneManagerSingleton.new()
	assert(sm != null, "SceneManagerSingleton must instantiate")
	assert(sm.is_transitioning == false, "Must start not transitioning")
	assert(is_equal_approx(sm.fade_duration, 0.35), "Default fade duration must be 0.35s")
	sm._ready()
	var fade_rect: ColorRect = sm.get("_fade_rect") as ColorRect
	assert(fade_rect != null, "Fade overlay ColorRect must be initialized")
	assert(fade_rect.color == Color.BLACK, "Fade overlay must be black")
	assert(fade_rect.modulate.a == 0.0, "Fade overlay must start completely transparent")
	sm.free()
	return true


static func test_spawn_point() -> bool:
	var spawn: SpawnPoint = SpawnPoint.new()
	assert(spawn != null, "SpawnPoint must instantiate")
	spawn.spawn_id = "point_alpha"
	spawn._ready()
	assert(spawn.spawn_id == "point_alpha", "SpawnPoint must retain spawn_id")
	assert(spawn.is_in_group("spawn_points"), "SpawnPoint must register in spawn_points group")
	spawn.free()
	return true


static func test_doorway_trigger() -> bool:
	var door: Doorway = Doorway.new()
	assert(door != null, "Doorway must instantiate")
	door.target_scene = "res://scenes/maps/test_room_b.tscn"
	door.target_spawn_id = "from_test_map"
	door.exit_direction = Player.Direction.UP
	assert(door.target_scene == "res://scenes/maps/test_room_b.tscn", "Target scene must match")
	assert(door.target_spawn_id == "from_test_map", "Target spawn must match")
	assert(door.exit_direction == Player.Direction.UP, "Exit direction must match")
	door.free()
	return true


static func test_player_transition_input_block() -> bool:
	var player_scene: PackedScene = load("res://scenes/characters/player.tscn")
	assert(player_scene != null, "Player scene must be loadable")
	var player: Player = player_scene.instantiate() as Player
	assert(player != null, "Player must instantiate")
	
	player.set_facing_direction(Player.Direction.LEFT)
	assert(player.current_direction == Player.Direction.LEFT, "Facing direction must update")
	assert(player.current_state == Player.State.IDLE, "State must be IDLE on arrival")
	player.free()
	return true

