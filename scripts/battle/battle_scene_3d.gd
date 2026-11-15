class_name BattleScene3D
extends Node3D

## Cena de batalha HD-2D 3D da Vila do Baltazar no enquadramento cinematográfico de referência: praça 3D em primeiro plano, patamar superior elevado com as casas em profundidade, floresta de carvalhos atrás das casas e horizonte de montanhas ao pôr do sol.

const CAMINHO_CASSIAN_FRAMES: String = "res://autosprite_imported/General_Cassian1/General_Cassian1_frames.tres"
const CAMINHO_CASA_PRINCIPAL_GLB: String = "res://assets/models/arena/casa_principal_vila_baltazar.glb"
const CAMINHO_CASA_LATERAL_GLB: String = "res://assets/models/arena/casa_lateral_vila_baltazar.glb"
const CAMINHO_FORJA_GLB: String = "res://assets/models/arena/forja_vila_baltazar.glb"
const CAMINHO_ARVORE_CARVALHO_PNG: String = "res://assets/art/props/battle/arvore_carvalho_vila.png"
const CAMINHO_HORIZONTE_POENTE_PNG: String = "res://assets/art/battle_backgrounds/baltazar_village/ceu_montanhas_poente.png"
const CAMINHO_MOLDURA_FG_PNG: String = "res://assets/art/battle_backgrounds/baltazar_village/battle_fg_praca_moldura.png"
const CAMINHO_FOGO_FORJA_FRAMES: String = "res://assets/art/props/battle/vfx_fogo_fornalha_frames.tres"
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
	env_node.name = "AmbienteVilaBaltazar"
	var env: Environment = Environment.new()
	var sky: Sky = Sky.new()
	var sky_mat: ProceduralSkyMaterial = ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.88, 0.56, 0.34)
	sky_mat.sky_horizon_color = Color(0.98, 0.74, 0.44)
	sky_mat.ground_horizon_color = Color(0.72, 0.54, 0.36)
	sky_mat.ground_bottom_color = Color(0.45, 0.34, 0.24)
	sky_mat.sun_angle_max = 42.0
	sky_mat.sun_curve = 0.08
	sky.sky_material = sky_mat
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.96, 0.84, 0.70)
	env.ambient_light_energy = 0.88
	env_node.environment = env
	add_child(env_node)
	_criar_luz_sol_e_camera()
	_criar_luzes_quentes_vila()


func _criar_luz_sol_e_camera() -> void:
	var sol: DirectionalLight3D = DirectionalLight3D.new()
	sol.name = "LuzSolPoente"
	sol.light_color = Color(1.0, 0.85, 0.64)
	sol.light_energy = 1.42
	sol.shadow_enabled = true
	sol.rotation_degrees = Vector3(-34.0, -35.0, 0.0)
	add_child(sol)
	camera_3d = Camera3D.new()
	camera_3d.name = "Camera3D"
	camera_3d.fov = 40.0
	camera_3d.current = true
	add_child(camera_3d)
	_aplicar_preset_camera(0, false)


func _criar_luzes_quentes_vila() -> void:
	var luz_forja: OmniLight3D = _criar_omni_light("LuzFornalhaBaltazar", Vector3(8.4, 1.7, -3.9), Color(1.0, 0.44, 0.12), 2.8, 7.5)
	var tw: Tween = create_tween().set_loops()
	tw.tween_property(luz_forja, "light_energy", 3.5, 0.85).set_trans(Tween.TRANS_SINE)
	tw.tween_property(luz_forja, "light_energy", 2.1, 0.85).set_trans(Tween.TRANS_SINE)
	_instanciar_fogo_fornalha_3d(Vector3(8.55, 1.55, -4.05))


func _instanciar_fogo_fornalha_3d(pos: Vector3) -> void:
	if not ResourceLoader.exists(CAMINHO_FOGO_FORJA_FRAMES):
		return
	var fogo: AnimatedSprite3D = AnimatedSprite3D.new()
	fogo.name = "FogoFornalha3D"
	fogo.sprite_frames = load(CAMINHO_FOGO_FORJA_FRAMES) as SpriteFrames
	fogo.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	fogo.shaded = false
	fogo.pixel_size = 0.0045
	fogo.position = pos
	if fogo.sprite_frames != null and fogo.sprite_frames.has_animation("default"):
		fogo.play("default")
	add_child(fogo)


func _criar_omni_light(nome: String, pos: Vector3, cor: Color, energia: float, alcance: float) -> OmniLight3D:
	var luz: OmniLight3D = OmniLight3D.new()
	luz.name = nome
	luz.position = pos
	luz.light_color = cor
	luz.light_energy = energia
	luz.omni_range = alcance
	add_child(luz)
	return luz


