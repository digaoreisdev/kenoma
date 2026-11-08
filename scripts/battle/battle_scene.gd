class_name BattleScene
extends Node2D

## Cena de combate com arena visual de combatentes, HUD e comandos de ação.

@onready var battle_manager: BattleManager = get_node_or_null("BattleManager")
@onready var state_label: Label = get_node_or_null("CanvasLayer/UI/HeaderPanel/Margin/HBox/StateLabel")
@onready var turn_label: Label = get_node_or_null("CanvasLayer/UI/HeaderPanel/Margin/HBox/TurnLabel")
@onready var command_panel: Control = get_node_or_null("CanvasLayer/UI/ActionCommandPanel")
@onready var btn_atacar: Button = get_node_or_null("CanvasLayer/UI/ActionCommandPanel/Margin/Grid/BtnAtacar")
@onready var btn_defender: Button = get_node_or_null("CanvasLayer/UI/ActionCommandPanel/Margin/Grid/BtnDefender")
@onready var btn_itens: Button = get_node_or_null("CanvasLayer/UI/ActionCommandPanel/Margin/Grid/BtnItens")
@onready var btn_fugir: Button = get_node_or_null("CanvasLayer/UI/ActionCommandPanel/Margin/Grid/BtnFugir")
@onready var ally_panel: Control = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel")
@onready var ally_portrait_rect: TextureRect = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel/Margin/HBox/PortraitRect")
@onready var ally_name_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel/Margin/HBox/VBox/NameLabel")
@onready var ally_hp_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel/Margin/HBox/VBox/HPLabel")
@onready var ally_est_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel/Margin/HBox/VBox/EstLabel")
@onready var ally_fase_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel/Margin/HBox/VBox/FaseLabel")
@onready var ally2_panel: Control = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel2")
@onready var ally2_portrait_rect: TextureRect = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel2/Margin/HBox/PortraitRect")
@onready var ally2_name_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel2/Margin/HBox/VBox/NameLabel")
@onready var ally2_hp_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel2/Margin/HBox/VBox/HPLabel")
@onready var ally2_est_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel2/Margin/HBox/VBox/EstLabel")
@onready var ally2_fase_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel2/Margin/HBox/VBox/FaseLabel")
@onready var enemy_panel: Control = get_node_or_null("CanvasLayer/UI/CombatantHUD/EnemyPanel")
@onready var enemy_portrait_rect: TextureRect = get_node_or_null("CanvasLayer/UI/CombatantHUD/EnemyPanel/Margin/HBox/PortraitRect")
@onready var enemy_name_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/EnemyPanel/Margin/HBox/VBox/NameLabel")
@onready var enemy_hp_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/EnemyPanel/Margin/HBox/VBox/HPLabel")
@onready var enemy_est_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/EnemyPanel/Margin/HBox/VBox/EstLabel")
@onready var enemy_fase_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/EnemyPanel/Margin/HBox/VBox/FaseLabel")
@onready var party_container: Node2D = get_node_or_null("CanvasLayer/UI/Arena/PartyContainer")
@onready var enemy_container: Node2D = get_node_or_null("CanvasLayer/UI/Arena/EnemyContainer")
@onready var victory_banner: Control = get_node_or_null("CanvasLayer/UI/VictoryBanner")

var ally_sprites: Dictionary = {}
var enemy_sprites: Dictionary = {}


func _ready() -> void:
	_inicializar_referencias_hud()
	if battle_manager != null:
		battle_manager.battle_state_changed.connect(_on_state_changed)
		battle_manager.timeline_updated.connect(_update_hud)
		battle_manager.battle_initialized.connect(_setup_arena_combatants)
		battle_manager.action_executed.connect(_on_action_executed)
		battle_manager.rupture_triggered.connect(_mostrar_efeito_ruptura)
		_update_labels(battle_manager.current_state)
		_update_hud()
		_update_command_panel(battle_manager.current_state)
		if not battle_manager.party_members.is_empty():
			_setup_arena_combatants(battle_manager.party_members, battle_manager.enemies)
	_connect_buttons()


