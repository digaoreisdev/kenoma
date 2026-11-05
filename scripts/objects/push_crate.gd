class_name PushCrate
extends CharacterBody2D

## Objeto de teste empurrável com indicador de interação e colisão na base.

@export var friction: float = 600.0

var _is_highlighted: bool = false
var _is_being_pushed: bool = false

@onready var prompt_icon: CanvasItem = get_node_or_null("InteractionPrompt")


func _physics_process(delta: float) -> void:
	if not _is_being_pushed and velocity != Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		move_and_slide()
	_is_being_pushed = false
	_update_prompt(delta)


func set_highlighted(highlight: bool) -> void:
	_is_highlighted = highlight


func push_by(dir: Vector2, speed: float) -> void:
	_is_being_pushed = true
	velocity = dir.normalized() * speed
	move_and_slide()


func pull_by(dir: Vector2, speed: float) -> void:
	_is_being_pushed = true
	velocity = dir.normalized() * speed
	move_and_slide()


func _update_prompt(delta: float) -> void:
	if prompt_icon == null:
		return
	var target_alpha: float = 1.0 if _is_highlighted else 0.0
	prompt_icon.modulate.a = move_toward(prompt_icon.modulate.a, target_alpha, 8.0 * delta)
