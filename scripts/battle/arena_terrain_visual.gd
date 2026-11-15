class_name ArenaTerrainVisual
extends Node3D

## Renderiza o pátio 3D original da Vila do Baltazar intacto na praça e o patamar superior elevado ao fundo para acesso às casas e árvores.

const CAMINHO_PATIO_GLB: String = "res://assets/models/arena/patio_vila_baltazar.glb"
const CAMINHO_CHAO_RUSTICO: String = "res://assets/art/battle_backgrounds/baltazar_village/chao_rustico_vila.png"
const ANGULO_NIVELAMENTO_X_DEG: float = -3.63
const OFFSET_SUPERFICIE_Y: float = 0.0535
const ESCALA_ALTURA_RELEVO: float = 26.0
const FATOR_LARGURA_PATIO: float = 1.35
const FATOR_PROFUNDIDADE_PATIO: float = 1.25
const ALTURA_PATAMAR_FUNDO: float = 0.88

@export var terrain: ArenaTerrain = null

var _cena_patio: PackedScene = null
var _mat_chao_rustico: StandardMaterial3D = null
var patio_instancia: Node3D = null


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
	_instanciar_patio_unico()
	_instanciar_patamar_superior_fundo()


func _limpar_blocos() -> void:
	for filho: Node in get_children():
		remove_child(filho)
		filho.queue_free()
	patio_instancia = null


func _preparar_recursos_visuais() -> void:
	if ResourceLoader.exists(CAMINHO_PATIO_GLB):
		_cena_patio = load(CAMINHO_PATIO_GLB) as PackedScene
	_mat_chao_rustico = StandardMaterial3D.new()
	_mat_chao_rustico.albedo_color = Color(0.92, 0.84, 0.72)
	_mat_chao_rustico.roughness = 0.92
	_mat_chao_rustico.uv1_triplanar = true
	_mat_chao_rustico.uv1_scale = Vector3(0.22, 0.22, 0.22)
	if ResourceLoader.exists(CAMINHO_CHAO_RUSTICO):
		_mat_chao_rustico.albedo_texture = load(CAMINHO_CHAO_RUSTICO) as Texture2D


func _instanciar_patio_unico() -> void:
	var largura_arena: float = float(terrain.colunas) * terrain.tamanho_celula * FATOR_LARGURA_PATIO
	var prof_arena: float = float(terrain.linhas) * terrain.tamanho_celula * FATOR_PROFUNDIDADE_PATIO
	if _cena_patio != null:
		patio_instancia = _cena_patio.instantiate() as Node3D
		patio_instancia.name = "PatioVilaBaltazar"
		_nivelar_malha_patio(patio_instancia, largura_arena, prof_arena)
		add_child(patio_instancia)
	else:
		var fallback: MeshInstance3D = MeshInstance3D.new()
		fallback.name = "PatioVilaBaltazar"
		var box: BoxMesh = BoxMesh.new()
		box.size = Vector3(largura_arena, 0.2, prof_arena)
		fallback.mesh = box
		fallback.position = Vector3(0.0, -0.1, 0.0)
		add_child(fallback)
		patio_instancia = fallback


func _instanciar_patamar_superior_fundo() -> void:
	var plato_fundo: MeshInstance3D = _criar_bloco_terreno(
		"PatamarSuperiorVila",
		Vector3(48.0, 2.0, 16.0),
		Vector3(0.0, ALTURA_PATAMAR_FUNDO - 1.0, -15.8)
	)
	add_child(plato_fundo)
	var aba_esq: MeshInstance3D = _criar_bloco_terreno(
		"TerracoLateralEsquerdo",
		Vector3(10.0, 1.6, 12.0),
		Vector3(-17.8, 0.54 - 0.8, -3.5)
	)
	add_child(aba_esq)
	var aba_dir: MeshInstance3D = _criar_bloco_terreno(
		"TerracoLateralDireito",
		Vector3(10.0, 1.6, 12.0),
		Vector3(17.8, 0.54 - 0.8, -3.5)
	)
	add_child(aba_dir)


func _criar_bloco_terreno(nome: String, tamanho: Vector3, pos: Vector3) -> MeshInstance3D:
	var mi: MeshInstance3D = MeshInstance3D.new()
	mi.name = nome
	var box: BoxMesh = BoxMesh.new()
	box.size = tamanho
	mi.mesh = box
	mi.material_override = _mat_chao_rustico
	mi.position = pos
	return mi


func _nivelar_malha_patio(instancia: Node3D, largura_alvo: float, prof_alvo: float) -> void:
	var mesh_node: MeshInstance3D = _achar_primeiro_mesh(instancia)
	var aabb: AABB = AABB(Vector3(-0.5, -0.08, -0.35), Vector3(1.0, 0.16, 0.70))
	if mesh_node != null and mesh_node.mesh != null:
		aabb = mesh_node.mesh.get_aabb()
		mesh_node.transform = Transform3D.IDENTITY
		mesh_node.rotation_degrees = Vector3(ANGULO_NIVELAMENTO_X_DEG, 0.0, 0.0)
		mesh_node.position = Vector3(0.0, -OFFSET_SUPERFICIE_Y, 0.0)
	var tam: Vector3 = aabb.size
	var sx: float = largura_alvo / maxf(0.01, tam.x)
	var sz: float = prof_alvo / maxf(0.01, tam.z)
	instancia.scale = Vector3(sx, ESCALA_ALTURA_RELEVO, sz)
	instancia.position = Vector3.ZERO


func _achar_primeiro_mesh(raiz: Node) -> MeshInstance3D:
	if raiz is MeshInstance3D:
		return raiz as MeshInstance3D
	for filho: Node in raiz.get_children():
		var achado: MeshInstance3D = _achar_primeiro_mesh(filho)
		if achado != null:
			return achado
	return null
