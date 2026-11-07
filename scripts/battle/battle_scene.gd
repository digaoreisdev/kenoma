class_name BattleScene
extends Node2D

## Cena de combate com HUD de combatentes e painel de comandos de ação.

@onready var battle_manager: BattleManager = get_node_or_null("BattleManager")
@onready var state_label: Label = get_node_or_null("CanvasLayer/UI/HeaderPanel/Margin/HBox/StateLabel")
@onready var turn_label: Label = get_node_or_null("CanvasLayer/UI/HeaderPanel/Margin/HBox/TurnLabel")
@onready var command_panel: Control = get_node_or_null("CanvasLayer/UI/ActionCommandPanel")
@onready var btn_atacar: Button = get_node_or_null("CanvasLayer/UI/ActionCommandPanel/Margin/Grid/BtnAtacar")
@onready var btn_defender: Button = get_node_or_null("CanvasLayer/UI/ActionCommandPanel/Margin/Grid/BtnDefender")
@onready var btn_itens: Button = get_node_or_null("CanvasLayer/UI/ActionCommandPanel/Margin/Grid/BtnItens")
@onready var btn_fugir: Button = get_node_or_null("CanvasLayer/UI/ActionCommandPanel/Margin/Grid/BtnFugir")
@onready var ally_name_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel/Margin/VBox/NameLabel")
@onready var ally_hp_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel/Margin/VBox/HPLabel")
@onready var ally_est_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel/Margin/VBox/EstLabel")
@onready var ally_fase_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel/Margin/VBox/FaseLabel")
@onready var enemy_name_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/EnemyPanel/Margin/VBox/NameLabel")
@onready var enemy_hp_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/EnemyPanel/Margin/VBox/HPLabel")
@onready var enemy_est_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/EnemyPanel/Margin/VBox/EstLabel")
@onready var enemy_fase_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/EnemyPanel/Margin/VBox/FaseLabel")


func _ready() -> void:
	if battle_manager != null:
		battle_manager.battle_state_changed.connect(_on_state_changed)
		battle_manager.timeline_updated.connect(_update_hud)
		_update_labels(battle_manager.current_state)
		_update_hud()
		_update_command_panel(battle_manager.current_state)
	_connect_buttons()


func _connect_buttons() -> void:
	if btn_atacar != null:
		btn_atacar.pressed.connect(_on_atacar_pressed)
	if btn_defender != null:
		btn_defender.pressed.connect(_on_defender_pressed)
	if btn_itens != null:
		btn_itens.pressed.connect(_on_itens_pressed)
	if btn_fugir != null:
		btn_fugir.pressed.connect(_on_fugir_pressed)


func _on_state_changed(_old_state: BattleManager.BattleState, new_state: BattleManager.BattleState) -> void:
	_update_labels(new_state)
	_update_command_panel(new_state)
	_update_hud()


func _update_command_panel(state: BattleManager.BattleState) -> void:
	if command_panel == null:
		return
	var is_selecting: bool = (state == BattleManager.BattleState.SELECIONANDO_ACAO)
	command_panel.visible = is_selecting
	if is_selecting and btn_atacar != null:
		btn_atacar.grab_focus()
		btn_atacar.call_deferred("grab_focus")


func _update_labels(state: BattleManager.BattleState) -> void:
	if state_label != null and battle_manager != null:
		state_label.text = "Estado: %s" % battle_manager.get_state_name(state)
	if turn_label != null and battle_manager != null:
		turn_label.text = "Turno: %s" % ("Grupo do Jogador" if battle_manager.is_player_turn else "Inimigos")


func _update_hud() -> void:
	if battle_manager == null:
		return
	_update_ally_hud()
	_update_enemy_hud()