func _inicializar_referencias_hud() -> void:
	if ally_panel != null and ally_name_lbl == null:
		ally_name_lbl = ally_panel.find_child("NameLabel", true, false) as Label
		ally_hp_lbl = ally_panel.find_child("HPLabel", true, false) as Label
		ally_est_lbl = ally_panel.find_child("EstLabel", true, false) as Label
		ally_fase_lbl = ally_panel.find_child("FaseLabel", true, false) as Label
		ally_portrait_rect = ally_panel.find_child("PortraitRect", true, false) as TextureRect
	if ally2_panel != null and ally2_name_lbl == null:
		ally2_name_lbl = ally2_panel.find_child("NameLabel", true, false) as Label
		ally2_hp_lbl = ally2_panel.find_child("HPLabel", true, false) as Label
		ally2_est_lbl = ally2_panel.find_child("EstLabel", true, false) as Label
		ally2_fase_lbl = ally2_panel.find_child("FaseLabel", true, false) as Label
		ally2_portrait_rect = ally2_panel.find_child("PortraitRect", true, false) as TextureRect
	_inicializar_referencias_inimigo()


func _inicializar_referencias_inimigo() -> void:
	if enemy_panel != null and enemy_name_lbl == null:
		enemy_name_lbl = enemy_panel.find_child("NameLabel", true, false) as Label
		enemy_hp_lbl = enemy_panel.find_child("HPLabel", true, false) as Label
		enemy_est_lbl = enemy_panel.find_child("EstLabel", true, false) as Label
		enemy_fase_lbl = enemy_panel.find_child("FaseLabel", true, false) as Label
		enemy_portrait_rect = enemy_panel.find_child("PortraitRect", true, false) as TextureRect



func _connect_buttons() -> void:
	if btn_atacar != null:
		btn_atacar.pressed.connect(_on_atacar_pressed)
	if btn_defender != null:
		btn_defender.pressed.connect(_on_defender_pressed)
	if btn_itens != null:
		btn_itens.pressed.connect(_on_itens_pressed)
	if btn_fugir != null:
		btn_fugir.pressed.connect(_on_fugir_pressed)


func _setup_arena_combatants(allies: Array[CharacterData], enemy_list: Array[Dictionary]) -> void:
	_spawn_allies(allies)
	_spawn_enemies(enemy_list)


func _spawn_allies(allies: Array[CharacterData]) -> void:
	if party_container == null:
		return
	for child: Node in party_container.get_children():
		child.queue_free()
	ally_sprites.clear()
	for idx: int in range(allies.size()):
		var ally: CharacterData = allies[idx]
		if ally != null:
			_criar_sprite_aliado(ally, idx)


func _criar_sprite_aliado(ally: CharacterData, idx: int) -> void:
	var sprite: AnimatedSprite2D = AnimatedSprite2D.new()
	sprite.name = ally.character_id
	var frames: SpriteFrames = ally.sprite_frames
	if frames == null:
		frames = _obter_fallback_frames_aliado(ally.character_id)
	sprite.sprite_frames = frames
	sprite.scale = Vector2(0.9, 0.9)
	sprite.offset = Vector2(0.0, 8.0)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position = Vector2(40.0 * idx, 50.0 * idx)
	_tocar_idle_aliado(sprite, ally.character_id)
	party_container.add_child(sprite)
	ally_sprites[ally.character_id] = sprite


func _obter_fallback_frames_aliado(c_id: String) -> SpriteFrames:
	var path: String = "res://assets/art/characters/player/player_frames.tres"
	if c_id == "davi":
		path = "res://assets/sprites/characters/davi/Davi_Reis_frames.tres"
	if ResourceLoader.exists(path):
		return load(path) as SpriteFrames
	return null


func _spawn_enemies(enemy_list: Array[Dictionary]) -> void:
	if enemy_container == null:
		return
	for child: Node in enemy_container.get_children():
		child.queue_free()
	enemy_sprites.clear()
	for idx: int in range(enemy_list.size()):
		_criar_sprite_inimigo(enemy_list[idx], idx)


