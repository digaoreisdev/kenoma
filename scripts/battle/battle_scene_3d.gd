class_name BattleScene3D
extends Node3D

## Cena de batalha HD-2D 3D (estilo Eiyuden) com terreno em blocos, construção medieval 3D e sprites 2D em Sprite3D/AnimatedSprite3D.

const CAMINHO_CASA_OBJ: String = "res://assets/models/medieval_bld_13/obj/p3d_medieval_enterable_bld-13.obj"
const CAMINHO_LABRADOR_GLB: String = "res://assets/models/labrador/Labrador_AllAnimations.glb"
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


func _ready() -> void:
	_inicializar_recursos()
	_montar_ambiente_e_luz()
	_montar_terreno_e_construcoes()
	_instanciar_equipe_3d()
	_instanciar_inimigos_3d()
	_instanciar_labrador_3d()
	_criar_hud_instrucoes()
	_atualizar_texto_hud()


func _inicializar_recursos() -> void:
	if terrain == null:
		terrain = load("res://resources/battle_layouts/arena_terrain_exemplo.tres") as ArenaTerrain
	if terrain == null:
		terrain = ArenaTerrain.criar_exemplo_patamar_lateral()
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
	env.ambient_light_energy = 0.75
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
	camera_3d.fov = 42.0
	camera_3d.current = true
	add_child(camera_3d)
	_aplicar_preset_camera(0, false)


func _montar_terreno_e_construcoes() -> void:
	terrain_visual = ArenaTerrainVisual.new()
	terrain_visual.name = "ArenaTerrainVisual"
	terrain_visual.terrain = terrain
	add_child(terrain_visual)
	terrain_visual.construir_terreno(terrain)
	_instanciar_casas_medievais()


func _instanciar_casas_medievais() -> void:
	if not ResourceLoader.exists(CAMINHO_CASA_OBJ):
		return
	var malha_casa: Mesh = load(CAMINHO_CASA_OBJ) as Mesh
	if malha_casa == null:
		return
	var casa_esq: MeshInstance3D = MeshInstance3D.new()
	casa_esq.name = "CasaMedievalEsq"
	casa_esq.mesh = malha_casa
	casa_esq.scale = Vector3(0.011, 0.011, 0.011)
	casa_esq.position = Vector3(-6.2, 0.0, -11.5)
	add_child(casa_esq)
	var casa_dir: MeshInstance3D = MeshInstance3D.new()
	casa_dir.name = "CasaMedievalDir"
	casa_dir.mesh = malha_casa
	casa_dir.scale = Vector3(0.011, 0.011, 0.011)
	casa_dir.position = Vector3(6.6, 0.0, -11.2)
	casa_dir.rotation_degrees = Vector3(0.0, -90.0, 0.0)
	add_child(casa_dir)