func _update_ally_hud() -> void:
	if battle_manager.party_members.is_empty() or ally_name_lbl == null:
		return
	var hero: CharacterData = battle_manager.party_members[0]
	ally_name_lbl.text = hero.name
	if ally_hp_lbl != null:
		ally_hp_lbl.text = "PV: %d/%d" % [hero.current_hp, hero.max_hp]
	if ally_est_lbl != null:
		var c_comb: Dictionary = battle_manager.timeline.obter_combatente(hero.character_id)
		var est: int = int(c_comb.get("estabilidade_atual", 100))
		ally_est_lbl.text = "Estabilidade: %d/100" % est
	if ally_fase_lbl != null:
		var c_comb: Dictionary = battle_manager.timeline.obter_combatente(hero.character_id)
		var pos: float = float(c_comb.get("posicao_tempo", 0.0))
		ally_fase_lbl.text = "Fase: %s (%.0f%%)" % [_obter_nome_fase(hero.character_id), pos]


func _update_enemy_hud() -> void:
	if battle_manager.enemies.is_empty() or enemy_name_lbl == null:
		return
	var en: Dictionary = battle_manager.enemies[0]
	enemy_name_lbl.text = str(en.get("name", "Inimigo"))
	if enemy_hp_lbl != null:
		enemy_hp_lbl.text = "PV: %d/%d" % [int(en.get("current_hp", 0)), int(en.get("max_hp", 100))]
	if enemy_est_lbl != null:
		enemy_est_lbl.text = "Estabilidade: %d/%d" % [int(en.get("estabilidade_atual", 100)), int(en.get("estabilidade_max", 100))]
	if enemy_fase_lbl != null:
		var c_comb: Dictionary = battle_manager.timeline.obter_combatente(str(en.get("id", "")))
		var pos: float = float(c_comb.get("posicao_tempo", 0.0))
		enemy_fase_lbl.text = "Fase: %s (%.0f%%)" % [_obter_nome_fase(str(en.get("id", ""))), pos]


func _obter_nome_fase(c_id: String) -> String:
	if battle_manager == null or battle_manager.timeline == null:
		return "Espera"
	var c: Dictionary = battle_manager.timeline.obter_combatente(c_id)
	var fase: int = int(c.get("fase_turno", BattleTimeline.FaseTurno.ESPERA))
	match fase:
		BattleTimeline.FaseTurno.ESPERA: return "Espera"
		BattleTimeline.FaseTurno.DECISAO: return "Decisão"
		BattleTimeline.FaseTurno.CONJURACAO: return "Conjuração"
		BattleTimeline.FaseTurno.EXECUCAO: return "Execução"
		_: return "Espera"


func _on_atacar_pressed() -> void:
	if battle_manager == null or battle_manager.enemies.is_empty():
		return
	battle_manager.change_state(BattleManager.BattleState.EXECUTANDO_ACAO)
	var hero: CharacterData = battle_manager.party_members[0] if not battle_manager.party_members.is_empty() else null
	var enemy: Dictionary = battle_manager.enemies[0]
	battle_manager.executar_ataque_basico(hero, enemy)
	if hero != null:
		battle_manager.timeline.concluir_execucao(hero.character_id)
	_update_hud()
	if not battle_manager.check_battle_end_conditions():
		battle_manager.change_state(BattleManager.BattleState.AGUARDANDO_TURNO)


func _on_defender_pressed() -> void:
	if battle_manager == null:
		return
	battle_manager.change_state(BattleManager.BattleState.EXECUTANDO_ACAO)
	var hero: CharacterData = battle_manager.party_members[0] if not battle_manager.party_members.is_empty() else null
	battle_manager.executar_defesa(hero)
	_update_hud()
	battle_manager.change_state(BattleManager.BattleState.AGUARDANDO_TURNO)


func _on_itens_pressed() -> void:
	if battle_manager == null or battle_manager.party_members.is_empty():
		return
	battle_manager.change_state(BattleManager.BattleState.EXECUTANDO_ACAO)
	var hero: CharacterData = battle_manager.party_members[0]
	battle_manager.executar_item(hero, ItemData.create_potion(), hero)
	if hero != null:
		battle_manager.timeline.concluir_execucao(hero.character_id)
	_update_hud()
	battle_manager.change_state(BattleManager.BattleState.AGUARDANDO_TURNO)


func _on_fugir_pressed() -> void:
	if battle_manager != null:
		battle_manager.change_state(BattleManager.BattleState.AGUARDANDO_TURNO)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and command_panel != null and command_panel.visible:
		if btn_atacar != null:
			btn_atacar.grab_focus()
