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
		"stability": estabilidade_atual
	}


static func create_general_cassian() -> Resource:
	var frames: SpriteFrames = null
	const FRAMES_PATH: String = "res://assets/sprites/characters/cassian/General_Cassian_frames.tres"
	if ResourceLoader.exists(FRAMES_PATH):
		frames = load(FRAMES_PATH) as SpriteFrames
	var script: GDScript = load("res://scripts/core/enemy_data.gd")
	var boss: Resource = script.new(
		"general_cassian", "General Cassian", 240, 120, 20, 14, 12, frames
	)
	boss.set("exp_recompensa", 350)
	boss.set("ouro_recompensa", 200)
	return boss
