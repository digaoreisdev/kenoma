class_name ArenaTerrainVisual
extends Node3D

## Gera visualmente os blocos 3D empilhados a partir de um recurso ArenaTerrain.

const TEX_CHAO_DIFF: String = "res://assets/textures/piso_pedra/bricks_round-d.png"
const TEX_CHAO_NORM: String = "res://assets/textures/piso_pedra/bricks_round-n.png"
const TEX_ELEV_DIFF: String = "res://assets/textures/piso_pedra/bricks_edged-d.png"
const TEX_ELEV_NORM: String = "res://assets/textures/piso_pedra/bricks_edged-n.png"

@export var terrain: ArenaTerrain = null

var _mat_chao: StandardMaterial3D = null
var _mat_elevado: StandardMaterial3D = null
var _mesh_bloco: BoxMesh = null


func _ready() -> void:
	if terrain == null:
		terrain = load("res://resources/battle_layouts/arena_terrain_exemplo.tres") as ArenaTerrain
	if terrain != null:
		construir_terreno(terrain)


func construir_terreno(dados_terreno: ArenaTerrain) -> void:
	assert(dados_terreno != null, "ArenaTerrain não pode ser nulo")
	terrain = dados_terreno
	terrain.garantir_grade()
	_limpar_blocos()
	_preparar_recursos_visuais()
	for lin: int in range(terrain.linhas):
		for col: int in range(terrain.colunas):
			_criar_pilha_celula(col, lin)


func _limpar_blocos() -> void:
	for filho: Node in get_children():
		remove_child(filho)
		filho.queue_free()


func _preparar_recursos_visuais() -> void:
	_mesh_bloco = BoxMesh.new()
	_mesh_bloco.size = Vector3(terrain.tamanho_celula, terrain.altura_degrau, terrain.tamanho_celula)
	_mat_chao = _criar_material_pedra(TEX_CHAO_DIFF, TEX_CHAO_NORM, Color(0.58, 0.56, 0.52))
	_mat_elevado = _criar_material_pedra(TEX_ELEV_DIFF, TEX_ELEV_NORM, Color(0.68, 0.64, 0.58))


func _criar_material_pedra(caminho_diff: String, caminho_norm: String, cor_base: Color) -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = cor_base
	mat.roughness = 0.88
	mat.uv1_triplanar = true
	mat.uv1_scale = Vector3(0.45, 0.45, 0.45)
	if ResourceLoader.exists(caminho_diff):
		mat.albedo_texture = load(caminho_diff) as Texture2D
		mat.albedo_color = Color(0.92, 0.88, 0.82)
	if ResourceLoader.exists(caminho_norm):
		mat.normal_enabled = true
		mat.normal_texture = load(caminho_norm) as Texture2D
	return mat


func _criar_pilha_celula(col: int, lin: int) -> void:
	var dados: Dictionary = terrain.obter_celula(col, lin)
	var nivel: int = int(dados.get("nivel_altura", 0))
	var u: float = (float(col) + 0.5) / float(terrain.colunas)
	var v: float = (float(lin) + 0.5) / float(terrain.linhas)
	var pos_topo: Vector3 = terrain.normalizado_para_mundo(u, v)
	for camada: int in range(nivel + 1):
		var instancia: MeshInstance3D = MeshInstance3D.new()
		instancia.name = "Bloco_%d_%d_N%d" % [col, lin, camada]
		instancia.mesh = _mesh_bloco
		instancia.material_override = _mat_elevado if camada > 0 else _mat_chao
		var y_centro: float = (float(camada) - 0.5) * terrain.altura_degrau
		instancia.position = Vector3(pos_topo.x, y_centro, pos_topo.z)
		add_child(instancia)
