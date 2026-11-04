class_name Player
extends CharacterBody2D

## Controlador de movimentação, física e máquina de direções do jogador.

enum Direction {
	DOWN,
	UP,
	LEFT,
	RIGHT,
}

enum MovementMode {
	IDLE,
	WALK,
}

@export var move_speed: float = 120.0

var current_direction: Direction = Direction.DOWN
var current_mode: MovementMode = MovementMode.IDLE

@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var placeholder_visual: ColorRect = get_node_or_null("PlaceholderVisual")


func _ready() -> void:
	if animated_sprite != null and animated_sprite.sprite_frames != null and placeholder_visual != null:
		placeholder_visual.visible = false


func _physics_process(_delta: float) -> void:
	if not _can_move():
		velocity = Vector2.ZERO
		current_mode = MovementMode.IDLE
		move_and_slide()
		_update_animation()
		return
	
	_handle_movement()
	_update_animation()


func _can_move() -> bool:
	if has_node("/root/GameState"):
		var state_mgr: Node = get_node("/root/GameState")
		if state_mgr.has_method("is_exploration"):
			return bool(state_mgr.call("is_exploration"))
	return true


func _handle_movement() -> void:
	var input_direction: Vector2 = Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)
	
	if input_direction != Vector2.ZERO:
		current_mode = MovementMode.WALK
		_resolve_direction(input_direction)
	else:
		current_mode = MovementMode.IDLE
	
	velocity = input_direction * move_speed
	move_and_slide()


func _resolve_direction(dir: Vector2) -> void:
	if absf(dir.x) >= absf(dir.y):
		current_direction = Direction.RIGHT if dir.x > 0.0 else Direction.LEFT
	else:
		current_direction = Direction.DOWN if dir.y > 0.0 else Direction.UP


func _update_animation() -> void:
	if animated_sprite == null or animated_sprite.sprite_frames == null:
		return
	
	var anim_name: String = _get_animation_name()
	if not animated_sprite.sprite_frames.has_animation(anim_name):
		return
	
	animated_sprite.flip_h = (current_direction == Direction.LEFT)
	if animated_sprite.animation != anim_name or not animated_sprite.is_playing():
		animated_sprite.play(anim_name)


func _get_animation_name() -> String:
	var prefix: String = "walk" if current_mode == MovementMode.WALK else "idle"
	match current_direction:
		Direction.UP:
			return prefix + "_up"
		Direction.DOWN:
			return prefix + "_down"
		Direction.LEFT, Direction.RIGHT:
			return prefix + "_side"
		_:
			return prefix + "_down"
