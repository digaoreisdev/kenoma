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
@export var equipped_primordial: PrimordialData = null

# Atributos de combate
@export var strength: int = 14
@export var defense: int = 10
@export var magic_power: int = 12
@export var magic_defense: int = 9
@export var agility: int = 11
@export var luck: int = 8
@export var current_exp: int = 0
@export var next_level_exp: int = 100

# Afinidades de arma (chave: EquipmentData.WeaponType, valor: float)
@export var weapon_affinities: Dictionary = {}

# Lista de habilidades conhecidas
@export var skills: Array[SkillData] = []

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
	p_primordial: PrimordialData = null
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


func get_primordial_bonus(stat_name: String) -> int:
	if equipped_primordial != null:
		return int(equipped_primordial.stat_bonus.get(stat_name, 0))
	return 0


func get_total_stat(stat_name: String) -> int:
	return get_base_stat(stat_name) + get_equipment_bonus(stat_name) + get_primordial_bonus(stat_name)


func get_weapon_affinity(w_type: int) -> float:
	return float(weapon_affinities.get(w_type, 1.0))


func equip_primordial(primordial: PrimordialData) -> PrimordialData:
	var prev: PrimordialData = equipped_primordial
	equipped_primordial = primordial
	return prev


func unequip_primordial() -> PrimordialData:
	var prev: PrimordialData = equipped_primordial
	equipped_primordial = null
	return prev


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
		"lucas", "Lucas Reis", 1, 120, 120, 45, 45, portrait_tex, null
	)
	lucas.weapon_affinities = {
		EquipmentData.WeaponType.HAMMER: 1.3,
		EquipmentData.WeaponType.SWORD: 0.9,
		EquipmentData.WeaponType.SHIELD: 0.8,
	}
	lucas.skills.append(SkillData.create_runic_impact())
	lucas.equip(EquipmentData.create_forge_hammer(), "main_hand")
	return lucas
