class_name TestDialogueSystem
extends RefCounted

## Testes automatizados para o sistema de diálogos, DialogueManager e NPC.


static func run_tests() -> bool:
	var all_passed: bool = true
	all_passed = all_passed and test_dialogue_line_data()
	all_passed = all_passed and test_dialogue_box_lifecycle()
	all_passed = all_passed and test_dialogue_manager_state_lock()
	all_passed = all_passed and test_npc_facing_and_interact()
	all_passed = all_passed and test_npc_collision_bounds()
	all_passed = all_passed and test_player_interaction_reach()
	all_passed = all_passed and test_player_walk_lock_on_dialogue()
	all_passed = all_passed and test_portrait_expressions_resolution()
	all_passed = all_passed and test_portrait_frame_autocollapse()
	return all_passed


static func test_dialogue_line_data() -> bool:
	var line: DialogueLine = DialogueLine.new("Hero", "Greetings.", null, "neutral")
	assert(line.speaker == "Hero", "Speaker must match")
	assert(line.text == "Greetings.", "Text must match")
	assert(line.portrait == null, "Portrait defaults to null")
	assert(line.expression == "neutral", "Expression must match")
	
	var from_d: DialogueLine = DialogueLine.from_dict({
		"speaker": "Elder",
		"text": "Beware the mist.",
		"portrait": null,
		"expression": "shock"
	})
	assert(from_d.speaker == "Elder", "from_dict speaker must match")
	assert(from_d.text == "Beware the mist.", "from_dict text must match")
	assert(from_d.expression == "shock", "from_dict expression must match")
	return true


static func test_dialogue_box_lifecycle() -> bool:
	var box_scene: PackedScene = load("res://scenes/ui/dialogue_box.tscn")
	assert(box_scene != null, "DialogueBox scene must be loadable")
	var box: DialogueBox = box_scene.instantiate() as DialogueBox
	assert(box != null, "DialogueBox must instantiate")
	
	var test_lines: Array[Dictionary] = [
		{"speaker": "Narrator", "text": "First line of text.", "portrait": null},
		{"speaker": "Narrator", "text": "Second line.", "portrait": null}
	]
	box.start(test_lines)
	assert(box.get("_current_index") == 0, "Current index must be 0")
	assert(box.get("_is_typing") == true, "Must be typing on start")
	
	box.skip_typing()
	assert(box.get("_is_typing") == false, "Must not be typing after skip")
	
	box.advance()
	assert(box.get("_current_index") == 1, "Must advance to index 1")
	
	box.advance()
	box.free()
	return true


static func test_dialogue_manager_state_lock() -> bool:
	var sm: DialogueManagerSingleton = DialogueManagerSingleton.new()
	assert(sm != null, "DialogueManagerSingleton must instantiate")
	assert(sm.is_active() == false, "Must start inactive")
	sm.free()
	
	var player_scene: PackedScene = load("res://scenes/characters/player.tscn")
	assert(player_scene != null, "Player scene must be loadable")
	var player: Player = player_scene.instantiate() as Player
	assert(player != null, "Player must instantiate")
	assert(player._can_walk() == true, "Player can walk normally")
	player.free()
	return true


static func test_npc_facing_and_interact() -> bool:
	var npc_scene: PackedScene = load("res://scenes/characters/npc.tscn")
	assert(npc_scene != null, "NPC scene must be loadable")
	var npc: NPC = npc_scene.instantiate() as NPC
	assert(npc != null, "NPC must instantiate")
	
	npc.global_position = Vector2(100, 100)
	npc._turn_towards_player(Vector2(50, 100))
	assert(npc.current_direction == NPC.Direction.LEFT, "NPC must turn LEFT when player is to the left")
	
	npc._turn_towards_player(Vector2(100, 50))
	assert(npc.current_direction == NPC.Direction.UP, "NPC must turn UP when player is above")
	
	npc._turn_towards_player(Vector2(150, 100))
	assert(npc.current_direction == NPC.Direction.RIGHT, "NPC must turn RIGHT when player is to the right")
	
	npc.free()
	return true