func _montar_terreno_e_construcoes() -> void:
	terrain_visual = ArenaTerrainVisual.new()
	terrain_visual.name = "ArenaTerrainVisual"
	terrain_visual.terrain = terrain
	add_child(terrain_visual)
	terrain_visual.construir_terreno(terrain)
	_instanciar_estruturas_vila_3d()
	_instanciar_vegetacao_hd2d()
	_instanciar_horizonte_e_moldura_3d()


func _instanciar_estruturas_vila_3d() -> void:
	_instanciar_construcao_sem_plataforma(
		CAMINHO_CASA_LATERAL_GLB, "CasaLateralVila",
		Vector3(-9.2, 0.54, -4.2), Vector3(5.4, 5.4, 5.4), Vector3(0.0, 26.0, 0.0), 0.056
	)
	_instanciar_construcao_sem_plataforma(
		CAMINHO_CASA_PRINCIPAL_GLB, "CasaPrincipalVila",
		Vector3(-2.0, 0.88, -8.8), Vector3(5.6, 5.6, 5.6), Vector3(0.0, 6.0, 0.0), 0.056
	)
	_instanciar_construcao_sem_plataforma(
		CAMINHO_FORJA_GLB, "ForjaVilaBaltazar",
		Vector3(8.8, 0.54, -4.0), Vector3(5.2, 5.2, 5.2), Vector3(0.0, -24.0, 0.0), 0.062
	)
	_instanciar_construcao_sem_plataforma(
		CAMINHO_CASA_LATERAL_GLB, "CasaVilaFundo1",
		Vector3(2.6, 0.88, -10.4), Vector3(4.6, 4.6, 4.6), Vector3(0.0, -8.0, 0.0), 0.056
	)
	_instanciar_construcao_sem_plataforma(
		CAMINHO_CASA_PRINCIPAL_GLB, "CasaVilaFundo2",
		Vector3(6.4, 0.88, -12.0), Vector3(4.0, 4.0, 4.0), Vector3(0.0, -14.0, 0.0), 0.056
	)


func _instanciar_construcao_sem_plataforma(caminho: String, nome_no: String, pos: Vector3, escala: Vector3, rot_deg: Vector3, corte_y: float) -> void:
	if not ResourceLoader.exists(caminho):
		return
	var cena_res: PackedScene = load(caminho) as PackedScene
	if cena_res == null:
		return
	var instancia: Node3D = cena_res.instantiate() as Node3D
	instancia.name = nome_no
	_recortar_plataforma_base(instancia, corte_y)
	instancia.position = pos
	instancia.scale = escala
	instancia.rotation_degrees = rot_deg
	add_child(instancia)


func _recortar_plataforma_base(raiz: Node, corte_y: float) -> void:
	for filho: Node in raiz.find_children("*", "MeshInstance3D", true, false):
		var mi: MeshInstance3D = filho as MeshInstance3D
		if mi != null and mi.mesh != null and mi.mesh.get_surface_count() > 0:
			var mat: Material = mi.get_active_material(0)
			mi.mesh = _criar_malha_sem_pedestal(mi.mesh, mat, corte_y)


func _criar_malha_sem_pedestal(malha: Mesh, mat: Material, corte_y: float) -> ArrayMesh:
	var arrays: Array = malha.surface_get_arrays(0)
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	var novos_indices: PackedInt32Array = PackedInt32Array()
	for i: int in range(0, indices.size(), 3):
		var i0: int = indices[i]
		var i1: int = indices[i + 1]
		var i2: int = indices[i + 2]
		if verts[i0].y >= corte_y or verts[i1].y >= corte_y or verts[i2].y >= corte_y:
			novos_indices.append(i0)
			novos_indices.append(i1)
			novos_indices.append(i2)
	for j: int in range(verts.size()):
		verts[j].y = maxf(0.0, verts[j].y - corte_y)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_INDEX] = novos_indices
	var nova: ArrayMesh = ArrayMesh.new()
	nova.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	if mat != null:
		nova.surface_set_material(0, mat)
	return nova


