class_name SkillData
extends Resource

## Dados estruturados de habilidades e técnicas ativas.

enum TargetType {
	SINGLE_ENEMY,
	ALL_ENEMIES,
	SINGLE_ALLY,
	SELF,
}

@export var id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var mp_cost: int = 0
@export var target_type: TargetType = TargetType.SINGLE_ENEMY


func _init(
	p_id: String = "",
	p_name: String = "",
	p_desc: String = "",
	p_mp: int = 0,
	p_target: TargetType = TargetType.SINGLE_ENEMY
) -> void:
	id = p_id
	name = p_name
	description = p_desc
	mp_cost = p_mp
	target_type = p_target


func get_target_name() -> String:
	match target_type:
		TargetType.SINGLE_ENEMY: return "Inimigo Único"
		TargetType.ALL_ENEMIES: return "Todos os Inimigos"
		TargetType.SINGLE_ALLY: return "Aliado Único"
		TargetType.SELF: return "Próprio Usuário"
		_: return "Alvo Geral"


static func create_runic_impact() -> SkillData:
	return SkillData.new(
		"runic_impact",
		"Impacto Rúnico",
		"Golpe pesado de marreta que abala a postura inimiga.",
		6,
		TargetType.SINGLE_ENEMY
	)
