@tool
class_name CampoGrama
extends MultiMeshInstance3D

## Distribuição em MultiMesh de tufos de grama 2D sobre o TerrenoBatalha.
## Otimizado para Forward+ sem projeção de sombras individuais para alta performance.

@export var tex_tufo: Texture2D = null
@export var quantidade: int = 15000
@export var zonas_livres: Array[AABB] = []
@export var tamanho_tufo: Vector2 = Vector2(0.55, 0.55)
@export var cor_base: Color = Color(0.42, 0.52, 0.22)
@export var cor_ponta: Color = Color(0.68, 0.78, 0.32)


func _ready() -> void:
	if tex_tufo == null:
		const P_TUFO: String = "res://assets/art/props/vegetation/grass/grass_tuft_01.png"
		if ResourceLoader.exists(P_TUFO):
			tex_tufo = load(P_TUFO) as Texture2D
	gerar_grama()


func gerar_grama() -> void:
	var terreno: TerrenoBatalha = _obter_terreno()
	if terreno == null or tex_tufo == null:
		return
	material_override = _criar_material_grama()
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var mm: MultiMesh = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = _criar_mesh_tufo()
	mm.instance_count = quantidade
	var inst_validas: int = _popular_instancias(mm, terreno)
	mm.visible_instance_count = inst_validas
	multimesh = mm


func _obter_terreno() -> TerrenoBatalha:
	if get_parent() is TerrenoBatalha:
		return get_parent() as TerrenoBatalha
	return get_node_or_null("../Terrain") as TerrenoBatalha


func _criar_mesh_tufo() -> QuadMesh:
	var qm: QuadMesh = QuadMesh.new()
	qm.size = tamanho_tufo
	qm.center_offset = Vector3(0.0, tamanho_tufo.y * 0.5, 0.0)
	return qm


func _criar_material_grama() -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_texture = tex_tufo
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	mat.alpha_scissor_threshold = 0.45
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	return mat


func _posicao_em_zona_livre(pos: Vector3) -> bool:
	for zona: AABB in zonas_livres:
		if zona.has_point(pos):
			return true
	return false


func _posicao_valida(x: float, z: float, terreno: TerrenoBatalha) -> bool:
	assert(terreno != null, "Terreno não pode ser nulo")
	# Não spawnar grama sobre a praça central de combate ou rua
	if terreno.has_method("_mascara_rua"):
		var m: float = float(terreno.call("_mascara_rua", x, z))
		if m > 0.15:
			return false
	var y: float = terreno.altura_em(x, z)
	return not _posicao_em_zona_livre(Vector3(x, y, z))


func _popular_instancias(mm: MultiMesh, terreno: TerrenoBatalha) -> int:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 42
	var larg: float = terreno.largura
	var prof: float = terreno.profundidade
	var count: int = 0
	for i: int in range(quantidade):
		var x: float = rng.randf_range(-larg * 0.48, larg * 0.48)
		var z: float = rng.randf_range(-prof * 0.48, prof * 0.48)
		if not _posicao_valida(x, z, terreno):
			continue
		var y: float = terreno.altura_em(x, z)
		var t: Transform3D = _calcular_transform_tufo(x, y, z, rng)
		mm.set_instance_transform(count, t)
		count += 1
	return count


func _calcular_transform_tufo(x: float, y: float, z: float, rng: RandomNumberGenerator) -> Transform3D:
	var esc: float = rng.randf_range(0.85, 1.25)
	var rot_y: float = rng.randf_range(0.0, TAU)
	var b: Basis = Basis(Vector3.UP, rot_y).scaled(Vector3(esc, esc, esc))
	return Transform3D(b, Vector3(x, y, z))
