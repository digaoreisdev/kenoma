class_name SceneManagerSingleton
extends Node

## Singleton global para gerenciamento de transição de cenas e batalhas.

signal transition_started
signal scene_loaded(new_scene: Node)
signal transition_finished

@export var fade_duration: float = 0.35

var is_transitioning: bool = false
var batalha_dados_retorno: Dictionary = {
	"mapa_origem": "",
	"player_pos": Vector2.ZERO,
	"rift_id": "",
	"grupo_inimigo": []
}
var rifts_derrotadas: Array[String] = []
var cena_batalha_ativa: Node = null
var ultima_cena_carregada: String = ""

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


func _get_active_tree() -> SceneTree:
	if is_inside_tree() and get_tree() != null:
		return get_tree()
	return Engine.get_main_loop() as SceneTree


func _get_autoload_node(autoload_name: String) -> Node:
	var tree: SceneTree = _get_active_tree()
	if tree != null and tree.root != null:
		return tree.root.get_node_or_null(autoload_name)
	return null


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
	var tree: SceneTree = _get_active_tree()
	if tree != null:
		tree.change_scene_to_file(path)
		await tree.process_frame
		var current_scene: Node = tree.current_scene
		scene_loaded.emit(current_scene)
		if current_scene != null:
			var player: Node = _find_player(current_scene)
			if player != null:
				_position_player(player, current_scene, spawn_id, dir)


func is_rift_derrotada(id: String) -> bool:
	return rifts_derrotadas.has(id)


func salvar_estado_batalha(dados: Dictionary) -> void:
	var mapa_path: String = ""
	var tree: SceneTree = _get_active_tree()
	if tree != null and tree.current_scene != null:
		mapa_path = tree.current_scene.scene_file_path
	if mapa_path.is_empty():
		mapa_path = str(dados.get("mapa_origem", "res://scenes/maps/test_map.tscn"))
	var p_pos: Vector2 = dados.get("player_pos", Vector2.ZERO)
	var r_id: String = str(dados.get("rift_id", ""))
	var grupo: Array = dados.get("grupo_inimigo", [])
	batalha_dados_retorno = {
		"mapa_origem": mapa_path,
		"player_pos": p_pos,
		"rift_id": r_id,
		"grupo_inimigo": grupo
	}


func iniciar_batalha(dados_encontro: Dictionary, animar_fade: bool = true) -> void:
	if is_transitioning:
		return
	salvar_estado_batalha(dados_encontro)
	var gs: Node = _get_autoload_node("GameState")
	if gs != null and gs.has_method("change_state"):
		gs.call("change_state", 2)
	if animar_fade and _fade_rect != null and is_inside_tree():
		await _transicionar_para_batalha("res://scenes/battle/battle_scene.tscn")
	else:
		_carregar_batalha_imediata("res://scenes/battle/battle_scene.tscn")


func _transicionar_para_batalha(path: String) -> void:
	is_transitioning = true
	transition_started.emit()
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var out_tw: Tween = create_tween()
	out_tw.tween_property(_fade_rect, "modulate:a", 1.0, fade_duration).set_trans(Tween.TRANS_SINE)
	await out_tw.finished
	_carregar_batalha_imediata(path)
	var in_tw: Tween = create_tween()
	in_tw.tween_property(_fade_rect, "modulate:a", 0.0, fade_duration).set_trans(Tween.TRANS_SINE)
	await in_tw.finished
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false
	transition_finished.emit()


func _carregar_batalha_imediata(path: String) -> void:
	ultima_cena_carregada = path
	var battle_packed: PackedScene = load(path) as PackedScene
	if battle_packed == null:
		return
	var scene: Node = battle_packed.instantiate()
	cena_batalha_ativa = scene
	var tree: SceneTree = _get_active_tree()
	if tree != null and tree.root != null and is_inside_tree():
		if tree.current_scene != null:
			tree.current_scene.queue_free()
		tree.root.add_child(scene)
		tree.current_scene = scene
	_configurar_encontro_batalha(scene)
	scene_loaded.emit(scene)


func _obter_aliados_para_batalha() -> Array[CharacterData]:
	var allies: Array[CharacterData] = []
	var pm: Node = _get_autoload_node("PartyManager")
	if pm != null and pm.has_method("get_active_party"):
		var party_raw: Array = pm.call("get_active_party")
		for m in party_raw:
			if m is CharacterData:
				allies.append(m)
	if allies.is_empty():
		allies.append(CharacterData.create_default_lucas())
	return allies


