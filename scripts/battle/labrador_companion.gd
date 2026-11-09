class_name LabradorCompanion
extends Node2D

## Companheiro canino vivo da vila de Baltazar na arena de batalha.
## Late defensivamente quando inimigos agridem heróis e realiza mordidas autônomas.

enum EstadoLabrador {
	DEITADO,
	LATINDO,
	INVESTIDA,
	MORDENDO,
	RETORNANDO
}

@export var dano_mordida: int = 4
@export var tempo_entre_investidas: float = 12.0

var estado_atual: EstadoLabrador = EstadoLabrador.DEITADO
var posicao_descanso: Vector2 = Vector2.ZERO
var timer_investida: float = 8.0
var battle_manager: BattleManager = null
var anim_player: AnimationPlayer = null


func _ready() -> void:
	posicao_descanso = position
	_localizar_anim_player()
	tocar_animacao("Lie_Idle")


func _process(delta: float) -> void:
	if battle_manager == null or estado_atual != EstadoLabrador.DEITADO:
		return
	if battle_manager.current_state != BattleManager.BattleState.AGUARDANDO_TURNO and battle_manager.current_state != BattleManager.BattleState.SELECIONANDO_ACAO:
		return
	timer_investida -= delta
	if timer_investida <= 0.0:
		executar_investida_autonoma()


func _localizar_anim_player() -> void:
	if anim_player != null:
		return
	anim_player = find_child("AnimationPlayer", true, false) as AnimationPlayer


func tocar_animacao(nome_anim: String) -> void:
	_localizar_anim_player()
	if anim_player == null or not anim_player.has_animation(nome_anim):
		return
	anim_player.play(nome_anim)


func conectar_batalha(bm: BattleManager) -> void:
	battle_manager = bm
	if battle_manager != null and not battle_manager.action_executed.is_connected(_on_acao_executada):
		battle_manager.action_executed.connect(_on_acao_executada)


func _on_acao_executada(ator_id: String, alvo_id: String, _tipo_acao: String) -> void:
	if estado_atual != EstadoLabrador.DEITADO:
		return
	if _ator_e_inimigo(ator_id) and _alvo_e_aliado(alvo_id):
		reagir_latindo()


func _ator_e_inimigo(ator_id: String) -> bool:
	if battle_manager == null:
		return false
	for inimigo: Dictionary in battle_manager.enemies:
		if str(inimigo.get("id", "")) == ator_id:
			return true
	return false


func _alvo_e_aliado(alvo_id: String) -> bool:
	if battle_manager == null:
		return false
	for heroi: CharacterData in battle_manager.party_members:
		if heroi != null and heroi.character_id == alvo_id:
			return true
	return false


func reagir_latindo() -> void:
	estado_atual = EstadoLabrador.LATINDO
	tocar_animacao("Bark")
	_exibir_texto_flutuante("Au! Au!", Color(1.0, 0.9, 0.3, 1.0))
	var tw: Tween = create_tween()
	tw.tween_interval(1.4)
	tw.finished.connect(_retornar_ao_repouso)


func _retornar_ao_repouso() -> void:
	if estado_atual == EstadoLabrador.LATINDO or estado_atual == EstadoLabrador.RETORNANDO:
		estado_atual = EstadoLabrador.DEITADO
		tocar_animacao("Lie_Idle")


func executar_investida_autonoma() -> void:
	timer_investida = tempo_entre_investidas
	var alvo_idx: int = _selecionar_indice_inimigo_vivo()
	if alvo_idx < 0:
		return
	var pos_alvo: Vector2 = _obter_posicao_global_alvo(alvo_idx)
	_iniciar_trajeto_ataque(alvo_idx, pos_alvo)


func _selecionar_indice_inimigo_vivo() -> int:
	if battle_manager == null:
		return -1
	for idx: int in range(battle_manager.enemies.size()):
		var e: Dictionary = battle_manager.enemies[idx]
		if int(e.get("current_hp", 0)) > 0:
			return idx
	return -1


func _obter_posicao_global_alvo(alvo_idx: int) -> Vector2:
	var cena_batalha: BattleScene = _obter_cena_batalha()
	if cena_batalha != null and battle_manager != null and alvo_idx < battle_manager.enemies.size():
		var e_id: String = str(battle_manager.enemies[alvo_idx].get("id", ""))
		var spr: Node2D = cena_batalha.enemy_sprites.get(e_id) as Node2D
		if spr != null:
			return spr.global_position + Vector2(60.0, 10.0)
	return global_position + Vector2(-200.0, 0.0)


func _obter_cena_batalha() -> BattleScene:
	var p: Node = get_parent()
	while p != null:
		if p is BattleScene:
			return p as BattleScene
		p = p.get_parent()
	return null


func _iniciar_trajeto_ataque(alvo_idx: int, pos_alvo: Vector2) -> void:
	estado_atual = EstadoLabrador.INVESTIDA
	tocar_animacao("Gallop")
	var tw: Tween = create_tween()
	tw.tween_property(self, "global_position", pos_alvo, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.finished.connect(func() -> void: _executar_mordida(alvo_idx))


func _executar_mordida(alvo_idx: int) -> void:
	estado_atual = EstadoLabrador.MORDENDO
	tocar_animacao("Bite")
	_aplicar_dano_ao_alvo(alvo_idx)
	var tw: Tween = create_tween()
	tw.tween_interval(0.6)
	tw.finished.connect(_iniciar_retorno)


func _aplicar_dano_ao_alvo(alvo_idx: int) -> void:
	if battle_manager != null and alvo_idx >= 0 and alvo_idx < battle_manager.enemies.size():
		battle_manager.apply_damage_to_enemy(alvo_idx, dano_mordida)
		_exibir_texto_flutuante("Mordida Amiga! -%d" % dano_mordida, Color(1.0, 0.6, 0.4, 1.0))
		var cena: BattleScene = _obter_cena_batalha()
		if cena != null:
			cena.call("_update_hud")


func _iniciar_retorno() -> void:
	estado_atual = EstadoLabrador.RETORNANDO
	tocar_animacao("Trot")
	var tw: Tween = create_tween()
	var dest: Vector2 = posicao_descanso
	if get_parent() != null and get_parent() is Node2D:
		dest = (get_parent() as Node2D).to_global(posicao_descanso)
	tw.tween_property(self, "global_position", dest, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.finished.connect(_retornar_ao_repouso)


func _exibir_texto_flutuante(texto: String, cor: Color) -> void:
	var label: Label = Label.new()
	label.text = texto
	label.modulate = cor
	label.set("theme_override_font_sizes/font_size", 14)
	label.position = Vector2(-40.0, -90.0)
	add_child(label)
	var tw: Tween = create_tween()
	tw.tween_property(label, "position:y", -130.0, 1.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(label, "modulate:a", 0.0, 1.2)
	tw.finished.connect(label.queue_free)

