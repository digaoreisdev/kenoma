@tool
class_name BattleScene3D
extends Node3D

## Cena 3D isolada com o pátio original do Meshy (patio_vila_baltazar.glb), os 3 combatentes e movimentações de câmera.

const CAMINHO_CASSIAN_FRAMES: String = "res://autosprite_imported/General_Cassian1/General_Cassian1_frames.tres"
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
var _orbit_angles: Vector2 = Vector2(0.0, deg_to_rad(18.0))
var _orbit_dist: float = 13.0
var _orbit_center: Vector3 = Vector3(0.0, 0.8, 0.0)
var _arrastando_mouse: bool = false


func _ready() -> void:
	_inicializar_recursos()
	_montar_ambiente_e_luz()
	_montar_terreno_isolado()
	_limpar_elementos_cenario_antigo()
	_instanciar_equipe_3d()
	_instanciar_inimigos_3d()
	if not Engine.is_editor_hint():
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
	var env_node: WorldEnvironment = get_node_or_null("AmbienteVilaBaltazar") as WorldEnvironment
	if env_node == null:
		env_node = WorldEnvironment.new()
		env_node.name = "AmbienteVilaBaltazar"
		add_child(env_node)
	env_node.environment = _criar_environment_limpo()
	_criar_luz_sol_e_camera()


func _criar_environment_limpo() -> Environment:
	var env: Environment = Environment.new()
	var sky: Sky = Sky.new()
	var sky_mat: ProceduralSkyMaterial = ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.55, 0.68, 0.82)
	sky_mat.sky_horizon_color = Color(0.85, 0.88, 0.92)
	sky_mat.ground_horizon_color = Color(0.70, 0.72, 0.74)
	sky_mat.ground_bottom_color = Color(0.40, 0.42, 0.44)
	sky.sky_material = sky_mat
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.88, 0.88, 0.90)
	env.ambient_light_energy = 0.95
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	return env


func _criar_luz_sol_e_camera() -> void:
	var sol: DirectionalLight3D = get_node_or_null("LuzSolPoente") as DirectionalLight3D
	if sol == null:
		sol = DirectionalLight3D.new()
		sol.name = "LuzSolPoente"
		add_child(sol)
	sol.light_color = Color(1.0, 0.95, 0.88)
	sol.light_energy = 1.35
	sol.shadow_enabled = true
	sol.rotation_degrees = Vector3(-42.0, -35.0, 0.0)
	camera_3d = get_node_or_null("Camera3D") as Camera3D
	if camera_3d == null:
		camera_3d = Camera3D.new()
		camera_3d.name = "Camera3D"
		camera_3d.fov = 44.0
		camera_3d.current = true
		add_child(camera_3d)
	_aplicar_preset_camera(0, false)


func _montar_terreno_isolado() -> void:
	terrain_visual = get_node_or_null("ArenaTerrainVisual") as ArenaTerrainVisual
	if terrain_visual == null:
		terrain_visual = ArenaTerrainVisual.new()
		terrain_visual.name = "ArenaTerrainVisual"
		terrain_visual.terrain = terrain
		add_child(terrain_visual)
	terrain_visual.construir_terreno(terrain)


func _limpar_elementos_cenario_antigo() -> void:
	var antigos: Array[String] = [
		"CasaLateralVila", "CasaPrincipalVila", "ForjaVilaBaltazar",
		"CasaVilaFundo1", "CasaVilaFundo2", "VegetacaoVilaHD2D",
		"HorizonteMontanhasPoente", "MolduraPrimeiroPlano3D",
		"LuzFornalhaBaltazar", "FogoFornalha3D"
	]
	for nome: String in antigos:
		var no: Node = get_node_or_null(nome)
		if no != null:
			no.queue_free()


func _instanciar_equipe_3d() -> void:
	herois_sprites.clear()
	container_herois = get_node_or_null("PartyContainer3D") as Node3D
	if container_herois == null:
		container_herois = Node3D.new()
		container_herois.name = "PartyContainer3D"
		add_child(container_herois)
	var herois: Array[CharacterData] = [
		CharacterData.create_default_lucas(),
		CharacterData.create_default_davi()
	]
	for i: int in range(herois.size()):
		var id_c: String = herois[i].character_id
		var sp: AnimatedSprite3D = container_herois.get_node_or_null(id_c) as AnimatedSprite3D
		if sp == null:
			var frames: SpriteFrames = _obter_frames_heroi(herois[i])
			sp = _criar_combatente_sprite3d(id_c, frames, false)
			container_herois.add_child(sp)
		else:
			_garantir_anim_combatente(sp, _obter_frames_heroi(herois[i]), id_c, false)
		_posicionar_combatente_padrao(sp, id_c)
		herois_sprites.append(sp)


