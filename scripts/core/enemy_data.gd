class_name EnemyData
extends Resource

## Dados estruturados de inimigos e chefes de combate no Kenoma.

@export var id: String = ""
@export var name: String = ""
@export var max_hp: int = 100
@export var current_hp: int = 100
@export var estabilidade_max: int = 100
@export var estabilidade_atual: int = 100
@export var strength: int = 10
@export var defense: int = 10
@export var agility: int = 10
@export var sprite_frames: SpriteFrames = null
@export var exp_recompensa: int = 45
@export var ouro_recompensa: int = 30
@export var is_boss: bool = false


func _init(
	p_id: String = "",
	p_name: String = "",
	p_hp: int = 100,
	p_est: int = 100,
	p_str: int = 10,
	p_def: int = 10,
	p_agi: int = 10,
	p_frames: SpriteFrames = null
) -> void:
	id = p_id
	name = p_name
	max_hp = p_hp
	current_hp = p_hp
	estabilidade_max = p_est
	estabilidade_atual = p_est
	strength = p_str
	defense = p_def
	agility = p_agi
	sprite_frames = p_frames


func to_dictionary() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"max_hp": max_hp,
		"current_hp": current_hp,
		"estabilidade_max": estabilidade_max,
		"estabilidade_atual": estabilidade_atual,
		"strength": strength,
		"defense": defense,
		"agility": agility,
		"velocidade": float(agility),
		"sprite_frames": sprite_frames,
		"exp_recompensa": exp_recompensa,
		"ouro_recompensa": ouro_recompensa,
		"stability": estabilidade_atual,
		"is_boss": is_boss
	}


static func create_general_cassian() -> Resource:
	var frames: SpriteFrames = null
	const CASSIAN_COMBAT_PATH: String = "res://autosprite_imported/General_Cassian1/General_Cassian1_frames.tres"
	const FRAMES_PATH: String = "res://assets/sprites/characters/cassian/General_Cassian_frames.tres"
	if ResourceLoader.exists(CASSIAN_COMBAT_PATH):
		frames = load(CASSIAN_COMBAT_PATH) as SpriteFrames
	elif ResourceLoader.exists(FRAMES_PATH):
		frames = load(FRAMES_PATH) as SpriteFrames
	var script: GDScript = load("res://scripts/core/enemy_data.gd")
	var boss: Resource = script.new(
		"general_cassian", "General Cassian", 240, 120, 20, 14, 13, frames
	)
	boss.set("is_boss", true)
	boss.set("exp_recompensa", 350)
	boss.set("ouro_recompensa", 200)
	return boss


static func create_squad_cassian_8() -> Array[Dictionary]:
	var squad: Array[Dictionary] = []
	var frames: SpriteFrames = null
	const P1: String = "res://autosprite_imported/General_Cassian1/General_Cassian1_frames.tres"
	const P2: String = "res://assets/sprites/characters/cassian/General_Cassian_frames.tres"
	if ResourceLoader.exists(P1):
		frames = load(P1) as SpriteFrames
	elif ResourceLoader.exists(P2):
		frames = load(P2) as SpriteFrames
	for i: int in range(8):
		var is_boss: bool = (i == 0)
		squad.append({
			"id": "general_cassian" if is_boss else ("cassian_squad_%d" % i),
			"name": "General Cassian" if is_boss else ("Oficial Cassian %d" % i),
			"max_hp": 240 if is_boss else 90,
			"current_hp": 240 if is_boss else 90,
			"estabilidade_max": 120 if is_boss else 60,
			"estabilidade_atual": 120 if is_boss else 60,
			"strength": 20 if is_boss else 14,
			"defense": 14 if is_boss else 10,
			"agility": 13 if is_boss else 11,
			"velocidade": 13.0 if is_boss else 11.0,
			"sprite_frames": frames,
			"is_boss": is_boss,
			"exp_recompensa": 350 if is_boss else 80,
			"ouro_recompensa": 200 if is_boss else 50,
			"stability": 120 if is_boss else 60
		})
	return squad

