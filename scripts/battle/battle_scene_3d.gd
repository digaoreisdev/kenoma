class_name BattleScene3D
extends Node3D

## Cena de batalha HD-2D 3D na praça medieval da Vila do Baltazar com pátio 3D completo (escadaria e fonte visíveis) e 3 combatentes (Lucas, Davi e General Cassian).

const CAMINHO_CASSIAN_FRAMES: String = "res://autosprite_imported/General_Cassian1/General_Cassian1_frames.tres"
const CAMINHO_BG_VILA: String = "res://assets/art/battle_backgrounds/baltazar_village/battle_bg_forge_village.png"
const TATICAS: Array[String] = ["LINHA_2X2", "LOSANGO", "VANGUARDA_3X1", "RETAGUARDA_1X3", "MEIA_LUA"]

@export var terrain: ArenaTerrain = null
@export var layout_cenario: BattleSceneLayout = null

var terrain_visual: ArenaTerrainVisual = null
var camera_3d: Camera3D = null
var container_herois: Node3D = null
var container_inimigos: Node3D = null
var label_info: Label = null
var herois_sprites: Array[AnimatedSprite3D] = []
var inimigos_sprites: Array[AnimatedSprite3D] = []
var indice_tatica: int = 0
var indice_camera: int = 0
var _em_animacao_ataque: bool = false


func _ready() -> void:
	_inicializar_recursos()
	_montar_ambiente_e_luz()
	_montar_terreno_e_construcoes()
	_instanciar_equipe_3d()
	_instanciar_inimigos_3d()
	_criar_hud_instrucoes()
	_atualizar_texto_hud()


func _inicializar_recursos() -> void:
	if terrain == null:
		terrain = load("res://resources/battle_layouts/arena_terrain_exemplo.tres") as ArenaTerrain
	if terrain == null:
		terrain = ArenaTerrain.new()
	if layout_cenario == null:
		layout_cenario = load("res://resources/battle_layouts/layout_vila_forja.tres") as BattleSceneLayout
	if layout_cenario == null:
		layout_cenario = BattleSceneLayout.new()


func _montar_ambiente_e_luz() -> void:
	var env_node: WorldEnvironment = WorldEnvironment.new()
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.88, 0.62, 0.42)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.95, 0.82, 0.68)
	env.ambient_light_energy = 0.82
	env_node.environment = env
	add_child(env_node)
	_criar_luz_sol_e_camera()


func _criar_luz_sol_e_camera() -> void:
	var sol: DirectionalLight3D = DirectionalLight3D.new()
	sol.name = "LuzSolPoente"
	sol.light_color = Color(1.0, 0.88, 0.72)
	sol.light_energy = 1.35
	sol.shadow_enabled = true
	sol.rotation_degrees = Vector3(-42.0, -35.0, 0.0)
	add_child(sol)
	camera_3d = Camera3D.new()
	camera_3d.name = "Camera3D"
	camera_3d.fov = 45.0
	camera_3d.current = true
	add_child(camera_3d)
	_aplicar_preset_camera(0, false)


func _montar_terreno_e_construcoes() -> void:
	terrain_visual = ArenaTerrainVisual.new()
	terrain_visual.name = "ArenaTerrainVisual"
	terrain_visual.terrain = terrain
	add_child(terrain_visual)
	terrain_visual.construir_terreno(terrain)
	_instanciar_fundo_vila_baltazar()


func _instanciar_fundo_vila_baltazar() -> void:
	if not ResourceLoader.exists(CAMINHO_BG_VILA):
		return
	var tex_vila: Texture2D = load(CAMINHO_BG_VILA) as Texture2D
	if tex_vila == null:
		return
	var telao_vila: Sprite3D = Sprite3D.new()
	telao_vila.name = "FundoVilaBaltazar"
	telao_vila.texture = tex_vila
	telao_vila.region_enabled = true
	telao_vila.region_rect = Rect2(0.0, 0.0, 1920.0, 620.0)
	telao_vila.pixel_size = 0.016
	telao_vila.shaded = false
	telao_vila.position = Vector3(0.0, 5.6, -6.7)
	add_child(telao_vila)