func _criar_sprite_inimigo(e: Dictionary, idx: int) -> void:
	var sprite: AnimatedSprite2D = AnimatedSprite2D.new()
	var e_id: String = str(e.get("id", "inimigo_%d" % idx))
	sprite.name = e_id
	var frames: SpriteFrames = e.get("sprite_frames") as SpriteFrames
	if frames == null and str(e.get("name", "")).contains("Cassian"):
		const CASSIAN_PATH: String = "res://assets/sprites/characters/cassian/General_Cassian_frames.tres"
		if ResourceLoader.exists(CASSIAN_PATH):
			frames = load(CASSIAN_PATH) as SpriteFrames
	sprite.sprite_frames = frames
	sprite.scale = Vector2(0.9, 0.9)
	sprite.offset = Vector2(0.0, 8.0)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position = Vector2(-50.0 * idx, 50.0 * idx)
	_tocar_idle_inimigo(sprite)
	enemy_container.add_child(sprite)
	enemy_sprites[e_id] = sprite


func _tocar_idle_aliado(sprite: AnimatedSprite2D, c_id: String) -> void:
	if sprite == null or sprite.sprite_frames == null:
		return
	var anim: String = "idle_down_left"
	if c_id == "davi":
		anim = "Idle Southwest_right"
	if not sprite.sprite_frames.has_animation(anim):
		var anims: PackedStringArray = sprite.sprite_frames.get_animation_names()
		for a: String in anims:
			if a.to_lower().contains("idle"):
				anim = a
				break
	if not anim.is_empty() and sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)


func _tocar_idle_inimigo(sprite: AnimatedSprite2D) -> void:
	if sprite == null or sprite.sprite_frames == null:
		return
	var anim: String = "iso_idle_southeast_right"
	if not sprite.sprite_frames.has_animation(anim):
		anim = "iso_idle_right_right"
	if not sprite.sprite_frames.has_animation(anim):
		var anims: PackedStringArray = sprite.sprite_frames.get_animation_names()
		for a: String in anims:
			if a.to_lower().contains("idle"):
				anim = a
				break
	if not anim.is_empty() and sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)


func _obter_sprite_combatente(c_id: String) -> AnimatedSprite2D:
	if ally_sprites.has(c_id):
		return ally_sprites[c_id] as AnimatedSprite2D
	if enemy_sprites.has(c_id):
		return enemy_sprites[c_id] as AnimatedSprite2D
	return null


func _eh_aliado(c_id: String) -> bool:
	return ally_sprites.has(c_id)


func _on_action_executed(actor_id: String, target_id: String, action_type: String) -> void:
	if action_type == "ataque":
		if actor_id == "lucas":
			_executar_ataque_melee_lucas(actor_id, target_id)
		elif actor_id == "davi":
			_executar_ataque_aura_davi(actor_id, target_id)
		else:
			_executar_ataque_melee_boss(actor_id, target_id)
	else:
		_tocar_animacao_estacionaria(actor_id, action_type)


