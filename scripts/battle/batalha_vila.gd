@tool
class_name BatalhaVila
extends Node3D

## Cena 3D de Batalha na Vila com Terreno Procedural (BatalhaVila.tscn).
## Utiliza TerrenoBatalha, câmera perspectiva em FOV 30, sol dourado e sprites proporcionais.

const CAMINHO_CASSIAN_FRAMES: String = "res://autosprite_imported/General_Cassian1/General_Cassian1_frames.tres"
const CAMINHO_LUCAS_FRAMES: String = "res://assets/art/characters/heroes/lucas/player_frames.tres"
const CAMINHO_DAVI_FRAMES: String = "res://assets/art/characters/heroes/davi/Davi_Reis_frames.tres"
const TATICAS: Array[String] = ["LINHA_2X2", "LOSANGO", "VANGUARDA_3X1", "RETAGUARDA_1X3"]

var terreno: TerrenoBatalha = null
var camera_3d: Camera3D = null
var luz_sol: DirectionalLight3D = null
var ambiente: WorldEnvironment = null
var container_herois: Node3D = null
var container_inimigos: Node3D = null
var label_info: Label = null

var herois_sprites: Array[AnimatedSprite3D] = []
var inimigos_sprites: Array[AnimatedSprite3D] = []
var indice_camera: int = 0
var indice_tatica: int = 0
var _em_ataque: bool = false
var _arrastando_mouse: bool = false
var _orbit_angles: Vector2 = Vector2(0.0, deg_to_rad(28.0))
var _orbit_dist: float = 21.0
var _orbit_center: Vector3 = Vector3(0.0, 1.2, 3.5)


func _ready() -> void:
	_garantir_terreno()
	_garantir_iluminacao_e_ambiente()
	_garantir_camera()
	_instanciar_combatentes()
	if not Engine.is_editor_hint():
		_criar_hud()
		_atualizar_hud()


func _garantir_terreno() -> void:
	terreno = get_node_or_null("Terreno") as TerrenoBatalha
	if terreno == null:
		terreno = TerrenoBatalha.new()
		terreno.name = "Terreno"
		add_child(terreno)
	const P_CHAO: String = "res://assets/art/battle_backgrounds/baltazar_village/chao_rustico_vila.png"
	if ResourceLoader.exists(P_CHAO) and terreno.tex_estrada == null:
		terreno.tex_estrada = load(P_CHAO) as Texture2D


func _garantir_iluminacao_e_ambiente() -> void:
	luz_sol = get_node_or_null("DirectionalLight3D") as DirectionalLight3D
	if luz_sol == null:
		luz_sol = DirectionalLight3D.new()
		luz_sol.name = "DirectionalLight3D"
		add_child(luz_sol)
	luz_sol.light_color = Color(1.0, 0.88, 0.72)
	luz_sol.light_energy = 1.35
	luz_sol.shadow_enabled = true
	luz_sol.rotation_degrees = Vector3(-40.0, -35.0, 0.0)
	_configurar_environment()


func _configurar_environment() -> void:
	ambiente = get_node_or_null("WorldEnvironment") as WorldEnvironment
	if ambiente == null:
		ambiente = WorldEnvironment.new()
		ambiente.name = "WorldEnvironment"
		add_child(ambiente)
	var env: Environment = Environment.new()
	var sky: Sky = Sky.new()
	var sm: ProceduralSkyMaterial = ProceduralSkyMaterial.new()
	sm.sky_top_color = Color(0.55, 0.68, 0.85)
	sm.sky_horizon_color = Color(0.92, 0.78, 0.58)
	sm.ground_horizon_color = Color(0.72, 0.60, 0.44)
	sm.ground_bottom_color = Color(0.38, 0.32, 0.24)
	sky.sky_material = sm
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.glow_enabled = true
	env.glow_intensity = 0.5
	env.glow_bloom = 0.25
	env.fog_enabled = true
	env.fog_light_color = Color(0.95, 0.84, 0.70)
	env.fog_density = 0.005
	ambiente.environment = env


func _garantir_camera() -> void:
	camera_3d = get_node_or_null("Camera3D") as Camera3D
	if camera_3d == null:
		camera_3d = Camera3D.new()
		camera_3d.name = "Camera3D"
		add_child(camera_3d)
	camera_3d.fov = 30.0
	camera_3d.current = true
	_aplicar_preset_camera(0, false)


func _instanciar_combatentes() -> void:
	_montar_container_herois()
	_montar_container_inimigos()


