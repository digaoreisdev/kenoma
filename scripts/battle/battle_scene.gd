class_name BattleScene
extends Node2D

## Cena de combate com arena visual de combatentes, HUD e comandos de ação.

@onready var battle_manager: BattleManager = get_node_or_null("BattleManager")
@onready var state_label: Label = get_node_or_null("CanvasLayer/UI/HeaderPanel/Margin/HBox/StateLabel")
@onready var turn_label: Label = get_node_or_null("CanvasLayer/UI/HeaderPanel/Margin/HBox/TurnLabel")
@onready var command_panel: Control = get_node_or_null("CanvasLayer/UI/ActionCommandPanel")
@onready var btn_atacar: Button = get_node_or_null("CanvasLayer/UI/ActionCommandPanel/Margin/Grid/BtnAtacar")
@onready var btn_habilidades: Button = get_node_or_null("CanvasLayer/UI/ActionCommandPanel/Margin/Grid/BtnHabilidades")
@onready var btn_defender: Button = get_node_or_null("CanvasLayer/UI/ActionCommandPanel/Margin/Grid/BtnDefender")
@onready var btn_itens: Button = get_node_or_null("CanvasLayer/UI/ActionCommandPanel/Margin/Grid/BtnItens")
@onready var btn_fugir: Button = get_node_or_null("CanvasLayer/UI/ActionCommandPanel/Margin/Grid/BtnFugir")
@onready var skills_panel: Control = get_node_or_null("CanvasLayer/UI/SkillsPanel")
@onready var skill_list: VBoxContainer = get_node_or_null("CanvasLayer/UI/SkillsPanel/Margin/VBox/SkillList")
@onready var btn_voltar_skills: Button = get_node_or_null("CanvasLayer/UI/SkillsPanel/Margin/VBox/BtnVoltar")
@onready var ally_panel: Control = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel")
@onready var ally_portrait_rect: TextureRect = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel/Margin/HBox/PortraitRect")
@onready var ally_name_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel/Margin/HBox/VBox/NameLabel")
@onready var ally_hp_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel/Margin/HBox/VBox/HPLabel")
@onready var ally_mp_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel/Margin/HBox/VBox/MPLabel")
@onready var ally_est_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel/Margin/HBox/VBox/EstLabel")
@onready var ally_fase_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel/Margin/HBox/VBox/FaseLabel")
@onready var ally2_panel: Control = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel2")
@onready var ally2_portrait_rect: TextureRect = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel2/Margin/HBox/PortraitRect")
@onready var ally2_name_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel2/Margin/HBox/VBox/NameLabel")
@onready var ally2_hp_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel2/Margin/HBox/VBox/HPLabel")
@onready var ally2_mp_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel2/Margin/HBox/VBox/MPLabel")
@onready var ally2_est_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel2/Margin/HBox/VBox/EstLabel")
@onready var ally2_fase_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/AllyPanel2/Margin/HBox/VBox/FaseLabel")
@onready var enemy_panel: Control = get_node_or_null("CanvasLayer/UI/CombatantHUD/EnemyPanel")
@onready var enemy_portrait_rect: TextureRect = get_node_or_null("CanvasLayer/UI/CombatantHUD/EnemyPanel/Margin/HBox/PortraitRect")
@onready var enemy_name_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/EnemyPanel/Margin/HBox/VBox/NameLabel")
@onready var enemy_hp_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/EnemyPanel/Margin/HBox/VBox/HPLabel")
@onready var enemy_est_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/EnemyPanel/Margin/HBox/VBox/EstLabel")
@onready var enemy_fase_lbl: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/EnemyPanel/Margin/HBox/VBox/FaseLabel")
@onready var enemy_hp_bar: ProgressBar = get_node_or_null("CanvasLayer/UI/CombatantHUD/EnemyPanel/Margin/HBox/VBox/HPBar")
@onready var enemy_est_bar: ProgressBar = get_node_or_null("CanvasLayer/UI/CombatantHUD/EnemyPanel/Margin/HBox/VBox/EstBar")
@onready var enemy_ruptura_badge: Label = get_node_or_null("CanvasLayer/UI/CombatantHUD/EnemyPanel/Margin/HBox/VBox/RupturaBadge")
@onready var timeline_tracker: Control = get_node_or_null("CanvasLayer/UI/TimelineTracker")
@onready var track_area: Control = get_node_or_null("CanvasLayer/UI/TimelineTracker/Margin/HBox/TrackArea")
@onready var arena_background: TextureRect = get_node_or_null("CanvasLayer/UI/ArenaBackground")
@onready var arena_foreground: TextureRect = get_node_or_null("CanvasLayer/UI/ArenaForeground")
@onready var props_container: Node2D = get_node_or_null("CanvasLayer/UI/Arena/PropsContainer")
@onready var miasma_crystal_prop: Sprite2D = get_node_or_null("CanvasLayer/UI/Arena/PropsContainer/MiasmaCrystalProp")
@onready var elevated_rock_prop: Sprite2D = get_node_or_null("CanvasLayer/UI/Arena/PropsContainer/ElevatedRockProp")
@onready var party_container: Node2D = get_node_or_null("CanvasLayer/UI/Arena/PartyContainer")
@onready var enemy_container: Node2D = get_node_or_null("CanvasLayer/UI/Arena/EnemyContainer")
@onready var victory_banner: Control = get_node_or_null("CanvasLayer/UI/VictoryBanner")

