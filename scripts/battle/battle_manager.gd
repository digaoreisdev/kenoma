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
var timeline: BattleTimeline = BattleTimeline.new()


func initialize_battle(allies: Array[CharacterData], enemy_list: Array[Dictionary]) -> void:
	current_state = BattleState.INICIALIZANDO
	party_members = allies.duplicate()
	enemies = []
	for e: Dictionary in enemy_list:
		enemies.append(_sanitize_enemy_dict(e))
	active_actor_index = 0
	is_player_turn = true
	_inicializar_timeline()
	battle_initialized.emit(party_members, enemies)
	change_state(BattleState.AGUARDANDO_TURNO)


func _inicializar_timeline() -> void:
	timeline = BattleTimeline.new()
	for ally: CharacterData in party_members:
		if ally != null:
			timeline.adicionar_combatente({
				"id": ally.character_id, "nome": ally.name,
				"velocidade": float(ally.get_total_stat("agility")),
				"estabilidade_max": 100, "estabilidade_atual": 100, "eh_jogador": true
			})
	for e: Dictionary in enemies:
		timeline.adicionar_combatente({
			"id": str(e.get("id")), "nome": str(e.get("name")),
			"velocidade": float(e.get("velocidade", 20.0)),
			"estabilidade_max": int(e.get("estabilidade_max", 100)),
			"estabilidade_atual": int(e.get("estabilidade_atual", 100)), "eh_jogador": false
		})