func _montar_container_herois() -> void:
	herois_sprites.clear()
	container_herois = get_node_or_null("PartyContainer3D") as Node3D
	if container_herois == null:
		container_herois = Node3D.new()
		container_herois.name = "PartyContainer3D"
		add_child(container_herois)
	var sp_lucas: AnimatedSprite3D = _obter_ou_criar_sprite(container_herois, "lucas", CAMINHO_LUCAS_FRAMES)
	var sp_davi: AnimatedSprite3D = _obter_ou_criar_sprite(container_herois, "davi", CAMINHO_DAVI_FRAMES)
	_calibrar_corpo_personagem(sp_lucas, 1.72, 207.0, -25.0)
	_calibrar_corpo_personagem(sp_davi, 1.68, 232.0, -74.0)
	_posicionar_sprite(sp_lucas, 5.0, 3.5)
	_posicionar_sprite(sp_davi, 6.5, 5.0)
	herois_sprites.append(sp_lucas)
	herois_sprites.append(sp_davi)


func _montar_container_inimigos() -> void:
	inimigos_sprites.clear()
	container_inimigos = get_node_or_null("EnemyContainer3D") as Node3D
	if container_inimigos == null:
		container_inimigos = Node3D.new()
		container_inimigos.name = "EnemyContainer3D"
		add_child(container_inimigos)
	var sp_cassian: AnimatedSprite3D = _obter_ou_criar_sprite(container_inimigos, "general_cassian", CAMINHO_CASSIAN_FRAMES)
	_calibrar_corpo_personagem(sp_cassian, 1.95, 206.0, -88.0)
	_posicionar_sprite(sp_cassian, -6.0, 4.0)
	inimigos_sprites.append(sp_cassian)


func _obter_ou_criar_sprite(pai: Node3D, nome_sp: String, caminho_frames: String) -> AnimatedSprite3D:
	var sp: AnimatedSprite3D = pai.get_node_or_null(nome_sp) as AnimatedSprite3D
	if sp == null:
		sp = AnimatedSprite3D.new()
		sp.name = nome_sp
		pai.add_child(sp)
	var frames: SpriteFrames = load(caminho_frames) as SpriteFrames
	if frames != null:
		sp.sprite_frames = frames
	sp.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	sp.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	sp.shaded = true
	sp.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	_tocar_anim_inicial(sp, nome_sp)
	return sp


func _tocar_anim_inicial(sp: AnimatedSprite3D, id_c: String) -> void:
	if sp.sprite_frames == null:
		return
	var anim: String = "idle_down_left"
	if id_c == "davi":
		anim = "Idle Southwest_right"
	elif id_c == "general_cassian":
		anim = "iso_idle_southeast_right"
	if sp.sprite_frames.has_animation(anim):
		sp.play(anim)


func _calibrar_corpo_personagem(sp: AnimatedSprite3D, altura_m: float, h_corpo_px: float, offset_y_px: float) -> void:
	sp.centered = false
	var tex: Texture2D = null
	if sp.sprite_frames != null and sp.sprite_frames.has_animation(sp.animation):
		tex = sp.sprite_frames.get_frame_texture(sp.animation, 0)
	var w_tex: float = float(tex.get_width()) if tex != null else 256.0
	sp.pixel_size = altura_m / maxf(16.0, h_corpo_px)
	sp.offset = Vector2(-w_tex * 0.5, offset_y_px)


func _posicionar_sprite(sp: AnimatedSprite3D, x: float, z: float) -> void:
	if terreno != null:
		terreno.posicionar_no_chao(sp, x, z, 0.0)
	else:
		sp.position = Vector3(x, 0.0, z)


func _aplicar_preset_camera(indice: int, animar: bool = true) -> void:
	indice_camera = posmod(indice, 4)
	if indice_camera == 0:
		_orbit_center = Vector3(0.0, 1.2, 4.0)
		_orbit_angles = Vector2(0.0, deg_to_rad(28.0))
		_orbit_dist = 21.0
	elif indice_camera == 1:
		_orbit_center = Vector3(-6.0, 1.4, 4.0)
		_orbit_angles = Vector2(deg_to_rad(-20.0), deg_to_rad(18.0))
		_orbit_dist = 10.5
	elif indice_camera == 2:
		_orbit_center = Vector3(5.5, 1.4, 4.2)
		_orbit_angles = Vector2(deg_to_rad(20.0), deg_to_rad(18.0))
		_orbit_dist = 10.5
	elif indice_camera == 3:
		_orbit_center = Vector3(0.0, 0.0, 0.0)
		_orbit_angles = Vector2(0.0, deg_to_rad(50.0))
		_orbit_dist = 28.0
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