func _obter_frames_heroi(dados: CharacterData) -> SpriteFrames:
	if dados != null and dados.sprite_frames != null:
		return dados.sprite_frames
	var id_c: String = dados.character_id if dados != null else "lucas"
	var caminho: String = "res://assets/art/characters/heroes/lucas/player_frames.tres"
	if id_c == "davi" or id_c == "dai":
		caminho = "res://assets/art/characters/heroes/davi/Davi_Reis_frames.tres"
	return load(caminho) as SpriteFrames if ResourceLoader.exists(caminho) else null


func _instanciar_inimigos_3d() -> void:
	inimigos_sprites.clear()
	container_inimigos = get_node_or_null("EnemyContainer3D") as Node3D
	if container_inimigos == null:
		container_inimigos = Node3D.new()
		container_inimigos.name = "EnemyContainer3D"
		add_child(container_inimigos)
	var frames_cassian: SpriteFrames = load(CAMINHO_CASSIAN_FRAMES) as SpriteFrames
	var sp: AnimatedSprite3D = container_inimigos.get_node_or_null("general_cassian") as AnimatedSprite3D
	if sp == null:
		sp = _criar_combatente_sprite3d("general_cassian", frames_cassian, true)
		container_inimigos.add_child(sp)
	else:
		_garantir_anim_combatente(sp, frames_cassian, "general_cassian", true)
	_posicionar_combatente_padrao(sp, "general_cassian")
	inimigos_sprites.append(sp)


func _posicionar_combatente_padrao(sp: AnimatedSprite3D, id_c: String) -> void:
	if id_c == "general_cassian":
		sp.position = Vector3(-4.5, 0.0, 0.2)
	elif id_c == "lucas":
		sp.position = Vector3(3.5, 0.0, -0.4)
	elif id_c == "davi":
		sp.position = Vector3(4.5, 0.0, 1.4)


func _garantir_anim_combatente(sp: AnimatedSprite3D, frames: SpriteFrames, id_comb: String, is_boss: bool) -> void:
	if sp.sprite_frames == null:
		sp.sprite_frames = frames
	sp.set_meta("id_comb", id_comb)
	sp.set_meta("is_boss", is_boss)
	var anim: String = _escolher_anim_idle(sp.sprite_frames, id_comb)
	if sp.sprite_frames != null and sp.sprite_frames.has_animation(anim):
		sp.play(anim)
	_calibrar_pivo_e_tamanho_3d(sp, is_boss)


func _criar_combatente_sprite3d(id_comb: String, frames: SpriteFrames, is_boss: bool) -> AnimatedSprite3D:
	var sp: AnimatedSprite3D = AnimatedSprite3D.new()
	sp.name = id_comb
	sp.sprite_frames = frames
	sp.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	sp.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	sp.shaded = true
	sp.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	_garantir_anim_combatente(sp, frames, id_comb, is_boss)
	return sp


func _escolher_anim_idle(frames: SpriteFrames, id_comb: String) -> String:
	if frames == null:
		return "default"
	var candidatos: Array[String] = ["idle_down_left", "idle_left", "idle_down"]
	if id_comb == "davi":
		candidatos = ["Idle Southwest_right", "Idle Left_right", "Idle West_right"]
	elif id_comb == "general_cassian":
		candidatos = ["iso_idle_southeast_right", "iso_idle_right_right", "Idle Southeast_right"]
	for c: String in candidatos:
		if frames.has_animation(c):
			return c
	var nomes: PackedStringArray = frames.get_animation_names()
	return nomes[0] if not nomes.is_empty() else "default"


func _escolher_anim_ataque(frames: SpriteFrames, id_comb: String) -> String:
	if frames == null:
		return "default"
	var candidatos: Array[String] = ["attack_left", "attack_down_left"]
	if id_comb == "davi":
		candidatos = ["Punch Southwest_right", "Punch Left_right"]
	elif id_comb == "general_cassian":
		candidatos = ["Attack Southeast_right", "Attack Right_right"]
	for c: String in candidatos:
		if frames.has_animation(c):
			return c
	return _escolher_anim_idle(frames, id_comb)


func _calibrar_pivo_e_tamanho_3d(sp: AnimatedSprite3D, is_boss: bool) -> void:
	var tex: Texture2D = null
	if sp.sprite_frames != null and sp.sprite_frames.has_animation(sp.animation):
		tex = sp.sprite_frames.get_frame_texture(sp.animation, 0)
	var h_tex: float = float(tex.get_height()) if tex != null else 300.0
	var w_tex: float = float(tex.get_width()) if tex != null else 200.0
	sp.centered = false
	sp.offset = Vector2(-w_tex * 0.5, 0.0)
	var alvo_metros: float = 1.85 if is_boss else 1.65
	sp.pixel_size = alvo_metros / maxf(32.0, h_tex)