func _sanitize_enemy_dict(raw: Dictionary) -> Dictionary:
	var m_hp: int = int(raw.get("max_hp", 100))
	var c_hp: int = int(raw.get("current_hp", m_hp))
	var est_max: int = int(raw.get("estabilidade_max", raw.get("stability", 100)))
	var est_atual: int = int(raw.get("estabilidade_atual", est_max))
	return {
		"id": str(raw.get("id", "inimigo_" + str(enemies.size()))),
		"name": str(raw.get("name", "Inimigo")),
		"max_hp": m_hp,
		"current_hp": clampi(c_hp, 0, m_hp),
		"estabilidade_max": est_max,
		"estabilidade_atual": clampi(est_atual, 0, est_max),
		"irritado": bool(raw.get("irritado", false)),
		"dano_quebra_estabilidade": int(raw.get("dano_quebra_estabilidade", 0)),
		"posicao_tempo": float(raw.get("posicao_tempo", 0.0)),
		"fase_turno": int(raw.get("fase_turno", BattleTimeline.FaseTurno.ESPERA)),
		"defendendo": bool(raw.get("defendendo", false)),
		"stability": est_atual
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


func _calcular_dano_final(atacante: Dictionary, dano_base: int) -> int:
	if bool(atacante.get("irritado", false)):
		return int(float(dano_base) * 1.25)
	return dano_base


func _processar_estabilidade_golpe(defensor: Dictionary, impacto: int) -> Dictionary:
	var est: int = maxi(0, int(defensor.get("estabilidade_atual", 100)) - impacto)
	defensor["estabilidade_atual"] = est
	defensor["stability"] = est
	var fase: int = int(defensor.get("fase_turno", BattleTimeline.FaseTurno.ESPERA))
	if fase == BattleTimeline.FaseTurno.CONJURACAO:
		if est <= 0:
			defensor["fase_turno"] = BattleTimeline.FaseTurno.ESPERA
			defensor["posicao_tempo"] = 0.0
			defensor["progresso_conjuracao"] = 0.0
			defensor["irritado"] = false
			return {"ruptura": true, "irritado": false}
		defensor["irritado"] = true
		return {"ruptura": false, "irritado": true}
	return {"ruptura": false, "irritado": bool(defensor.get("irritado", false))}


func aplicar_golpe(atacante: Dictionary, defensor: Dictionary, dano: int, impacto_estabilidade: int) -> Dictionary:
	var dano_final: int = _calcular_dano_final(atacante, dano)
	if bool(defensor.get("defendendo", false)):
		dano_final = int(float(dano_final) * 0.5)
	var hp_atual: int = int(defensor.get("current_hp", defensor.get("max_hp", 100)))
	defensor["current_hp"] = maxi(0, hp_atual - dano_final)
	var res_est: Dictionary = _processar_estabilidade_golpe(defensor, impacto_estabilidade)
	return {
		"dano": dano_final,
		"ruptura": bool(res_est.get("ruptura", false)),
		"irritado": bool(res_est.get("irritado", false)),
		"vida_restante": int(defensor["current_hp"]),
		"estabilidade_restante": int(defensor.get("estabilidade_atual", 0))
	}


func _extrair_dados_ataque(atacante: Variant) -> Dictionary:
	var forca: int = 10
	var poder_arma: int = 0
	var afinidade: float = 1.0
	var is_hammer: bool = false
	if atacante is CharacterData:
		var c: CharacterData = atacante as CharacterData
		forca = c.get_base_stat("strength")
		var eq: EquipmentData = c.equipment.get("main_hand") as EquipmentData
		if eq != null:
			poder_arma = eq.get_bonus("strength")
			afinidade = c.get_weapon_affinity(eq.weapon_type)
			is_hammer = (eq.weapon_type == EquipmentData.WeaponType.HAMMER)
	elif atacante is Dictionary:
		var d: Dictionary = atacante as Dictionary
		forca = int(d.get("strength", d.get("forca", 10)))
		poder_arma = int(d.get("poder_arma", d.get("weapon_power", 0)))
		afinidade = float(d.get("afinidade", d.get("affinity", 1.0)))
		is_hammer = bool(d.get("is_hammer", false))
	return {"forca": forca, "poder_arma": poder_arma, "afinidade": afinidade, "is_hammer": is_hammer}


func _calcular_dano_ataque_basico(dados: Dictionary) -> int:
	var forca: float = float(dados.get("forca", 10))
	var poder: float = float(dados.get("poder_arma", 0))
	var afinidade: float = float(dados.get("afinidade", 1.0))
	var dano_efetivo: float = forca + (poder * afinidade)
	return int(round(dano_efetivo))


func _calcular_impacto_estabilidade(dados: Dictionary) -> int:
	if bool(dados.get("is_hammer", false)):
		return 35
	return 15


func executar_ataque_basico(atacante: Variant, defensor: Variant) -> Dictionary:
	var dados_atk: Dictionary = _extrair_dados_ataque(atacante)
	var dano_efetivo: int = _calcular_dano_ataque_basico(dados_atk)
	var impacto: int = _calcular_impacto_estabilidade(dados_atk)
	var def_dict: Dictionary = defensor if defensor is Dictionary else {}
	if defensor is CharacterData:
		def_dict = {"name": defensor.name, "current_hp": defensor.current_hp, "max_hp": defensor.max_hp}
	var res: Dictionary = aplicar_golpe({"id": "atacante"}, def_dict, dano_efetivo, impacto)
	if defensor is CharacterData:
		(defensor as CharacterData).current_hp = int(def_dict.get("current_hp", 0))
	res["dano_efetivo"] = dano_efetivo
	res["impacto_estabilidade"] = impacto
	return res


func executar_defesa(combatente: Variant) -> Dictionary:
	if combatente is Dictionary:
		var c: Dictionary = combatente as Dictionary
		c["defendendo"] = true
		c["status"] = "DEFENDENDO"
		var pos: float = float(c.get("posicao_tempo", 0.0)) + 30.0
		c["posicao_tempo"] = minf(100.0, pos)
		return {"defendendo": true, "posicao_tempo": c["posicao_tempo"]}
	elif combatente is CharacterData:
		var cd: CharacterData = combatente as CharacterData
		var t_comb: Dictionary = timeline.obter_combatente(cd.character_id)
		if not t_comb.is_empty():
			t_comb["defendendo"] = true
			t_comb["status"] = "DEFENDENDO"
			t_comb["posicao_tempo"] = minf(100.0, float(t_comb.get("posicao_tempo", 0.0)) + 30.0)
			return {"defendendo": true, "posicao_tempo": t_comb["posicao_tempo"]}
		return {"defendendo": true, "posicao_tempo": 30.0}
	return {}


func executar_item(combatente: Variant, item_data: ItemData, alvo: Variant) -> Dictionary:
	if item_data == null or alvo == null:
		return {"sucesso": false, "cura": 0}
	var cura: int = 0
	if alvo is CharacterData:
		var c: CharacterData = alvo as CharacterData
		var ant: int = c.current_hp
		c.current_hp = mini(c.max_hp, c.current_hp + item_data.effect_value)
		cura = c.current_hp - ant
	elif alvo is Dictionary:
		var d: Dictionary = alvo as Dictionary
		var m_hp: int = int(d.get("max_hp", 100))
		var c_hp: int = int(d.get("current_hp", 0))
		var novo_hp: int = mini(m_hp, c_hp + item_data.effect_value)
		d["current_hp"] = novo_hp
		cura = novo_hp - c_hp
	return {"sucesso": true, "cura": cura, "item": item_data.name}


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