var ally_sprites: Dictionary = {}
var enemy_sprites: Dictionary = {}
var timeline_badges: Dictionary = {}


func _ready() -> void:
	_inicializar_referencias_hud()
	_configurar_texturas_cenario()
	_iniciar_pulsacao_cristal()
	if battle_manager != null:
		battle_manager.battle_state_changed.connect(_on_state_changed)
		battle_manager.timeline_updated.connect(_update_hud)
		battle_manager.battle_initialized.connect(_setup_arena_combatants)
		battle_manager.action_executed.connect(_on_action_executed)
		battle_manager.rupture_triggered.connect(_mostrar_efeito_ruptura)
		battle_manager.spell_interrupted.connect(_mostrar_efeito_interrompido)
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
		ally_mp_lbl = ally_panel.find_child("MPLabel", true, false) as Label
		ally_est_lbl = ally_panel.find_child("EstLabel", true, false) as Label
		ally_fase_lbl = ally_panel.find_child("FaseLabel", true, false) as Label
		ally_portrait_rect = ally_panel.find_child("PortraitRect", true, false) as TextureRect
	if ally2_panel != null and ally2_name_lbl == null:
		ally2_name_lbl = ally2_panel.find_child("NameLabel", true, false) as Label
		ally2_hp_lbl = ally2_panel.find_child("HPLabel", true, false) as Label
		ally2_mp_lbl = ally2_panel.find_child("MPLabel", true, false) as Label
		ally2_est_lbl = ally2_panel.find_child("EstLabel", true, false) as Label
		ally2_fase_lbl = ally2_panel.find_child("FaseLabel", true, false) as Label
		ally2_portrait_rect = ally2_panel.find_child("PortraitRect", true, false) as TextureRect
	if skills_panel != null:
		if skill_list == null:
			skill_list = skills_panel.find_child("SkillList", true, false) as VBoxContainer
		if btn_voltar_skills == null:
			btn_voltar_skills = skills_panel.find_child("BtnVoltar", true, false) as Button
	if timeline_tracker != null and track_area == null:
		track_area = timeline_tracker.find_child("TrackArea", true, false) as Control
	_inicializar_referencias_cenario()
	_inicializar_referencias_inimigo()


