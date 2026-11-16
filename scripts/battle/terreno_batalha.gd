@tool
class_name TerrenoBatalha
extends Node3D

## Terreno procedural para cena de batalha HD-2D (Godot 4.x)
##
## Convenção: a câmera fica na FRENTE (+Z) olhando para o FUNDO (-Z).
##   - Frente: praça totalmente plana (onde ficam os sprites da batalha)
##   - Fundo: o chão sobe suavemente, a rua estreita e curva (vila do Baltazar)
##   - Laterais: barrancos baixos que escondem a borda do mapa

@export_group("Tamanho")
@export var largura: float = 70.0          # eixo X, em metros
@export var profundidade: float = 60.0     # eixo Z, em metros
@export var celula: float = 0.5            # tamanho de cada quadradinho

@export_group("Relevo")
@export var z_inicio_subida: float = 0.0   # daqui em direção ao fundo o chão começa a subir
@export var altura_subida: float = 6.0     # quanto o chão sobe até o fundo
@export var x_plano: float = 20.0          # |X| até onde as laterais ficam planas
@export var largura_talude: float = 15.0   # distância em que o barranco lateral sobe
@export var altura_talude: float = 2.5
@export var amp_ondulacao: float = 0.6     # ondulações suaves do terreno (não afeta a praça)
@export var freq_ondulacao: float = 0.05
@export var semente: int = 7

@export_group("Rua")
@export var largura_praca: float = 36.0    # largura da área batalha/praça na frente
@export var largura_rua: float = 8.0       # largura da rua lá no fundo
@export var curva_rua: float = 5.0         # quanto a rua serpenteia no X
@export var freq_curva: float = 0.08
@export var borda_rua: float = 1.5         # suavidade da transição rua -> grama
@export var rebaixo_rua: float = 0.08      # a rua fica levemente mais baixa

@export_group("Material")
@export var tex_estrada: Texture2D = null  # paralelepípedo / terra batida
@export var tex_grama: Texture2D = null    # grama / terra das laterais
@export var tiling: float = 0.25           # repetições por metro
@export var cor_estrada: Color = Color(0.58, 0.44, 0.28)
@export var cor_grama: Color = Color(0.36, 0.44, 0.20)

@export_group("Física")
@export var gerar_colisao: bool = true

var _ruido: FastNoiseLite = FastNoiseLite.new()
var _malha: MeshInstance3D = null
var _corpo: StaticBody3D = null


func _ready() -> void:
	gerar()


## Quanto "andamos" para o fundo, de 0 (praça) a 1 (borda do fundo).
func _u(z: float) -> float:
	var dist: float = maxf(z_inicio_subida + profundidade * 0.5, 0.001)
	return clampf((z_inicio_subida - z) / dist, 0.0, 1.0)


func _centro_rua(z: float) -> float:
	return sin(z * freq_curva) * curva_rua * smoothstep(0.0, 0.4, _u(z))


## 1.0 em cima da rua/praça, 0.0 na grama, com transição suave.
func _mascara_rua(x: float, z: float) -> float:
	var larg: float = lerpf(largura_praca, largura_rua, smoothstep(0.0, 0.6, _u(z)))
	var d: float = absf(x - _centro_rua(z))
	return 1.0 - smoothstep(larg * 0.5, larg * 0.5 + borda_rua, d)


## Altura do chão em qualquer ponto (X, Z) locais do terreno.
func altura_em(x: float, z: float) -> float:
	var u: float = _u(z)
	var m: float = _mascara_rua(x, z)
	var h: float = altura_subida * smoothstep(0.0, 1.0, u)
	h += altura_talude * smoothstep(x_plano, x_plano + largura_talude, absf(x))
	h += _ruido.get_noise_2d(x, z) * amp_ondulacao * smoothstep(0.0, 0.35, u) * (1.0 - m * 0.7)
	h -= m * rebaixo_rua * smoothstep(0.0, 0.2, u)
	return h


func _normal_em(x: float, z: float) -> Vector3:
	var e: float = celula
	var dx: float = altura_em(x + e, z) - altura_em(x - e, z)
	var dz: float = altura_em(x, z + e) - altura_em(x, z - e)
	return Vector3(-dx / (2.0 * e), 1.0, -dz / (2.0 * e)).normalized()


## Coloca um nó em pé sobre o chão. offset_y = altura do "pé" do sprite.
func posicionar_no_chao(no: Node3D, x: float, z: float, offset_y: float = 0.0) -> void:
	assert(no != null, "Nó a posicionar não pode ser nulo")
	var lpos: Vector3 = Vector3(x, altura_em(x, z) + offset_y, z)
	if is_inside_tree():
		no.global_position = to_global(lpos)
	else:
		no.position = lpos