func _instanciar_vegetacao_hd2d() -> void:
	if not ResourceLoader.exists(CAMINHO_ARVORE_CARVALHO_PNG):
		return
	var tex_arvore: Texture2D = load(CAMINHO_ARVORE_CARVALHO_PNG) as Texture2D
	if tex_arvore == null:
		return
	var container_veg: Node3D = Node3D.new()
	container_veg.name = "VegetacaoVilaHD2D"
	add_child(container_veg)
	_criar_arvore_hd2d(container_veg, tex_arvore, "CarvalhoFlancoEsq", Vector3(-13.2, 0.88, -7.8), 6.2, true, Color(1.0, 0.96, 0.90))
	_criar_arvore_hd2d(container_veg, tex_arvore, "CarvalhoVaoEsq", Vector3(-6.2, 0.88, -9.8), 6.0, false, Color(1.0, 0.98, 0.92))
	_criar_arvore_hd2d(container_veg, tex_arvore, "CarvalhoFundoEsq", Vector3(-9.8, 0.88, -12.8), 6.8, false, Color(0.92, 0.88, 0.80))
	_criar_arvore_hd2d(container_veg, tex_arvore, "CarvalhoAtrasCasaPrin", Vector3(-2.4, 0.88, -12.6), 6.6, true, Color(0.94, 0.90, 0.82))
	_criar_arvore_hd2d(container_veg, tex_arvore, "CarvalhoVaoCentro", Vector3(0.8, 0.88, -11.8), 5.8, false, Color(0.96, 0.92, 0.86))
	_criar_arvore_hd2d(container_veg, tex_arvore, "CarvalhoAtrasCasaFundo1", Vector3(4.5, 0.88, -13.2), 6.4, true, Color(0.90, 0.86, 0.78))
	_criar_arvore_hd2d(container_veg, tex_arvore, "CarvalhoAtrasForja", Vector3(9.4, 0.88, -10.8), 6.2, false, Color(0.96, 0.92, 0.84))
	_criar_arvore_hd2d(container_veg, tex_arvore, "CarvalhoFlancoDir", Vector3(13.0, 0.88, -8.2), 6.0, true, Color(0.98, 0.94, 0.88))
	_criar_arvore_hd2d(container_veg, tex_arvore, "CarvalhoMataFundo", Vector3(1.5, 0.88, -15.0), 7.2, true, Color(0.86, 0.82, 0.74))


func _criar_arvore_hd2d(pai: Node3D, tex: Texture2D, nome: String, pos: Vector3, altura_m: float, espelhar: bool, tom: Color) -> void:
	var sp: Sprite3D = Sprite3D.new()
	sp.name = nome
	sp.texture = tex
	sp.centered = false
	sp.offset = Vector2(-float(tex.get_width()) * 0.5, 0.0)
	sp.pixel_size = altura_m / maxf(1.0, float(tex.get_height()))
	sp.flip_h = espelhar
	sp.modulate = tom
	sp.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	sp.shaded = true
	sp.alpha_cut = SpriteBase3D.ALPHA_CUT_OPAQUE_PREPASS
	sp.alpha_scissor_threshold = 0.35
	sp.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	sp.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	sp.position = pos
	pai.add_child(sp)


func _instanciar_horizonte_e_moldura_3d() -> void:
	if ResourceLoader.exists(CAMINHO_HORIZONTE_POENTE_PNG):
		var tex_hor: Texture2D = load(CAMINHO_HORIZONTE_POENTE_PNG) as Texture2D
		if tex_hor != null:
			var sp_hor: Sprite3D = Sprite3D.new()
			sp_hor.name = "HorizonteMontanhasPoente"
			sp_hor.texture = tex_hor
			sp_hor.centered = false
			sp_hor.offset = Vector2(-float(tex_hor.get_width()) * 0.5, 0.0)
			sp_hor.pixel_size = 52.0 / maxf(1.0, float(tex_hor.get_width()))
			sp_hor.shaded = false
			sp_hor.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
			sp_hor.position = Vector3(0.0, 1.4, -22.5)
			add_child(sp_hor)
	if ResourceLoader.exists(CAMINHO_MOLDURA_FG_PNG):
		var tex_fg: Texture2D = load(CAMINHO_MOLDURA_FG_PNG) as Texture2D
		if tex_fg != null:
			var sp_fg: Sprite3D = Sprite3D.new()
			sp_fg.name = "MolduraPrimeiroPlano3D"
			sp_fg.texture = tex_fg
			sp_fg.centered = false
			sp_fg.offset = Vector2(-float(tex_fg.get_width()) * 0.5, 0.0)
			sp_fg.pixel_size = 9.8 / maxf(1.0, float(tex_fg.get_width()))
			sp_fg.shaded = false
			sp_fg.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
			sp_fg.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
			sp_fg.position = Vector3(0.0, -0.35, 5.8)
			add_child(sp_fg)


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
		candidatos = ["Idle Southwest_right", "Idle Left_right", "Idle West_right", "Idle Down_right"]
	elif id_comb == "general_cassian":
		candidatos = ["iso_idle_southeast_right", "iso_idle_right_right", "Idle Southeast_right", "Idle Right_right"]
	for c: String in candidatos:
		if frames.has_animation(c):
			return c
	var nomes: PackedStringArray = frames.get_animation_names()
	return nomes[0] if not nomes.is_empty() else "default"