func _instanciar_equipe_3d() -> void:
	container_herois = Node3D.new()
	container_herois.name = "PartyContainer3D"
	add_child(container_herois)
	var herois: Array[CharacterData] = [
		CharacterData.create_default_lucas(),
		CharacterData.create_default_davi()
	]
	var tatica_atual: String = TATICAS[indice_tatica]
	for i: int in range(herois.size()):
		var uv: Vector2 = _obter_uv_aliado(i, tatica_atual)
		var frames: SpriteFrames = _obter_frames_heroi(herois[i])
		var sp: AnimatedSprite3D = _criar_combatente_sprite3d(herois[i].character_id, frames, false)
		container_herois.add_child(sp)
		posicionar_sprite_no_terreno(sp, uv.x, uv.y)
		herois_sprites.append(sp)


func _obter_frames_heroi(dados: CharacterData) -> SpriteFrames:
	if dados != null and dados.sprite_frames != null:
		return dados.sprite_frames
	var id_c: String = dados.character_id if dados != null else "lucas"
	var caminho: String = "res://assets/art/characters/player/player_frames.tres"
	if id_c == "davi" or id_c == "dai":
		caminho = "res://assets/sprites/characters/davi/Davi_Reis_frames.tres"
	return load(caminho) as SpriteFrames if ResourceLoader.exists(caminho) else null


func _instanciar_inimigos_3d() -> void:
	container_inimigos = Node3D.new()
	container_inimigos.name = "EnemyContainer3D"
	add_child(container_inimigos)
	var frames_cassian: SpriteFrames = load(CAMINHO_CASSIAN_FRAMES) as SpriteFrames
	var sp: AnimatedSprite3D = _criar_combatente_sprite3d("general_cassian", frames_cassian, true)
	container_inimigos.add_child(sp)
	var uv: Vector2 = _obter_uv_inimigo(0)
	posicionar_sprite_no_terreno(sp, uv.x, uv.y)
	inimigos_sprites.append(sp)


func _criar_combatente_sprite3d(id_comb: String, frames: SpriteFrames, is_boss: bool) -> AnimatedSprite3D:
	var sp: AnimatedSprite3D = AnimatedSprite3D.new()
	sp.name = id_comb
	sp.sprite_frames = frames
	sp.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	sp.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	sp.shaded = true
	sp.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	sp.set_meta("id_comb", id_comb)
	sp.set_meta("is_boss", is_boss)
	var anim: String = _escolher_anim_idle(frames, id_comb)
	if frames != null and frames.has_animation(anim):
		sp.play(anim)
	_calibrar_pivo_e_tamanho_3d(sp, is_boss)
	return sp


func _escolher_anim_idle(frames: SpriteFrames, id_comb: String) -> String:
	if frames == null:
		return "default"
	var candidatos: Array[String] = ["idle_down_left", "idle_left", "idle_down"]
	if id_comb == "davi":
		candidatos = ["Idle Southwest_right", "Idle Left_right", "iso_idle_down_right"]
	elif id_comb == "general_cassian" or id_comb.begins_with("inimigo"):
		candidatos = ["iso_idle_southeast_right", "iso_idle_right_right", "iso_idle_down_right", "Idle Left_right"]
	for c: String in candidatos:
		if frames.has_animation(c):
			return c
	var nomes: PackedStringArray = frames.get_animation_names()
	return nomes[0] if not nomes.is_empty() else "default"


func _escolher_anim_ataque(frames: SpriteFrames, id_comb: String) -> String:
	if frames == null:
		return "default"
	var candidatos: Array[String] = ["attack_axe_down_left", "attack_axe_left"]
	if id_comb == "davi":
		candidatos = ["Cast Southwest_right", "Cast Left_right"]
	elif id_comb == "general_cassian" or id_comb.begins_with("inimigo"):
		candidatos = ["Attack Southeast_right", "Attack Right_right", "Attack Down_right"]
	for c: String in candidatos:
		if frames.has_animation(c):
			return c
	return _escolher_anim_idle(frames, id_comb)


