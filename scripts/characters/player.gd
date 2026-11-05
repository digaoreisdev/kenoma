class_name Player
extends CharacterBody2D

## Controlador de locomoção em 8 direções e interação de empurrão sem trepidação.

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
@export var pull_speed: float = 45.0
@export var max_health: int = 100

var current_health: int = 100
var current_direction: Direction = Direction.DOWN
var current_state: State = State.IDLE
var current_action_name: String = ""
var _last_interactable: Object = null
var _push_buffer: float = 0.0
var _pushed_crate: PushCrate = null

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


func _physics_process(delta: float) -> void:
	if _push_buffer > 0.0:
		_push_buffer = maxf(0.0, _push_buffer - delta)
	
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
		if Input.is_action_pressed("action_interact") and _try_crate_interaction(input_dir):
			return
		_resolve_8way_direction(input_dir)
		current_state = State.WALK
		velocity = input_dir * move_speed
		_reset_push_state()
	else:
		current_state = State.IDLE
		velocity = Vector2.ZERO
		_reset_push_state()
	move_and_slide()


func _try_crate_interaction(input_dir: Vector2) -> bool:
	var facing_vec: Vector2 = _direction_to_vector(current_direction)
	var move_dot: float = input_dir.dot(facing_vec)
	if move_dot > 0.3:
		return _try_push(input_dir)
	elif move_dot < -0.3:
		return _try_pull(input_dir)
	return false


func _try_push(input_dir: Vector2) -> bool:
	var target_crate: PushCrate = _find_pushable_target(input_dir)
	if target_crate != null:
		_resolve_8way_direction(input_dir)
		_pushed_crate = target_crate
		_push_buffer = 0.2
	elif _push_buffer > 0.0 and _pushed_crate != null and is_instance_valid(_pushed_crate):
		target_crate = _pushed_crate
	else:
		_reset_push_state()
		return false
	
	current_state = State.INTERACTING
	velocity = input_dir * push_speed
	target_crate.push_by(input_dir, push_speed)
	move_and_slide()
	_play_push_animation(current_direction)
	return true


func _try_pull(input_dir: Vector2) -> bool:
	var target_crate: PushCrate = _find_pullable_target()
	if target_crate != null:
		_pushed_crate = target_crate
		_push_buffer = 0.2
	elif _push_buffer > 0.0 and _pushed_crate != null and is_instance_valid(_pushed_crate):
		target_crate = _pushed_crate
	else:
		_reset_push_state()
		return false
	
	current_state = State.INTERACTING
	velocity = input_dir * pull_speed
	move_and_slide()
	target_crate.pull_by(input_dir, pull_speed)
	_play_pull_animation(current_direction)
	return true


func _find_pushable_target(input_dir: Vector2) -> PushCrate:
	for i: int in get_slide_collision_count():
		var col: KinematicCollision2D = get_slide_collision(i)
		var collider: Object = col.get_collider()
		if collider is PushCrate and (-col.get_normal()).dot(input_dir) > 0.3:
			return collider as PushCrate
	
	if interaction_ray != null and interaction_ray.is_colliding():
		var ray_col: Object = interaction_ray.get_collider()
		if ray_col is PushCrate:
			var to_crate: Vector2 = (ray_col.global_position - global_position).normalized()
			if to_crate.dot(input_dir) > 0.3:
				return ray_col as PushCrate
	
	if _pushed_crate != null and is_instance_valid(_pushed_crate):
		var to_crate: Vector2 = _pushed_crate.global_position - global_position
		if to_crate.length() <= 38.0 and to_crate.normalized().dot(input_dir) > 0.3:
			return _pushed_crate
	return null