func _escolher_anim_ataque(frames: SpriteFrames, id_comb: String) -> String:
	if frames == null:
		return "default"
	var candidatos: Array[String] = ["attack_left", "attack_down_left", "attack_down"]
	if id_comb == "davi":
		candidatos = ["Punch Southwest_right", "Punch Left_right", "Throw Southwest_right"]
	elif id_comb == "general_cassian":
		candidatos = ["Attack Southeast_right", "Attack Right_right", "Attack East_right", "Attack Down_right"]
	for c: String in candidatos:
		if frames.has_animation(c):
			return c
	return _escolher_anim_idle(frames, id_comb)


func _calibrar_pivo_e_tamanho_3d(sp: AnimatedSprite3D, is_boss: bool) -> void:
	var tex: Texture2D = null
	if sp.sprite_frames != null and sp.sprite_frames.has_animation(sp.animation):
		tex = sp.sprite_frames.get_frame_texture(sp.animation, 0)
	var h_tex: float = float(tex.get_height()) if tex != null else 300.0
	var base_pes_ratio: float = 0.08
	if tex != null:
		var img: Image = tex.get_image()
		if img != null and img.get_height() > 0:
			var r_used: Rect2i = img.get_used_rect()
			if r_used.size.y > 0:
				var px_abaixo: int = img.get_height() - (r_used.position.y + r_used.size.y)
				base_pes_ratio = float(maxi(0, px_abaixo)) / float(img.get_height())
	sp.centered = false
	var w_tex: float = float(tex.get_width()) if tex != null else 200.0
	sp.offset = Vector2(-w_tex * 0.5, -h_tex * base_pes_ratio)
	var altura_visivel: float = h_tex * (1.0 - base_pes_ratio * 2.0)
	var alvo_metros: float = 1.95 if is_boss else 1.55
	sp.pixel_size = alvo_metros / maxf(32.0, altura_visivel)


func posicionar_sprite_no_terreno(sp: AnimatedSprite3D, u: float, v: float) -> void:
	if sp == null or terrain == null:
		return
	var pos_3d: Vector3 = terrain.normalizado_para_mundo(u, v)
	sp.position = pos_3d
	sp.set_meta("uv_terreno", Vector2(u, v))


func _obter_uv_aliado(indice: int, nome_tatica: String) -> Vector2:
	var uv_2d: Vector2 = Vector2(0.68, 0.70) if indice == 0 else Vector2(0.72, 0.82)
	if layout_cenario != null and layout_cenario.formacoes_aliados.has(nome_tatica):
		var lista: Array = layout_cenario.formacoes_aliados[nome_tatica]
		if indice >= 0 and indice < lista.size():
			uv_2d = lista[indice] as Vector2
	var u: float = clampf((uv_2d.x - 0.14) / 0.72, 0.56, 0.82)
	var v: float = clampf((uv_2d.y - 0.50) / 0.40, 0.42, 0.72)
	return Vector2(u, v)


func _obter_uv_inimigo(indice: int) -> Vector2:
	if indice == 0:
		return Vector2(0.28, 0.52)
	return Vector2(0.22, 0.64)