func aplicar_formacao(nome_tatica: String) -> void:
	if herois_sprites.size() < 2:
		return
	var p0: Vector2 = Vector2(5.0, 3.5)
	var p1: Vector2 = Vector2(6.5, 5.0)
	if nome_tatica == "LOSANGO":
		p0 = Vector2(4.5, 4.0)
		p1 = Vector2(6.8, 4.0)
	elif nome_tatica == "VANGUARDA_3X1":
		p0 = Vector2(4.0, 4.0)
		p1 = Vector2(7.2, 5.2)
	_posicionar_sprite(herois_sprites[0], p0.x, p0.y)
	_posicionar_sprite(herois_sprites[1], p1.x, p1.y)


func executar_investida() -> void:
	if _em_ataque or herois_sprites.is_empty() or inimigos_sprites.is_empty():
		return
	var atacante: AnimatedSprite3D = herois_sprites[0]
	var alvo: AnimatedSprite3D = inimigos_sprites[0]
	var pos_origem: Vector3 = atacante.position
	var pos_impacto: Vector3 = alvo.position + Vector3(1.5, 0.0, 0.0)
	_em_ataque = true
	var tw: Tween = create_tween()
	tw.tween_property(atacante, "position", pos_impacto, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(alvo, "modulate", Color(1.0, 0.35, 0.35), 0.12)
	tw.tween_property(alvo, "modulate", Color.WHITE, 0.12)
	tw.tween_callback(func() -> void:
		if alvo.sprite_frames != null and alvo.sprite_frames.has_animation("Attack Southeast_right"):
			alvo.play("Attack Southeast_right")
	)
	tw.tween_interval(0.40)
	tw.tween_callback(func() -> void: _tocar_anim_inicial(alvo, "general_cassian"))
	tw.tween_property(atacante, "position", pos_origem, 0.28).set_trans(Tween.TRANS_QUAD)
	tw.tween_callback(func() -> void: _em_ataque = false)


func _criar_hud() -> void:
	if get_node_or_null("HUD_BatalhaVila") != null:
		return
	var camada: CanvasLayer = CanvasLayer.new()
	camada.name = "HUD_BatalhaVila"
	add_child(camada)
	var painel: PanelContainer = PanelContainer.new()
	painel.position = Vector2(20.0, 18.0)
	var estilo: StyleBoxFlat = StyleBoxFlat.new()
	estilo.bg_color = Color(0.08, 0.06, 0.05, 0.84)
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


func _atualizar_hud() -> void:
	if label_info == null:
		return
	var nomes_cam: Array[String] = [
		"Panorâmica da Vila (FOV 30)", "Foco no General Cassian",
		"Foco nos Heróis", "Visão Tática Aérea"
	]
	label_info.text = (
		"BATALHA DA VILA - TERRENO PROCEDURAL HD-2D\n"
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
		_atualizar_hud()
	elif event.is_action_pressed("ui_down"):
		_aplicar_preset_camera(indice_camera - 1, true)
		_atualizar_hud()
	elif event.is_action_pressed("ui_right"):
		indice_tatica = posmod(indice_tatica + 1, TATICAS.size())
		aplicar_formacao(TATICAS[indice_tatica])
		_atualizar_hud()
	elif event.is_action_pressed("ui_left"):
		indice_tatica = posmod(indice_tatica - 1, TATICAS.size())
		aplicar_formacao(TATICAS[indice_tatica])
		_atualizar_hud()
	elif event.is_action_pressed("ui_accept"):
		executar_investida()
	elif event is InputEventKey:
		_processar_teclas(event as InputEventKey)


func _processar_input_mouse_botao(mb: InputEventMouseButton) -> void:
	if mb.button_index == MOUSE_BUTTON_RIGHT:
		_arrastando_mouse = mb.pressed
	elif mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
		_orbit_dist = clampf(_orbit_dist - 1.2, 5.0, 40.0)
		_atualizar_posicao_camera(false)
	elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
		_orbit_dist = clampf(_orbit_dist + 1.2, 5.0, 40.0)
		_atualizar_posicao_camera(false)


func _processar_input_mouse_movimento(mm: InputEventMouseMotion) -> void:
	if not _arrastando_mouse:
		return
	_orbit_angles.x -= mm.relative.x * 0.005
	_orbit_angles.y = clampf(_orbit_angles.y + mm.relative.y * 0.005, deg_to_rad(5.0), deg_to_rad(80.0))
	_atualizar_posicao_camera(false)


func _processar_teclas(k: InputEventKey) -> void:
	if not k.pressed or k.echo:
		return
	if k.keycode == KEY_F5:
		get_tree().change_scene_to_file("res://scenes/battle/battle_scene.tscn")
	elif k.keycode == KEY_F7:
		_aplicar_preset_camera(0, true)
		_atualizar_hud()

