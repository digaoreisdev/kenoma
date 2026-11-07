class_name TestSceneManager
extends RefCounted

## Testes automatizados para validação do SceneManager, transições de tela e fendas de miasma.


static func run_tests(tree: SceneTree = null) -> bool:
	var all_passed: bool = true
	all_passed = all_passed and test_scene_manager_singleton_structure()
	all_passed = all_passed and test_spawn_point()
	all_passed = all_passed and test_doorway_trigger()
	all_passed = all_passed and test_player_transition_input_block()
	all_passed = all_passed and test_battle_transition_initiating()
	all_passed = all_passed and test_battle_transition_returning_and_clearing_rift()
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


static func test_battle_transition_initiating() -> bool:
	var sm: SceneManagerSingleton = SceneManagerSingleton.new()
	sm._ready()
	var dados: Dictionary = {
		"rift_id": "fenda_teste",
		"player_pos": Vector2(100, 200),
		"mapa_origem": "res://scenes/maps/test_map.tscn",
		"grupo_inimigo": [{"name": "Espectro", "max_hp": 50}]
	}
	sm.iniciar_batalha(dados, false)
	assert(sm.batalha_dados_retorno["rift_id"] == "fenda_teste", "Rift ID must be recorded")
	assert(sm.batalha_dados_retorno["player_pos"] == Vector2(100, 200), "Player pos must be recorded")
	assert(sm.batalha_dados_retorno["mapa_origem"] == "res://scenes/maps/test_map.tscn", "Map path must be recorded")
	assert(sm.cena_batalha_ativa != null, "Battle scene instance must be created")
	assert(sm.ultima_cena_carregada.contains("battle_scene"), "Battle scene path must match")
	if sm.cena_batalha_ativa != null:
		sm.cena_batalha_ativa.free()
	var gs: Node = sm._get_autoload_node("GameState")
	if gs != null and gs.has_method("change_state"):
		gs.call("change_state", 0)
	sm.free()
	return true


static func _criar_mock_mapa_com_rift(r_id: String) -> Node2D:
	var mock_map: Node2D = Node2D.new()
	var mock_player: CharacterBody2D = CharacterBody2D.new()
	mock_player.name = "Player"
	mock_map.add_child(mock_player)
	var mock_rift: MiasmaRift = MiasmaRift.new()
	mock_rift.name = "MiasmaRift"
	mock_rift.rift_id = r_id
	mock_map.add_child(mock_rift)
	return mock_map


static func test_battle_transition_returning_and_clearing_rift() -> bool:
	var sm: SceneManagerSingleton = SceneManagerSingleton.new()
	sm._ready()
	var dados: Dictionary = {"rift_id": "fenda_01", "player_pos": Vector2(150, -50), "mapa_origem": "test"}
	sm.iniciar_batalha(dados, false)
	if sm.cena_batalha_ativa != null:
		sm.cena_batalha_ativa.free()
	var mock_map: Node2D = _criar_mock_mapa_com_rift("fenda_01")
	sm.aplicar_retorno_batalha(mock_map, true)
	var p: Node2D = mock_map.get_node("Player") as Node2D
	assert(p.global_position == Vector2(150, -50), "Player pos must be restored")
	assert(sm.is_rift_derrotada("fenda_01") == true, "Defeated rift must be recorded")
	var r: MiasmaRift = mock_map.get_node("MiasmaRift") as MiasmaRift
	assert(r.foi_ativada == true or r.is_queued_for_deletion(), "Defeated rift must be deactivated")
	mock_map.free()
	sm.free()
	return true