## Inclinação do terreno em graus (0 = plano).
func inclinacao_em(x: float, z: float) -> float:
	return rad_to_deg(acos(clampf(_normal_em(x, z).y, -1.0, 1.0)))


func gerar() -> void:
	if _malha != null:
		_malha.queue_free()
	if _corpo != null:
		_corpo.queue_free()
	_inicializar_ruido()
	var nx: int = maxi(int(largura / celula), 1)
	var nz: int = maxi(int(profundidade / celula), 1)
	var arrays: Array = _construir_arrays_malha(nx, nz)
	var malha: ArrayMesh = ArrayMesh.new()
	malha.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	_criar_instancia_malha(malha)
	if gerar_colisao:
		_criar_colisao(malha)


func _inicializar_ruido() -> void:
	_ruido.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_ruido.frequency = freq_ondulacao
	_ruido.seed = semente


func _construir_arrays_malha(nx: int, nz: int) -> Array:
	var verts: PackedVector3Array = PackedVector3Array()
	var normais: PackedVector3Array = PackedVector3Array()
	var uvs: PackedVector2Array = PackedVector2Array()
	var cores: PackedColorArray = PackedColorArray()
	var indices: PackedInt32Array = PackedInt32Array()

	for iz: int in range(nz + 1):
		for ix: int in range(nx + 1):
			var x: float = -largura * 0.5 + ix * celula
			var z: float = -profundidade * 0.5 + iz * celula
			verts.append(Vector3(x, altura_em(x, z), z))
			normais.append(_normal_em(x, z))
			uvs.append(Vector2(float(ix) / nx, float(iz) / nz))
			cores.append(Color(_mascara_rua(x, z), 0.0, 0.0, 1.0))

	for iz: int in range(nz):
		for ix: int in range(nx):
			var a: int = iz * (nx + 1) + ix
			var b: int = a + 1
			var c: int = a + (nx + 1)
			var d: int = c + 1
			# Triângulos com winding anti-horário visto de cima (OpenGL/Godot padrão): a, c, b e b, c, d
			indices.append_array([a, c, b, b, c, d])

	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = normais
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_COLOR] = cores
	arrays[Mesh.ARRAY_INDEX] = indices
	return arrays


func _criar_instancia_malha(malha: ArrayMesh) -> void:
	_malha = MeshInstance3D.new()
	_malha.name = "TerrenoMalha"
	_malha.mesh = malha
	_malha.material_override = _criar_material()
	add_child(_malha)


func _criar_colisao(malha: ArrayMesh) -> void:
	_corpo = StaticBody3D.new()
	_corpo.name = "TerrenoColisao"
	var col: CollisionShape3D = CollisionShape3D.new()
	col.shape = malha.create_trimesh_shape()
	_corpo.add_child(col)
	add_child(_corpo)


func _criar_material() -> ShaderMaterial:
	var sh: Shader = Shader.new()
	sh.code = """
shader_type spatial;

uniform sampler2D tex_estrada : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D tex_grama : source_color, filter_linear_mipmap, repeat_enable;
uniform bool usar_texturas = false;
uniform vec3 cor_estrada : source_color;
uniform vec3 cor_grama : source_color;
uniform float tiling = 0.25;

varying vec3 pos_mundo;
varying float mascara;

void vertex() {
	pos_mundo = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	mascara = COLOR.r;
}

void fragment() {
	vec2 uv = pos_mundo.xz * tiling;
	vec3 estrada = usar_texturas ? texture(tex_estrada, uv).rgb : cor_estrada;
	vec3 grama = usar_texturas ? texture(tex_grama, uv).rgb : cor_grama;
	ALBEDO = mix(grama, estrada, smoothstep(0.35, 0.65, mascara));
	ROUGHNESS = 1.0;
	SPECULAR = 0.1;
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = sh
	mat.set_shader_parameter("tiling", tiling)
	mat.set_shader_parameter("cor_estrada", Vector3(cor_estrada.r, cor_estrada.g, cor_estrada.b))
	mat.set_shader_parameter("cor_grama", Vector3(cor_grama.r, cor_grama.g, cor_grama.b))
	if tex_estrada != null and tex_grama != null:
		mat.set_shader_parameter("usar_texturas", true)
		mat.set_shader_parameter("tex_estrada", tex_estrada)
		mat.set_shader_parameter("tex_grama", tex_grama)
	return mat