func _calibrar_pivo_e_tamanho_3d(sp: AnimatedSprite3D, is_boss: bool) -> void:
	var frames: SpriteFrames = sp.sprite_frames
	if frames == null or not frames.has_animation(sp.animation):
		sp.pixel_size = 0.01
		return
	var tex: Texture2D = frames.get_frame_texture(sp.animation, 0)
	var img: Image = tex.get_image() if tex != null else null
	if img == null or img.is_empty():
		sp.pixel_size = 0.01
		return
	var rect: Rect2i = img.get_used_rect()
	var altura_visivel: float = maxf(float(rect.size.y), 32.0)
	var altura_alvo_m: float = 2.25 if is_boss else 1.85
	sp.pixel_size = altura_alvo_m / altura_visivel
	var base_y: float = float(rect.end.y)
	var centro_y: float = float(img.get_height()) * 0.5
	sp.offset = Vector2(0.0, base_y - centro_y)


func posicionar_sprite_no_terreno(sp: SpriteBase3D, u: float, v: float) -> Vector3:
	assert(sp != null and terrain != null, "Sprite3D e ArenaTerrain obrigatórios")
	var pos_mundo: Vector3 = terrain.normalizado_para_mundo(u, v)
	sp.position = pos_mundo
	sp.set_meta("uv_atual", Vector2(u, v))
	return pos_mundo


func _obter_uv_aliado(slot_idx: int, tatica: String) -> Vector2:
	var slots: Array = layout_cenario.formacoes_aliados.get(tatica, layout_cenario.formacoes_aliados.get("LINHA_2X2", []))
	var pt: Vector2 = slots[slot_idx] as Vector2 if slot_idx < slots.size() else Vector2(0.68, 0.72)
	var u: float = clampf(0.56 + (pt.x - 0.64) * 1.1, 0.54, 0.74)
	var v: float = clampf(0.45 + (pt.y - 0.64) * 1.4, 0.40, 0.76)
	return Vector2(u, v)


func _obter_uv_inimigo(slot_idx: int) -> Vector2:
	var lista: Array[Vector2] = layout_cenario.posicoes_monstros_padrao
	var pt: Vector2 = lista[slot_idx] if slot_idx < lista.size() else Vector2(0.24, 0.72)
	var u: float = clampf(pt.x + 0.02, 0.20, 0.42)
	var v: float = clampf(0.45 + (pt.y - 0.64) * 1.3, 0.40, 0.75)
	return Vector2(u, v)


func _criar_hud_instrucoes() -> void:
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.name = "HUD3D"
	canvas.layer = 20
	add_child(canvas)
	var painel: PanelContainer = PanelContainer.new()
	painel.position = Vector2(32.0, 24.0)
	canvas.add_child(painel)
	label_info = Label.new()
	label_info.set("theme_override_font_sizes/font_size", 20)
	label_info.modulate = Color(1.0, 0.96, 0.85)
	painel.add_child(label_info)


func _atualizar_texto_hud() -> void:
	if label_info == null:
		return
	var nomes_cam: Array[String] = ["Panorâmica Pátio Completo", "Close Vanguarda", "Tática Aérea", "Diagonal Dramática"]
	var tatica: String = TATICAS[indice_tatica]
	var cam_nome: String = nomes_cam[indice_camera % nomes_cam.size()]
	label_info.text = "ARENA 3D HD-2D - PÁTIO DA VILA DO BALTAZAR\nFormação [Setas ←/→]: %s  |  Câmera [Setas ↑/↓]: %s\n[Espaço/Enter]: Testar Ataque (Lucas + Espada do General)  |  [F5]: Voltar para Arena 2D" % [tatica, cam_nome]


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var ev_key: InputEventKey = event as InputEventKey
	if ev_key.keycode == KEY_RIGHT or ev_key.keycode == KEY_D:
		alternar_formacao_3d(1)
	elif ev_key.keycode == KEY_LEFT or ev_key.keycode == KEY_A:
		alternar_formacao_3d(-1)
	elif ev_key.keycode == KEY_UP or ev_key.keycode == KEY_W:
		_aplicar_preset_camera(indice_camera + 1, true)
	elif ev_key.keycode == KEY_DOWN or ev_key.keycode == KEY_S:
		_aplicar_preset_camera(indice_camera - 1, true)
	elif ev_key.keycode == KEY_SPACE or ev_key.keycode == KEY_ENTER:
		_executar_demo_investida_3d()
	elif ev_key.keycode == KEY_F5:
		get_tree().change_scene_to_file("res://scenes/battle/battle_scene.tscn")