func _executar_ataque_melee_lucas(actor_id: String, target_id: String) -> void:
	var atk: AnimatedSprite2D = _obter_sprite_combatente(actor_id)
	var tgt: AnimatedSprite2D = _obter_sprite_combatente(target_id)
	if atk == null:
		_finalizar_acao_cena()
		return
	var orig: Vector2 = atk.position
	var dash: Vector2 = _calcular_dash_ataque(atk, tgt, Vector2(-220.0, 0.0))
	var anim: String = _obter_nome_anim_ataque(atk.sprite_frames, actor_id)
	var tw: Tween = create_tween()
	tw.tween_property(atk, "position", orig + dash, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func():
		_no_contato_golpe(atk, anim, target_id)
		_aplicar_tremor_impacto()
	)
	tw.tween_interval(0.45)
	tw.tween_property(atk, "position", orig, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(func():
		_restaurar_idle(atk, actor_id, true)
		_finalizar_acao_cena()
	)


func _calcular_dash_ataque(atk: AnimatedSprite2D, tgt: AnimatedSprite2D, fallback: Vector2) -> Vector2:
	if tgt == null:
		return fallback
	var diff: Vector2 = tgt.global_position - atk.global_position
	return diff.normalized() * (diff.length() - 50.0) if diff.length() > 60.0 else fallback


func _executar_ataque_aura_davi(actor_id: String, target_id: String) -> void:
	var atk: AnimatedSprite2D = _obter_sprite_combatente(actor_id)
	var tgt: AnimatedSprite2D = _obter_sprite_combatente(target_id)
	if atk == null:
		_finalizar_acao_cena()
		return
	var anim: String = _obter_nome_anim_ataque(atk.sprite_frames, actor_id)
	if not anim.is_empty() and atk.sprite_frames != null and atk.sprite_frames.has_animation(anim):
		atk.sprite_frames.set_animation_loop(anim, false)
		atk.play(anim)
	var tw: Tween = create_tween()
	tw.tween_interval(0.4)
	tw.tween_callback(func(): _disparar_projetil_aura(atk, tgt, actor_id, target_id))


func _disparar_projetil_aura(atk: AnimatedSprite2D, tgt: AnimatedSprite2D, actor_id: String, target_id: String) -> void:
	var aura: ColorRect = ColorRect.new()
	aura.custom_minimum_size = Vector2(28.0, 28.0)
	aura.size = Vector2(28.0, 28.0)
	aura.color = Color(0.3, 0.9, 2.5, 0.9)
	aura.position = atk.global_position - Vector2(14.0, 14.0)
	get_parent().add_child(aura)
	var tgt_pos: Vector2 = tgt.global_position - Vector2(14.0, 14.0) if tgt != null else aura.position + Vector2(-400.0, 0.0)
	var tw: Tween = create_tween()
	tw.tween_property(aura, "position", tgt_pos, 0.45).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(func(): _no_impacto_aura(aura, atk, actor_id, target_id))


func _criar_projetil_aura(atk: AnimatedSprite2D, tgt: AnimatedSprite2D, target_id: String) -> void:
	_disparar_projetil_aura(atk, tgt, "davi", target_id)


func _no_impacto_aura(aura: ColorRect, atk: AnimatedSprite2D, actor_id: String, target_id: String) -> void:
	_tocar_reacao_alvo(target_id)
	_aplicar_tremor_impacto()
	if is_instance_valid(aura):
		aura.queue_free()
	var tw: Tween = create_tween()
	tw.tween_interval(0.4)
	tw.tween_callback(func():
		_restaurar_idle(atk, actor_id, true)
		_finalizar_acao_cena()
	)


func _executar_ataque_melee_boss(actor_id: String, target_id: String) -> void:
	var atk: AnimatedSprite2D = _obter_sprite_combatente(actor_id)
	var tgt: AnimatedSprite2D = _obter_sprite_combatente(target_id)
	if atk == null:
		_finalizar_acao_cena()
		return
	var orig: Vector2 = atk.position
	var dash: Vector2 = _calcular_dash_ataque(atk, tgt, Vector2(160.0, 0.0))
	var anim: String = _obter_nome_anim_ataque(atk.sprite_frames, actor_id)
	var tw: Tween = create_tween()
	tw.tween_property(atk, "position", orig + dash, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func():
		_no_contato_golpe(atk, anim, target_id)
		_aplicar_tremor_impacto()
	)
	tw.tween_interval(0.45)
	tw.tween_property(atk, "position", orig, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(func():
		_restaurar_idle(atk, actor_id, false)
		_finalizar_acao_cena()
	)


func _executar_passo_ataque_tween(actor_id: String, target_id: String) -> void:
	_on_action_executed(actor_id, target_id, "ataque")


func _aplicar_tremor_impacto() -> void:
	var arena_node: Node2D = get_node_or_null("CanvasLayer/UI/Arena") as Node2D
	if arena_node == null:
		return
	var orig_pos: Vector2 = Vector2.ZERO
	var tw: Tween = create_tween()
	tw.tween_property(arena_node, "position", orig_pos + Vector2(6.0, -3.0), 0.05)
	tw.tween_property(arena_node, "position", orig_pos + Vector2(-5.0, 4.0), 0.05)
	tw.tween_property(arena_node, "position", orig_pos + Vector2(3.0, -2.0), 0.05)
	tw.tween_property(arena_node, "position", orig_pos, 0.05)


func _finalizar_acao_cena() -> void:
	if battle_manager != null:
		battle_manager.concluir_acao()


func _no_contato_golpe(atk_sprite: AnimatedSprite2D, anim: String, target_id: String) -> void:
	if not anim.is_empty() and atk_sprite.sprite_frames != null and atk_sprite.sprite_frames.has_animation(anim):
		atk_sprite.sprite_frames.set_animation_loop(anim, false)
		atk_sprite.play(anim)
	_tocar_reacao_alvo(target_id)


func _tocar_animacao_estacionaria(actor_id: String, _action_type: String) -> void:
	var sprite: AnimatedSprite2D = _obter_sprite_combatente(actor_id)
	if sprite == null or sprite.sprite_frames == null:
		_finalizar_acao_cena()
		return
	var anim: String = _obter_nome_anim_defesa(sprite.sprite_frames)
	if not anim.is_empty() and sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)
	var orig: Vector2 = sprite.position
	var offset: Vector2 = Vector2(15.0, 0.0) if _eh_aliado(actor_id) else Vector2(-15.0, 0.0)
	var tw: Tween = create_tween()
	tw.tween_property(sprite, "position", orig + offset, 0.1)
	tw.tween_property(sprite, "position", orig, 0.15)
	tw.tween_callback(func():
		_restaurar_idle(sprite, actor_id, _eh_aliado(actor_id))
		_finalizar_acao_cena()
	)


func _obter_nome_anim_ataque(frames: SpriteFrames, actor_id: String) -> String:
	if frames == null:
		return ""
	if actor_id == "lucas":
		for pref: String in ["attack_axe_down_left", "attack_axe_left", "attack_axe_down_right"]:
			if frames.has_animation(pref):
				return pref
	if actor_id == "davi":
		for pref: String in ["Cast Southwest_right", "Cast Left_right", "Throw Left_right", "Cast Right_right"]:
			if frames.has_animation(pref):
				return pref
	for pref: String in ["iso_walk_southeast_right", "iso_walk_right_right", "iso_walk_down_right"]:
		if frames.has_animation(pref):
			return pref
	for n: String in frames.get_animation_names():
		if n.to_lower().contains("attack") or n.to_lower().contains("hit"):
			return n
	return frames.get_animation_names()[0] if frames.get_animation_names().size() > 0 else ""


func _obter_nome_anim_defesa(frames: SpriteFrames) -> String:
	for n: String in frames.get_animation_names():
		var lower: String = n.to_lower()
		if lower.contains("block") or lower.contains("crouch") or lower.contains("defense"):
			return n
	return ""


func _restaurar_idle(sprite: AnimatedSprite2D, actor_id: String, is_ally: bool) -> void:
	if is_ally:
		_tocar_idle_aliado(sprite, actor_id)
	else:
		_tocar_idle_inimigo(sprite)


func _tocar_reacao_alvo(target_id: String) -> void:
	var sprite: AnimatedSprite2D = _obter_sprite_combatente(target_id)
	if sprite == null:
		return
	var t: Tween = create_tween()
	sprite.modulate = Color(2.5, 0.3, 0.3, 1.0)
	t.tween_property(sprite, "modulate", Color.WHITE, 0.25)


func _mostrar_efeito_ruptura(target_id: String) -> void:
	var sprite: AnimatedSprite2D = _obter_sprite_combatente(target_id)
	if sprite == null:
		return
	_aplicar_flash_atordoamento(sprite)
	_criar_label_flutuante_ruptura(sprite)


func _aplicar_flash_atordoamento(sprite: AnimatedSprite2D) -> void:
	var tw: Tween = create_tween()
	sprite.modulate = Color(2.5, 1.8, 0.2, 1.0)
	tw.tween_property(sprite, "modulate", Color(1.8, 1.4, 0.4, 1.0), 0.3)
	tw.tween_property(sprite, "modulate", Color.WHITE, 0.4)


func _criar_label_flutuante_ruptura(sprite: AnimatedSprite2D) -> void:
	var lbl: Label = Label.new()
	lbl.text = "RUPTURA!"
	lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.1, 1.0))
	lbl.add_theme_font_size_override("font_size", 22)
	lbl.position = sprite.position + Vector2(-45.0, -95.0)
	sprite.get_parent().add_child(lbl)
	var tw: Tween = create_tween()
	tw.tween_property(lbl, "position:y", lbl.position.y - 35.0, 0.8)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.8)
	tw.tween_callback(lbl.queue_free)


