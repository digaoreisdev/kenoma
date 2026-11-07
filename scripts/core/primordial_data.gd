class_name PrimordialData
extends Resource

## Dados canônicos de entidades primordiais (Espers/Invocações).

enum ElementType {
	IGNIS_FOGO,
	HYDROS_AGUA,
	GEOS_TERRA,
	AURA_AR,
	FULGUR_TROVAO,
	GLACIES_GELO,
	FERRUM_METAL,
	FLORA_BIOMASSA,
	UMBRA_VACUO,
	ANIMA_LUZ,
}

@export var id: String = ""
@export var name: String = ""
@export var element: ElementType = ElementType.IGNIS_FOGO
@export var stat_bonus: Dictionary = {}
@export var supreme_spell_name: String = ""


func _init(
	p_id: String = "",
	p_name: String = "",
	p_element: ElementType = ElementType.IGNIS_FOGO,
	p_stat_bonus: Dictionary = {},
	p_supreme: String = ""
) -> void:
	id = p_id
	name = p_name
	element = p_element
	stat_bonus = p_stat_bonus
	supreme_spell_name = p_supreme


func get_element_name() -> String:
	match element:
		ElementType.IGNIS_FOGO: return "Fogo (Ignis)"
		ElementType.HYDROS_AGUA: return "Água (Hydros)"
		ElementType.GEOS_TERRA: return "Terra (Geos)"
		ElementType.AURA_AR: return "Ar (Aura)"
		ElementType.FULGUR_TROVAO: return "Trovão (Fulgur)"
		ElementType.GLACIES_GELO: return "Gelo (Glacies)"
		ElementType.FERRUM_METAL: return "Metal (Ferrum)"
		ElementType.FLORA_BIOMASSA: return "Biomassa (Flora)"
		ElementType.UMBRA_VACUO: return "Vácuo (Umbra)"
		ElementType.ANIMA_LUZ: return "Luz (Anima)"
		_: return "Desconhecido"


func get_bonus_text() -> String:
	var parts: Array[String] = []
	for k: String in stat_bonus.keys():
		var val: int = int(stat_bonus[k])
		var sign_str: String = "+%d" % val if val >= 0 else "%d" % val
		var stat_label: String = k.capitalize()
		match k:
			"strength": stat_label = "Força"
			"defense": stat_label = "Defesa"
			"magic_power": stat_label = "Poder Mágico"
			"magic_defense": stat_label = "Def. Mágica"
			"agility": stat_label = "Agilidade"
			"luck": stat_label = "Sorte"
		parts.append("%s %s" % [sign_str, stat_label])
	return ", ".join(parts) if not parts.is_empty() else "Nenhum"


static func create_ignis() -> PrimordialData:
	return PrimordialData.new(
		"ignis",
		"Ignis",
		ElementType.IGNIS_FOGO,
		{"strength": 2},
		"Apocalipse Ígneo"
	)
