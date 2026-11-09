class_name BattleSceneLayout
extends Resource

## Define a arena, os slots táticos e a escala por profundidade de um cenário de batalha.
## Todas as posições são normalizadas (0.0 a 1.0) e representam o PÉ do combatente no chão.

@export var id_cenario: String = "baltazar_village"
@export var nome_cenario: String = "Vila da Forja de Baltazar"

# Área pisável da praça (X: 0.04 a 0.84 | Y: 0.58 a 0.93), medida sobre o background da vila.
@export var area_arena: Rect2 = Rect2(0.04, 0.58, 0.80, 0.35)

# Zonas dentro da arena que devem ficar livres: cerca, pedras/barris do primeiro plano e menu de ações.
@export var zonas_bloqueadas: Array[Rect2] = [
	Rect2(0.00, 0.80, 0.13, 0.20),
	Rect2(0.78, 0.82, 0.22, 0.18),
	Rect2(0.85, 0.66, 0.15, 0.34),
	Rect2(0.375, 0.68, 0.25, 0.15)
]

# Perspectiva: combatentes ao fundo (Y menor) ficam menores e os da frente (Y maior) ficam maiores.
@export var y_fundo: float = 0.58
@export var y_frente: float = 0.93
@export var escala_fundo: float = 0.70
@export var escala_frente: float = 1.10

# Formações dos heróis. O Slot 1 é sempre a âncora (vanguarda central); distribuição ampla pela metade direita.
@export var formacoes_aliados: Dictionary = {
	"LINHA_2X2": [
		Vector2(0.64, 0.70), # Slot 1: Âncora, coluna da frente
		Vector2(0.66, 0.84), # Slot 2: Coluna da frente, mais perto da tela
		Vector2(0.76, 0.65), # Slot 3: Coluna de trás, ao fundo
		Vector2(0.77, 0.79)  # Slot 4: Coluna de trás, meio
	],
	"LOSANGO": [
		Vector2(0.64, 0.72), # Slot 1: Âncora, ponta avançada
		Vector2(0.72, 0.62), # Slot 2: Flanco ao fundo
		Vector2(0.72, 0.84), # Slot 3: Flanco perto da tela
		Vector2(0.78, 0.72)  # Slot 4: Retaguarda
	],
	"VANGUARDA_3X1": [
		Vector2(0.64, 0.72), # Slot 1: Âncora, vanguarda central
		Vector2(0.65, 0.62), # Slot 2: Vanguarda ao fundo
		Vector2(0.65, 0.84), # Slot 3: Vanguarda perto da tela
		Vector2(0.78, 0.72)  # Slot 4: Retaguarda solitária
	],
	"RETAGUARDA_1X3": [
		Vector2(0.64, 0.72), # Slot 1: Âncora, vanguarda solitária
		Vector2(0.77, 0.72), # Slot 2: Retaguarda central
		Vector2(0.76, 0.62), # Slot 3: Retaguarda ao fundo
		Vector2(0.76, 0.84)  # Slot 4: Retaguarda perto da tela
	],
	"MEIA_LUA": [
		Vector2(0.64, 0.72), # Slot 1: Âncora, centro do arco
		Vector2(0.70, 0.63), # Slot 2: Ponta superior do arco
		Vector2(0.70, 0.84), # Slot 3: Ponta inferior do arco
		Vector2(0.78, 0.74)  # Slot 4: Fechamento do arco
	]
}

# Grade de 8 slots de inimigos espalhados pela praça esquerda (chefe ancorado em X <= 0.38).
@export var posicoes_monstros_padrao: Array[Vector2] = [
	Vector2(0.24, 0.72), # Slot 1: Chefe Principal / Inimigo 1 (X <= 0.38, Y no piso)
	Vector2(0.18, 0.63), # Slot 2: Fundo esquerdo
	Vector2(0.20, 0.85), # Slot 3: Frente esquerda
	Vector2(0.32, 0.64), # Slot 4: Fundo central
	Vector2(0.33, 0.84), # Slot 5: Frente central
	Vector2(0.10, 0.70), # Slot 6: Extremo esquerdo
	Vector2(0.14, 0.80), # Slot 7: Flanco esquerdo inferior
	Vector2(0.26, 0.80)  # Slot 8: Meio direito
]

# Cerco 1: Heróis encurralam os monstros (círculo 360 graus)
@export var cerco_herois_aliados: Array[Vector2] = [
	Vector2(0.62, 0.76), # Leste
	Vector2(0.18, 0.76), # Oeste
	Vector2(0.40, 0.62), # Norte
	Vector2(0.40, 0.90)  # Sul
]
@export var cerco_herois_monstros: Array[Vector2] = [
	Vector2(0.40, 0.76),
	Vector2(0.37, 0.70),
	Vector2(0.43, 0.82),
	Vector2(0.40, 0.84)
]

# Cerco 2: Monstros encurralam os heróis
@export var cerco_monstros_aliados: Array[Vector2] = [
	Vector2(0.40, 0.76), # Herói 1 centro
	Vector2(0.37, 0.70), # Herói 2
	Vector2(0.43, 0.82), # Herói 3
	Vector2(0.40, 0.84)  # Herói 4
]
@export var cerco_monstros_monstros: Array[Vector2] = [
	Vector2(0.62, 0.76), # Monstro Leste
	Vector2(0.18, 0.76), # Monstro Oeste
	Vector2(0.40, 0.62), # Monstro Norte
	Vector2(0.40, 0.90)  # Monstro Sul
]

# Pontos de interação normalizados
@export var pontos_interacao: Array[Dictionary] = [
	{"id": "bigorna", "pos": Vector2(0.86, 0.50), "tipo": "prop"},
	{"id": "fornalha", "pos": Vector2(0.914, 0.476), "tipo": "vfx"}
]


static func converter_para_tela(ponto_normalizado: Vector2, tamanho_viewport: Vector2) -> Vector2:
	return Vector2(
		ponto_normalizado.x * tamanho_viewport.x,
		ponto_normalizado.y * tamanho_viewport.y
	)


func obter_fator_profundidade(y_norm: float) -> float:
	var faixa: float = maxf(y_frente - y_fundo, 0.001)
	var t: float = clampf((y_norm - y_fundo) / faixa, 0.0, 1.0)
	return lerpf(escala_fundo, escala_frente, t)


func ponto_em_zona_bloqueada(ponto_norm: Vector2) -> bool:
	for zona: Rect2 in zonas_bloqueadas:
		if zona.has_point(ponto_norm):
			return true
	return false


func obter_posicao_aliado(idx: int, tatica: String, modo_encontro: String, tamanho_viewport: Vector2 = Vector2(1920.0, 1080.0)) -> Vector2:
	var pt_norm: Vector2 = Vector2(0.64, 0.70)
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
			pt_norm = Vector2(0.64 + idx * 0.04, 0.70)
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
