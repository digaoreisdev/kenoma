class_name ArenaTerrainVisual
extends Node3D

## Renderiza o pátio 3D único da Vila de Baltazar nivelado exatamente na base da arena (Y=0.0) preservando a altura real da escada e da fonte.

const CAMINHO_PATIO_GLB: String = "res://assets/models/arena/patio_vila_baltazar.glb"
const ANGULO_NIVELAMENTO_X_DEG: float = -3.63
const OFFSET_SUPERFICIE_Y: float = 0.0535
const ESCALA_ALTURA_RELEVO: float = 26.0

@export var terrain: ArenaTerrain = null

var _cena_patio: PackedScene = null
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


func _limpar_blocos() -> void:
	for filho: Node in get_children():
		remove_child(filho)
		filho.queue_free()
	patio_instancia = null


func _preparar_recursos_visuais() -> void:
	if ResourceLoader.exists(CAMINHO_PATIO_GLB):
		_cena_patio = load(CAMINHO_PATIO_GLB) as PackedScene


func _instanciar_patio_unico() -> void:
	var largura_arena: float = float(terrain.colunas) * terrain.tamanho_celula
	var prof_arena: float = float(terrain.linhas) * terrain.tamanho_celula
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


func _nivelar_malha_patio(raiz_patio: Node3D, largura_arena: float, prof_arena: float) -> void:
	for filho: Node in raiz_patio.get_children():
		if filho is MeshInstance3D:
			var mesh_inst: MeshInstance3D = filho as MeshInstance3D
			var mat_ativo: Material = mesh_inst.get_active_material(0)
			mesh_inst.mesh = _criar_malha_nivelada(mesh_inst.mesh, mat_ativo)
			var aabb: AABB = mesh_inst.mesh.get_aabb()
			var tam_x: float = maxf(aabb.size.x, 0.01)
			var tam_z: float = maxf(aabb.size.z, 0.01)
			mesh_inst.scale = Vector3(largura_arena / tam_x, ESCALA_ALTURA_RELEVO, prof_arena / tam_z)
			mesh_inst.position = Vector3.ZERO


func _criar_malha_nivelada(malha_orig: Mesh, mat_orig: Material) -> ArrayMesh:
	var arrays: Array = malha_orig.surface_get_arrays(0)
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var norms: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var rot: Basis = Basis(Vector3.RIGHT, deg_to_rad(ANGULO_NIVELAMENTO_X_DEG))
	for i: int in range(verts.size()):
		var v: Vector3 = rot * verts[i]
		v.y -= OFFSET_SUPERFICIE_Y
		verts[i] = v
	for i: int in range(norms.size()):
		norms[i] = (rot * norms[i]).normalized()
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = norms
	var nova_malha: ArrayMesh = ArrayMesh.new()
	nova_malha.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	if mat_orig != null:
		nova_malha.surface_set_material(0, mat_orig)
	return nova_malha
