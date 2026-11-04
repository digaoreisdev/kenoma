class_name PushCrate
extends CharacterBody2D

## Objeto interativo de teste que reage a golpes de machado e suporta empurrão.

signal destroyed

@export var max_health: int = 3
@export var friction: float = 800.0

var current_health: int = 3
var is_invulnerable: bool = false

@onready var visual_rect: ColorRect = get_node_or_null("VisualRect")
@onready var hurtbox: Area2D = get_node_or_null("Hurtbox")


func _ready() -> void:
	current_health = max_health
	if hurtbox != null:
		hurtbox.area_entered.connect(_on_hurtbox_area_entered)


func _physics_process(delta: float) -> void:
	if velocity != Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		move_and_slide()


func push_by(dir: Vector2, speed: float) -> void:
	velocity = dir.normalized() * speed
	move_and_slide()


func take_hit(damage: int = 1) -> void:
	if is_invulnerable or current_health <= 0:
		return
	
	current_health -= damage
	_flash_effect()
	
	if current_health <= 0:
		_destroy()


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.name == "AttackHitbox" or area.is_in_group("player_hitbox"):
		take_hit(1)


func _flash_effect() -> void:
	if visual_rect == null:
		return
	is_invulnerable = true
	var orig_color: Color = visual_rect.color
	visual_rect.color = Color(1.0, 0.9, 0.4, 1.0)
	var timer: SceneTreeTimer = get_tree().create_timer(0.12)
	timer.timeout.connect(func() -> void:
		if is_instance_valid(visual_rect):
			visual_rect.color = orig_color
		is_invulnerable = false
	)


func _destroy() -> void:
	destroyed.emit()
	queue_free()
