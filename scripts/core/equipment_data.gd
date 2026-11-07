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

enum WeaponType {
	NONE,
	HAMMER,
	SWORD,
	AXE,
	SPEAR,
	SHIELD,
	CATALYST,
}

@export var id: String = ""
@export var name: String = ""
@export var slot_type: SlotType = SlotType.MAIN_HAND
@export var weapon_type: WeaponType = WeaponType.NONE
@export var stat_bonuses: Dictionary = {}
@export var sockets: Array[Dictionary] = []


func _init(
	p_id: String = "",
	p_name: String = "",
	p_slot: SlotType = SlotType.MAIN_HAND,
	p_bonuses: Dictionary = {},
	p_weapon_type: WeaponType = WeaponType.NONE,
	p_sockets: Array[Dictionary] = []
) -> void:
	id = p_id
	name = p_name
	slot_type = p_slot
	stat_bonuses = p_bonuses
	weapon_type = p_weapon_type
	sockets = p_sockets


func get_bonus(stat_name: String) -> int:
	return int(stat_bonuses.get(stat_name, 0))


static func create_forge_hammer() -> EquipmentData:
	var hammer: EquipmentData = EquipmentData.new(
		"forge_hammer",
		"Martelo de Forja",
		SlotType.MAIN_HAND,
		{"strength": 6},
		WeaponType.HAMMER,
		[
			{"gem": null, "unlocked": true},
			{"gem": null, "unlocked": true}
		]
	)
	return hammer


static func create_short_sword() -> EquipmentData:
	return EquipmentData.new(
		"short_sword",
		"Espada Curta",
		SlotType.MAIN_HAND,
		{"strength": 5},
		WeaponType.SWORD
	)