func _inicializar_referencias_cenario() -> void:
	if arena_background == null:
		arena_background = find_child("ArenaBackground", true, false) as TextureRect
	if arena_foreground == null:
		arena_foreground = find_child("ArenaForeground", true, false) as TextureRect
	if arena_background != null:
		arena_background.z_index = -10
		arena_background.position = Vector2.ZERO
		arena_background.size = Vector2(1920.0, 1080.0)
	if arena_foreground != null:
		arena_foreground.z_index = 10
		arena_foreground.position = Vector2.ZERO
		arena_foreground.size = Vector2(1920.0, 1080.0)
		arena_foreground.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _inicializar_referencias_inimigo() -> void:
	if enemy_panel != null:
		if enemy_name_lbl == null: enemy_name_lbl = enemy_panel.find_child("NameLabel", true, false) as Label
		if enemy_hp_lbl == null: enemy_hp_lbl = enemy_panel.find_child("HPLabel", true, false) as Label
		if enemy_est_lbl == null: enemy_est_lbl = enemy_panel.find_child("EstLabel", true, false) as Label
		if enemy_fase_lbl == null: enemy_fase_lbl = enemy_panel.find_child("FaseLabel", true, false) as Label
		if enemy_portrait_rect == null: enemy_portrait_rect = enemy_panel.find_child("PortraitRect", true, false) as TextureRect
		if enemy_hp_bar == null: enemy_hp_bar = enemy_panel.find_child("HPBar", true, false) as ProgressBar
		if enemy_est_bar == null: enemy_est_bar = enemy_panel.find_child("EstBar", true, false) as ProgressBar
		if enemy_ruptura_badge == null: enemy_ruptura_badge = enemy_panel.find_child("RupturaBadge", true, false) as Label


func _connect_buttons() -> void:
	if btn_atacar != null:
		btn_atacar.pressed.connect(_on_atacar_pressed)
	if btn_habilidades != null:
		btn_habilidades.pressed.connect(_on_habilidades_pressed)
	if btn_defender != null:
		btn_defender.pressed.connect(_on_defender_pressed)
	if btn_itens != null:
		btn_itens.pressed.connect(_on_itens_pressed)
	if btn_fugir != null:
		btn_fugir.pressed.connect(_on_fugir_pressed)
	if btn_voltar_skills != null:
		btn_voltar_skills.pressed.connect(_on_voltar_skills_pressed)


func _setup_arena_combatants(allies: Array[CharacterData], enemy_list: Array[Dictionary]) -> void:
	_spawn_allies(allies)
	_spawn_enemies(enemy_list)
	_setup_timeline_badges(allies, enemy_list)


func _setup_timeline_badges(allies: Array[CharacterData], enemy_list: Array[Dictionary]) -> void:
	if track_area == null:
		return
	for c: Node in track_area.get_children():
		if c.name != "TrackLine":
			c.queue_free()
	timeline_badges.clear()
	for ally: CharacterData in allies:
		if ally != null:
			_criar_badge_combatente(ally.character_id, _obter_textura_retrato(ally), true)
	for e: Dictionary in enemy_list:
		var e_id: String = str(e.get("id", "inimigo"))
		_criar_badge_combatente(e_id, _obter_textura_retrato_inimigo(e), false)


func _criar_badge_combatente(c_id: String, tex: Texture2D, _eh_aliado: bool) -> void:
	var badge: TextureRect = TextureRect.new()
	badge.name = "Badge_" + c_id
	badge.custom_minimum_size = Vector2(36.0, 36.0)
	badge.size = Vector2(36.0, 36.0)
	badge.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	badge.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	badge.texture = tex
	badge.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	badge.position = Vector2(0.0, 2.0)
	track_area.add_child(badge)
	timeline_badges[c_id] = badge


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


static func obter_caminho_background() -> String:
	const P_VILLAGE: String = "res://assets/art/battle_backgrounds/baltazar_village/battle_bg_forge_village.png"
	if ResourceLoader.exists(P_VILLAGE):
		return P_VILLAGE
	const P_JPG: String = "res://assets/art/battle_backgrounds/baltazar_village/battle_bg_forge_village.jpg"
	if ResourceLoader.exists(P_JPG):
		return P_JPG
	const P_FALLBACK: String = "res://assets/art/battle_backgrounds/floresta_miasma/bg_floresta_miasma_completo.png"
	if ResourceLoader.exists(P_FALLBACK):
		return P_FALLBACK
	return ""


