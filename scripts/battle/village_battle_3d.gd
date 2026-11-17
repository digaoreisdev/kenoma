@tool
class_name VillageBattle3D
extends Node3D

## Apresentação 3D da Batalha na Vila do Baltazar (HD-2D).
## Controla o cenário estático, terreno, vegetação, construções e câmera.

const P_COBBLE: String = "res://assets/art/textures/terrain/cobblestone_01.png"
const P_GRASS_TEX: String = "res://assets/art/textures/terrain/grass_01.png"
const P_BACKDROP_TEX: String = "res://assets/art/battle_backgrounds/baltazar_village/battle_bg_forge_village.png"

const FORGE_GLB: String = "res://assets/models/houses/casa_forja_medieval/casa_forja_medieval.glb"
const HOUSE1_GLB: String = "res://assets/models/houses/casa_medieval1/casa_medieval1.glb"
const HOUSE2_GLB: String = "res://assets/models/houses/casa_medieval2/casa_medieval2.glb"
const CHEST_GLB: String = "res://assets/models/props/bau_madeira_aberto/bau_madeira_aberto.glb"
const ROCK_MOSS_GLB: String = "res://assets/models/rocks/rocha_com_musgo1/rocha_com_musgo1.glb"
const ROCK_CLUST1_GLB: String = "res://assets/models/rocks/rock_cluster_01/rock_cluster_01.glb"
const ROCK_CLUST2_GLB: String = "res://assets/models/rocks/rock_cluster_02/rock_cluster_02.glb"
const ROCK_CLUST3_GLB: String = "res://assets/models/rocks/rock_cluster_03/rock_cluster_03.glb"

@onready var terreno: TerrenoBatalha = get_node_or_null("Terrain") as TerrenoBatalha
@onready var buildings_container: Node3D = get_node_or_null("Buildings") as Node3D
@onready var props_container: Node3D = get_node_or_null("Props") as Node3D
@onready var vegetation_container: Node3D = get_node_or_null("Vegetation") as Node3D
@onready var slots_container: Node3D = get_node_or_null("Slots") as Node3D
@onready var backdrop_mesh: MeshInstance3D = get_node_or_null("Backdrop") as MeshInstance3D
@onready var camera_3d: Camera3D = get_node_or_null("Camera3D") as Camera3D
@onready var sun_light: DirectionalLight3D = get_node_or_null("DirectionalLight3D") as DirectionalLight3D
@onready var world_env: WorldEnvironment = get_node_or_null("WorldEnvironment") as WorldEnvironment


func _ready() -> void:
	_configurar_terreno()
	_configurar_backdrop()
	_configurar_iluminacao()
	_configurar_ambiente()
	_configurar_camera_inicial()
	_instanciar_construcoes()
	_instanciar_props()
	_configurar_pedra_elevada()
	_instanciar_vegetacao()
	_configurar_slots()


func _configurar_terreno() -> void:
	if terreno == null:
		return
	terreno.largura = 70.0
	terreno.profundidade = 60.0
	terreno.celula = 0.25
	terreno.z_inicio_subida = 0.0
	terreno.altura_subida = 5.2
	terreno.amp_ondulacao = 0.9
	terreno.largura_praca = 36.0
	terreno.largura_rua = 9.0
	if ResourceLoader.exists(P_COBBLE) and terreno.tex_estrada == null:
		terreno.tex_estrada = load(P_COBBLE) as Texture2D
	if ResourceLoader.exists(P_GRASS_TEX) and terreno.tex_grama == null:
		terreno.tex_grama = load(P_GRASS_TEX) as Texture2D
	terreno.gerar()


func _configurar_backdrop() -> void:
	if backdrop_mesh == null or not ResourceLoader.exists(P_BACKDROP_TEX):
		return
	var qm: QuadMesh = QuadMesh.new()
	qm.size = Vector2(200.0, 112.5)
	backdrop_mesh.mesh = qm
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_texture = load(P_BACKDROP_TEX) as Texture2D
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	backdrop_mesh.material_override = mat
	backdrop_mesh.position = Vector3(0.0, 42.0, -95.0)


