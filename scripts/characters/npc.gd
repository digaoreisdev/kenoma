class_name NPC
extends CharacterBody2D

## NPC interativo para diálogos narrativos e interação exploratória.

enum Direction {
	DOWN,
	UP,
	LEFT,
	RIGHT,
}

@export var npc_name: String = "Guardião"
@export var initial_direction: Direction = Direction.DOWN
@export var dialogue_lines: Array[Dictionary] = []

var current_direction: Direction = Direction.DOWN
var _is_highlighted: bool = false

@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var prompt_icon: CanvasItem = get_node_or_null("InteractionPrompt")


func _ready() -> void:
	current_direction = initial_direction
	_update_visual_facing()


func _physics_process(delta: float) -> void:
	_update_prompt(delta)


func interact(player: Node2D) -> void:
	if player != null:
		_turn_towards_player(player.global_position)
	_start_dialogue()


func set_highlighted(highlight: bool) -> void:
	_is_highlighted = highlight


func _turn_towards_player(player_pos: Vector2) -> void:
	var diff: Vector2 = player_pos - global_position
	if absf(diff.x) > absf(diff.y):
		current_direction = Direction.RIGHT if diff.x > 0.0 else Direction.LEFT
	else:
		current_direction = Direction.DOWN if diff.y > 0.0 else Direction.UP
	_update_visual_facing()


func _update_visual_facing() -> void:
	if animated_sprite == null or animated_sprite.sprite_frames == null:
		return
	var dir_str: String = _direction_to_string(current_direction)
	var anim_name: String = "idle_" + dir_str
	if animated_sprite.sprite_frames.has_animation(anim_name):
		animated_sprite.play(anim_name)


func _direction_to_string(dir: Direction) -> String:
	match dir:
		Direction.DOWN: return "down"
		Direction.UP: return "up"
		Direction.LEFT: return "left"
		Direction.RIGHT: return "right"
		_: return "down"


func _start_dialogue() -> void:
	if not has_node("/root/DialogueManager"):
		return
	var dm: Node = get_node("/root/DialogueManager")
	var lines: Array[Dictionary] = dialogue_lines if not dialogue_lines.is_empty() else _get_default_dialogue()
	dm.call("start_dialogue", lines, "guardian_intro")


func _get_default_dialogue() -> Array[Dictionary]:
	return [
		{
			"speaker": npc_name,
			"text": "Greetings, traveler. Welcome to the forgotten borders of Kenoma.",
			"portrait": null
		},
		{
			"speaker": "Lucas",
			"text": "Who are you? What is this place?",
			"portrait": preload("res://assets/art/portraits/lucas/lucas_neutral.png")
		},
		{
			"speaker": npc_name,
			"text": "Beware the ruins ahead... ancient forces sleep beneath the stones.",
			"portrait": null
		},
		{
			"speaker": "Lucas",
			"text": "Ancient forces...? I must tread carefully, then.",
			"expression": "serious"
		}
	]


func _update_prompt(delta: float) -> void:
	if prompt_icon == null:
		return
	var target_alpha: float = 1.0 if _is_highlighted else 0.0
	prompt_icon.modulate.a = move_toward(prompt_icon.modulate.a, target_alpha, 8.0 * delta)

