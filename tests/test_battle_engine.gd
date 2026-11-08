class_name TestBattleEngine
extends RefCounted

## Testes automatizados para validação do BattleManager, ações de combate e HUD da cena.

const PartyManagerScript: GDScript = preload("res://scripts/core/party_manager.gd")
const EnemyDataScript: GDScript = preload("res://scripts/core/enemy_data.gd")


static func run_tests(tree: SceneTree = null) -> bool:
	return _run_group_a(tree) and _run_group_b() and _run_group_c()


static func _run_group_a(tree: SceneTree) -> bool:
	var p: bool = test_battle_initialization_with_lucas() and test_battle_state_machine_flow()
	p = p and test_battle_victory_condition() and test_battle_scene_instantiation(tree)
	p = p and test_battle_timeline_progression() and test_battle_stability_ruptura()
	p = p and test_battle_stability_irritacao() and test_battle_basic_attack_affinity_and_stability()
	p = p and test_battle_defender_command() and test_battle_defender_resets_timeline()
	p = p and test_battle_item_consumption() and test_battle_realtime_process_loop()
	p = p and test_party_manager_starts_with_lucas_and_davi() and test_davi_weapon_affinities()
	p = p and test_battle_initialization_with_davi_and_general_cassian()
	p = p and test_lucas_and_davi_independent_turns_progression()
	p = p and test_general_cassian_resource_loading()
	return p


static func _run_group_b() -> bool:
	var p: bool = test_zero_enemy_hp_triggers_victory_and_scene_manager_exit()
	p = p and test_breaking_enemy_stability_applies_rupture_stun_penalty()
	p = p and test_battle_hud_portraits_hook()
	p = p and test_cassian_stability_withstands_multiple_hits()
	p = p and test_boss_action_opportunity_and_grace_period()
	p = p and test_parallel_timeline_and_action_queue_ordering()
	p = p and test_distinct_melee_vs_ranged_attack_paths()
	p = p and test_boss_turn_frequency_in_multiparty_encounter()
	p = p and test_simultaneous_ready_actions_execute_sequentially()
	p = p and test_executando_acao_locks_timeline_tick()
	p = p and test_selecting_skill_deducts_mp()
	return p


static func _run_group_c() -> bool:
	var p: bool = test_casting_phase_advances_and_triggers_at_100()
	p = p and test_damage_taken_during_conjuracao_interrupts_spell()
	p = p and test_timeline_badge_position_mapping()
	p = p and test_eiyuden_ui_dock_and_banner_instantiation()
	p = p and test_village_arena_layers_and_z_indexing()
	p = p and test_normalized_coordinate_engine_and_conversions()
	p = p and test_tactical_formations_clear_of_anvil_and_action_menu()
	p = p and test_flat_plaza_party_and_enemy_positioning()
	p = p and test_tactical_encirclement_modes()
	p = p and test_melee_dash_straight_horizontal_and_return()
	p = p and test_attack_aligns_to_target_line_before_advancing()
	p = p and test_combatant_attack_scale_compensation_and_idle_restoration()
	p = p and test_general_cassian_combat_frames_and_attack_selection()
	return p


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
	var battle_scene: Node2D = scene_res.instantiate() as Node2D
	if tree != null and tree.root != null:
		tree.root.add_child(battle_scene)
	var party_cont: Node2D = battle_scene.get_node_or_null("CanvasLayer/UI/Arena/PartyContainer") as Node2D
	var enemy_cont: Node2D = battle_scene.get_node_or_null("CanvasLayer/UI/Arena/EnemyContainer") as Node2D
	var banner: Control = battle_scene.get_node_or_null("CanvasLayer/UI/VictoryBanner") as Control
	assert(party_cont != null and enemy_cont != null, "Containers must exist in arena")
	assert(banner != null, "VictoryBanner must exist in battle scene UI")
	assert(is_equal_approx(enemy_cont.position.x, 420.0), "EnemyContainer must be at X=420 (centered arena)")
	assert(is_equal_approx(party_cont.position.x, 940.0), "PartyContainer must be at X=940")
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
		"posicao_tempo": 100.0,
		"fase_turno": BattleTimeline.FaseTurno.DECISAO,
		"defendendo": false
	}
	var _def_res: Dictionary = bm.executar_defesa(combatente)
	assert(combatente["defendendo"] == true, "Combatant must have defendendo flag true")
	assert(combatente["posicao_tempo"] == 30.0, "Timeline position must restart at 30.0")
	var atacante: Dictionary = {"id": "atk", "name": "Atacante"}
	var golpe: Dictionary = bm.aplicar_golpe(atacante, combatente, 40, 0)
	assert(golpe["dano"] == 20, "Damage must be reduced by 50% (40 -> 20)")
	assert(combatente["current_hp"] == 80, "HP must reflect 50% reduced damage")
	bm.free()
	return true


