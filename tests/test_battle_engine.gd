class_name TestBattleEngine
extends RefCounted

## Testes automatizados para validação do BattleManager, máquina de estados e cena de combate.


static func run_tests(tree: SceneTree = null) -> bool:
	var passed: bool = true
	passed = passed and test_battle_initialization_with_lucas()
	passed = passed and test_battle_state_machine_flow()
	passed = passed and test_battle_victory_condition()
	passed = passed and test_battle_scene_instantiation(tree)
	return passed


static func test_battle_initialization_with_lucas() -> bool:
	var bm: BattleManager = BattleManager.new()
	assert(bm != null, "BattleManager must instantiate")
	var lucas: CharacterData = CharacterData.create_default_lucas()
	assert(lucas != null, "Lucas Reis must instantiate")
	var enemy: Dictionary = {
		"name": "Soldado Corrompido",
		"max_hp": 80,
		"current_hp": 80,
		"stability": 100
	}
	bm.initialize_battle([lucas], [enemy])
	assert(bm.party_members.size() == 1, "Party must contain 1 member")
	assert(bm.party_members[0].name == "Lucas Reis", "Member must be Lucas Reis")
	assert(bm.enemies.size() == 1, "Enemies must contain 1 enemy")
	assert(bm.enemies[0]["name"] == "Soldado Corrompido", "Enemy name must match")
	assert(bm.current_state == BattleManager.BattleState.AGUARDANDO_TURNO, "State must transition to AGUARDANDO_TURNO")
	bm.free()
	return true


static func test_battle_state_machine_flow() -> bool:
	var bm: BattleManager = BattleManager.new()
	var lucas: CharacterData = CharacterData.create_default_lucas()
	bm.initialize_battle([lucas], [{"name": "Espectro", "max_hp": 40, "current_hp": 40}])
	assert(bm.current_state == BattleManager.BattleState.AGUARDANDO_TURNO, "Initial ready state must be AGUARDANDO_TURNO")
	
	var to_select: bool = bm.change_state(BattleManager.BattleState.SELECIONANDO_ACAO)
	assert(to_select == true, "Must allow transition to SELECIONANDO_ACAO")
	assert(bm.current_state == BattleManager.BattleState.SELECIONANDO_ACAO, "State must be SELECIONANDO_ACAO")
	
	var to_exec: bool = bm.change_state(BattleManager.BattleState.EXECUTANDO_ACAO)
	assert(to_exec == true, "Must allow transition to EXECUTANDO_ACAO")
	assert(bm.current_state == BattleManager.BattleState.EXECUTANDO_ACAO, "State must be EXECUTANDO_ACAO")
	
	var to_wait: bool = bm.change_state(BattleManager.BattleState.AGUARDANDO_TURNO)
	assert(to_wait == true, "Must allow transition back to AGUARDANDO_TURNO")
	
	var invalid: bool = bm.change_state(BattleManager.BattleState.INICIALIZANDO)
	assert(invalid == false, "Must reject invalid transition to INICIALIZANDO")
	bm.free()
	return true


static func test_battle_victory_condition() -> bool:
	var bm: BattleManager = BattleManager.new()
	var lucas: CharacterData = CharacterData.create_default_lucas()
	bm.initialize_battle([lucas], [{"name": "Autômato Guardião", "max_hp": 50, "current_hp": 50}])
	
	bm.change_state(BattleManager.BattleState.SELECIONANDO_ACAO)
	bm.change_state(BattleManager.BattleState.EXECUTANDO_ACAO)
	var dmg: int = bm.apply_damage_to_enemy(0, 50)
	assert(dmg == 50, "Damage dealt must be 50")
	assert(int(bm.enemies[0]["current_hp"]) == 0, "Enemy HP must reach 0")
	assert(bm.is_all_enemies_defeated() == true, "All enemies must be marked defeated")
	assert(bm.current_state == BattleManager.BattleState.VITORIA, "State must transition to VITORIA")
	bm.free()
	return true


static func test_battle_scene_instantiation(tree: SceneTree = null) -> bool:
	if tree == null:
		tree = Engine.get_main_loop() as SceneTree
	var scene_res: PackedScene = load("res://scenes/battle/battle_scene.tscn")
	assert(scene_res != null, "battle_scene.tscn must be loadable")
	var battle_scene: Node2D = scene_res.instantiate() as Node2D
	assert(battle_scene != null, "Battle scene must instantiate")
	if tree != null and tree.root != null:
		tree.root.add_child(battle_scene)
	
	var bm: BattleManager = battle_scene.get_node_or_null("BattleManager") as BattleManager
	assert(bm != null, "BattleManager node must exist in battle scene")
	var state_lbl: Label = battle_scene.get_node_or_null("CanvasLayer/UI/HeaderPanel/Margin/HBox/StateLabel") as Label
	assert(state_lbl != null, "StateLabel must exist")
	assert(state_lbl.text.contains("Inicializando"), "State label must display PT-BR state")
	
	if tree != null and tree.root != null:
		tree.root.remove_child(battle_scene)
	battle_scene.free()
	return true
