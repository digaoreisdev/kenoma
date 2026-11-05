class_name SceneManagerSingleton
extends Node

## Singleton global para gerenciamento de transição de cenas com fade out/in e posicionamento em spawn points.

signal transition_started
signal scene_loaded(new_scene: Node)
signal transition_finished

@export var fade_duration: float = 0.35

var is_transitioning: bool = false

var _canvas_layer: CanvasLayer
var _fade_rect: ColorRect


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_fade_overlay()


func _setup_fade_overlay() -> void:
	_canvas_layer = CanvasLayer.new()
	_canvas_layer.layer = 100
	add_child(_canvas_layer)
	
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color.BLACK
	_fade_rect.modulate.a = 0.0
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas_layer.add_child(_fade_rect)


func change_scene(target_path: String, spawn_id: String = "", dir: Player.Direction = Player.Direction.DOWN) -> void:
	if is_transitioning or target_path.is_empty():
		return
	is_transitioning = true
	transition_started.emit()
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var out_tween: Tween = create_tween()
	out_tween.tween_property(_fade_rect, "modulate:a", 1.0, fade_duration).set_trans(Tween.TRANS_SINE)
	await out_tween.finished
	
	await _load_and_setup_scene(target_path, spawn_id, dir)
	
	var in_tween: Tween = create_tween()
	in_tween.tween_property(_fade_rect, "modulate:a", 0.0, fade_duration).set_trans(Tween.TRANS_SINE)
	await in_tween.finished
	
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false
	transition_finished.emit()


func _load_and_setup_scene(path: String, spawn_id: String, dir: Player.Direction) -> void:
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	
	var current_scene: Node = get_tree().current_scene
	scene_loaded.emit(current_scene)
	if current_scene == null:
		return
	
	var player: Player = _find_player(current_scene)
	if player != null:
		_position_player(player, current_scene, spawn_id, dir)


func _find_player(node: Node) -> Player:
	if node is Player:
		return node as Player
	for child: Node in node.get_children():
		var found: Player = _find_player(child)
		if found != null:
			return found
	return null


func _position_player(player: Player, root: Node, spawn_id: String, dir: Player.Direction) -> void:
	if not spawn_id.is_empty():
		var spawn: SpawnPoint = _find_spawn_point(root, spawn_id)
		if spawn != null:
			player.global_position = spawn.global_position
	if player.has_method("set_facing_direction"):
		player.call("set_facing_direction", dir)


func _find_spawn_point(node: Node, target_id: String) -> SpawnPoint:
	if node is SpawnPoint and (node as SpawnPoint).spawn_id == target_id:
		return node as SpawnPoint
	for child: Node in node.get_children():
		var found: SpawnPoint = _find_spawn_point(child, target_id)
		if found != null:
			return found
	return null