static func test_battle_defender_resets_timeline() -> bool:
	var bm: BattleManager = BattleManager.new()
	var lucas: CharacterData = CharacterData.create_default_lucas()
	var enemy: Dictionary = {"name": "Inimigo", "max_hp": 50, "current_hp": 50}
	bm.initialize_battle([lucas], [enemy])
	bm.change_state(BattleManager.BattleState.SELECIONANDO_ACAO)
	bm.change_state(BattleManager.BattleState.EXECUTANDO_ACAO)
	var c_comb: Dictionary = bm.timeline.obter_combatente(lucas.character_id)
	c_comb["posicao_tempo"] = 100.0
	c_comb["fase_turno"] = BattleTimeline.FaseTurno.DECISAO
	bm.executar_defesa(lucas)
	assert(c_comb["posicao_tempo"] == 30.0, "posicao_tempo must reset to 30.0 on defend")
	assert(c_comb["fase_turno"] == BattleTimeline.FaseTurno.ESPERA, "fase_turno must reset to ESPERA on defend")
	bm.concluir_acao()
	assert(bm.current_state == BattleManager.BattleState.AGUARDANDO_TURNO, "State must return to AGUARDANDO_TURNO")
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


static func test_battle_realtime_process_loop() -> bool:
	var bm: BattleManager = BattleManager.new()
	var lucas: CharacterData = CharacterData.create_default_lucas()
	var enemy: Dictionary = {"name": "Soldado", "max_hp": 80, "current_hp": 80, "velocidade": 10.0}
	bm.initialize_battle([lucas], [enemy])
	assert(bm.current_state == BattleManager.BattleState.AGUARDANDO_TURNO, "Initial state must be AGUARDANDO_TURNO")
	
	bm._process(15.0)
	
	assert(bm.current_state == BattleManager.BattleState.SELECIONANDO_ACAO, "State must advance to SELECIONANDO_ACAO")
	var c: Dictionary = bm.timeline.obter_combatente(lucas.character_id)
	assert(c["fase_turno"] == BattleTimeline.FaseTurno.DECISAO, "Lucas must reach DECISAO")
	bm.free()
	return true


static func test_party_manager_starts_with_lucas_and_davi() -> bool:
	var pm: Node = PartyManagerScript.new()
	pm.call("reset_to_defaults")
	var active_members: Array = pm.call("get_active_party") as Array
	assert(active_members.size() == 2, "Active party must contain 2 members")
	assert(active_members[0].name == "Lucas Reis", "First member must be Lucas Reis")
	assert(active_members[1].name == "Davi Reis", "Second member must be Davi Reis")
	assert(active_members[1].max_hp == 90, "Davi max HP must be 90")
	assert(active_members[1].defense == 16, "Davi defense must be 16")
	pm.free()
	return true


static func test_davi_weapon_affinities() -> bool:
	var davi: CharacterData = CharacterData.create_default_davi()
	assert(davi != null, "Davi must instantiate")
	var shield_aff: float = davi.get_weapon_affinity(EquipmentData.WeaponType.SHIELD)
	assert(is_equal_approx(shield_aff, 1.3), "Davi SHIELD affinity must be 1.3")
	var cat_aff: float = davi.get_weapon_affinity(EquipmentData.WeaponType.CATALYST)
	assert(is_equal_approx(cat_aff, 1.3), "Davi CATALYST affinity must be 1.3")
	var sword_aff: float = davi.get_weapon_affinity(EquipmentData.WeaponType.SWORD)
	assert(is_equal_approx(sword_aff, 0.5), "Davi SWORD affinity must be 0.5")
	var hammer_aff: float = davi.get_weapon_affinity(EquipmentData.WeaponType.HAMMER)
	assert(is_equal_approx(hammer_aff, 1.0), "Davi HAMMER affinity must be 1.0")
	return true


static func test_battle_initialization_with_davi_and_general_cassian() -> bool:
	var bm: BattleManager = BattleManager.new()
	var lucas: CharacterData = CharacterData.create_default_lucas()
	var davi: CharacterData = CharacterData.create_default_davi()
	var cassian: Resource = EnemyDataScript.create_general_cassian()
	bm.initialize_battle([lucas, davi], [cassian])
	assert(bm.party_members.size() == 2, "Battle party must contain 2 members")
	assert(bm.enemies.size() == 1, "Enemies must contain 1 enemy")
	assert(bm.enemies[0]["name"] == "General Cassian", "Enemy name must be General Cassian")
	assert(int(bm.enemies[0]["max_hp"]) == 240, "General Cassian max HP must be 240")
	assert(int(bm.enemies[0]["estabilidade_max"]) == 120, "General Cassian max stability must be 120")
	bm.free()
	return true


static func test_lucas_and_davi_independent_turns_progression() -> bool:
	var bm: BattleManager = BattleManager.new()
	var lucas: CharacterData = CharacterData.create_default_lucas()
	var davi: CharacterData = CharacterData.create_default_davi()
	var cassian: Resource = EnemyDataScript.create_general_cassian()
	bm.initialize_battle([lucas, davi], [cassian])
	bm._process(15.0)
	assert(bm.current_state == BattleManager.BattleState.SELECIONANDO_ACAO, "Must enter SELECIONANDO_ACAO")
	assert(bm.get_active_actor().character_id == "lucas", "Lucas must act first")
	bm.executar_defesa(lucas)
	bm.concluir_acao()
	assert(bm.current_state == BattleManager.BattleState.AGUARDANDO_TURNO, "State returns to AGUARDANDO_TURNO")
	bm._process(4.0)
	bm.concluir_acao()
	assert(bm.current_state == BattleManager.BattleState.SELECIONANDO_ACAO, "Davi must reach SELECIONANDO_ACAO")
	assert(bm.get_active_actor().character_id == "davi", "Davi must be active actor")
	bm.executar_ataque_basico(davi, bm.enemies[0])
	bm.concluir_acao()
	bm.free()
	return true


