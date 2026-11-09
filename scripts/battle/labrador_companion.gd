class_name LabradorCompanion
extends Node2D

## Companheiro canino vivo da vila de Baltazar na arena de batalha.
## Fica no caminho entre as casas e late em direção à tela quando o combate começa ou quando aliados são agredidos.

enum EstadoLabrador {
	DEITADO,
	LATINDO,
	SENTADO_ALERTA
}

var estado_atual: EstadoLabrador = EstadoLabrador.DEITADO
var battle_manager: BattleManager = null
var anim_player: AnimationPlayer = null
var ja_despertou: bool = false


func _ready() -> void:
	_localizar_anim_player()
	deitar_olhando_frente()


func _localizar_anim_player() -> void:
	if anim_player != null:
		return
	anim_player = find_child("AnimationPlayer", true, false) as AnimationPlayer


func tocar_animacao(nome_anim: String) -> void:
	_localizar_anim_player()
	if anim_player == null or not anim_player.has_animation(nome_anim):
		return
	anim_player.play(nome_anim)


func deitar_olhando_frente() -> void:
	estado_atual = EstadoLabrador.DEITADO
	tocar_animacao("Lie_Idle")


func sentar_alerta() -> void:
	estado_atual = EstadoLabrador.SENTADO_ALERTA
	tocar_animacao("Sit_Idle")


func conectar_batalha(bm: BattleManager) -> void:
	battle_manager = bm
	if battle_manager == null:
		return
	if not battle_manager.action_executed.is_connected(_on_acao_executada):
		battle_manager.action_executed.connect(_on_acao_executada)
	if not battle_manager.battle_state_changed.is_connected(_on_estado_batalha_alterado):
		battle_manager.battle_state_changed.connect(_on_estado_batalha_alterado)


func _on_estado_batalha_alterado(_old_state: BattleManager.BattleState, novo_estado: BattleManager.BattleState) -> void:
	if ja_despertou:
		return
	if novo_estado == BattleManager.BattleState.AGUARDANDO_TURNO or novo_estado == BattleManager.BattleState.SELECIONANDO_ACAO:
		ja_despertou = true
		levantar_e_latir()


func levantar_e_latir() -> void:
	estado_atual = EstadoLabrador.LATINDO
	tocar_animacao("Bark")
	_exibir_texto_flutuante("Au! Au!", Color(1.0, 0.9, 0.3, 1.0))
	var tw: Tween = create_tween()
	tw.tween_interval(1.8)
	tw.finished.connect(sentar_alerta)


func _on_acao_executada(ator_id: String, alvo_id: String, _tipo_acao: String) -> void:
	if estado_atual == EstadoLabrador.LATINDO:
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
	_exibir_texto_flutuante("Grrr... Au!", Color(1.0, 0.85, 0.25, 1.0))
	var tw: Tween = create_tween()
	tw.tween_interval(1.5)
	tw.finished.connect(sentar_alerta)


func _exibir_texto_flutuante(texto: String, cor: Color) -> void:
	var label: Label = Label.new()
	label.text = texto
	label.modulate = cor
	label.set("theme_override_font_sizes/font_size", 14)
	label.position = Vector2(-30.0, -90.0)
	add_child(label)
	var tw: Tween = create_tween()
	tw.tween_property(label, "position:y", -130.0, 1.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(label, "modulate:a", 0.0, 1.2)
	tw.finished.connect(label.queue_free)
