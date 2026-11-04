class_name Player
extends CharacterBody2D

## Controlador de movimentação, física e locomoção em 8 direções do jogador.

enum Direction {
	DOWN,
	UP,
	LEFT,
	RIGHT,
	DOWN_RIGHT,
	DOWN_LEFT,
	UP_RIGHT,
	UP_LEFT,
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
		_resolve_8way_direction(input_direction)
	else:
		current_mode = MovementMode.IDLE
	
	velocity = input_direction * move_speed
	move_and_slide()


func _resolve_8way_direction(dir: Vector2) -> void:
	var angle_deg: float = rad_to_deg(dir.angle())
	var norm_angle: float = fposmod(angle_deg, 360.0)
	var octant: int = int(round(norm_angle / 45.0)) % 8
	
	match octant:
		0: current_direction = Direction.RIGHT
		1: current_direction = Direction.DOWN_RIGHT
		2: current_direction = Direction.DOWN
		3: current_direction = Direction.DOWN_LEFT
		4: current_direction = Direction.LEFT
		5: current_direction = Direction.UP_LEFT
		6: current_direction = Direction.UP
		7: current_direction = Direction.UP_RIGHT


func _update_animation() -> void:
	if animated_sprite == null or animated_sprite.sprite_frames == null:
		return
	
	var anim_name: String = _resolve_animation_name()
	if anim_name.is_empty():
		return
	
	var is_left: bool = (current_direction == Direction.LEFT or current_direction == Direction.UP_LEFT or current_direction == Direction.DOWN_LEFT)
	animated_sprite.flip_h = is_left and anim_name.ends_with("_side")
	
	if animated_sprite.animation != anim_name or not animated_sprite.is_playing():
		animated_sprite.play(anim_name)


func _resolve_animation_name() -> String:
	assert(animated_sprite != null and animated_sprite.sprite_frames != null)
	var prefix: String = "walk" if current_mode == MovementMode.WALK else "idle"
	var primary: String = prefix + "_" + _direction_to_string(current_direction)
	
	if animated_sprite.sprite_frames.has_animation(primary):
		return primary
	
	return _get_fallback_animation(prefix)


func _direction_to_string(dir: Direction) -> String:
	match dir:
		Direction.DOWN: return "down"
		Direction.UP: return "up"
		Direction.LEFT: return "left"
		Direction.RIGHT: return "right"
		Direction.DOWN_RIGHT: return "down_right"
		Direction.DOWN_LEFT: return "down_left"
		Direction.UP_RIGHT: return "up_right"
		Direction.UP_LEFT: return "up_left"
		_: return "down"


func _get_fallback_animation(prefix: String) -> String:
	var frames: SpriteFrames = animated_sprite.sprite_frames
	match current_direction:
		Direction.DOWN_RIGHT, Direction.DOWN_LEFT:
			if frames.has_animation(prefix + "_down"): return prefix + "_down"
		Direction.UP_RIGHT, Direction.UP_LEFT:
			if frames.has_animation(prefix + "_up"): return prefix + "_up"
	
	if frames.has_animation(prefix + "_side"):
		return prefix + "_side"
	if frames.has_animation(prefix + "_down"):
		return prefix + "_down"
	return ""