func _on_state_changed(_old_state: BattleManager.BattleState, new_state: BattleManager.BattleState) -> void:
	_update_labels(new_state)
	_update_command_panel(new_state)
	_update_hud()
	if new_state == BattleManager.BattleState.VITORIA:
		_executar_sequencia_vitoria()


func _executar_sequencia_vitoria() -> void:
	if command_panel != null:
		command_panel.visible = false
	if victory_banner != null:
		victory_banner.visible = true
	var tree: SceneTree = get_tree()
	if tree != null:
		await tree.create_timer(1.5).timeout
	var sm: Node = get_node_or_null("/root/SceneManager")
	if sm != null and sm.has_method("finalizar_batalha"):
		sm.call("finalizar_batalha", true)


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
	if battle_manager.party_members.is_empty():
		return
	if battle_manager.party_members.size() > 0:
		_atualizar_painel_aliado(battle_manager.party_members[0], ally_panel, ally_portrait_rect, ally_name_lbl, ally_hp_lbl, ally_est_lbl, ally_fase_lbl, 0)
	if battle_manager.party_members.size() > 1 and ally2_panel != null:
		ally2_panel.visible = true
		_atualizar_painel_aliado(battle_manager.party_members[1], ally2_panel, ally2_portrait_rect, ally2_name_lbl, ally2_hp_lbl, ally2_est_lbl, ally2_fase_lbl, 1)
	elif ally2_panel != null:
		ally2_panel.visible = false


