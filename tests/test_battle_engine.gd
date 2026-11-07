class_name TestBattleEngine
extends RefCounted

## Testes automatizados para validação do BattleManager, ações de combate e HUD da cena.


static func run_tests(tree: SceneTree = null) -> bool:
	var passed: bool = true
	passed = passed and test_battle_initialization_with_lucas()
	passed = passed and test_battle_state_machine_flow()
	passed = passed and test_battle_victory_condition()
	passed = passed and test_battle_scene_instantiation(tree)
	passed = passed and test_battle_timeline_progression()
	passed = passed and test_battle_stability_ruptura()
	passed = passed and test_battle_stability_irritacao()
	passed = passed and test_battle_basic_attack_affinity_and_stability()
	passed = passed and test_battle_defender_command()
	passed = passed and test_battle_item_consumption()
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
	var cmd_panel: Control = battle_scene.get_node_or_null("CanvasLayer/UI/ActionCommandPanel") as Control
	assert(cmd_panel != null, "ActionCommandPanel must exist")
	
	if tree != null and tree.root != null:
		tree.root.remove_child(battle_scene)
	battle_scene.free()
	return true


static func test_battle_timeline_progression() -> bool:
	var timeline: BattleTimeline = BattleTimeline.new()
	var combatant: Dictionary = {
		"id": "lucas",
		"nome": "Lucas Reis",
		"velocidade": 50.0,
		"posicao_tempo": 0.0
	}
	timeline.adicionar_combatente(combatant)
	var ev1: Array[Dictionary] = timeline.avancar_tempo(1.0)
	var c: Dictionary = timeline.obter_combatente("lucas")
	assert(c["posicao_tempo"] == 50.0, "Position should be 50.0 after 1s at 50 speed")
	assert(ev1.is_empty(), "No events should trigger before 100.0")
	var ev2: Array[Dictionary] = timeline.avancar_tempo(1.0)
	c = timeline.obter_combatente("lucas")
	assert(c["posicao_tempo"] == 100.0, "Position should reach 100.0")
	assert(c["fase_turno"] == BattleTimeline.FaseTurno.DECISAO, "Combatant should enter DECISAO")
	assert(ev2.size() == 1, "One event should trigger")
	assert(ev2[0]["evento"] == "DECISAO", "Event must be DECISAO")
	return true


static func test_battle_stability_ruptura() -> bool:
	var bm: BattleManager = BattleManager.new()
	var atacante: Dictionary = {"id": "lucas", "name": "Lucas Reis", "irritado": false}
	var defensor: Dictionary = {
		"id": "inimigo_1",
		"name": "Soldado Corrompido",
		"max_hp": 100,
		"current_hp": 100,
		"estabilidade_max": 50,
		"estabilidade_atual": 50,
		"fase_turno": BattleTimeline.FaseTurno.CONJURACAO,
		"posicao_tempo": 100.0,
		"progresso_conjuracao": 40.0,
		"irritado": false
	}
	var res: Dictionary = bm.aplicar_golpe(atacante, defensor, 20, 50)
	assert(res["ruptura"] == true, "Strike must trigger RUPTURA when stability reaches 0")
	assert(res["irritado"] == false, "Irritado must be false on RUPTURA")
	assert(defensor["fase_turno"] == BattleTimeline.FaseTurno.ESPERA, "Casting must be cancelled back to ESPERA")
	assert(defensor["posicao_tempo"] == 0.0, "posicao_tempo must reset to 0.0")
	assert(defensor["estabilidade_atual"] == 0, "estabilidade_atual must be 0")
	bm.free()
	return true


static func test_battle_stability_irritacao() -> bool:
	var bm: BattleManager = BattleManager.new()
	var atacante: Dictionary = {"id": "lucas", "name": "Lucas Reis", "irritado": false}
	var defensor: Dictionary = {
		"id": "inimigo_1", "name": "Soldado Corrompido", "max_hp": 100, "current_hp": 100,
		"estabilidade_max": 50, "estabilidade_atual": 50,
		"fase_turno": BattleTimeline.FaseTurno.CONJURACAO, "posicao_tempo": 100.0, "progresso_conjuracao": 30.0,
		"irritado": false
	}
	var res: Dictionary = bm.aplicar_golpe(atacante, defensor, 15, 20)
	assert(res["ruptura"] == false, "Strike must NOT trigger RUPTURA if stability remains")
	assert(res["irritado"] == true, "Strike must trigger IRRITACAO when stability > 0")
	assert(defensor["irritado"] == true, "Defensor must be flagged irritado")
	assert(defensor["estabilidade_atual"] == 30, "Stability must decrease by 20 to 30")
	var target: Dictionary = {"max_hp": 100, "current_hp": 100}
	var res_irritado: Dictionary = bm.aplicar_golpe(defensor, target, 20, 0)
	assert(res_irritado["dano"] == 25, "Irritated combatant must deal +25% damage")
	bm.free()
	return true


static func test_battle_basic_attack_affinity_and_stability() -> bool:
	var bm: BattleManager = BattleManager.new()
	var lucas: CharacterData = CharacterData.create_default_lucas()
	var enemy: Dictionary = {
		"id": "inimigo_1",
		"name": "Soldado Corrompido",
		"max_hp": 80,
		"current_hp": 80,
		"estabilidade_max": 60,
		"estabilidade_atual": 60
	}
	var res: Dictionary = bm.executar_ataque_basico(lucas, enemy)
	assert(res["dano_efetivo"] == 22, "Lucas with Forge Hammer must deal 22 effective damage (14 + 6*1.3)")
	assert(res["dano"] == 22, "Damage dealt must match effective damage")
	assert(enemy["current_hp"] == 58, "Enemy HP must decrease from 80 to 58")
	assert(res["impacto_estabilidade"] == 35, "Hammer affinity must inflict 35 stability damage")
	assert(enemy["estabilidade_atual"] == 25, "Enemy stability must decrease from 60 to 25")
	bm.free()
	return true


static func test_battle_defender_command() -> bool:
	var bm: BattleManager = BattleManager.new()
	var combatente: Dictionary = {
		"id": "defensor",
		"name": "Guardião",
		"max_hp": 100,
		"current_hp": 100,
		"posicao_tempo": 10.0,
		"defendendo": false
	}
	var _def_res: Dictionary = bm.executar_defesa(combatente)
	assert(combatente["defendendo"] == true, "Combatant must have defendendo flag true")
	assert(combatente["posicao_tempo"] == 40.0, "Timeline position must advance by +30 points")
	var atacante: Dictionary = {"id": "atk", "name": "Atacante"}
	var golpe: Dictionary = bm.aplicar_golpe(atacante, combatente, 40, 0)
	assert(golpe["dano"] == 20, "Damage must be reduced by 50% (40 -> 20)")
	assert(combatente["current_hp"] == 80, "HP must reflect 50% reduced damage")
	bm.free()
	return true


static func test_battle_item_consumption() -> bool:
	var bm: BattleManager = BattleManager.new()
	var lucas: CharacterData = CharacterData.create_default_lucas()
	lucas.current_hp = 50
	var pocao: ItemData = ItemData.create_potion()
	var res: Dictionary = bm.executar_item(lucas, pocao, lucas)
	assert(res["sucesso"] == true, "Item execution must succeed")
	assert(res["cura"] == 50, "Potion must restore 50 HP")
	assert(lucas.current_hp == 100, "Lucas HP must be restored to 100")
	bm.free()
	return true