static func test_general_cassian_resource_loading() -> bool:
	var cassian_res: Resource = load("res://resources/enemies/general_cassian.tres")
	assert(cassian_res != null, "general_cassian.tres must exist and load")
	assert(cassian_res.get("name") == "General Cassian", "Name must match General Cassian")
	assert(int(cassian_res.get("max_hp")) == 240, "HP must be 240")
	assert(int(cassian_res.get("estabilidade_max")) == 120, "Estabilidade max must be 120")
	assert(int(cassian_res.get("strength")) == 20, "Força must be 20")
	assert(int(cassian_res.get("defense")) == 14, "Defesa must be 14")
	assert(cassian_res.get("sprite_frames") != null, "SpriteFrames must be attached")
	return true


static func test_zero_enemy_hp_triggers_victory_and_scene_manager_exit() -> bool:
	var bm: BattleManager = BattleManager.new()
	var lucas: CharacterData = CharacterData.create_default_lucas()
	var enemy: Dictionary = {"name": "Inimigo", "max_hp": 30, "current_hp": 30}
	bm.initialize_battle([lucas], [enemy])
	bm.change_state(BattleManager.BattleState.SELECIONANDO_ACAO)
	var finished_box: Array[bool] = [false]
	var on_finished: Callable = func(victory: bool) -> void:
		if victory:
			finished_box[0] = true
	bm.battle_finished.connect(on_finished)
	bm.apply_damage_to_enemy(0, 30)
	assert(bm.current_state == BattleManager.BattleState.VITORIA, "State must be VITORIA")
	assert(finished_box[0] == true, "battle_finished signal must be emitted with victory = true")
	bm.free()
	return true


static func test_breaking_enemy_stability_applies_rupture_stun_penalty() -> bool:
	var bm: BattleManager = BattleManager.new()
	var atacante: Dictionary = {"id": "lucas", "name": "Lucas"}
	var defensor: Dictionary = {
		"id": "cassian", "name": "General Cassian", "max_hp": 240, "current_hp": 240,
		"estabilidade_max": 120, "estabilidade_atual": 40, "posicao_tempo": 90.0,
		"progresso_conjuracao": 30.0, "fase_turno": BattleTimeline.FaseTurno.CONJURACAO,
		"irritado": true
	}
	var rupture_box: Array[bool] = [false]
	bm.rupture_triggered.connect(func(target_id: String) -> void:
		if target_id == "cassian":
			rupture_box[0] = true
	)
	var res: Dictionary = bm.aplicar_golpe(atacante, defensor, 30, 45)
	assert(res["ruptura"] == true, "Rupture flag must be true")
	assert(rupture_box[0] == true, "rupture_triggered signal must be emitted")
	assert(defensor["fase_turno"] == BattleTimeline.FaseTurno.ESPERA, "Phase must reset to ESPERA")
	assert(defensor["posicao_tempo"] == 0.0, "posicao_tempo must reset to 0.0")
	assert(defensor["irritado"] == false, "Irritado must be cleared on rupture")
	bm.free()
	return true


static func test_battle_hud_portraits_hook() -> bool:
	var lucas: CharacterData = CharacterData.create_default_lucas()
	var davi: CharacterData = CharacterData.create_default_davi()
	assert(lucas.portrait != null, "Lucas portrait must not be null")
	assert(davi.portrait != null, "Davi portrait must not be null")
	var scene_res: PackedScene = load("res://scenes/battle/battle_scene.tscn")
	var scene: BattleScene = scene_res.instantiate() as BattleScene
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree != null and tree.root != null:
		tree.root.add_child(scene)
	var p1: TextureRect = scene.get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel/Margin/HBox/PortraitRect") as TextureRect
	var p2: TextureRect = scene.get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel2/Margin/HBox/PortraitRect") as TextureRect
	assert(p1 != null, "AllyPanel PortraitRect must exist")
	assert(p2 != null, "AllyPanel2 PortraitRect must exist")
	if tree != null and tree.root != null:
		tree.root.remove_child(scene)
	scene.free()
	return true


static func test_cassian_stability_withstands_multiple_hits() -> bool:
	var bm: BattleManager = BattleManager.new()
	var lucas: CharacterData = CharacterData.create_default_lucas()
	var cassian_res: Resource = EnemyDataScript.create_general_cassian()
	bm.initialize_battle([lucas], [cassian_res])
	var cassian: Dictionary = bm.enemies[0]
	var res1: Dictionary = bm.executar_ataque_basico(lucas, cassian)
	bm.concluir_acao()
	assert(res1["ruptura"] == false, "Cassian must NOT trigger Ruptura on 1st hit")
	assert(cassian["estabilidade_atual"] == 96, "Stability must reduce by 24 (120 -> 96)")
	var res2: Dictionary = bm.executar_ataque_basico(lucas, cassian)
	bm.concluir_acao()
	assert(res2["ruptura"] == false, "Cassian must NOT trigger Ruptura on 2nd hit")
	assert(cassian["estabilidade_atual"] == 72, "Stability must reduce by 24 (96 -> 72)")
	bm.free()
	return true