func _atualizar_painel_aliado(hero: CharacterData, panel: Control, p_rect: TextureRect, n_lbl: Label, hp_lbl: Label, est_lbl: Label, f_lbl: Label, idx: int) -> void:
	if hero == null or panel == null:
		return
	if p_rect != null:
		var tex: Texture2D = _obter_textura_retrato(hero)
		if tex != null and p_rect.texture != tex:
			p_rect.texture = tex
	if n_lbl != null: n_lbl.text = hero.name
	if hp_lbl != null: hp_lbl.text = "PV: %d/%d" % [hero.current_hp, hero.max_hp]
	var c_comb: Dictionary = battle_manager.timeline.obter_combatente(hero.character_id) if battle_manager.timeline != null else {}
	if est_lbl != null: est_lbl.text = "Estabilidade: %d/100" % int(c_comb.get("estabilidade_atual", 100))
	if f_lbl != null:
		var pos: float = float(c_comb.get("posicao_tempo", 0.0))
		f_lbl.text = "Fase: %s (%.0f%%)" % [_obter_nome_fase(hero.character_id), pos]
	var is_acting: bool = (battle_manager.current_state == BattleManager.BattleState.SELECIONANDO_ACAO and battle_manager.active_actor_index == idx)
	panel.modulate = Color(1.2, 1.2, 0.7, 1.0) if is_acting else Color.WHITE


