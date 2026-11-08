class_name BattleSceneLayout
extends Resource

## Define os pontos fixos e formações táticas de batalha para um cenário específico.

@export var id_cenario: String = "baltazar_village"
@export var nome_cenario: String = "Vila da Forja de Baltazar"
@export var posicao_chefe_unico: Vector2 = Vector2(640.0, 465.0)

# Formações Táticas do Usuário (Slot 1 = Posição mais central do chão)
@export var formacoes_aliados: Dictionary = {
	"LINHA_2X2": [
		Vector2(820.0, 530.0), # Slot 1: Central no chão da tela
		Vector2(970.0, 480.0), # Slot 2: Retaguarda superior
		Vector2(840.0, 610.0), # Slot 3: Vanguarda inferior
		Vector2(990.0, 560.0)  # Slot 4: Retaguarda inferior
	],
	"LOSANGO": [
		Vector2(800.0, 530.0), # Slot 1: Ponta central avançada
		Vector2(930.0, 460.0), # Slot 2: Flanco superior
		Vector2(930.0, 600.0), # Slot 3: Flanco inferior
		Vector2(1060.0, 530.0) # Slot 4: Retaguarda recuada
	],
	"VANGUARDA_3X1": [
		Vector2(820.0, 530.0), # Slot 1: Vanguarda centro
		Vector2(840.0, 450.0), # Slot 2: Vanguarda topo
		Vector2(840.0, 610.0), # Slot 3: Vanguarda inferior
		Vector2(1020.0, 530.0) # Slot 4: Retaguarda solitária
	],
	"RETAGUARDA_1X3": [
		Vector2(800.0, 530.0), # Slot 1: Vanguarda solitária
		Vector2(980.0, 530.0), # Slot 2: Retaguarda centro
		Vector2(1000.0, 450.0),# Slot 3: Retaguarda topo
		Vector2(1000.0, 610.0) # Slot 4: Retaguarda inferior
	],
	"MEIA_LUA": [
		Vector2(800.0, 530.0), # Slot 1: Centro convexo
		Vector2(890.0, 460.0), # Slot 2: Curva superior
		Vector2(890.0, 600.0), # Slot 3: Curva inferior
		Vector2(1020.0, 430.0) # Slot 4: Ponta extrema
	]
}

# Posições normais dos monstros (quando não é cerco e não é chefe único)
@export var posicoes_monstros_padrao: Array[Vector2] = [
	Vector2(420.0, 530.0),
	Vector2(320.0, 460.0),
	Vector2(320.0, 600.0),
	Vector2(220.0, 530.0)
]

# Cerco 1: Heróis encurralam os monstros (círculo completo de 360 graus)
@export var cerco_herois_aliados: Array[Vector2] = [
	Vector2(850.0, 530.0), # Leste (frente dos monstros)
	Vector2(430.0, 530.0), # Oeste (costas dos monstros)
	Vector2(640.0, 440.0), # Norte (topo do chão)
	Vector2(640.0, 620.0)  # Sul (base do chão)
]
@export var cerco_herois_monstros: Array[Vector2] = [
	Vector2(640.0, 530.0),
	Vector2(600.0, 510.0),
	Vector2(680.0, 550.0),
	Vector2(640.0, 560.0)
]

# Cerco 2: Monstros encurralam os heróis
@export var cerco_monstros_aliados: Array[Vector2] = [
	Vector2(640.0, 530.0), # Herói 1 centro da praça
	Vector2(600.0, 510.0), # Herói 2
	Vector2(680.0, 520.0), # Herói 3
	Vector2(640.0, 560.0)  # Herói 4
]
@export var cerco_monstros_monstros: Array[Vector2] = [
	Vector2(850.0, 530.0), # Monstro Leste
	Vector2(430.0, 530.0), # Monstro Oeste
	Vector2(640.0, 440.0), # Monstro Norte
	Vector2(640.0, 620.0)  # Monstro Sul
]

# Pontos de interesse / interação no cenário
@export var pontos_interacao: Array[Dictionary] = [
	{"id": "bigorna", "pos": Vector2(1040.0, 520.0), "tipo": "prop"},
	{"id": "fornalha", "pos": Vector2(1026.0, 342.0), "tipo": "vfx"}
]


func obter_posicao_aliado(idx: int, tatica: String, modo_encontro: String) -> Vector2:
	if modo_encontro == "HEROIS_ENCURRALAM":
		if idx >= 0 and idx < cerco_herois_aliados.size():
			return cerco_herois_aliados[idx]
	elif modo_encontro == "MONSTROS_ENCURRALAM":
		if idx >= 0 and idx < cerco_monstros_aliados.size():
			return cerco_monstros_aliados[idx]
	var slots: Array = formacoes_aliados.get(tatica, formacoes_aliados.get("LINHA_2X2", []))
	if idx >= 0 and idx < slots.size():
		return slots[idx] as Vector2
	return Vector2(820.0 + idx * 30.0, 530.0)


func obter_posicao_inimigo(idx: int, total_inimigos: int, is_boss: bool, modo_encontro: String) -> Vector2:
	if is_boss and total_inimigos == 1:
		return posicao_chefe_unico
	if modo_encontro == "HEROIS_ENCURRALAM":
		if idx >= 0 and idx < cerco_herois_monstros.size():
			return cerco_herois_monstros[idx]
	elif modo_encontro == "MONSTROS_ENCURRALAM":
		if idx >= 0 and idx < cerco_monstros_monstros.size():
			return cerco_monstros_monstros[idx]
	if idx >= 0 and idx < posicoes_monstros_padrao.size():
		return posicoes_monstros_padrao[idx]
	return Vector2(420.0 - idx * 40.0, 530.0)