func _find_pullable_target() -> PushCrate:
	var facing_vec: Vector2 = _direction_to_vector(current_direction)
	if _pushed_crate != null and is_instance_valid(_pushed_crate):
		var to_crate: Vector2 = _pushed_crate.global_position - global_position
		if to_crate.length() <= 38.0 and to_crate.normalized().dot(facing_vec) > 0.3:
			return _pushed_crate
	
	if interaction_ray != null and interaction_ray.is_colliding():
		var ray_col: Object = interaction_ray.get_collider()
		if ray_col is PushCrate:
			var to_crate: Vector2 = (ray_col.global_position - global_position).normalized()
			if to_crate.dot(facing_vec) > 0.3:
				return ray_col as PushCrate
	
	for i: int in get_slide_collision_count():
		var col: KinematicCollision2D = get_slide_collision(i)
		var collider: Object = col.get_collider()
		if collider is PushCrate and (-col.get_normal()).dot(facing_vec) > 0.3:
			return collider as PushCrate
	return null


func _reset_push_state() -> void:
	_push_buffer = 0.0
	_pushed_crate = null


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
		Direction.DOWN: interaction_ray.target_position = Vector2(0, 24)
		Direction.UP: interaction_ray.target_position = Vector2(0, -24)
		Direction.LEFT: interaction_ray.target_position = Vector2(-24, 0)
		Direction.RIGHT: interaction_ray.target_position = Vector2(24, 0)
		Direction.DOWN_RIGHT: interaction_ray.target_position = Vector2(18, 18)
		Direction.DOWN_LEFT: interaction_ray.target_position = Vector2(-18, 18)
		Direction.UP_RIGHT: interaction_ray.target_position = Vector2(18, -18)
		Direction.UP_LEFT: interaction_ray.target_position = Vector2(-18, -18)


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


func _play_push_animation(dir: Direction) -> void:
	if animated_sprite == null or animated_sprite.sprite_frames == null:
		return
	var target_anim: String = "push_" + _direction_to_string(dir)
	if not animated_sprite.sprite_frames.has_animation(target_anim):
		if animated_sprite.sprite_frames.has_animation("push_side") and (dir == Direction.LEFT or dir == Direction.RIGHT):
			target_anim = "push_side"
		else:
			return
	if animated_sprite.animation != target_anim:
		animated_sprite.play(target_anim)
	elif not animated_sprite.is_playing():
		animated_sprite.play()


func _play_pull_animation(dir: Direction) -> void:
	if animated_sprite == null or animated_sprite.sprite_frames == null:
		return
	var target_anim: String = "pull_" + _direction_to_string(dir)
	if not animated_sprite.sprite_frames.has_animation(target_anim):
		if animated_sprite.sprite_frames.has_animation("pull_side") and (dir == Direction.LEFT or dir == Direction.RIGHT):
			target_anim = "pull_side"
		else:
			return
	if animated_sprite.animation != target_anim:
		animated_sprite.play(target_anim)
	elif not animated_sprite.is_playing():
		animated_sprite.play()


func _play_raw_animation(anim_name: String) -> void:
	if animated_sprite == null or animated_sprite.sprite_frames == null:
		return
	if not animated_sprite.sprite_frames.has_animation(anim_name):
		return
	if animated_sprite.animation != anim_name:
		animated_sprite.play(anim_name)
	elif not animated_sprite.is_playing():
		animated_sprite.play()


func _on_animation_finished() -> void:
	if current_state == State.DEAD:
		return
	if current_state == State.INTERACTING and _pushed_crate != null:
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


func _direction_to_vector(dir: Direction) -> Vector2:
	match dir:
		Direction.DOWN: return Vector2.DOWN
		Direction.UP: return Vector2.UP
		Direction.LEFT: return Vector2.LEFT
		Direction.RIGHT: return Vector2.RIGHT
		Direction.DOWN_RIGHT: return Vector2(1, 1).normalized()
		Direction.DOWN_LEFT: return Vector2(-1, 1).normalized()
		Direction.UP_RIGHT: return Vector2(1, -1).normalized()
		Direction.UP_LEFT: return Vector2(-1, -1).normalized()
		_: return Vector2.DOWN