func _configurar_iluminacao() -> void:
	if sun_light == null:
		return
	sun_light.light_color = Color(1.0, 0.851, 0.627)
	sun_light.light_energy = 1.3
	sun_light.rotation_degrees = Vector3(-45.0, 35.0, 0.0)
	sun_light.shadow_enabled = true
	sun_light.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	sun_light.directional_shadow_max_distance = 65.0


func _configurar_ambiente() -> void:
	if world_env == null or world_env.environment == null:
		return
	var env: Environment = world_env.environment
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.glow_enabled = true
	env.glow_intensity = 0.55
	env.glow_bloom = 0.2
	env.ssao_enabled = true
	env.adjustment_enabled = true
	env.adjustment_saturation = 1.15
	env.volumetric_fog_enabled = true
	env.volumetric_fog_density = 0.007
	env.volumetric_fog_albedo = Color(1.0, 0.88, 0.72)


func _configurar_camera_inicial() -> void:
	if camera_3d == null:
		return
	camera_3d.fov = 32.0
	camera_3d.position = Vector3(0.0, 9.0, 24.0)
	camera_3d.rotation_degrees = Vector3(-24.0, 0.0, 0.0)


func _instanciar_construcoes() -> void:
	if buildings_container == null or terreno == null:
		return
	buildings_container.position = Vector3.ZERO
	_posicionar_casa(FORGE_GLB, Vector3(10.5, 0.0, -18.0), Vector3(6.2, 6.2, 6.2), -15.0)
	_posicionar_casa(HOUSE1_GLB, Vector3(-12.0, 0.0, -21.0), Vector3(6.0, 6.0, 6.0), 25.0)
	_posicionar_casa(HOUSE2_GLB, Vector3(13.5, 0.0, -28.0), Vector3(5.8, 5.8, 5.8), -30.0)


func _posicionar_casa(caminho: String, pos_xz: Vector3, escala: Vector3, rot_y: float) -> void:
	if not ResourceLoader.exists(caminho):
		return
	var scn: PackedScene = load(caminho) as PackedScene
	if scn == null:
		return
	var casa: Node3D = scn.instantiate() as Node3D
	buildings_container.add_child(casa)
	casa.scale = escala
	casa.rotation_degrees = Vector3(0.0, rot_y, 0.0)
	var x: float = pos_xz.x
	var z: float = pos_xz.z
	if terreno.inclinacao_em(x, z) < 6.0:
		terreno.posicionar_no_chao(casa, x, z, -0.25)


func _instanciar_props() -> void:
	if props_container == null or terreno == null:
		return
	_posicionar_prop_simples(CHEST_GLB, Vector3(13.0, 0.0, -4.5), Vector3(1.5, 1.5, 1.5), -20.0)
	_posicionar_prop_simples(ROCK_CLUST1_GLB, Vector3(-17.0, 0.0, -8.0), Vector3(3.2, 3.2, 3.2), 45.0)
	_posicionar_prop_simples(ROCK_CLUST2_GLB, Vector3(-19.0, 0.0, -24.0), Vector3(3.5, 3.5, 3.5), 110.0)
	_posicionar_prop_simples(ROCK_CLUST3_GLB, Vector3(18.0, 0.0, -9.0), Vector3(3.0, 3.0, 3.0), -65.0)


func _posicionar_prop_simples(caminho: String, pos_xz: Vector3, escala: Vector3, rot_y: float) -> void:
	if not ResourceLoader.exists(caminho):
		return
	var scn: PackedScene = load(caminho) as PackedScene
	if scn == null:
		return
	var prop: Node3D = scn.instantiate() as Node3D
	props_container.add_child(prop)
	prop.scale = escala
	prop.rotation_degrees = Vector3(0.0, rot_y, 0.0)
	terreno.posicionar_no_chao(prop, pos_xz.x, pos_xz.z, -0.1)


