extends SceneTree

## Runner de suíte de testes automatizados headless para o projeto Kenoma.


func _init() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	print("--- KENOMA AUTOMATED TEST SUITE ---")
	_setup_autoloads()
	var all_ok: bool = true
	all_ok = _run_test("1/5", "test_push_physics", TestPushPhysics.run_tests(self)) and all_ok
	all_ok = _run_test("2/5", "test_scene_manager", TestSceneManager.run_tests(self)) and all_ok
	all_ok = _run_test("3/5", "test_dialogue_system", TestDialogueSystem.run_tests(self)) and all_ok
	all_ok = _run_test("4/5", "test_pause_menu", TestPauseMenu.run_tests(self)) and all_ok
	all_ok = _run_test("5/5", "test_battle_engine", TestBattleEngine.run_tests(self)) and all_ok
	_print_summary_and_exit(all_ok)


func _run_test(num: String, test_name: String, result: bool) -> bool:
	print("[%s] Running %s.gd..." % [num, test_name])
	print("       %s: %s" % [test_name, "PASS" if result else "FAIL"])
	return result


func _print_summary_and_exit(all_ok: bool) -> void:
	print("====================================")
	print("SUITE OVERALL RESULT: ", "ALL PASS" if all_ok else "FAIL")
	print("====================================")
	if all_ok:
		quit(0)
	else:
		quit(1)


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
