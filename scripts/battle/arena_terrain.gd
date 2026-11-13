class_name ArenaTerrain
extends Resource

## Define a grade 3D de terreno em blocos com níveis de altura para arenas HD-2D.

enum TipoCelula {
	CHAO = 0,
	OBSTACULO = 1,
	RAMPA = 2
}

@export var colunas: int = 12
@export var linhas: int = 8
@export var tamanho_celula: float = 1.6
@export var altura_degrau: float = 0.75
@export var celulas: Array[Dictionary] = []


func _init() -> void:
	garantir_grade()


func garantir_grade() -> void:
	var total: int = maxi(colunas, 1) * maxi(linhas, 1)
	while celulas.size() < total:
		celulas.append({"nivel_altura": 0, "tipo": TipoCelula.CHAO})
	if celulas.size() > total:
		celulas.resize(total)


func definir_celula(col: int, lin: int, nivel: int, tipo_celula: int = TipoCelula.CHAO) -> void:
	garantir_grade()
	if col < 0 or col >= colunas or lin < 0 or lin >= linhas:
		return
	var idx: int = lin * colunas + col
	celulas[idx] = {"nivel_altura": maxi(nivel, 0), "tipo": tipo_celula}


func obter_celula(col: int, lin: int) -> Dictionary:
	garantir_grade()
	var c_clamp: int = clampi(col, 0, maxi(colunas - 1, 0))
	var l_clamp: int = clampi(lin, 0, maxi(linhas - 1, 0))
	var idx: int = l_clamp * colunas + c_clamp
	return celulas[idx]


func _uv_para_indices(u: float, v: float) -> Vector2i:
	var u_clamp: float = clampf(u, 0.0, 1.0)
	var v_clamp: float = clampf(v, 0.0, 1.0)
	var col: int = clampi(int(floor(u_clamp * float(colunas))), 0, maxi(colunas - 1, 0))
	var lin: int = clampi(int(floor(v_clamp * float(linhas))), 0, maxi(linhas - 1, 0))
	return Vector2i(col, lin)


func get_altura(u: float, v: float) -> float:
	var indices: Vector2i = _uv_para_indices(u, v)
	var dados: Dictionary = obter_celula(indices.x, indices.y)
	var nivel: int = int(dados.get("nivel_altura", 0))
	return float(nivel) * altura_degrau


func normalizado_para_mundo(u: float, v: float) -> Vector3:
	var u_clamp: float = clampf(u, 0.0, 1.0)
	var v_clamp: float = clampf(v, 0.0, 1.0)
	var largura_total: float = float(colunas) * tamanho_celula
	var prof_total: float = float(linhas) * tamanho_celula
	var x: float = (u_clamp - 0.5) * largura_total
	var z: float = (v_clamp - 0.5) * prof_total
	var y: float = get_altura(u_clamp, v_clamp)
	return Vector3(x, y, z)


static func criar_exemplo_patamar_lateral() -> ArenaTerrain:
	var t: ArenaTerrain = ArenaTerrain.new()
	t.colunas = 12
	t.linhas = 8
	t.tamanho_celula = 1.6
	t.altura_degrau = 0.75
	t.garantir_grade()
	_preencher_patamares_exemplo(t)
	return t


static func _preencher_patamares_exemplo(t: ArenaTerrain) -> void:
	for lin: int in range(t.linhas):
		for col: int in range(t.colunas):
			if col <= 2 and lin <= 4:
				t.definir_celula(col, lin, 2, TipoCelula.CHAO)
			elif col == 3 and lin <= 4:
				t.definir_celula(col, lin, 1, TipoCelula.RAMPA)
			elif col >= 9 and lin <= 3:
				t.definir_celula(col, lin, 1, TipoCelula.CHAO)
			elif lin == 0 and col >= 4 and col <= 8:
				t.definir_celula(col, lin, 1, TipoCelula.OBSTACULO)
