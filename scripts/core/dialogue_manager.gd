class_name DialogueManagerSingleton
extends Node

## Singleton global para gerenciamento da execução de diálogos narrativos.

signal dialogue_started(dialogue_id: String)
signal dialogue_finished

var is_dialogue_active: bool = false
var _dialogue_box: DialogueBox = null

const DIALOGUE_BOX_SCENE: PackedScene = preload("res://scenes/ui/dialogue_box.tscn")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_dialogue_box()


func _setup_dialogue_box() -> void:
	_dialogue_box = DIALOGUE_BOX_SCENE.instantiate() as DialogueBox
	if _dialogue_box != null:
		add_child(_dialogue_box)
		_dialogue_box.dialogue_completed.connect(_on_dialogue_completed)


func start_dialogue(lines: Array, dialogue_id: String = "") -> void:
	if is_dialogue_active or lines.is_empty():
		return
	is_dialogue_active = true
	if has_node("/root/GameState"):
		var gs: Node = get_node("/root/GameState")
		gs.call("change_state", GameState.State.DIALOGUE)
	dialogue_started.emit(dialogue_id)
	if _dialogue_box != null:
		_dialogue_box.start(lines)


func _on_dialogue_completed() -> void:
	is_dialogue_active = false
	if has_node("/root/GameState"):
		var gs: Node = get_node("/root/GameState")
		gs.call("change_state", GameState.State.EXPLORATION)
	dialogue_finished.emit()


func is_active() -> bool:
	return is_dialogue_active


func advance_current_dialogue() -> void:
	if _dialogue_box != null and is_dialogue_active:
		_dialogue_box.advance()