static func obter_caminho_foreground() -> String:
	const FG_PATH: String = "res://assets/art/props/battle/battle_fg_signpost_village.png"
	if ResourceLoader.exists(FG_PATH):
		return FG_PATH
	return ""


static func obter_caminho_prop(nome_prop: String) -> String:
	var p1: String = "res://assets/art/props/battle/" + nome_prop
	if ResourceLoader.exists(p1):
		return p1
	var p2: String = "res://assets/art/props/batle/" + nome_prop
	if ResourceLoader.exists(p2):
		return p2
	return ""


func _configurar_texturas_cenario() -> void:
	if arena_background != null and arena_background.texture == null:
		var bg_path: String = obter_caminho_background()
		if not bg_path.is_empty():
			arena_background.texture = load(bg_path) as Texture2D
	if arena_foreground != null and arena_foreground.texture == null:
		var fg_path: String = obter_caminho_foreground()
		if not fg_path.is_empty():
			arena_foreground.texture = load(fg_path) as Texture2D


func _iniciar_pulsacao_cristal() -> void:
	if miasma_crystal_prop == null:
		return
	var tw: Tween = create_tween().set_loops()
	tw.tween_property(miasma_crystal_prop, "modulate:a", 0.85, 1.2).set_trans(Tween.TRANS_SINE)
	tw.tween_property(miasma_crystal_prop, "modulate:a", 1.0, 1.2).set_trans(Tween.TRANS_SINE)


func _obter_posicao_base_aliado(c_id: String, idx: int) -> Vector2:
	if c_id == "lucas" or idx == 0:
		return Vector2(0.0, 0.0)
	if c_id == "davi" or idx == 1:
		return Vector2(160.0, -30.0)
	if idx == 2:
		return Vector2(0.0, -70.0)
	if idx == 3:
		return Vector2(160.0, -90.0)
	return Vector2(160.0 * (idx % 2), -70.0 * int(idx / 2))


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
	sprite.position = _obter_posicao_base_aliado(ally.character_id, idx)
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
	if action_type == "ataque" or action_type == "habilidade":
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


func _mostrar_efeito_interrompido(target_id: String) -> void:
	var sprite: AnimatedSprite2D = _obter_sprite_combatente(target_id)
	if sprite == null:
		return
	_criar_label_flutuante_interrompido(sprite)


func _criar_label_flutuante_interrompido(sprite: AnimatedSprite2D) -> void:
	var lbl: Label = Label.new()
	lbl.text = "INTERROMPIDO!"
	lbl.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3, 1.0))
	lbl.add_theme_font_size_override("font_size", 22)
	lbl.position = sprite.position + Vector2(-60.0, -95.0)
	sprite.get_parent().add_child(lbl)
	var tw: Tween = create_tween()
	tw.tween_property(lbl, "position:y", lbl.position.y - 35.0, 0.8)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.8)
	tw.tween_callback(lbl.queue_free)


func _on_state_changed(_old_state: BattleManager.BattleState, new_state: BattleManager.BattleState) -> void:
	_update_labels(new_state)
	_update_command_panel(new_state)
	if new_state != BattleManager.BattleState.SELECIONANDO_ACAO and skills_panel != null:
		skills_panel.visible = false
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
	_update_timeline_tracker()
	_update_ally_hud()
	_update_enemy_hud()


static func obter_posicao_badge_timeline(progresso: float, largura_trilha: float) -> float:
	return clampf(progresso / 100.0, 0.0, 1.0) * largura_trilha


