class_name CharacterData
extends Resource

## Dados estruturados de um membro do grupo (Party Member) no estilo JRPG clássico.

@export var character_id: String = ""
@export var name: String = ""
@export var level: int = 1
@export var current_hp: int = 120
@export var max_hp: int = 120
@export var current_mp: int = 40
@export var max_mp: int = 40
@export var pm_atual: int = 40
@export var pm_max: int = 40
@export var portrait: Texture2D = null
@export var equipped_primordial: PrimordialData = null

# Atributos de combate
@export var strength: int = 14
@export var defense: int = 10
@export var magic_power: int = 12
@export var magic_defense: int = 9
@export var agility: int = 11
@export var luck: int = 8
@export var willpower: int = 10
@export var current_exp: int = 0
@export var next_level_exp: int = 100
@export var sprite_frames: SpriteFrames = null
@export var fileira: String = "VANGUARDA"

# Afinidades de arma (chave: EquipmentData.WeaponType, valor: float)
@export var weapon_affinities: Dictionary = {}

# Lista de habilidades conhecidas
@export var habilidades: Array[SkillData] = []
@export var skills: Array[SkillData] = []

# Slots de equipamento
@export var equipment: Dictionary = {
	"main_hand": null,
	"off_hand": null,
	"head": null,
	"body": null,
	"accessory": null,
}


func _init(p_id: String = "", p_name: String = "", p_level: int = 1, p_hp: int = 120,
		p_max_hp: int = 120, p_mp: int = 45, p_max_mp: int = 45,
		p_portrait: Texture2D = null, p_primordial: PrimordialData = null) -> void:
	character_id = p_id
	name = p_name
	level = p_level
	current_hp = p_hp
	max_hp = p_max_hp
	current_mp = p_mp
	max_mp = p_max_mp
	pm_atual = p_mp
	pm_max = p_max_mp
	skills = []
	habilidades = []
	portrait = p_portrait
	equipped_primordial = p_primordial


func gastar_pm(custo: int) -> bool:
	if pm_atual < custo:
		return false
	pm_atual -= custo
	current_mp = pm_atual
	return true


func tem_pm(custo: int) -> bool:
	return pm_atual >= custo


func obter_habilidades() -> Array[SkillData]:
	if not habilidades.is_empty():
		return habilidades
	return skills


func get_base_stat(stat_name: String) -> int:
	match stat_name:
		"strength", "forca": return strength
		"defense", "defesa": return defense
		"magic_power", "poder_magico": return magic_power
		"magic_defense", "defesa_magica": return magic_defense
		"agility", "agilidade": return agility
		"luck", "sorte": return luck
		"willpower", "vontade": return willpower
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
	var port_p: String = "res://assets/art/portraits/lucas/lucas_neutral.png"
	var portrait_tex: Texture2D = load(port_p) as Texture2D if ResourceLoader.exists(port_p) else null
	var lucas: CharacterData = CharacterData.new("lucas", "Lucas Reis", 1, 120, 120, 45, 45, portrait_tex, null)
	var frm_p: String = "res://assets/art/characters/player/player_frames.tres"
	if ResourceLoader.exists(frm_p):
		lucas.sprite_frames = load(frm_p) as SpriteFrames
	lucas.strength = 14
	lucas.defense = 10
	lucas.agility = 14
	lucas.weapon_affinities = {
		EquipmentData.WeaponType.HAMMER: 1.3,
		EquipmentData.WeaponType.SWORD: 0.9,
		EquipmentData.WeaponType.SHIELD: 0.8,
	}
	lucas.habilidades.append(SkillData.create_golpe_sismico())
	lucas.skills.append(SkillData.create_runic_impact())
	lucas.equip(EquipmentData.create_forge_hammer(), "main_hand")
	return lucas


static func create_default_davi() -> CharacterData:
	var frames: SpriteFrames = load("res://assets/sprites/characters/davi/Davi_Reis_frames.tres") if ResourceLoader.exists("res://assets/sprites/characters/davi/Davi_Reis_frames.tres") else null
	var portrait_tex: Texture2D = load("res://assets/art/portraits/davi/davi_neutral.png") if ResourceLoader.exists("res://assets/art/portraits/davi/davi_neutral.png") else null
	var davi: CharacterData = CharacterData.new("davi", "Davi Reis", 1, 90, 90, 60, 60, portrait_tex, null)
	davi.strength = 8
	davi.defense = 16
	davi.agility = 11
	davi.willpower = 15
	davi.magic_defense = 15
	davi.sprite_frames = frames
	davi.weapon_affinities = {
		EquipmentData.WeaponType.SHIELD: 1.3,
		EquipmentData.WeaponType.CATALYST: 1.3,
		EquipmentData.WeaponType.SWORD: 0.5,
		EquipmentData.WeaponType.AXE: 0.5,
		EquipmentData.WeaponType.HAMMER: 1.0,
	}
	var lanca: SkillData = SkillData.create_lanca_de_eter()
	davi.habilidades.append(lanca)
	davi.skills.append(lanca)
	return davi


static func create_default_baltazar() -> CharacterData:
	var port_p: String = "res://assets/art/portraits/baltazar/baltazar_neutral.png"
	var port_tex: Texture2D = load(port_p) as Texture2D if ResourceLoader.exists(port_p) else null
	var baltazar: CharacterData = CharacterData.new("baltazar", "Mestre Baltazar", 1, 150, 150, 30, 30, port_tex, null)
	baltazar.strength = 18
	baltazar.defense = 14
	baltazar.agility = 9
	baltazar.willpower = 10
	var frm_p: String = "res://assets/art/characters/player/player_frames.tres"
	if ResourceLoader.exists(frm_p):
		baltazar.sprite_frames = load(frm_p) as SpriteFrames
	baltazar.weapon_affinities = {
		EquipmentData.WeaponType.HAMMER: 1.4,
		EquipmentData.WeaponType.AXE: 1.2,
		EquipmentData.WeaponType.SWORD: 0.8,
	}
	baltazar.habilidades.append(SkillData.create_golpe_sismico())
	return baltazar


static func create_default_dai() -> CharacterData:
	var port_p: String = "res://assets/art/portraits/dai/dai_neutral.png"
	var port_tex: Texture2D = load(port_p) as Texture2D if ResourceLoader.exists(port_p) else null
	var dai: CharacterData = CharacterData.new("dai", "Sacerdotisa Dai", 1, 85, 85, 70, 70, port_tex, null)
	dai.strength = 6
	dai.defense = 8
	dai.magic_power = 16
	dai.magic_defense = 18
	dai.agility = 13
	dai.willpower = 16
	var frm_p: String = "res://assets/sprites/characters/davi/Davi_Reis_frames.tres"
	if ResourceLoader.exists(frm_p):
		dai.sprite_frames = load(frm_p) as SpriteFrames
	dai.weapon_affinities = {
		EquipmentData.WeaponType.CATALYST: 1.4,
		EquipmentData.WeaponType.SHIELD: 1.1,
		EquipmentData.WeaponType.HAMMER: 0.6,
	}
	dai.habilidades.append(SkillData.create_lanca_de_eter())
	return dai