func _configurar_pedra_elevada() -> void:
	var pedra_node: Node3D = get_node_or_null("ElevatedRock") as Node3D
	if pedra_node == null or terreno == null:
		return
	var x: float = 8.5
	var z: float = 6.5
	terreno.posicionar_no_chao(pedra_node, x, z, -0.15)


func _instanciar_vegetacao() -> void:
	if vegetation_container == null or terreno == null:
		return
	var arvores: Array[String] = [
		"res://assets/art/props/vegetation/trees/golden_oak_01.png",
		"res://assets/art/props/vegetation/trees/green_oak_01.png",
		"res://assets/art/props/vegetation/trees/green_pine_01.png",
		"res://assets/art/props/vegetation/trees/tall_cypress_01.png"
	]
	var posicoes_arvores: Array[Vector3] = [
		Vector3(-22.0, 0.0, -6.0), Vector3(-24.0, 0.0, -18.0),
		Vector3(22.0, 0.0, -5.0), Vector3(23.0, 0.0, -22.0),
		Vector3(-10.0, 0.0, -32.0), Vector3(8.0, 0.0, -34.0)
	]
	for i: int in range(posicoes_arvores.size()):
		var p: Vector3 = posicoes_arvores[i]
		var tex_path: String = arvores[i % arvores.size()]
		_criar_sprite_vegetacao(tex_path, p, Vector2(5.5, 5.5))


func _criar_sprite_vegetacao(tex_path: String, pos: Vector3, tam: Vector2) -> void:
	if not ResourceLoader.exists(tex_path):
		return
	var sp: Sprite3D = Sprite3D.new()
	sp.texture = load(tex_path) as Texture2D
	sp.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	sp.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	sp.shaded = true
	sp.alpha_cut = SpriteBase3D.ALPHA_CUT_OPAQUE_PREPASS
	sp.offset = Vector2(0.0, float(sp.texture.get_height()) * 0.48)
	sp.pixel_size = tam.y / float(sp.texture.get_height())
	vegetation_container.add_child(sp)
	terreno.posicionar_no_chao(sp, pos.x, pos.z, 0.0)


func _configurar_slots() -> void:
	if slots_container == null or terreno == null:
		return
	var pos_aliados: Array[Vector3] = [
		Vector3(3.5, 0.0, 3.0),
		Vector3(5.5, 0.0, 0.5),
		Vector3(7.5, 0.0, 2.5),
		Vector3(3.0, 0.0, -0.5),
		Vector3(6.5, 0.0, -1.5),
		Vector3(8.5, 0.0, 6.5) # Sobre a rocha elevada
	]
	var pos_inimigos: Array[Vector3] = [
		Vector3(-4.0, 0.0, 2.0),
		Vector3(-6.5, 0.0, 0.0),
		Vector3(-4.5, 0.0, -1.5),
		Vector3(-7.5, 0.0, 2.5),
		Vector3(-8.5, 0.0, -1.0),
		Vector3(-10.0, 0.0, 1.0)
	]
	_atualizar_slots_grupo("ally_", pos_aliados)
	_atualizar_slots_grupo("enemy_", pos_inimigos)


func _atualizar_slots_grupo(prefixo: String, posicoes: Array[Vector3]) -> void:
	for i: int in range(posicoes.size()):
		var slot_name: String = prefixo + str(i + 1)
		var mk: Marker3D = slots_container.get_node_or_null(slot_name) as Marker3D
		if mk != null:
			var p: Vector3 = posicoes[i]
			terreno.posicionar_no_chao(mk, p.x, p.z, 0.0)
			if slot_name == "ally_6":
				mk.position.y += 1.45 # Elevação sobre o platô da rocha
