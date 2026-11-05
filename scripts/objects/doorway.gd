class_name Doorway
extends Area2D

## Ponto de transição e teletransporte entre cenas com transição suave de tela.

@export_file("*.tscn") var target_scene: String = ""
@export var target_spawn_id: String = ""
@export var exit_direction: Player.Direction = Player.Direction.DOWN

var _is_triggered: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _is_triggered or not (body is Player):
		return
	if target_scene.is_empty() or not has_node("/root/SceneManager"):
		return
	var sm: Node = get_node("/root/SceneManager")
	if sm.get("is_transitioning") == true:
		return
	_is_triggered = true
	sm.call("change_scene", target_scene, target_spawn_id, exit_direction)

