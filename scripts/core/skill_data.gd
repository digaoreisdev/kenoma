class_name SkillData
extends Resource

## Dados estruturados de habilidades e técnicas ativas no Kenoma.

enum TargetType {
	SINGLE_ENEMY,
	ALL_ENEMIES,
	SINGLE_ALLY,
	SELF,
}

@export var id: String = ""
@export var nome: String = ""
@export var descricao: String = ""
@export var custo_pm: int = 0
@export var dano_base: int = 0
@export var dano_estabilidade: int = 0
@export var tempo_conjuracao: float = 0.0
@export var tipo: String = "FISICO"
@export var target_type: TargetType = TargetType.SINGLE_ENEMY

@export var name: String:
	get: return nome if not nome.is_empty() else _compat_name
	set(v):
		_compat_name = v
		if nome.is_empty(): nome = v

@export var description: String:
	get: return descricao if not descricao.is_empty() else _compat_desc
	set(v):
		_compat_desc = v
		if descricao.is_empty(): descricao = v

@export var mp_cost: int:
	get: return custo_pm if custo_pm > 0 else _compat_mp
	set(v):
		_compat_mp = v
		if custo_pm == 0: custo_pm = v

var _compat_name: String = ""
var _compat_desc: String = ""
var _compat_mp: int = 0


func _init(
	p_id: String = "",
	p_nome: String = "",
	p_desc: String = "",
	p_pm: int = 0,
	p_dano: int = 0,
	p_est: int = 0,
	p_tempo: float = 0.0,
	p_tipo: String = "FISICO",
	p_target: TargetType = TargetType.SINGLE_ENEMY
) -> void:
	id = p_id
	nome = p_nome
	descricao = p_desc
	custo_pm = p_pm
	dano_base = p_dano
	dano_estabilidade = p_est
	tempo_conjuracao = p_tempo
	tipo = p_tipo
	target_type = p_target


func get_target_name() -> String:
	match target_type:
		TargetType.SINGLE_ENEMY: return "Inimigo Único"
		TargetType.ALL_ENEMIES: return "Todos os Inimigos"
		TargetType.SINGLE_ALLY: return "Aliado Único"
		TargetType.SELF: return "Próprio Usuário"
		_: return "Alvo Geral"


static func create_golpe_sismico() -> SkillData:
	return SkillData.new(
		"golpe_sismico", "Golpe Sísmico",
		"Golpe pesado de marreta que esmaga a estabilidade do alvo.",
		8, 28, 45, 0.0, "FISICO", TargetType.SINGLE_ENEMY
	)


static func create_lanca_de_eter() -> SkillData:
	return SkillData.new(
		"lanca_de_eter", "Lança de Éter",
		"Disparo concentrado de energia mágica após canalização.",
		12, 42, 15, 2.0, "MAGICO", TargetType.SINGLE_ENEMY
	)


static func create_runic_impact() -> SkillData:
	return SkillData.new(
		"impacto_runico", "Impacto Rúnico",
		"Canaliza energia primordial na marreta.",
		8, 28, 45, 0.0, "FISICO", TargetType.SINGLE_ENEMY
	)