static func test_boss_action_opportunity_and_grace_period() -> bool:
	var bm: BattleManager = BattleManager.new()
	var lucas: CharacterData = CharacterData.create_default_lucas()
	var cassian_res: Resource = EnemyDataScript.create_general_cassian()
	bm.initialize_battle([lucas], [cassian_res])
	var cassian: Dictionary = bm.enemies[0]
	bm.aplicar_golpe({"id": "lucas"}, cassian, 20, 120)
	assert(cassian["estabilidade_atual"] == 0, "Stability reached 0 on rupture")
	assert(cassian["em_recuperacao_ruptura"] == true, "Must flag recovery needed")
	var t_c: Dictionary = bm.timeline.obter_combatente(cassian["id"])
	t_c["posicao_tempo"] = 100.0
	t_c["fase_turno"] = BattleTimeline.FaseTurno.DECISAO
	bm._processar_evento_decisao(cassian["id"], t_c)
	assert(cassian["estabilidade_atual"] == 120, "Stability restored to 120 after rupture recovery")
	assert(cassian["imunidade_interrupcao"] == true, "Must have interrupt immunity")
	var golpe_imune: Dictionary = bm.aplicar_golpe({"id": "lucas"}, cassian, 20, 50)
	assert(golpe_imune["ruptura"] == false, "Must not trigger rupture during immunity")
	bm.free()
	return true


static func test_parallel_timeline_and_action_queue_ordering() -> bool:
	var bm: BattleManager = BattleManager.new()
	var lucas: CharacterData = CharacterData.create_default_lucas()
	var davi: CharacterData = CharacterData.create_default_davi()
	var cassian: Resource = EnemyDataScript.create_general_cassian()
	bm.initialize_battle([lucas, davi], [cassian])
	bm._process(15.0)
	assert(bm.current_state == BattleManager.BattleState.SELECIONANDO_ACAO, "Lucas at 100 enters SELECIONANDO_ACAO")
	bm._process(5.0)
	var t_c: Dictionary = bm.timeline.obter_combatente("general_cassian")
	var t_d: Dictionary = bm.timeline.obter_combatente("davi")
	assert(t_c["posicao_tempo"] >= 100.0, "Cassian timeline must progress in parallel to 100")
	assert(t_d["posicao_tempo"] >= 100.0, "Davi timeline must progress in parallel to 100")
	assert(bm.fila_de_acoes.has("general_cassian"), "Cassian must be queued in fila_de_acoes")
	bm.free()
	return true


static func test_distinct_melee_vs_ranged_attack_paths() -> bool:
	var scene_res: PackedScene = load("res://scenes/battle/battle_scene.tscn")
	var scene: BattleScene = scene_res.instantiate() as BattleScene
	assert(scene != null, "BattleScene must instantiate")
	assert(scene.has_method("_executar_ataque_melee_lucas"), "Must implement Lucas melee attack path")
	assert(scene.has_method("_executar_ataque_aura_davi"), "Must implement Davi aura/cast attack path")
	assert(scene.has_method("_executar_ataque_melee_boss"), "Must implement Boss melee attack path")
	assert(scene.has_method("_criar_projetil_aura"), "Must implement projectile tween creator")
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree != null and tree.root != null:
		tree.root.add_child(scene)
	var cassian_port: TextureRect = scene.get_node_or_null("CanvasLayer/UI/CombatantHUD/EnemyPanel/Margin/HBox/PortraitRect") as TextureRect
	assert(cassian_port != null, "EnemyPanel PortraitRect must exist for Cassian")
	if tree != null and tree.root != null:
		tree.root.remove_child(scene)
	scene.free()
	return true


static func test_boss_turn_frequency_in_multiparty_encounter() -> bool:
	var bm: BattleManager = BattleManager.new()
	var lucas: CharacterData = CharacterData.create_default_lucas()
	var davi: CharacterData = CharacterData.create_default_davi()
	var cassian: Resource = EnemyDataScript.create_general_cassian()
	bm.initialize_battle([lucas, davi], [cassian])
	var order: Array[String] = []
	bm.action_executed.connect(func(atk: String, _def: String, _tipo: String) -> void:
		order.append(atk)
	)
	bm._process(15.0)
	bm.executar_ataque_basico(lucas, bm.enemies[0])
	bm.concluir_acao()
	bm._process(4.0)
	assert(order.size() >= 2, "Both Lucas and Cassian must have executed actions")
	assert(order[0] == "lucas", "Lucas acts 1st")
	assert(order[1] == "general_cassian", "Cassian acts 2nd between Lucas and Davi")
	bm.concluir_acao()
	assert(bm.current_state == BattleManager.BattleState.SELECIONANDO_ACAO, "Davi ready for action")
	assert(bm.get_active_actor().character_id == "davi", "Davi acts 3rd")
	bm.free()
	return true


static func test_simultaneous_ready_actions_execute_sequentially() -> bool:
	var bm: BattleManager = BattleManager.new()
	var lucas: CharacterData = CharacterData.create_default_lucas()
	var e1: Dictionary = {"id": "e_a", "name": "A", "max_hp": 80, "current_hp": 80, "agility": 20.0}
	var e2: Dictionary = {"id": "e_b", "name": "B", "max_hp": 80, "current_hp": 80, "agility": 20.0}
	bm.initialize_battle([lucas], [e1, e2])
	bm.timeline.obter_combatente("e_a")["posicao_tempo"] = 100.0
	bm.timeline.obter_combatente("e_a")["fase_turno"] = BattleTimeline.FaseTurno.DECISAO
	bm.timeline.obter_combatente("e_b")["posicao_tempo"] = 100.0
	bm.timeline.obter_combatente("e_b")["fase_turno"] = BattleTimeline.FaseTurno.DECISAO
	var order: Array[String] = []
	bm.action_executed.connect(func(atk: String, _tgt: String, _tipo: String) -> void: order.append(atk))
	bm._verificar_proximo_turno()
	assert(order.size() == 1 and order[0] == "e_a", "First enemy acts first")
	assert(bm.executando_acao and bm.fila_de_acoes.has("e_b"), "Mutex locks & second enemy waits")
	bm.concluir_acao()
	assert(order.size() == 2 and order[1] == "e_b", "Second enemy acts sequentially")
	bm.concluir_acao()
	bm.free()
	return true