func aplicar_formacao_3d(nome_tatica: String, animar: bool = true) -> void:
	var pos_lucas: Vector3 = Vector3(3.5, 0.0, -0.4)
	var pos_davi: Vector3 = Vector3(4.5, 0.0, 1.4)
	if nome_tatica == "LOSANGO":
		pos_lucas = Vector3(3.2, 0.0, 0.0)
		pos_davi = Vector3(4.8, 0.0, 0.0)
	elif nome_tatica == "VANGUARDA_3X1":
		pos_lucas = Vector3(2.8, 0.0, 0.2)
		pos_davi = Vector3(5.0, 0.0, 1.0)
	_mover_heroi(0, pos_lucas, animar)
	_mover_heroi(1, pos_davi, animar)


func _mover_heroi(idx: int, pos: Vector3, animar: bool) -> void:
	if idx < 0 or idx >= herois_sprites.size():
		return
	var sp: AnimatedSprite3D = herois_sprites[idx]
	if animar and is_inside_tree():
		create_tween().tween_property(sp, "position", pos, 0.25).set_trans(Tween.TRANS_QUAD)
	else:
		sp.position = pos


func _aplicar_preset_camera(indice: int, animar: bool = true) -> void:
	indice_camera = posmod(indice, 4)
	if indice_camera == 0:
		_orbit_center = Vector3(0.0, 0.8, 0.0)
		_orbit_angles = Vector2(0.0, deg_to_rad(18.0))
		_orbit_dist = 13.0
	elif indice_camera == 1:
		_orbit_center = Vector3(-4.5, 1.0, 0.2)
		_orbit_angles = Vector2(deg_to_rad(-24.0), deg_to_rad(14.0))
		_orbit_dist = 6.8
	elif indice_camera == 2:
		_orbit_center = Vector3(4.0, 1.0, 0.5)
		_orbit_angles = Vector2(deg_to_rad(24.0), deg_to_rad(14.0))
		_orbit_dist = 6.8
	elif indice_camera == 3:
		_orbit_center = Vector3(0.0, 0.0, 0.0)
		_orbit_angles = Vector2(0.0, deg_to_rad(48.0))
		_orbit_dist = 14.5
	_atualizar_posicao_camera(animar)


func _atualizar_posicao_camera(animar: bool) -> void:
	if camera_3d == null:
		return
	var offset: Vector3 = Vector3(
		_orbit_dist * cos(_orbit_angles.y) * sin(_orbit_angles.x),
		_orbit_dist * sin(_orbit_angles.y),
		_orbit_dist * cos(_orbit_angles.y) * cos(_orbit_angles.x)
	)
	var pos_cam: Vector3 = _orbit_center + offset
	var dir: Vector3 = (_orbit_center - pos_cam).normalized()
	var tr_alvo: Transform3D = Transform3D(Basis.looking_at(dir, Vector3.UP), pos_cam)
	if animar and is_inside_tree():
		create_tween().tween_property(camera_3d, "transform", tr_alvo, 0.35).set_trans(Tween.TRANS_CUBIC)
	else:
		camera_3d.transform = tr_alvo


func executar_investida_exemplo() -> void:
	if _em_animacao_ataque or herois_sprites.is_empty() or inimigos_sprites.is_empty():
		return
	var atacante: AnimatedSprite3D = herois_sprites[0]
	var alvo: AnimatedSprite3D = inimigos_sprites[0]
	var pos_origem: Vector3 = atacante.position
	var pos_impacto: Vector3 = alvo.position + Vector3(1.3, 0.0, 0.0)
	var anim_atk_h: String = _escolher_anim_ataque(atacante.sprite_frames, "lucas")
	var anim_idle_h: String = _escolher_anim_idle(atacante.sprite_frames, "lucas")
	var anim_atk_i: String = _escolher_anim_ataque(alvo.sprite_frames, "general_cassian")
	var anim_idle_i: String = _escolher_anim_idle(alvo.sprite_frames, "general_cassian")
	_em_animacao_ataque = true
	var tw: Tween = create_tween()
	tw.tween_property(atacante, "position", pos_impacto, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func() -> void: atacante.play(anim_atk_h))
	tw.tween_property(alvo, "modulate", Color(1.0, 0.3, 0.3), 0.12)
	tw.tween_property(alvo, "modulate", Color.WHITE, 0.12)
	tw.tween_callback(func() -> void: alvo.play(anim_atk_i))
	tw.tween_interval(0.40)
	tw.tween_callback(func() -> void:
		alvo.play(anim_idle_i)
		atacante.play(anim_idle_h)
	)
	tw.tween_property(atacante, "position", pos_origem, 0.25).set_trans(Tween.TRANS_QUAD)
	tw.tween_callback(func() -> void: _em_animacao_ataque = false)


