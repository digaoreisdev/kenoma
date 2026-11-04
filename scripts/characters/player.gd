class_name Player
extends CharacterBody2D

## Controlador de movimentação e física do jogador em visão top-down.

@export var move_speed: float = 120.0


func _physics_process(_delta: float) -> void:
	if not _can_move():
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	_handle_movement()


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
	
	velocity = input_direction * move_speed
	move_and_slide()