func _configurar_encontro_batalha(scene: Node) -> void:
	var bm: BattleManager = scene.get_node_or_null("BattleManager") as BattleManager
	if bm == null:
		return
	var allies: Array[CharacterData] = _obter_aliados_para_batalha()
	var raw_enemies: Array = batalha_dados_retorno.get("grupo_inimigo", [])
	var inimigos: Array = []
	for e: Variant in raw_enemies:
		if e is Dictionary:
			inimigos.append(e)
		elif e is Object and (e as Object).has_method("to_dictionary"):
			inimigos.append((e as Object).call("to_dictionary"))
	if inimigos.is_empty():
		inimigos = EnemyData.create_squad_cassian_8()
	bm.initialize_battle(allies, inimigos)


func finalizar_batalha(vitoria: bool, animar_fade: bool = true) -> void:
	var mapa_path: String = str(batalha_dados_retorno.get("mapa_origem", ""))
	if mapa_path.is_empty():
		mapa_path = "res://scenes/maps/test_map.tscn"
	if animar_fade and _fade_rect != null and is_inside_tree():
		await _retornar_mapa_com_fade(mapa_path, vitoria)
	else:
		_retornar_mapa_imediato(mapa_path, vitoria)


func _retornar_mapa_com_fade(mapa_path: String, vitoria: bool) -> void:
	is_transitioning = true
	transition_started.emit()
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var out_tw: Tween = create_tween()
	out_tw.tween_property(_fade_rect, "modulate:a", 1.0, fade_duration).set_trans(Tween.TRANS_SINE)
	await out_tw.finished
	_retornar_mapa_imediato(mapa_path, vitoria)
	var in_tw: Tween = create_tween()
	in_tw.tween_property(_fade_rect, "modulate:a", 0.0, fade_duration).set_trans(Tween.TRANS_SINE)
	await in_tw.finished
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false
	transition_finished.emit()


func _retornar_mapa_imediato(mapa_path: String, vitoria: bool) -> void:
	ultima_cena_carregada = mapa_path
	var map_packed: PackedScene = load(mapa_path) as PackedScene
	if map_packed == null:
		return
	var scene: Node = map_packed.instantiate()
	var tree: SceneTree = _get_active_tree()
	if tree != null and tree.root != null and is_inside_tree():
		if tree.current_scene != null:
			tree.current_scene.queue_free()
		tree.root.add_child(scene)
		tree.current_scene = scene
	aplicar_retorno_batalha(scene, vitoria)
	scene_loaded.emit(scene)


func aplicar_retorno_batalha(scene: Node, vitoria: bool) -> void:
	if scene == null:
		return
	if vitoria:
		var r_id: String = str(batalha_dados_retorno.get("rift_id", ""))
		if not r_id.is_empty() and not rifts_derrotadas.has(r_id):
			rifts_derrotadas.append(r_id)
		_limpar_rifts_derrotadas(scene)
	var player: Node = _find_player(scene)
	if player != null and player is Node2D:
		(player as Node2D).global_position = batalha_dados_retorno.get("player_pos", (player as Node2D).global_position)
	var gs: Node = _get_autoload_node("GameState")
	if gs != null and gs.has_method("change_state"):
		gs.call("change_state", 0)


func _limpar_rifts_derrotadas(root: Node) -> void:
	if root is MiasmaRift:
		var rift: MiasmaRift = root as MiasmaRift
		if rifts_derrotadas.has(rift.rift_id):
			rift.desativar()
	for child: Node in root.get_children():
		_limpar_rifts_derrotadas(child)


func _find_player(node: Node) -> Node:
	if node is Player or node.name == "Player":
		return node
	for child: Node in node.get_children():
		var found: Node = _find_player(child)
		if found != null:
			return found
	return null


func _position_player(player: Node, root: Node, spawn_id: String, dir: Player.Direction) -> void:
	if player is Node2D and not spawn_id.is_empty():
		var spawn: SpawnPoint = _find_spawn_point(root, spawn_id)
		if spawn != null:
			(player as Node2D).global_position = spawn.global_position
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