func _obter_textura_retrato(hero: CharacterData) -> Texture2D:
	if hero == null:
		return null
	var path: String = ""
	if hero.character_id == "lucas":
		path = "res://assets/art/portraits/lucas/lucas_confident.png"
		if hero.current_hp < int(hero.max_hp * 0.3):
			path = "res://assets/art/portraits/lucas/lucas_serious.png"
	elif hero.character_id == "davi":
		path = "res://assets/art/portraits/davi/davi_neutral.png"
		if hero.current_hp < int(hero.max_hp * 0.3):
			path = "res://assets/art/portraits/davi/davi_hurt.png"
	if not path.is_empty() and ResourceLoader.exists(path):
		return load(path) as Texture2D
	return hero.portrait


func _update_enemy_hud() -> void:
	if battle_manager.enemies.is_empty():
		return
	var en: Dictionary = battle_manager.enemies[0]
	if enemy_portrait_rect != null:
		var tex: Texture2D = _obter_textura_retrato_inimigo(en)
		if tex != null and enemy_portrait_rect.texture != tex:
			enemy_portrait_rect.texture = tex
	if enemy_name_lbl != null: enemy_name_lbl.text = str(en.get("name", "Inimigo"))
	if enemy_hp_lbl != null: enemy_hp_lbl.text = "PV: %d/%d" % [int(en.get("current_hp", 0)), int(en.get("max_hp", 100))]
	if enemy_est_lbl != null: enemy_est_lbl.text = "Estabilidade: %d/%d" % [int(en.get("estabilidade_atual", 100)), int(en.get("estabilidade_max", 100))]
	if enemy_fase_lbl != null:
		var c_comb: Dictionary = battle_manager.timeline.obter_combatente(str(en.get("id", ""))) if battle_manager.timeline != null else {}
		var pos: float = float(c_comb.get("posicao_tempo", 0.0))
		enemy_fase_lbl.text = "Fase: %s (%.0f%%)" % [_obter_nome_fase(str(en.get("id", ""))), pos]


func _obter_textura_retrato_inimigo(en: Dictionary) -> Texture2D:
	var path: String = "res://assets/art/portraits/cassian/cassian_neutral.png"
	var hp: int = int(en.get("current_hp", 100))
	var m_hp: int = int(en.get("max_hp", 100))
	var est: int = int(en.get("estabilidade_atual", 100))
	if est <= 0 or hp < int(m_hp * 0.3):
		path = "res://assets/art/portraits/cassian/cassian_hurt.png"
	elif bool(en.get("irritado", false)):
		path = "res://assets/art/portraits/cassian/cassian_angry.png"
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null


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
	if command_panel != null:
		command_panel.visible = false
	battle_manager.change_state(BattleManager.BattleState.EXECUTANDO_ACAO)
	var hero: CharacterData = battle_manager.get_active_actor()
	var enemy: Dictionary = battle_manager.enemies[0]
	battle_manager.executar_ataque_basico(hero, enemy)
	_update_hud()


func _on_defender_pressed() -> void:
	if battle_manager == null:
		return
	if command_panel != null:
		command_panel.visible = false
	battle_manager.change_state(BattleManager.BattleState.EXECUTANDO_ACAO)
	var hero: CharacterData = battle_manager.get_active_actor()
	battle_manager.executar_defesa(hero)
	_update_hud()


func _on_itens_pressed() -> void:
	if battle_manager == null or battle_manager.party_members.is_empty():
		return
	if command_panel != null:
		command_panel.visible = false
	battle_manager.change_state(BattleManager.BattleState.EXECUTANDO_ACAO)
	var hero: CharacterData = battle_manager.get_active_actor()
	battle_manager.executar_item(hero, ItemData.create_potion(), hero)
	_update_hud()


func _on_fugir_pressed() -> void:
	if battle_manager == null:
		return
	if command_panel != null:
		command_panel.visible = false
	battle_manager.change_state(BattleManager.BattleState.AGUARDANDO_TURNO)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and command_panel != null and command_panel.visible:
		if btn_atacar != null:
			btn_atacar.grab_focus()
