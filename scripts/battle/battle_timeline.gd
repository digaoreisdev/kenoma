class_name BattleTimeline
extends RefCounted

## Gerenciador da barra de linha do tempo e iniciativa de combate por turnos no Kenoma.

enum FaseTurno {
	ESPERA,
	DECISAO,
	CONJURACAO,
	EXECUCAO,
}

var combatentes: Array[Dictionary] = []


func adicionar_combatente(combatente: Dictionary) -> void:
	combatentes.append(_sanitizar_combatente(combatente))


func _sanitizar_combatente(c: Dictionary) -> Dictionary:
	var c_id: String = str(c.get("id", "combatente_" + str(combatentes.size())))
	var nome: String = str(c.get("nome", "Guerreiro"))
	var vel: float = float(c.get("velocidade", 20.0))
	var est_max: int = int(c.get("estabilidade_max", 100))
	var est_atual: int = int(c.get("estabilidade_atual", est_max))
	return {
		"id": c_id,
		"nome": nome,
		"velocidade": vel,
		"posicao_tempo": float(c.get("posicao_tempo", 0.0)),
		"fase_turno": c.get("fase_turno", FaseTurno.ESPERA),
		"progresso_conjuracao": float(c.get("progresso_conjuracao", 0.0)),
		"velocidade_conjuracao": float(c.get("velocidade_conjuracao", 25.0)),
		"estabilidade_max": est_max,
		"estabilidade_atual": est_atual,
		"irritado": bool(c.get("irritado", false)),
		"eh_jogador": bool(c.get("eh_jogador", false))
	}


func obter_combatente(id: String) -> Dictionary:
	for c: Dictionary in combatentes:
		if str(c.get("id", "")) == id:
			return c
	return {}


func remover_combatente(id: String) -> void:
	for i: int in range(combatentes.size()):
		if str(combatentes[i].get("id", "")) == id:
			combatentes.remove_at(i)
			return


func avancar_tempo(delta: float) -> Array[Dictionary]:
	var eventos: Array[Dictionary] = []
	for i: int in range(combatentes.size()):
		var c: Dictionary = combatentes[i]
		var fase: int = int(c.get("fase_turno", FaseTurno.ESPERA))
		if fase == FaseTurno.ESPERA:
			_avancar_fase_espera(c, delta, eventos)
		elif fase == FaseTurno.CONJURACAO:
			_avancar_fase_conjuracao(c, delta, eventos)
		combatentes[i] = c
	eventos.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("excesso", 0.0)) > float(b.get("excesso", 0.0))
	)
	return eventos


func _avancar_fase_espera(c: Dictionary, delta: float, eventos: Array[Dictionary]) -> void:
	var vel: float = float(c.get("velocidade", 20.0))
	var pos: float = float(c.get("posicao_tempo", 0.0)) + (vel * delta)
	if pos >= 100.0:
		c["posicao_tempo"] = 100.0
		c["fase_turno"] = FaseTurno.DECISAO
		eventos.append({
			"id": str(c.get("id", "")), "evento": "DECISAO",
			"combatente": c, "excesso": pos - 100.0
		})
	else:
		c["posicao_tempo"] = pos


func _avancar_fase_conjuracao(c: Dictionary, delta: float, eventos: Array[Dictionary]) -> void:
	var vel_conj: float = float(c.get("velocidade_conjuracao", 25.0))
	var prog: float = float(c.get("progresso_conjuracao", 0.0)) + (vel_conj * delta)
	if prog >= 100.0:
		c["progresso_conjuracao"] = 100.0
		c["fase_turno"] = FaseTurno.EXECUCAO
		eventos.append({"id": str(c.get("id", "")), "evento": "CONJURACAO_CONCLUIDA", "combatente": c})
	else:
		c["progresso_conjuracao"] = prog


func iniciar_conjuracao(id: String, tempo_conjuracao: float = 2.0) -> void:
	for c: Dictionary in combatentes:
		if str(c.get("id", "")) == id:
			c["fase_turno"] = FaseTurno.CONJURACAO
			c["progresso_conjuracao"] = 0.0
			c["tempo_conjuracao"] = tempo_conjuracao
			var vel: float = (100.0 / tempo_conjuracao) if tempo_conjuracao > 0.0 else 100.0
			c["velocidade_conjuracao"] = vel
			return


func aplicar_interrupcao(id: String, penalidade_posicao: float = 30.0) -> void:
	for c: Dictionary in combatentes:
		if str(c.get("id", "")) == id:
			c["fase_turno"] = FaseTurno.ESPERA
			c["progresso_conjuracao"] = 0.0
			var pos: float = float(c.get("posicao_tempo", 100.0))
			c["posicao_tempo"] = clampf(pos - penalidade_posicao, 0.0, 100.0)
			c["irritado"] = false
			return


func concluir_execucao(id: String) -> void:
	for c: Dictionary in combatentes:
		if str(c.get("id", "")) == id:
			c["fase_turno"] = FaseTurno.ESPERA
			c["posicao_tempo"] = 0.0
			c["progresso_conjuracao"] = 0.0
			c["irritado"] = false
			return


func aplicar_ruptura(id: String) -> void:
	for c: Dictionary in combatentes:
		if str(c.get("id", "")) == id:
			c["fase_turno"] = FaseTurno.ESPERA
			c["posicao_tempo"] = 0.0
			c["progresso_conjuracao"] = 0.0
			c["irritado"] = false
			return