func _instanciar_equipe_3d() -> void:
	container_herois = Node3D.new()
	container_herois.name = "PartyContainer3D"
	add_child(container_herois)
	var herois: Array[CharacterData] = [
		CharacterData.create_default_lucas(),
		CharacterData.create_default_davi(),
		CharacterData.create_default_baltazar(),
		CharacterData.create_default_dai()
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
	var total: int = layout_cenario.posicoes_monstros_padrao.size()
	for i: int in range(total):
		var is_boss: bool = (i == 0)
		var sp: AnimatedSprite3D = _criar_combatente_sprite3d("inimigo_%d" % i, frames_cassian, is_boss)
		container_inimigos.add_child(sp)
		var uv: Vector2 = _obter_uv_inimigo(i)
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
	var anim: String = _escolher_anim_idle(frames, id_comb)
	if frames != null and frames.has_animation(anim):
		sp.play(anim)
	_calibrar_pivo_e_tamanho_3d(sp, is_boss)
	return sp


func _escolher_anim_idle(frames: SpriteFrames, id_comb: String) -> String:
	if frames == null:
		return "default"
	var candidatos: Array[String] = ["idle_left", "Breathing Idle West", "Fight Stance Idle West", "iso_walk_southeast_right", "idle_down"]
	if id_comb.begins_with("inimigo"):
		candidatos = ["iso_walk_southeast_right", "Attack Southeast_right", "idle_right", "idle_down"]
	for c: String in candidatos:
		if frames.has_animation(c):
			return c
	var nomes: PackedStringArray = frames.get_animation_names()
	return nomes[0] if not nomes.is_empty() else "default"


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
	var altura_alvo_m: float = 2.15 if is_boss else 1.75
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
	var u: float = clampf((pt.x - 0.04) / 0.80, 0.05, 0.95)
	var v: float = clampf((pt.y - layout_cenario.y_fundo) / (layout_cenario.y_frente - layout_cenario.y_fundo), 0.08, 0.92)
	return Vector2(u, v)


func _obter_uv_inimigo(slot_idx: int) -> Vector2:
	var lista: Array[Vector2] = layout_cenario.posicoes_monstros_padrao
	var pt: Vector2 = lista[slot_idx] if slot_idx < lista.size() else Vector2(0.24, 0.72)
	var u: float = clampf((pt.x - 0.04) / 0.80, 0.05, 0.95)
	var v: float = clampf((pt.y - layout_cenario.y_fundo) / (layout_cenario.y_frente - layout_cenario.y_fundo), 0.08, 0.92)
	return Vector2(u, v)


func _instanciar_labrador_3d() -> void:
	if not ResourceLoader.exists(CAMINHO_LABRADOR_GLB):
		return
	var cena_cao: PackedScene = load(CAMINHO_LABRADOR_GLB) as PackedScene
	if cena_cao == null:
		return
	var cao: Node3D = cena_cao.instantiate() as Node3D
	cao.name = "Labrador3DNativo"
	var pos_cao: Vector3 = terrain.normalizado_para_mundo(0.52, 0.18)
	cao.position = pos_cao
	cao.scale = Vector3(0.85, 0.85, 0.85)
	add_child(cao)
	var anim: AnimationPlayer = cao.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if anim != null and anim.has_animation("Bark"):
		anim.play("Bark")


func _criar_hud_instrucoes() -> void:
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.name = "HUD3D"
	add_child(canvas)
	var painel: PanelContainer = PanelContainer.new()
	painel.position = Vector2(24.0, 20.0)
	canvas.add_child(painel)
	label_info = Label.new()
	label_info.set("theme_override_font_sizes/font_size", 18)
	label_info.modulate = Color(1.0, 0.95, 0.82)
	painel.add_child(label_info)


func _atualizar_texto_hud() -> void:
	if label_info == null:
		return
	var nomes_cam: Array[String] = ["Panorâmica Eiyuden", "Close Vanguarda", "Tática Aérea", "Diagonal Dramática"]
	var tatica: String = TATICAS[indice_tatica]
	var cam_nome: String = nomes_cam[indice_camera % nomes_cam.size()]
	label_info.text = "ARENA 3D HD-2D (PROTOTIPO EIYUDEN)\nFormação [Setas ←/→]: %s  |  Câmera [Setas ↑/↓]: %s\n[Espaço/Enter]: Testar Investida 3D nos Degraus  |  [F5]: Voltar para Arena 2D" % [tatica, cam_nome]


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
		Vector3(0.0, 7.8, 12.8),
		Vector3(3.2, 4.2, 8.6),
		Vector3(0.0, 13.5, 9.5),
		Vector3(-5.5, 5.2, 10.2)
	]
	var rotacoes: Array[Vector3] = [
		Vector3(-28.0, 0.0, 0.0),
		Vector3(-16.0, 14.0, 0.0),
		Vector3(-52.0, 0.0, 0.0),
		Vector3(-21.0, -24.0, 0.0)
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


func _executar_demo_investida_3d() -> void:
	if _em_animacao_ataque or herois_sprites.is_empty() or inimigos_sprites.is_empty():
		return
	_em_animacao_ataque = true
	var atacante: AnimatedSprite3D = herois_sprites[0]
	var alvo: AnimatedSprite3D = inimigos_sprites[0]
	var pos_origem: Vector3 = atacante.position
	var pos_impacto: Vector3 = alvo.position + Vector3(1.2, 0.0, 0.0)
	var tw: Tween = create_tween()
	tw.tween_property(atacante, "position", pos_impacto, 0.32).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_interval(0.25)
	tw.tween_property(atacante, "position", pos_origem, 0.32).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.finished.connect(func() -> void: _em_animacao_ataque = false)
