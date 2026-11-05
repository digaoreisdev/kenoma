class_name CharacterData
extends Resource

## Dados estruturados de um membro do grupo (Party Member) no estilo JRPG clássico.

@export var character_id: String = ""
@export var name: String = ""
@export var level: int = 1
@export var current_hp: int = 120
@export var max_hp: int = 120
@export var current_mp: int = 45
@export var max_mp: int = 45
@export var portrait: Texture2D = null
@export var equipped_primordial: String = ""

# Atributos de combate
@export var strength: int = 14
@export var defense: int = 10
@export var magic_power: int = 12
@export var magic_defense: int = 9
@export var agility: int = 11
@export var luck: int = 8
@export var current_exp: int = 0
@export var next_level_exp: int = 100

# Slots de equipamento
@export var equipment: Dictionary = {
	"main_hand": null,
	"off_hand": null,
	"head": null,
	"body": null,
	"accessory": null,
}


func _init(
	p_id: String = "",
	p_name: String = "",
	p_level: int = 1,
	p_hp: int = 120,
	p_max_hp: int = 120,
	p_mp: int = 45,
	p_max_mp: int = 45,
	p_portrait: Texture2D = null,
	p_primordial: String = ""
) -> void:
	character_id = p_id
	name = p_name
	level = p_level
	current_hp = p_hp
	max_hp = p_max_hp
	current_mp = p_mp
	max_mp = p_max_mp
	portrait = p_portrait
	equipped_primordial = p_primordial


func get_base_stat(stat_name: String) -> int:
	match stat_name:
		"strength": return strength
		"defense": return defense
		"magic_power": return magic_power
		"magic_defense": return magic_defense
		"agility": return agility
		"luck": return luck
		"max_hp": return max_hp
		"max_mp": return max_mp
		_: return 0


func get_equipment_bonus(stat_name: String) -> int:
	var total: int = 0
	for slot_key: String in equipment.keys():
		var eq: EquipmentData = equipment.get(slot_key) as EquipmentData
		if eq != null:
			total += eq.get_bonus(stat_name)
	return total


func get_total_stat(stat_name: String) -> int:
	return get_base_stat(stat_name) + get_equipment_bonus(stat_name)


func equip(item: EquipmentData, slot_name: String = "") -> EquipmentData:
	if item == null:
		return null
	var target_slot: String = slot_name
	if target_slot.is_empty():
		match item.slot_type:
			EquipmentData.SlotType.MAIN_HAND: target_slot = "main_hand"
			EquipmentData.SlotType.OFF_HAND: target_slot = "off_hand"
			EquipmentData.SlotType.HEAD: target_slot = "head"
			EquipmentData.SlotType.BODY: target_slot = "body"
			EquipmentData.SlotType.ACCESSORY: target_slot = "accessory"
	var prev: EquipmentData = equipment.get(target_slot) as EquipmentData
	equipment[target_slot] = item
	return prev


static func create_default_lucas() -> CharacterData:
	var portrait_tex: Texture2D = null
	const PORTRAIT_PATH: String = "res://assets/art/portraits/lucas/lucas_neutral.png"
	if ResourceLoader.exists(PORTRAIT_PATH):
		portrait_tex = load(PORTRAIT_PATH) as Texture2D
	var lucas: CharacterData = CharacterData.new(
		"lucas",
		"Lucas Reis",
		1,
		120,
		120,
		45,
		45,
		portrait_tex,
		""
	)
	lucas.strength = 14
	lucas.defense = 10
	lucas.magic_power = 12
	lucas.magic_defense = 9
	lucas.agility = 11
	lucas.luck = 8
	lucas.current_exp = 0
	lucas.next_level_exp = 100
	lucas.equip(EquipmentData.create_short_sword(), "main_hand")
	return lucas