static func test_executando_acao_locks_timeline_tick() -> bool:
	var bm: BattleManager = BattleManager.new()
	var lucas: CharacterData = CharacterData.create_default_lucas()
	bm.initialize_battle([lucas], [{"id": "e1", "name": "Inimigo", "max_hp": 80, "current_hp": 80}])
	var c: Dictionary = bm.timeline.obter_combatente(lucas.character_id)
	bm.executar_defesa(lucas)
	assert(bm.executando_acao and float(c.get("posicao_tempo", 0.0)) == 30.0, "Defense locks action at 30.0")
	bm._process(5.0)
	assert(float(c.get("posicao_tempo", 0.0)) == 30.0, "Timeline locked during action")
	var signaled: Array[bool] = [false]
	bm.acao_concluida.connect(func() -> void: signaled[0] = true)
	bm.concluir_acao()
	assert(signaled[0] and not bm.executando_acao, "acao_concluida emitted and mutex unlocked")
	bm._process(1.0)
	assert(float(c.get("posicao_tempo", 0.0)) > 30.0, "Timeline advances once unlocked")
	bm.free()
	return true


static func test_selecting_skill_deducts_mp() -> bool:
	var bm: BattleManager = BattleManager.new()
	var lucas: CharacterData = CharacterData.create_default_lucas()
	var enemy: Dictionary = {"id": "e1", "name": "Inimigo", "max_hp": 80, "current_hp": 80, "estabilidade_max": 100, "estabilidade_atual": 100}
	bm.initialize_battle([lucas], [enemy])
	var golpe: SkillData = SkillData.create_golpe_sismico()
	assert(lucas.pm_atual == 45, "Lucas must start with 45 PM")
	var res: Dictionary = bm.executar_habilidade(lucas, golpe, bm.enemies[0])
	assert(res["sucesso"] == true, "Instant skill execution must succeed")
	assert(lucas.pm_atual == 37, "Lucas PM must be deducted by 8 (45 -> 37)")
	assert(int(bm.enemies[0]["estabilidade_atual"]) == 55, "Golpe Sismico must inflict 45 stability damage (100 -> 55)")
	bm.concluir_acao()
	lucas.pm_atual = 5
	var res_insuficiente: Dictionary = bm.executar_habilidade(lucas, golpe, bm.enemies[0])
	assert(res_insuficiente["sucesso"] == false and res_insuficiente["motivo"] == "pm_insuficiente", "Cannot cast without PM")
	bm.free()
	return true


static func test_casting_phase_advances_and_triggers_at_100() -> bool:
	var bm: BattleManager = BattleManager.new()
	bm.timeline_speed_scale = 1.0
	var davi: CharacterData = CharacterData.create_default_davi()
	var enemy: Dictionary = {"id": "e1", "name": "Inimigo", "max_hp": 100, "current_hp": 100, "estabilidade_max": 100, "estabilidade_atual": 100}
	bm.initialize_battle([davi], [enemy])
	var lanca: SkillData = SkillData.create_lanca_de_eter()
	var res: Dictionary = bm.executar_habilidade(davi, lanca, bm.enemies[0])
	assert(res["sucesso"] == true and res["conjurando"] == true, "Must enter conjuracao phase")
	assert(davi.pm_atual == 48, "Davi PM must be deducted immediately (60 -> 48)")
	var t_c: Dictionary = bm.timeline.obter_combatente("davi")
	assert(int(t_c["fase_turno"]) == BattleTimeline.FaseTurno.CONJURACAO, "Timeline phase must be CONJURACAO")
	bm._process(1.0)
	assert(is_equal_approx(float(t_c["progresso_conjuracao"]), 50.0), "Casting progress must reach 50% in 1.0s")
	bm._process(1.0)
	assert(int(bm.enemies[0]["current_hp"]) < 100, "Enemy must take damage when cast reaches 100%")
	assert(int(t_c["fase_turno"]) == BattleTimeline.FaseTurno.ESPERA, "Phase must reset to ESPERA after spell")
	bm.free()
	return true


static func test_damage_taken_during_conjuracao_interrupts_spell() -> bool:
	var bm: BattleManager = BattleManager.new()
	var davi: CharacterData = CharacterData.create_default_davi()
	var enemy: Dictionary = {"id": "boss", "name": "General Cassian", "max_hp": 240, "current_hp": 240, "strength": 20}
	bm.initialize_battle([davi], [enemy])
	var lanca: SkillData = SkillData.create_lanca_de_eter()
	bm.executar_habilidade(davi, lanca, bm.enemies[0])
	var interrupted: Array[bool] = [false]
	bm.spell_interrupted.connect(func(c_id: String) -> void: if c_id == "davi": interrupted[0] = true)
	var t_davi: Dictionary = bm.timeline.obter_combatente("davi")
	assert(int(t_davi["fase_turno"]) == BattleTimeline.FaseTurno.CONJURACAO, "Davi must be in CONJURACAO")
	bm._executar_ataque_inimigo("boss")
	assert(interrupted[0] == true, "spell_interrupted must be emitted when hit during cast")
	assert(int(t_davi["fase_turno"]) == BattleTimeline.FaseTurno.ESPERA, "Phase must reset to ESPERA on interrupt")
	assert(float(t_davi["progresso_conjuracao"]) == 0.0, "Casting progress must reset to 0.0")
	bm.free()
	return true


