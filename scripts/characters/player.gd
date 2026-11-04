class_name Player
extends CharacterBody2D

## Controlador de locomoção em 8 direções e interação com mapa do jogador.

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

enum State {
	IDLE,
	WALK,
	INTERACTING,
	HURT,
	DEAD,
	RESTING,
}

signal health_changed(new_health: int, max_health: int)
signal player_died
signal action_started(action_name: String)
signal action_finished(action_name: String)

@export var move_speed: float = 120.0
@export var push_speed: float = 45.0
@export var max_health: int = 100

var current_health: int = 100
var current_direction: Direction = Direction.DOWN
var current_state: State = State.IDLE
var current_action_name: String = ""
var _last_interactable: Object = null

@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var placeholder_visual: ColorRect = get_node_or_null("PlaceholderVisual")
@onready var camera_2d: Camera2D = get_node_or_null("Camera2D")
@onready var interaction_ray: RayCast2D = get_node_or_null("InteractionRay")


func _ready() -> void:
	current_health = max_health
	if animated_sprite != null and animated_sprite.sprite_frames != null and placeholder_visual != null:
		placeholder_visual.visible = false
	if animated_sprite != null:
		animated_sprite.animation_finished.connect(_on_animation_finished)
	_update_interaction_ray()


func _physics_process(_delta: float) -> void:
	_update_ray_sensing()
	if not _can_walk():
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	_handle_movement()
	_update_locomotion_animation()


func set_camera_limits(left: int, top: int, right: int, bottom: int) -> void:
	if camera_2d == null:
		return
	camera_2d.limit_left = left
	camera_2d.limit_top = top
	camera_2d.limit_right = right
	camera_2d.limit_bottom = bottom


func _can_walk() -> bool:
	if current_state in [State.HURT, State.DEAD, State.RESTING]:
		return false
	if has_node("/root/GameState"):
		var state_mgr: Node = get_node("/root/GameState")
		if state_mgr.has_method("is_exploration"):
			return bool(state_mgr.call("is_exploration"))
	return true


func _handle_movement() -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir != Vector2.ZERO:
		_resolve_8way_direction(input_dir)
		if Input.is_action_pressed("action_interact") and _try_push(input_dir):
			return
		current_state = State.WALK
		velocity = input_dir * move_speed
	else:
		current_state = State.IDLE
		velocity = Vector2.ZERO
	move_and_slide()


func _try_push(input_dir: Vector2) -> bool:
	for i: int in get_slide_collision_count():
		var col: KinematicCollision2D = get_slide_collision(i)
		var collider: Object = col.get_collider()
		if collider != null and collider.has_method("push_by"):
			var push_dir: Vector2 = -col.get_normal()
			if push_dir.dot(input_dir) > 0.5:
				current_state = State.INTERACTING
				collider.call("push_by", push_dir, push_speed)
				velocity = input_dir * push_speed
				move_and_slide()
				_play_raw_animation("push_" + _direction_to_string(current_direction))
				return true
	return false


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
	_update_interaction_ray()


func _update_interaction_ray() -> void:
	if interaction_ray == null:
		return
	match current_direction:
		Direction.DOWN: interaction_ray.target_position = Vector2(0, 18)
		Direction.UP: interaction_ray.target_position = Vector2(0, -18)
		Direction.LEFT: interaction_ray.target_position = Vector2(-18, 0)
		Direction.RIGHT: interaction_ray.target_position = Vector2(18, 0)
		Direction.DOWN_RIGHT: interaction_ray.target_position = Vector2(14, 14)
		Direction.DOWN_LEFT: interaction_ray.target_position = Vector2(-14, 14)
		Direction.UP_RIGHT: interaction_ray.target_position = Vector2(14, -14)
		Direction.UP_LEFT: interaction_ray.target_position = Vector2(-14, -14)


func _update_ray_sensing() -> void:
	if interaction_ray == null:
		return
	var collider: Object = interaction_ray.get_collider() if interaction_ray.is_colliding() else null
	if collider != _last_interactable:
		if _last_interactable != null and _last_interactable.has_method("set_highlighted"):
			_last_interactable.call("set_highlighted", false)
		_last_interactable = collider
		if _last_interactable != null and _last_interactable.has_method("set_highlighted"):
			_last_interactable.call("set_highlighted", true)


func take_damage(amount: int) -> void:
	if current_state == State.DEAD:
		return
	current_health = clampi(current_health - amount, 0, max_health)
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		current_state = State.DEAD
		player_died.emit()
		play_action("die", current_direction)
	else:
		current_state = State.HURT
		play_action("hurt", current_direction)


func play_action(action_name: String, dir: Direction = current_direction) -> void:
	current_direction = dir
	current_action_name = action_name
	_update_state_from_action(action_name)
	var anim_name: String = action_name + "_" + _direction_to_string(current_direction)
	_play_raw_animation(anim_name)
	action_started.emit(action_name)


func _update_state_from_action(action_name: String) -> void:
	match action_name:
		"hurt": current_state = State.HURT
		"die": current_state = State.DEAD
		"push", "pull": current_state = State.INTERACTING
		"sleep", "sit", "crouch": current_state = State.RESTING
		_: current_state = State.INTERACTING


func _update_locomotion_animation() -> void:
	if current_state == State.INTERACTING:
		return
	var prefix: String = "walk" if current_state == State.WALK else "idle"
	var anim_name: String = prefix + "_" + _direction_to_string(current_direction)
	_play_raw_animation(anim_name)


func _play_raw_animation(anim_name: String) -> void:
	if animated_sprite == null or animated_sprite.sprite_frames == null:
		return
	if not animated_sprite.sprite_frames.has_animation(anim_name):
		return
	if animated_sprite.animation != anim_name or not animated_sprite.is_playing():
		animated_sprite.play(anim_name)


func _on_animation_finished() -> void:
	if current_state == State.DEAD:
		return
	if current_state in [State.HURT, State.RESTING, State.INTERACTING]:
		var finished_action: String = current_action_name
		current_state = State.IDLE
		current_action_name = ""
		action_finished.emit(finished_action)
		_update_locomotion_animation()


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