static func test_npc_collision_bounds() -> bool:
	var npc_scene: PackedScene = load("res://scenes/characters/npc.tscn")
	assert(npc_scene != null, "NPC scene must be loadable")
	var npc: NPC = npc_scene.instantiate() as NPC
	assert(npc != null, "NPC must instantiate")
	assert(npc.y_sort_enabled == true, "NPC must have y_sort_enabled = true")
	
	var col: CollisionShape2D = npc.get_node_or_null("CollisionShape2D") as CollisionShape2D
	assert(col != null, "NPC must have CollisionShape2D")
	assert(col.shape is RectangleShape2D, "Shape must be RectangleShape2D")
	var rect_shape: RectangleShape2D = col.shape as RectangleShape2D
	assert(rect_shape.size.x >= 24.0, "Foot collision width must be at least 24px")
	assert(rect_shape.size.y >= 14.0, "Foot collision height must be at least 14px")
	assert(col.position.y <= 0.0, "Foot collision must be at base or slightly offset upwards")
	
	npc.free()
	return true


static func test_player_interaction_reach() -> bool:
	var player_scene: PackedScene = load("res://scenes/characters/player.tscn")
	assert(player_scene != null, "Player scene must be loadable")
	var player: Player = player_scene.instantiate() as Player
	assert(player != null, "Player must instantiate")
	assert(player.y_sort_enabled == true, "Player must have y_sort_enabled = true")
	
	var ray: RayCast2D = player.get_node_or_null("InteractionRay") as RayCast2D
	assert(ray != null, "Player must have InteractionRay")
	player._resolve_8way_direction(Vector2(0, 1))
	assert(ray.target_position.y >= 30.0, "InteractionRay down reach must be >= 30px")
	player._resolve_8way_direction(Vector2(0, -1))
	assert(ray.target_position.y <= -30.0, "InteractionRay up reach must be <= -30px")
	player._resolve_8way_direction(Vector2(1, 0))
	assert(ray.target_position.x >= 30.0, "InteractionRay right reach must be >= 30px")
	player._resolve_8way_direction(Vector2(-1, 0))
	assert(ray.target_position.x <= -30.0, "InteractionRay left reach must be <= -30px")
	
	player.free()
	return true


static func test_player_walk_lock_on_dialogue() -> bool:
	var player_scene: PackedScene = load("res://scenes/characters/player.tscn")
	assert(player_scene != null, "Player scene must be loadable")
	var player: Player = player_scene.instantiate() as Player
	assert(player != null, "Player must instantiate")
	
	player.current_state = Player.State.WALK
	player.velocity = Vector2(0, 120)
	player.force_idle()
	assert(player.current_state == Player.State.IDLE, "Player must transition to IDLE on force_idle")
	assert(player.velocity == Vector2.ZERO, "Player velocity must be zeroed")
	if player.animated_sprite != null:
		assert(player.animated_sprite.animation.begins_with("idle_"), "Animation must switch to idle")
	
	player.free()
	return true


static func test_portrait_expressions_resolution() -> bool:
	var neutral_tex: Texture2D = DialogueBox.get_portrait_by_expression("neutral")
	var serious_tex: Texture2D = DialogueBox.get_portrait_by_expression("serious")
	var shock_tex: Texture2D = DialogueBox.get_portrait_by_expression("shock")
	var confident_tex: Texture2D = DialogueBox.get_portrait_by_expression("confident")
	
	assert(neutral_tex != null, "Neutral portrait must resolve")
	assert(serious_tex != null, "Serious portrait must resolve")
	assert(shock_tex != null, "Shock portrait must resolve")
	assert(confident_tex != null, "Confident portrait must resolve")
	assert(DialogueBox.get_portrait_by_expression("invalid_tag") == null, "Invalid tag must be null")
	return true


static func test_portrait_frame_autocollapse() -> bool:
	var box_scene: PackedScene = load("res://scenes/ui/dialogue_box.tscn")
	assert(box_scene != null, "DialogueBox scene must be loadable")
	var box: DialogueBox = box_scene.instantiate() as DialogueBox
	assert(box != null, "DialogueBox must instantiate")
	
	var lines: Array[Dictionary] = [
		{"speaker": "Guard", "text": "No portrait line.", "portrait": null},
		{"speaker": "Lucas", "text": "Portrait line.", "expression": "shock"}
	]
	box.start(lines)
	assert(box.portrait_frame != null, "Must have portrait_frame")
	assert(box.portrait_frame.visible == false, "Must auto-collapse when no portrait")
	
	box.advance()
	assert(box.portrait_frame.visible == true, "Must be visible when expression has portrait")
	assert(box.portrait_rect.texture != null, "Texture must be assigned")
	
	box.free()
	return true


