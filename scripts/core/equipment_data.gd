class_name EquipmentData
extends Resource

## Dados de peças de equipamento (armas, armaduras, acessórios).

enum SlotType {
	MAIN_HAND,
	OFF_HAND,
	HEAD,
	BODY,
	ACCESSORY,
}

@export var id: String = ""
@export var name: String = ""
@export var slot_type: SlotType = SlotType.MAIN_HAND
@export var stat_bonuses: Dictionary = {}


func _init(
	p_id: String = "",
	p_name: String = "",
	p_slot: SlotType = SlotType.MAIN_HAND,
	p_bonuses: Dictionary = {}
) -> void:
	id = p_id
	name = p_name
	slot_type = p_slot
	stat_bonuses = p_bonuses


func get_bonus(stat_name: String) -> int:
	return int(stat_bonuses.get(stat_name, 0))


static func create_short_sword() -> EquipmentData:
	return EquipmentData.new(
		"short_sword",
		"Espada Curta",
		SlotType.MAIN_HAND,
		{"strength": 5}
	)
