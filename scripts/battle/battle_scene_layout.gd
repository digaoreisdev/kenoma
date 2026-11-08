class_name BattleSceneLayout
extends Resource

## Define os pontos fixos e formações táticas em coordenadas normalizadas (0.0 a 1.0) para a arena.

@export var id_cenario: String = "baltazar_village"
@export var nome_cenario: String = "Vila da Forja de Baltazar"

# Formações Táticas Normalizadas dos Heróis (X entre 0.54 e 0.73, Y entre 0.62 e 0.80)
@export var formacoes_aliados: Dictionary = {
	"LINHA_2X2": [
		Vector2(0.55, 0.68), # Slot 1: Vanguarda superior
		Vector2(0.55, 0.78), # Slot 2: Vanguarda inferior
		Vector2(0.67, 0.66), # Slot 3: Retaguarda superior
		Vector2(0.67, 0.76)  # Slot 4: Retaguarda inferior
	],
	"LOSANGO": [
		Vector2(0.54, 0.72), # Slot 1: Ponta central avançada
		Vector2(0.63, 0.64), # Slot 2: Flanco superior
		Vector2(0.63, 0.80), # Slot 3: Flanco inferior
		Vector2(0.72, 0.72)  # Slot 4: Retaguarda recuada
	],
	"VANGUARDA_3X1": [
		Vector2(0.55, 0.72), # Slot 1: Vanguarda centro
		Vector2(0.55, 0.63), # Slot 2: Vanguarda topo
		Vector2(0.55, 0.80), # Slot 3: Vanguarda baixo
		Vector2(0.69, 0.72)  # Slot 4: Retaguarda solitária
	],
	"RETAGUARDA_1X3": [
		Vector2(0.55, 0.72), # Slot 1: Vanguarda solitária
		Vector2(0.69, 0.72), # Slot 2: Retaguarda centro
		Vector2(0.69, 0.63), # Slot 3: Retaguarda topo
		Vector2(0.69, 0.80)  # Slot 4: Retaguarda baixo
	],
	"MEIA_LUA": [
		Vector2(0.58, 0.72), # Slot 1: Centro convexo
		Vector2(0.66, 0.63), # Slot 2: Curva superior
		Vector2(0.66, 0.80), # Slot 3: Curva inferior
		Vector2(0.73, 0.72)  # Slot 4: Ponta extrema
	]
}

# Grade Normalizada de 8 Slots de Inimigos (X entre 0.18 e 0.38, Y entre 0.62 e 0.80)
@export var posicoes_monstros_padrao: Array[Vector2] = [
	Vector2(0.24, 0.72), # Slot 1: Chefe Principal / Inimigo 1
	Vector2(0.20, 0.64), # Slot 2: Retaguarda alta
	Vector2(0.20, 0.78), # Slot 3: Retaguarda baixa
	Vector2(0.32, 0.66), # Slot 4: Meio alto
	Vector2(0.32, 0.76), # Slot 5: Meio baixo
	Vector2(0.36, 0.71), # Slot 6: Vanguarda centro
	Vector2(0.26, 0.63), # Slot 7: Reserva topo
	Vector2(0.26, 0.79)  # Slot 8: Reserva base
]

# Cerco 1: Heróis encurralam os monstros (círculo 360 graus)
@export var cerco_herois_aliados: Array[Vector2] = [
	Vector2(0.58, 0.71), # Leste
	Vector2(0.22, 0.71), # Oeste
	Vector2(0.40, 0.62), # Norte
	Vector2(0.40, 0.80)  # Sul
]
@export var cerco_herois_monstros: Array[Vector2] = [
	Vector2(0.40, 0.71),
	Vector2(0.37, 0.68),
	Vector2(0.43, 0.74),
	Vector2(0.40, 0.75)
]

# Cerco 2: Monstros encurralam os heróis
@export var cerco_monstros_aliados: Array[Vector2] = [
	Vector2(0.40, 0.71), # Herói 1 centro
	Vector2(0.37, 0.68), # Herói 2
	Vector2(0.43, 0.74), # Herói 3
	Vector2(0.40, 0.75)  # Herói 4
]
@export var cerco_monstros_monstros: Array[Vector2] = [
	Vector2(0.58, 0.71), # Monstro Leste
	Vector2(0.22, 0.71), # Monstro Oeste
	Vector2(0.40, 0.62), # Monstro Norte
	Vector2(0.40, 0.80)  # Monstro Sul
]

# Pontos de interação normalizados
@export var pontos_interacao: Array[Dictionary] = [
	{"id": "bigorna", "pos": Vector2(0.83, 0.77), "tipo": "prop"},
	{"id": "fornalha", "pos": Vector2(0.534, 0.317), "tipo": "vfx"}
]


static func converter_para_tela(ponto_normalizado: Vector2, tamanho_viewport: Vector2) -> Vector2:
	return Vector2(
		ponto_normalizado.x * tamanho_viewport.x,
		ponto_normalizado.y * tamanho_viewport.y
	)


func obter_posicao_aliado(idx: int, tatica: String, modo_encontro: String, tamanho_viewport: Vector2 = Vector2(1920.0, 1080.0)) -> Vector2:
	var pt_norm: Vector2 = Vector2(0.55, 0.68)
	if modo_encontro == "HEROIS_ENCURRALAM":
		if idx >= 0 and idx < cerco_herois_aliados.size():
			pt_norm = cerco_herois_aliados[idx]
	elif modo_encontro == "MONSTROS_ENCURRALAM":
		if idx >= 0 and idx < cerco_monstros_aliados.size():
			pt_norm = cerco_monstros_aliados[idx]
	else:
		var slots: Array = formacoes_aliados.get(tatica, formacoes_aliados.get("LINHA_2X2", []))
		if idx >= 0 and idx < slots.size():
			pt_norm = slots[idx] as Vector2
		else:
			pt_norm = Vector2(0.55 + idx * 0.04, 0.70)
	return converter_para_tela(pt_norm, tamanho_viewport)


func obter_posicao_inimigo(idx: int, _total_inimigos: int, _is_boss: bool, modo_encontro: String, tamanho_viewport: Vector2 = Vector2(1920.0, 1080.0)) -> Vector2:
	var pt_norm: Vector2 = Vector2(0.24, 0.72)
	if modo_encontro == "HEROIS_ENCURRALAM":
		if idx >= 0 and idx < cerco_herois_monstros.size():
			pt_norm = cerco_herois_monstros[idx]
	elif modo_encontro == "MONSTROS_ENCURRALAM":
		if idx >= 0 and idx < cerco_monstros_monstros.size():
			pt_norm = cerco_monstros_monstros[idx]
	else:
		if idx >= 0 and idx < posicoes_monstros_padrao.size():
			pt_norm = posicoes_monstros_padrao[idx]
		else:
			pt_norm = Vector2(0.24 - idx * 0.02, 0.72)
	return converter_para_tela(pt_norm, tamanho_viewport)
