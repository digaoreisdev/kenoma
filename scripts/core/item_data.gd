class_name ItemData
extends Resource

## Recurso de dados para itens consumíveis e equipamentos no Kenoma.

enum TargetType {
	SINGLE_ALLY,
	ALL_ALLIES,
}

@export var id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var effect_value: int = 0
@export var target_type: TargetType = TargetType.SINGLE_ALLY


func _init(
	p_id: String = "",
	p_name: String = "",
	p_desc: String = "",
	p_effect: int = 0,
	p_target: TargetType = TargetType.SINGLE_ALLY
) -> void:
	id = p_id
	name = p_name
	description = p_desc
	effect_value = p_effect
	target_type = p_target


static func create_potion() -> ItemData:
	return ItemData.new(
		"potion",
		"Poção",
		"Restaura 50 PV de um aliado.",
		50,
		TargetType.SINGLE_ALLY
	)