static func test_timeline_badge_position_mapping() -> bool:
	assert(is_equal_approx(BattleScene.obter_posicao_badge_timeline(0.0, 400.0), 0.0), "0% progress is at 0.0")
	assert(is_equal_approx(BattleScene.obter_posicao_badge_timeline(50.0, 400.0), 200.0), "50% progress is at 200.0")
	assert(is_equal_approx(BattleScene.obter_posicao_badge_timeline(100.0, 400.0), 400.0), "100% progress is at 400.0")
	assert(is_equal_approx(BattleScene.obter_posicao_badge_timeline(-10.0, 400.0), 0.0), "Clamp lower bound")
	assert(is_equal_approx(BattleScene.obter_posicao_badge_timeline(120.0, 400.0), 400.0), "Clamp upper bound")
	return true


static func test_eiyuden_ui_dock_and_banner_instantiation() -> bool:
	var scene_res: PackedScene = load("res://scenes/battle/battle_scene.tscn")
	var scene: BattleScene = scene_res.instantiate() as BattleScene
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree != null and tree.root != null:
		tree.root.add_child(scene)
	var tracker: Control = scene.get_node_or_null("CanvasLayer/UI/TimelineTracker") as Control
	var track_area: Control = scene.get_node_or_null("CanvasLayer/UI/TimelineTracker/Margin/HBox/TrackArea") as Control
	var enemy_hp_bar: ProgressBar = scene.get_node_or_null("CanvasLayer/UI/CombatantHUD/EnemyPanel/Margin/HBox/VBox/HPBar") as ProgressBar
	var ally_mp_bar: ProgressBar = scene.get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel/Margin/HBox/VBox/MPBar") as ProgressBar
	assert(tracker != null and track_area != null, "TimelineTracker and TrackArea must exist")
	assert(enemy_hp_bar != null, "EnemyPanel HPBar must exist")
	assert(ally_mp_bar != null, "AllyPanel MPBar must exist")
	if tree != null and tree.root != null:
		tree.root.remove_child(scene)
	scene.free()
	return true


static func test_village_arena_layers_and_z_indexing() -> bool:
	var scene_res: PackedScene = load("res://scenes/battle/battle_scene.tscn")
	var scene: BattleScene = scene_res.instantiate() as BattleScene
	var bg: TextureRect = scene.get_node_or_null("CanvasLayer/UI/ArenaBackground") as TextureRect
	var fg: TextureRect = scene.get_node_or_null("CanvasLayer/UI/ArenaForeground") as TextureRect
	var birds: Node2D = scene.get_node_or_null("CanvasLayer/UI/DistantBirds") as Node2D
	var clouds: Node2D = scene.get_node_or_null("CanvasLayer/UI/SkyClouds") as Node2D
	var ally_panel: PanelContainer = scene.get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel") as PanelContainer
	var action_panel: PanelContainer = scene.get_node_or_null("CanvasLayer/UI/ActionCommandPanel") as PanelContainer
	assert(bg != null and fg != null, "ArenaBackground and ArenaForeground must exist")
	assert(bg.z_index == -10, "Background z_index must be -10")
	assert(fg.z_index == 10, "Foreground z_index must be 10")
	assert(birds != null and birds.z_index == -9, "DistantBirds sky ambiance must exist at z=-9")
	assert(clouds != null and clouds.z_index == -9, "SkyClouds drifting ambiance must exist at z=-9")
	clouds.inicializar()
	assert(clouds.get_child_count() > 0, "SkyClouds must spawn Sprite2D children")
	var first_cloud: Sprite2D = clouds.get_child(0) as Sprite2D
	assert(first_cloud != null and first_cloud.texture != null, "SkyClouds sprite must have valid texture")
	assert(ally_panel != null and ally_panel.offset_top < 400.0, "AllyPanel must be placed in the upper right dock (Y < 400)")
	assert(action_panel != null and action_panel.offset_top < 800.0, "ActionCommandPanel must be raised comfortably above screen edge (Y < 800)")
	assert(not BattleScene.obter_caminho_background().is_empty(), "Background path must resolve")
	assert(not BattleScene.obter_caminho_foreground().is_empty(), "Foreground path must resolve")
	scene.free()
	return true


static func test_normalized_coordinate_engine_and_conversions() -> bool:
	var p_1080: Vector2 = BattleSceneLayout.converter_para_tela(Vector2(0.5, 0.5), Vector2(1920.0, 1080.0))
	var p_720: Vector2 = BattleSceneLayout.converter_para_tela(Vector2(0.5, 0.5), Vector2(1280.0, 720.0))
	assert(p_1080 == Vector2(960.0, 540.0), "Normalized conversion 1920x1080")
	assert(p_720 == Vector2(640.0, 360.0), "Normalized conversion 1280x720")
	var layout: BattleSceneLayout = BattleSceneLayout.new()
	var pos_hero1: Vector2 = layout.obter_posicao_aliado(0, "LINHA_2X2", "PADRAO", Vector2(1920.0, 1080.0))
	var pos_enemy1: Vector2 = layout.obter_posicao_inimigo(0, 1, false, "PADRAO", Vector2(1920.0, 1080.0))
	var dist: float = pos_hero1.distance_to(pos_enemy1)
	assert(dist >= 500.0, "Runway distance between Enemy 1 and Hero 1 must be >= 500px on 1920x1080")
	return true


