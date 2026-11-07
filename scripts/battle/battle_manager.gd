class_name BattleManager
extends Node

## Gerenciador do motor de combate por turnos e máquina de estados de batalha no Kenoma.

enum BattleState {
	INICIALIZANDO,
	AGUARDANDO_TURNO,
	SELECIONANDO_ACAO,
	EXECUTANDO_ACAO,
	VITORIA,
	DERROTA,
}

signal battle_state_changed(old_state: BattleState, new_state: BattleState)
signal battle_initialized(allies: Array[CharacterData], enemies: Array[Dictionary])
signal battle_finished(is_victory: bool)

@export var current_state: BattleState = BattleState.INICIALIZANDO

var party_members: Array[CharacterData] = []
var enemies: Array[Dictionary] = []
var active_actor_index: int = 0
var is_player_turn: bool = true


func initialize_battle(allies: Array[CharacterData], enemy_list: Array[Dictionary]) -> void:
	current_state = BattleState.INICIALIZANDO
	party_members = allies.duplicate()
	enemies = []
	for e: Dictionary in enemy_list:
		enemies.append(_sanitize_enemy_dict(e))
	active_actor_index = 0
	is_player_turn = true
	battle_initialized.emit(party_members, enemies)
	change_state(BattleState.AGUARDANDO_TURNO)


func _sanitize_enemy_dict(raw: Dictionary) -> Dictionary:
	var m_hp: int = int(raw.get("max_hp", 100))
	var c_hp: int = int(raw.get("current_hp", m_hp))
	var stab: int = int(raw.get("stability", 100))
	var en_name: String = str(raw.get("name", "Inimigo"))
	return {
		"name": en_name,
		"max_hp": m_hp,
		"current_hp": clampi(c_hp, 0, m_hp),
		"stability": stab
	}


func can_transition_to(target_state: BattleState) -> bool:
	match current_state:
		BattleState.INICIALIZANDO:
			return target_state == BattleState.AGUARDANDO_TURNO
		BattleState.AGUARDANDO_TURNO:
			return target_state in [BattleState.SELECIONANDO_ACAO, BattleState.EXECUTANDO_ACAO, BattleState.VITORIA, BattleState.DERROTA]
		BattleState.SELECIONANDO_ACAO:
			return target_state in [BattleState.EXECUTANDO_ACAO, BattleState.AGUARDANDO_TURNO]
		BattleState.EXECUTANDO_ACAO:
			return target_state in [BattleState.AGUARDANDO_TURNO, BattleState.VITORIA, BattleState.DERROTA]
		BattleState.VITORIA, BattleState.DERROTA:
			return false
	return false


func change_state(new_state: BattleState) -> bool:
	if current_state == new_state or not can_transition_to(new_state):
		return false
	var old_state: BattleState = current_state
	current_state = new_state
	battle_state_changed.emit(old_state, new_state)
	if new_state == BattleState.VITORIA:
		battle_finished.emit(true)
	elif new_state == BattleState.DERROTA:
		battle_finished.emit(false)
	return true


func get_state_name(state: BattleState) -> String:
	match state:
		BattleState.INICIALIZANDO: return "Inicializando"
		BattleState.AGUARDANDO_TURNO: return "Aguardando Turno"
		BattleState.SELECIONANDO_ACAO: return "Selecionando Ação"
		BattleState.EXECUTANDO_ACAO: return "Executando Ação"
		BattleState.VITORIA: return "Vitória"
		BattleState.DERROTA: return "Derrota"
		_: return "Desconhecido"


func apply_damage_to_enemy(enemy_index: int, damage: int) -> int:
	if enemy_index < 0 or enemy_index >= enemies.size():
		return 0
	var enemy: Dictionary = enemies[enemy_index]
	var current: int = int(enemy.get("current_hp", 0))
	var new_hp: int = maxi(0, current - damage)
	enemy["current_hp"] = new_hp
	enemies[enemy_index] = enemy
	check_battle_end_conditions()
	return damage


func is_all_enemies_defeated() -> bool:
	if enemies.is_empty():
		return false
	for e: Dictionary in enemies:
		if int(e.get("current_hp", 0)) > 0:
			return false
	return true


func is_all_allies_defeated() -> bool:
	if party_members.is_empty():
		return true
	for ally: CharacterData in party_members:
		if ally != null and ally.current_hp > 0:
			return false
	return true


func check_battle_end_conditions() -> bool:
	if is_all_enemies_defeated():
		if current_state == BattleState.EXECUTANDO_ACAO or current_state == BattleState.AGUARDANDO_TURNO:
			change_state(BattleState.VITORIA)
		return true
	if is_all_allies_defeated():
		if current_state == BattleState.EXECUTANDO_ACAO or current_state == BattleState.AGUARDANDO_TURNO:
			change_state(BattleState.DERROTA)
		return true
	return false