func _criar_hud_instrucoes() -> void:
	if get_node_or_null("HUD3D") != null:
		return
	var camada: CanvasLayer = CanvasLayer.new()
	camada.name = "HUD3D"
	add_child(camada)
	var painel: PanelContainer = PanelContainer.new()
	painel.position = Vector2(20.0, 18.0)
	var estilo: StyleBoxFlat = StyleBoxFlat.new()
	estilo.bg_color = Color(0.08, 0.06, 0.05, 0.82)
	estilo.set_corner_radius_all(6)
	estilo.content_margin_left = 14.0
	estilo.content_margin_right = 14.0
	estilo.content_margin_top = 10.0
	estilo.content_margin_bottom = 10.0
	painel.add_theme_stylebox_override("panel", estilo)
	camada.add_child(painel)
	label_info = Label.new()
	label_info.add_theme_font_size_override("font_size", 16)
	label_info.add_theme_color_override("font_color", Color(0.96, 0.92, 0.82))
	painel.add_child(label_info)


func _atualizar_texto_hud() -> void:
	if label_info == null:
		return
	var nomes_cam: Array[String] = [
		"Visão Panorâmica Pátio", "Foco no General Cassian",
		"Foco nos Heróis", "Visão Tática Aérea"
	]
	label_info.text = (
		"PÁTIO 3D ISOLADO - VILA DO BALTAZAR\n"
		+ "Câmera [Setas ↑/↓ ou Botão Direito Mouse]: %s  |  Formação [Setas ←/→]: %s\n" % [nomes_cam[indice_camera], TATICAS[indice_tatica]]
		+ "[Espaço/Enter]: Testar Ataque  |  [F5]: Arena 2D  |  [F7]: Reset Câmera"
	)


func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if event is InputEventMouseButton:
		_processar_input_mouse_botao(event as InputEventMouseButton)
	elif event is InputEventMouseMotion:
		_processar_input_mouse_movimento(event as InputEventMouseMotion)
	elif event.is_action_pressed("ui_up"):
		_aplicar_preset_camera(indice_camera + 1, true)
		_atualizar_texto_hud()
	elif event.is_action_pressed("ui_down"):
		_aplicar_preset_camera(indice_camera - 1, true)
		_atualizar_texto_hud()
	elif event.is_action_pressed("ui_right"):
		indice_tatica = posmod(indice_tatica + 1, TATICAS.size())
		aplicar_formacao_3d(TATICAS[indice_tatica], true)
		_atualizar_texto_hud()
	elif event.is_action_pressed("ui_left"):
		indice_tatica = posmod(indice_tatica - 1, TATICAS.size())
		aplicar_formacao_3d(TATICAS[indice_tatica], true)
		_atualizar_texto_hud()
	elif event.is_action_pressed("ui_accept"):
		executar_investida_exemplo()
	elif event is InputEventKey:
		_processar_input_tecla(event as InputEventKey)


func _processar_input_mouse_botao(mb: InputEventMouseButton) -> void:
	if mb.button_index == MOUSE_BUTTON_RIGHT:
		_arrastando_mouse = mb.pressed
	elif mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
		_orbit_dist = clampf(_orbit_dist - 0.8, 3.5, 25.0)
		_atualizar_posicao_camera(false)
	elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
		_orbit_dist = clampf(_orbit_dist + 0.8, 3.5, 25.0)
		_atualizar_posicao_camera(false)


func _processar_input_mouse_movimento(mm: InputEventMouseMotion) -> void:
	if not _arrastando_mouse:
		return
	_orbit_angles.x -= mm.relative.x * 0.006
	_orbit_angles.y = clampf(_orbit_angles.y + mm.relative.y * 0.006, deg_to_rad(4.0), deg_to_rad(82.0))
	_atualizar_posicao_camera(false)


func _processar_input_tecla(k: InputEventKey) -> void:
	if not k.pressed or k.echo:
		return
	if k.keycode == KEY_F5:
		get_tree().change_scene_to_file("res://scenes/battle/battle_scene.tscn")
	elif k.keycode == KEY_F7:
		_aplicar_preset_camera(0, true)
		_atualizar_texto_hud()