func alternar_formacao_3d(delta: int) -> void:
	indice_tatica = posmod(indice_tatica + delta, TATICAS.size())
	var tatica: String = TATICAS[indice_tatica]
	for i: int in range(herois_sprites.size()):
		var uv: Vector2 = _obter_uv_aliado(i, tatica)
		var alvo: Vector3 = terrain.normalizado_para_mundo(uv.x, uv.y)
		herois_sprites[i].set_meta("uv_atual", uv)
		var tw: Tween = create_tween()
		tw.tween_property(herois_sprites[i], "position", alvo, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_atualizar_texto_hud()


func _aplicar_preset_camera(novo_indice: int, animar: bool) -> void:
	var posicoes: Array[Vector3] = [
		Vector3(0.0, 9.2, 16.5),
		Vector3(2.5, 5.2, 11.5),
		Vector3(0.0, 14.5, 12.2),
		Vector3(-5.2, 6.4, 13.5)
	]
	var rotacoes: Array[Vector3] = [
		Vector3(-27.5, 0.0, 0.0),
		Vector3(-19.0, 11.0, 0.0),
		Vector3(-48.0, 0.0, 0.0),
		Vector3(-22.0, -18.0, 0.0)
	]
	indice_camera = posmod(novo_indice, posicoes.size())
	if not animar:
		camera_3d.position = posicoes[indice_camera]
		camera_3d.rotation_degrees = rotacoes[indice_camera]
	else:
		var tw: Tween = create_tween().set_parallel(true)
		tw.tween_property(camera_3d, "position", posicoes[indice_camera], 0.45).set_trans(Tween.TRANS_CUBIC)
		tw.tween_property(camera_3d, "rotation_degrees", rotacoes[indice_camera], 0.45).set_trans(Tween.TRANS_CUBIC)
	_atualizar_texto_hud()


func _tocar_anim_combatente_3d(sp: AnimatedSprite3D, anim: String) -> void:
	if sp == null or sp.sprite_frames == null or not sp.sprite_frames.has_animation(anim):
		return
	sp.play(anim)
	_calibrar_pivo_e_tamanho_3d(sp, bool(sp.get_meta("is_boss", false)))


func _executar_demo_investida_3d() -> void:
	if _em_animacao_ataque or herois_sprites.is_empty() or inimigos_sprites.is_empty():
		return
	_em_animacao_ataque = true
	var lucas: AnimatedSprite3D = herois_sprites[0]
	var cassian: AnimatedSprite3D = inimigos_sprites[0]
	var orig_lucas: Vector3 = lucas.position
	var orig_cassian: Vector3 = cassian.position
	var anim_atk_lucas: String = _escolher_anim_ataque(lucas.sprite_frames, "lucas")
	var anim_idle_lucas: String = _escolher_anim_idle(lucas.sprite_frames, "lucas")
	var anim_atk_cassian: String = _escolher_anim_ataque(cassian.sprite_frames, "general_cassian")
	var anim_idle_cassian: String = _escolher_anim_idle(cassian.sprite_frames, "general_cassian")
	var tw: Tween = create_tween()
	tw.tween_property(lucas, "position", orig_cassian + Vector3(1.3, 0.0, 0.0), 0.30).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func() -> void: _tocar_anim_combatente_3d(lucas, anim_atk_lucas))
	tw.tween_interval(0.45)
	tw.tween_callback(func() -> void: _tocar_anim_combatente_3d(lucas, anim_idle_lucas))
	tw.tween_property(lucas, "position", orig_lucas, 0.30).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(cassian, "position", orig_lucas + Vector3(-1.3, 0.0, 0.0), 0.30).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func() -> void: _tocar_anim_combatente_3d(cassian, anim_atk_cassian))
	tw.tween_interval(0.55)
	tw.tween_callback(func() -> void: _tocar_anim_combatente_3d(cassian, anim_idle_cassian))
	tw.tween_property(cassian, "position", orig_cassian, 0.30).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.finished.connect(func() -> void: _em_animacao_ataque = false)
