extends SceneTree

## Runner de suíte de testes automatizados headless para o projeto Kenoma.


func _init() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	print("--- KENOMA AUTOMATED TEST SUITE ---")
	_setup_autoloads()
	var all_ok: bool = true
	
	print("[1/4] Running test_push_physics.gd...")
	var t1: bool = TestPushPhysics.run_tests(self)
	print("       test_push_physics: ", "PASS" if t1 else "FAIL")
	all_ok = all_ok and t1
	
	print("[2/4] Running test_scene_manager.gd...")
	var t2: bool = TestSceneManager.run_tests()
	print("       test_scene_manager: ", "PASS" if t2 else "FAIL")
	all_ok = all_ok and t2
	
	print("[3/4] Running test_dialogue_system.gd...")
	var t3: bool = TestDialogueSystem.run_tests(self)
	print("       test_dialogue_system: ", "PASS" if t3 else "FAIL")
	all_ok = all_ok and t3
	
	print("[4/4] Running test_pause_menu.gd...")
	var t4: bool = TestPauseMenu.run_tests(self)
	print("       test_pause_menu: ", "PASS" if t4 else "FAIL")
	all_ok = all_ok and t4
	
	print("====================================")
	print("SUITE OVERALL RESULT: ", "ALL PASS" if all_ok else "FAIL")
	print("====================================")
	quit(0 if all_ok else 1)


func _setup_autoloads() -> void:
	_ensure_autoload("GameState", "res://scripts/autoload/game_state.gd")
	_ensure_autoload("SceneManager", "res://scripts/core/scene_manager.gd")
	_ensure_autoload("DialogueManager", "res://scripts/core/dialogue_manager.gd")
	_ensure_autoload("PartyManager", "res://scripts/core/party_manager.gd")


func _ensure_autoload(node_name: String, path: String) -> void:
	if not root.has_node(node_name):
		var res: Resource = load(path)
		var instance: Node = null
		if res is PackedScene:
			instance = (res as PackedScene).instantiate()
		elif res is GDScript:
			instance = (res as GDScript).new()
		if instance != null:
			instance.name = node_name
			root.add_child(instance)