func _update_timeline_tracker() -> void:
	if track_area == null or battle_manager == null or battle_manager.timeline == null:
		return
	if timeline_badges.is_empty() and not battle_manager.party_members.is_empty():
		_setup_timeline_badges(battle_manager.party_members, battle_manager.enemies)
	var largura: float = maxf(10.0, track_area.size.x - 36.0)
	for c: Dictionary in battle_manager.timeline.combatentes:
		var c_id: String = str(c.get("id", ""))
		if not timeline_badges.has(c_id):
			continue
		var badge: TextureRect = timeline_badges[c_id] as TextureRect
		if badge == null:
			continue
		var pos: float = float(c.get("posicao_tempo", 0.0))
		badge.position.x = obter_posicao_badge_timeline(pos, largura)
		var fase: int = int(c.get("fase_turno", BattleTimeline.FaseTurno.ESPERA))
		if fase == BattleTimeline.FaseTurno.CONJURACAO:
			badge.modulate = Color(0.7, 0.4, 2.2, 1.0)
		else:
			badge.modulate = Color.WHITE


func _update_ally_hud() -> void:
	if battle_manager.party_members.is_empty():
		return
	if battle_manager.party_members.size() > 0:
		_atualizar_painel_aliado(battle_manager.party_members[0], ally_panel, ally_portrait_rect, ally_name_lbl, ally_hp_lbl, ally_mp_lbl, ally_est_lbl, ally_fase_lbl, 0)
	if battle_manager.party_members.size() > 1 and ally2_panel != null:
		ally2_panel.visible = true
		_atualizar_painel_aliado(battle_manager.party_members[1], ally2_panel, ally2_portrait_rect, ally2_name_lbl, ally2_hp_lbl, ally2_mp_lbl, ally2_est_lbl, ally2_fase_lbl, 1)
	elif ally2_panel != null:
		ally2_panel.visible = false


func _atualizar_painel_aliado(hero: CharacterData, panel: Control, p_rect: TextureRect, n_lbl: Label, hp_lbl: Label, mp_lbl: Label, est_lbl: Label, f_lbl: Label, idx: int) -> void:
	if hero == null or panel == null:
		return
	if p_rect != null:
		var tex: Texture2D = _obter_textura_retrato(hero)
		if tex != null and p_rect.texture != tex:
			p_rect.texture = tex
	if n_lbl != null: n_lbl.text = hero.name
	if hp_lbl != null: hp_lbl.text = "PV: %d/%d" % [hero.current_hp, hero.max_hp]
	if mp_lbl != null: mp_lbl.text = "PM: %d/%d" % [hero.pm_atual, hero.pm_max]
	var c_comb: Dictionary = battle_manager.timeline.obter_combatente(hero.character_id) if battle_manager.timeline != null else {}
	var est_val: int = int(c_comb.get("estabilidade_atual", 100))
	if est_lbl != null: est_lbl.text = "Estabilidade: %d/100" % est_val
	if f_lbl != null:
		var pos: float = float(c_comb.get("posicao_tempo", 0.0))
		f_lbl.text = "Fase: %s (%.0f%%)" % [_obter_nome_fase(hero.character_id), pos]
	_atualizar_barras_aliado(panel, hero, est_val)
	var is_acting: bool = (battle_manager.current_state == BattleManager.BattleState.SELECIONANDO_ACAO and battle_manager.active_actor_index == idx)
	panel.modulate = Color(1.3, 1.25, 0.7, 1.0) if is_acting else Color.WHITE