static func test_tactical_formations_clear_of_anvil_and_action_menu() -> bool:
	var layout: BattleSceneLayout = BattleSceneLayout.new()
	var vp: Vector2 = Vector2(1920.0, 1080.0)
	var formacoes: Array = ["LINHA_2X2", "LOSANGO", "VANGUARDA_3X1", "RETAGUARDA_1X3", "MEIA_LUA"]
	for f: String in formacoes:
		for slot: int in range(4):
			var pos: Vector2 = layout.obter_posicao_aliado(slot, f, "PADRAO", vp)
			assert(pos.x <= 0.75 * vp.x, "Slot %d in %s must stay clear of the anvil (X <= 0.75*W)" % [slot, f])
			assert(pos.y < 750.0, "Slot %d in %s must stay above the action menu (Y < 750)" % [slot, f])
			assert(pos.y >= 0.50 * vp.y, "Slot %d in %s must stay on the plaza area" % [slot, f])
	return true


static func test_flat_plaza_party_and_enemy_positioning() -> bool:
	var scene_res: PackedScene = load("res://scenes/battle/battle_scene.tscn")
	var scene: BattleScene = scene_res.instantiate() as BattleScene
	var enemy_cont: Node2D = scene.get_node_or_null("CanvasLayer/UI/Arena/EnemyContainer") as Node2D
	var party_cont: Node2D = scene.get_node_or_null("CanvasLayer/UI/Arena/PartyContainer") as Node2D
	assert(enemy_cont.position == Vector2(420.0, 470.0), "EnemyContainer must be at (420, 470)")
	assert(party_cont.position == Vector2(940.0, 510.0), "PartyContainer must be at (940, 510)")
	var p0: Vector2 = party_cont.position + scene._obter_posicao_base_aliado(0)
	var p1: Vector2 = party_cont.position + scene._obter_posicao_base_aliado(1)
	var e0: Vector2 = enemy_cont.position + scene._obter_posicao_base_inimigo(0, 1, false)
	assert(p0.x > 1000.0 and p0.y >= 540.0 and p0.y <= 700.0, "Hero Slot 1 in LINHA_2X2 raised to plaza Y 540..700")
	assert(e0.x < 500.0 and e0.y >= 540.0 and e0.y <= 700.0, "Enemy Slot 1 on left road at Y 540..700")
	assert(p0 != p1, "Hero slots 1 and 2 must not overlap")
	scene.free()
	return true


static func test_tactical_encirclement_modes() -> bool:
	var scene_res: PackedScene = load("res://scenes/battle/battle_scene.tscn")
	var scene: BattleScene = scene_res.instantiate() as BattleScene
	var enemy_cont: Node2D = scene.get_node_or_null("CanvasLayer/UI/Arena/EnemyContainer") as Node2D
	var party_cont: Node2D = scene.get_node_or_null("CanvasLayer/UI/Arena/PartyContainer") as Node2D
	scene.modo_encontro_override = "HEROIS_ENCURRALAM"
	var cerco_h0: Vector2 = party_cont.position + scene._obter_posicao_base_aliado(0)
	var cerco_h1: Vector2 = party_cont.position + scene._obter_posicao_base_aliado(1)
	assert(cerco_h0.x > 1000.0 and cerco_h1.x < 500.0, "Heroes surround monsters from East and West")
	scene.modo_encontro_override = "MONSTROS_ENCURRALAM"
	var cerco_m0: Vector2 = enemy_cont.position + scene._obter_posicao_base_inimigo(0, 4, false)
	var cerco_m1: Vector2 = enemy_cont.position + scene._obter_posicao_base_inimigo(1, 4, false)
	assert(cerco_m0.x > 1000.0 and cerco_m1.x < 500.0, "Monsters surround heroes from East and West")
	scene.free()
	return true


static func test_melee_dash_straight_horizontal_and_return() -> bool:
	var scene_res: PackedScene = load("res://scenes/battle/battle_scene.tscn")
	var scene: BattleScene = scene_res.instantiate() as BattleScene
	var dummy_atk: AnimatedSprite2D = AnimatedSprite2D.new()
	var dummy_tgt: AnimatedSprite2D = AnimatedSprite2D.new()
	dummy_atk.global_position = Vector2(940.0, 510.0)
	dummy_tgt.global_position = Vector2(420.0, 470.0)
	var fallback: Vector2 = Vector2(-470.0, -40.0)
	var dash: Vector2 = scene._calcular_dash_ataque(dummy_atk, dummy_tgt, fallback)
	var dest: Vector2 = dummy_atk.global_position + dash
	assert(is_equal_approx(dest.distance_to(dummy_tgt.global_position), 50.0), "Dash target must stop 50px away")
	assert(dash.x < -400.0, "Dash must travel across the central earthen plaza horizontally")
	dummy_atk.free()
	dummy_tgt.free()
	scene.free()
	return true


