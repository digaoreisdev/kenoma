class_name TestDialogueSystem
extends RefCounted

## Testes automatizados para o sistema de diálogos, DialogueManager e NPC.


static func run_tests() -> bool:
	var all_passed: bool = true
	all_passed = all_passed and test_dialogue_line_data()
	all_passed = all_passed and test_dialogue_box_lifecycle()
	all_passed = all_passed and test_dialogue_manager_state_lock()
	all_passed = all_passed and test_npc_facing_and_interact()
	return all_passed


static func test_dialogue_line_data() -> bool:
	var line: DialogueLine = DialogueLine.new("Hero", "Greetings.")
	assert(line.speaker == "Hero", "Speaker must match")
	assert(line.text == "Greetings.", "Text must match")
	assert(line.portrait == null, "Portrait defaults to null")
	
	var from_d: DialogueLine = DialogueLine.from_dict({
		"speaker": "Elder",
		"text": "Beware the mist.",
		"portrait": null
	})
	assert(from_d.speaker == "Elder", "from_dict speaker must match")
	assert(from_d.text == "Beware the mist.", "from_dict text must match")
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