func _atualizar_barras_aliado(panel: Control, hero: CharacterData, est_val: int) -> void:
	var hp_b: ProgressBar = panel.find_child("HPBar", true, false) as ProgressBar
	if hp_b != null:
		hp_b.max_value = hero.max_hp
		hp_b.value = hero.current_hp
	var mp_b: ProgressBar = panel.find_child("MPBar", true, false) as ProgressBar
	if mp_b != null:
		mp_b.max_value = hero.pm_max
		mp_b.value = hero.pm_atual
	var est_b: ProgressBar = panel.find_child("EstBar", true, false) as ProgressBar
	if est_b != null:
		est_b.max_value = 100
		est_b.value = est_val


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
	var cur_hp: int = int(en.get("current_hp", 0))
	var max_hp: int = int(en.get("max_hp", 100))
	var cur_est: int = int(en.get("estabilidade_atual", 100))
	var max_est: int = int(en.get("estabilidade_max", 100))
	if enemy_name_lbl != null: enemy_name_lbl.text = str(en.get("name", "Inimigo"))
	if enemy_hp_lbl != null: enemy_hp_lbl.text = "PV: %d/%d" % [cur_hp, max_hp]
	if enemy_est_lbl != null: enemy_est_lbl.text = "Estabilidade: %d/%d" % [cur_est, max_est]
	_atualizar_barras_inimigo(cur_hp, max_hp, cur_est, max_est)
	if enemy_fase_lbl != null:
		var c_comb: Dictionary = battle_manager.timeline.obter_combatente(str(en.get("id", ""))) if battle_manager.timeline != null else {}
		var pos: float = float(c_comb.get("posicao_tempo", 0.0))
		enemy_fase_lbl.text = "Fase: %s (%.0f%%)" % [_obter_nome_fase(str(en.get("id", ""))), pos]


func _atualizar_barras_inimigo(cur_hp: int, max_hp: int, cur_est: int, max_est: int) -> void:
	if enemy_hp_bar != null:
		enemy_hp_bar.max_value = max_hp
		enemy_hp_bar.value = cur_hp
	if enemy_est_bar != null:
		enemy_est_bar.max_value = max_est
		enemy_est_bar.value = cur_est
	if enemy_ruptura_badge != null:
		enemy_ruptura_badge.visible = (cur_est <= 0)


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
		BattleTimeline.FaseTurno.CONJURACAO:
			var prog: float = float(c.get("progresso_conjuracao", 0.0))
			return "Conjuração (%.0f%%)" % prog
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


func _on_habilidades_pressed() -> void:
	if command_panel != null:
		command_panel.visible = false
	_popular_submenu_habilidades()
	if skills_panel != null:
		skills_panel.visible = true


func _on_voltar_skills_pressed() -> void:
	if skills_panel != null:
		skills_panel.visible = false
	if command_panel != null:
		command_panel.visible = true
	if btn_habilidades != null:
		btn_habilidades.grab_focus()


func _popular_submenu_habilidades() -> void:
	if skill_list == null or battle_manager == null:
		return
	for c: Node in skill_list.get_children():
		c.queue_free()
	var hero: CharacterData = battle_manager.get_active_actor()
	if hero == null:
		return
	var skills: Array[SkillData] = hero.obter_habilidades()
	for sk: SkillData in skills:
		_criar_botao_habilidade(sk, hero)


func _criar_botao_habilidade(sk: SkillData, hero: CharacterData) -> void:
	var btn: Button = Button.new()
	btn.custom_minimum_size = Vector2(0, 38)
	btn.text = "%s (%d PM)" % [sk.nome, sk.custo_pm]
	var pode_usar: bool = hero.tem_pm(sk.custo_pm)
	btn.disabled = not pode_usar
	if not pode_usar:
		btn.modulate = Color(0.6, 0.6, 0.6, 0.7)
	btn.pressed.connect(func(): _on_skill_clicked(sk))
	skill_list.add_child(btn)


func _on_skill_clicked(sk: SkillData) -> void:
	if battle_manager == null or battle_manager.enemies.is_empty():
		return
	if skills_panel != null:
		skills_panel.visible = false
	var hero: CharacterData = battle_manager.get_active_actor()
	var enemy: Dictionary = battle_manager.enemies[0]
	battle_manager.executar_habilidade(hero, sk, enemy)
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
	if event.is_action_pressed("ui_cancel"):
		if skills_panel != null and skills_panel.visible:
			_on_voltar_skills_pressed()
		elif command_panel != null and command_panel.visible:
			if btn_atacar != null:
				btn_atacar.grab_focus()