static func test_attack_aligns_to_target_line_before_advancing() -> bool:
	var scene_res: PackedScene = load("res://scenes/battle/battle_scene.tscn")
	var scene: BattleScene = scene_res.instantiate() as BattleScene
	var party_cont: Node2D = scene.get_node_or_null("CanvasLayer/UI/Arena/PartyContainer") as Node2D
	var enemy_cont: Node2D = scene.get_node_or_null("CanvasLayer/UI/Arena/EnemyContainer") as Node2D
	var atk: AnimatedSprite2D = AnimatedSprite2D.new()
	var tgt: AnimatedSprite2D = AnimatedSprite2D.new()
	party_cont.add_child(atk)
	enemy_cont.add_child(tgt)
	atk.position = Vector2.ZERO
	tgt.position = Vector2.ZERO
	var linha_y: float = scene._obter_y_local_alvo(atk, tgt, 0.0)
	assert(is_equal_approx(party_cont.global_position.y + linha_y, tgt.global_position.y), "Aligns to target Y")
	var contato_x: float = scene._obter_x_local_contato(atk, tgt, 50.0, -650.0)
	var pos_final: Vector2 = party_cont.global_position + Vector2(contato_x, linha_y)
	assert(is_equal_approx(pos_final.y, tgt.global_position.y), "Contact strike is on target's line")
	assert(is_equal_approx(pos_final.x, tgt.global_position.x + 50.0), "Contact strike stops 50px away")
	var boss_linha_y: float = scene._obter_y_local_alvo(tgt, atk, 0.0)
	assert(is_equal_approx(enemy_cont.global_position.y + boss_linha_y, atk.global_position.y), "Boss aligns to ally Y")
	atk.free()
	tgt.free()
	scene.free()
	return true


static func test_combatant_attack_scale_compensation_and_idle_restoration() -> bool:
	var scene_res: PackedScene = load("res://scenes/battle/battle_scene.tscn")
	var scene: BattleScene = scene_res.instantiate() as BattleScene
	assert(BattleScene.ESCALA_COMBATENTE_BASE == Vector2(0.9, 0.9), "Base scale must be (0.9, 0.9)")
	assert(BattleScene.ESCALA_CHEFE_BASE == Vector2(1.05, 1.05), "Boss base scale must be (1.05, 1.05)")
	assert(is_equal_approx(BattleScene.MULTIPLICADOR_COMPENSACAO_ATAQUE, 1.25), "Attack scale compensation multiplier must be 1.25")
	var dummy_ally: AnimatedSprite2D = AnimatedSprite2D.new()
	dummy_ally.set_meta("escala_base", BattleScene.ESCALA_COMBATENTE_BASE)
	scene.restaurar_escala_base(dummy_ally)
	assert(dummy_ally.scale == BattleScene.ESCALA_COMBATENTE_BASE, "Idle restoration resets sprite scale to base")
	scene.aplicar_escala_ataque(dummy_ally)
	assert(dummy_ally.scale == BattleScene.ESCALA_COMBATENTE_BASE * BattleScene.MULTIPLICADOR_COMPENSACAO_ATAQUE, "Attack scale applies 1.25 compensation")
	assert(is_equal_approx(dummy_ally.scale.x, 1.125) and is_equal_approx(dummy_ally.scale.y, 1.125), "Attack scale equals (1.125, 1.125)")
	scene.restaurar_escala_base(dummy_ally)
	assert(dummy_ally.scale == BattleScene.ESCALA_COMBATENTE_BASE, "Restores back to base scale after strike")

	var dummy_boss: AnimatedSprite2D = AnimatedSprite2D.new()
	dummy_boss.set_meta("escala_base", BattleScene.ESCALA_CHEFE_BASE)
	scene.restaurar_escala_base(dummy_boss)
	assert(dummy_boss.scale == BattleScene.ESCALA_CHEFE_BASE, "Boss idle scale is (1.05, 1.05)")
	scene.aplicar_escala_ataque(dummy_boss)
	assert(is_equal_approx(dummy_boss.scale.x, 1.05 * 1.25) and is_equal_approx(dummy_boss.scale.y, 1.05 * 1.25), "Boss attack scale is 1.05 * 1.25")
	scene.restaurar_escala_base(dummy_boss)
	assert(dummy_boss.scale == BattleScene.ESCALA_CHEFE_BASE, "Boss restores back to (1.05, 1.05)")
	dummy_ally.free()
	dummy_boss.free()
	scene.free()
	return true


static func test_general_cassian_combat_frames_and_attack_selection() -> bool:
	var cassian_res: Resource = load("res://resources/enemies/general_cassian.tres")
	assert(cassian_res != null, "General Cassian resource must exist")
	var frames: SpriteFrames = cassian_res.get("sprite_frames") as SpriteFrames
	assert(frames != null, "SpriteFrames must be assigned to General Cassian")
	assert(frames.has_animation("Attack Southeast_right") or frames.has_animation("Attack Right_right"), "Must possess directional sword attack")
	var scene_res: PackedScene = load("res://scenes/battle/battle_scene.tscn")
	var scene: BattleScene = scene_res.instantiate() as BattleScene
	var atk_anim: String = scene._obter_nome_anim_ataque(frames, "general_cassian")
	assert(atk_anim == "Attack Southeast_right" or atk_anim == "Attack Right_right", "Boss must select directional sword attack animation")
	scene.free()
	return true