func aplicar_formacao_3d(nome_tatica: String, animar: bool = true) -> void:
	for i: int in range(herois_sprites.size()):
		var sp: AnimatedSprite3D = herois_sprites[i]
		var uv: Vector2 = _obter_uv_aliado(i, nome_tatica)
		var destino: Vector3 = terrain.normalizado_para_mundo(uv.x, uv.y)
		sp.set_meta("uv_terreno", uv)
		if animar and is_inside_tree():
			var tw: Tween = create_tween()
			tw.tween_property(sp, "position", destino, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		else:
			sp.position = destino


func _aplicar_preset_camera(indice: int, animar: bool = true) -> void:
	indice_camera = posmod(indice, 4)
	var pos_alvo: Vector3 = Vector3(0.0, 2.55, 10.6)
	var olhar_para: Vector3 = Vector3(0.0, 1.55, -4.5)
	if indice_camera == 1:
		pos_alvo = Vector3(4.5, 2.45, 9.8)
		olhar_para = Vector3(-1.4, 1.45, -4.2)
	elif indice_camera == 2:
		pos_alvo = Vector3(-4.5, 2.45, 9.8)
		olhar_para = Vector3(1.6, 1.45, -4.2)
	elif indice_camera == 3:
		pos_alvo = Vector3(0.0, 6.2, 13.0)
		olhar_para = Vector3(0.0, 0.9, -3.5)
	var dir: Vector3 = (olhar_para - pos_alvo).normalized()
	var base_alvo: Basis = Basis.looking_at(dir, Vector3.UP)
	var tr_alvo: Transform3D = Transform3D(base_alvo, pos_alvo)
	if animar and is_inside_tree():
		var tw: Tween = create_tween()
		tw.tween_property(camera_3d, "transform", tr_alvo, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	else:
		camera_3d.transform = tr_alvo


func executar_investida_exemplo() -> void:
	if _em_animacao_ataque or herois_sprites.is_empty() or inimigos_sprites.is_empty():
		return
	var atacante: AnimatedSprite3D = herois_sprites[0]
	var alvo: AnimatedSprite3D = inimigos_sprites[0]
	var pos_origem: Vector3 = atacante.position
	var pos_impacto: Vector3 = alvo.position + Vector3(1.25, 0.0, 0.2)
	var id_h: String = str(atacante.get_meta("id_comb", "lucas"))
	var id_i: String = str(alvo.get_meta("id_comb", "general_cassian"))
	var anim_atk_h: String = _escolher_anim_ataque(atacante.sprite_frames, id_h)
	var anim_idle_h: String = _escolher_anim_idle(atacante.sprite_frames, id_h)
	var anim_atk_i: String = _escolher_anim_ataque(alvo.sprite_frames, id_i)
	var anim_idle_i: String = _escolher_anim_idle(alvo.sprite_frames, id_i)
	if not is_inside_tree():
		atacante.position = pos_origem
		return
	_em_animacao_ataque = true
	var tw: Tween = create_tween()
	tw.tween_property(atacante, "position", pos_impacto, 0.22).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func() -> void: atacante.play(anim_atk_h))
	tw.tween_property(alvo, "modulate", Color(1.0, 0.35, 0.35), 0.12)
	tw.tween_property(alvo, "modulate", Color.WHITE, 0.14)
	tw.tween_callback(func() -> void: alvo.play(anim_atk_i))
	tw.tween_interval(0.45)
	tw.tween_callback(func() -> void:
		alvo.play(anim_idle_i)
		atacante.play(anim_idle_h)
	)
	tw.tween_property(atacante, "position", pos_origem, 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tw.tween_callback(func() -> void: _em_animacao_ataque = false)


func _criar_hud_instrucoes() -> void:
	var camada: CanvasLayer = CanvasLayer.new()
	camada.name = "HUD3D"
	add_child(camada)
	var painel: PanelContainer = PanelContainer.new()
	painel.position = Vector2(20.0, 18.0)
	var estilo: StyleBoxFlat = StyleBoxFlat.new()
	estilo.bg_color = Color(0.08, 0.06, 0.05, 0.80)
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
	var nomes_cam: Array[String] = ["Cinematográfica Vila HD-2D", "Diagonal Heróis -> General", "Contra-ataque -> Forja", "Tática Alta Pátio"]
	label_info.text = (
		"ARENA 3D HD-2D - VILA DO BALTAZAR\n"
		+ "Formação [Setas ←/→]: %s  |  Câmera [Setas ↑/↓]: %s\n" % [TATICAS[indice_tatica], nomes_cam[indice_camera]]
		+ "[Espaço/Enter]: Testar Ataque (Lucas + Espada do General)  |  [F5]: Voltar para Arena 2D"
	)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right"):
		indice_tatica = posmod(indice_tatica + 1, TATICAS.size())
		aplicar_formacao_3d(TATICAS[indice_tatica], true)
		_atualizar_texto_hud()
	elif event.is_action_pressed("ui_left"):
		indice_tatica = posmod(indice_tatica - 1, TATICAS.size())
		aplicar_formacao_3d(TATICAS[indice_tatica], true)
		_atualizar_texto_hud()
	elif event.is_action_pressed("ui_up"):
		_aplicar_preset_camera(indice_camera + 1, true)
		_atualizar_texto_hud()
	elif event.is_action_pressed("ui_down"):
		_aplicar_preset_camera(indice_camera - 1, true)
		_atualizar_texto_hud()
	elif event.is_action_pressed("ui_accept"):
		executar_investida_exemplo()
	elif event is InputEventKey:
		var k: InputEventKey = event as InputEventKey
		if k.pressed and not k.echo and k.keycode == KEY_F5:
			get_tree().change_scene_to_file("res://scenes/battle/battle_scene.tscn")
