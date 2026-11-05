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


static func create_default_lucas() -> CharacterData:
	var portrait_tex: Texture2D = null
	const PORTRAIT_PATH: String = "res://assets/art/portraits/lucas/lucas_neutral.png"
	if ResourceLoader.exists(PORTRAIT_PATH):
		portrait_tex = load(PORTRAIT_PATH) as Texture2D
	return CharacterData.new(
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

