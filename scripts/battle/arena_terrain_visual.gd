@tool
class_name ArenaTerrainVisual
extends Node3D

## Renderiza exclusivamente o pátio 3D original da Vila de Baltazar (patio_vila_baltazar.glb) isolado na cena.

const CAMINHO_PATIO_GLB: String = "res://assets/models/arena/patio_vila_baltazar.glb"
const ANGULO_NIVELAMENTO_X_DEG: float = -3.63
const OFFSET_SUPERFICIE_Y: float = 0.0535
const ESCALA_PATIO_BASE: float = 26.0

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
	_limpar_outros_elementos()
	_carregar_recurso_patio()
	_garantir_patio_unico()


func _limpar_outros_elementos() -> void:
	for filho: Node in get_children():
		if filho.name != "PatioVilaBaltazar":
			filho.queue_free()


func _carregar_recurso_patio() -> void:
	if ResourceLoader.exists(CAMINHO_PATIO_GLB):
		_cena_patio = load(CAMINHO_PATIO_GLB) as PackedScene


func _garantir_patio_unico() -> void:
	var existente: Node3D = get_node_or_null("PatioVilaBaltazar") as Node3D
	if existente != null:
		patio_instancia = existente
		_nivelar_patio(patio_instancia)
		return
	if _cena_patio != null:
		patio_instancia = _cena_patio.instantiate() as Node3D
		patio_instancia.name = "PatioVilaBaltazar"
		_nivelar_patio(patio_instancia)
		add_child(patio_instancia)
	else:
		patio_instancia = _criar_fallback_patio()
		add_child(patio_instancia)


func _nivelar_patio(instancia: Node3D) -> void:
	instancia.scale = Vector3(ESCALA_PATIO_BASE, ESCALA_PATIO_BASE, ESCALA_PATIO_BASE)
	instancia.position = Vector3.ZERO
	for filho: Node in instancia.find_children("*", "MeshInstance3D", true, false):
		var mi: MeshInstance3D = filho as MeshInstance3D
		if mi != null:
			mi.rotation_degrees = Vector3(ANGULO_NIVELAMENTO_X_DEG, 0.0, 0.0)
			mi.position = Vector3(0.0, -OFFSET_SUPERFICIE_Y, 0.0)


func _criar_fallback_patio() -> MeshInstance3D:
	var mi: MeshInstance3D = MeshInstance3D.new()
	mi.name = "PatioVilaBaltazar"
	var cyl: CylinderMesh = CylinderMesh.new()
	cyl.top_radius = 12.0
	cyl.bottom_radius = 12.0
	cyl.height = 0.4
	mi.mesh = cyl
	mi.position = Vector3(0.0, -0.2, 0.0)
	return mi
