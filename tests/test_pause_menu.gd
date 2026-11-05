class_name TestPauseMenu
extends RefCounted

## Testes automatizados para CharacterData, PartyManager e PauseMenu (PT-BR).

const PartyManagerScript: GDScript = preload("res://scripts/core/party_manager.gd")
const PauseMenuScript: GDScript = preload("res://scripts/ui/pause_menu.gd")


static func run_tests() -> bool:
	var passed: bool = true
	passed = passed and test_character_data_defaults()
	passed = passed and test_party_manager_slots_and_swap()
	passed = passed and test_pause_menu_lifecycle()
	passed = passed and test_pause_menu_pt_br_commands()
	passed = passed and test_character_select_and_banner()
	return passed


static func test_character_data_defaults() -> bool:
	var lucas: CharacterData = CharacterData.create_default_lucas()
	assert(lucas != null, "Lucas CharacterData must be created")
	assert(lucas.name == "Lucas Reis", "Name must match Lucas Reis")
	assert(lucas.level == 1, "Level must default to 1")
	assert(lucas.current_hp == 120 and lucas.max_hp == 120, "PV must be 120/120")
	assert(lucas.current_mp == 45 and lucas.max_mp == 45, "PM must be 45/45")
	assert(lucas.equipped_primordial == "", "Default primordial must be empty")
	return true


static func test_party_manager_slots_and_swap() -> bool:
	var pm: Node = PartyManagerScript.new()
	assert(pm != null, "PartyManager instance must be created")
	pm.call("reset_to_defaults")
	assert(pm.call("has_member", 0) == true, "Slot 0 must have Lucas")
	assert(pm.call("has_member", 1) == false, "Slot 1 must be empty")
	assert(pm.call("has_member", 2) == false, "Slot 2 must be empty")
	assert(pm.call("has_member", 3) == false, "Slot 3 must be empty")
	
	pm.call("add_gold", 150)
	assert(str(pm.call("get_gold_text")) == "150 G", "Gold text must be 150 G")
	pm.call("swap_members", 0, 1)
	assert(pm.call("has_member", 0) == false, "Slot 0 should now be empty")
	assert(pm.call("has_member", 1) == true, "Slot 1 should now have Lucas")
	pm.free()
	return true


static func test_pause_menu_lifecycle() -> bool:
	var menu_scene: PackedScene = load("res://scenes/ui/pause_menu.tscn")
	assert(menu_scene != null, "pause_menu.tscn must be loadable")
	var menu: CanvasLayer = menu_scene.instantiate() as CanvasLayer
	assert(menu != null, "PauseMenu must instantiate")
	
	assert(int(menu.get("current_state")) == int(PauseMenuScript.MenuState.CLOSED), "Menu must start closed")
	menu.call("open_menu")
	assert(int(menu.get("current_state")) == int(PauseMenuScript.MenuState.COMMAND_SELECT), "State must be COMMAND_SELECT on open")
	var root: Control = menu.get("panel_root") as Control
	assert(root != null and root.visible == true, "Root panel must be visible")
	
	menu.call("close_menu")
	assert(int(menu.get("current_state")) == int(PauseMenuScript.MenuState.CLOSED), "State must be CLOSED")
	assert(root.visible == false, "Root panel must be hidden")
	menu.free()
	return true


static func test_pause_menu_pt_br_commands() -> bool:
	var expected_commands: Array[String] = [
		"Itens", "Habilidades", "Primordiais", "Equipamento",
		"Status", "Formação", "Configurações", "Salvar"
	]
	var actual_commands: Array[String] = PauseMenuScript.COMMAND_LABELS
	assert(actual_commands == expected_commands, "PT-BR commands must match specification exactly")
	
	var menu_scene: PackedScene = load("res://scenes/ui/pause_menu.tscn")
	var menu: CanvasLayer = menu_scene.instantiate() as CanvasLayer
	menu.call("open_menu")
	
	menu.call("_on_command_chosen", 1)
	assert(int(menu.get("current_state")) == int(PauseMenuScript.MenuState.CHARACTER_SELECT), "Habilidades must prompt character select")
	assert(str(menu.get("target_system_name")) == "Habilidades", "Target system must be Habilidades")
	
	menu.call("_handle_cancel")
	assert(int(menu.get("current_state")) == int(PauseMenuScript.MenuState.COMMAND_SELECT), "Cancel must return to command select")
	menu.free()
	return true


static func test_character_select_and_banner() -> bool:
	var menu_scene: PackedScene = load("res://scenes/ui/pause_menu.tscn")
	var menu: CanvasLayer = menu_scene.instantiate() as CanvasLayer
	menu.call("open_menu")
	
	menu.call("_on_command_chosen", 2)
	assert(int(menu.get("current_state")) == int(PauseMenuScript.MenuState.CHARACTER_SELECT), "Primordiais must enter character select")
	
	menu.call("_on_character_chosen", 0)
	assert(int(menu.get("current_state")) == int(PauseMenuScript.MenuState.BANNER_DISPLAY), "State must become BANNER_DISPLAY")
	var banner: Control = menu.get("banner_panel") as Control
	var label: Label = menu.get("banner_label") as Label
	assert(banner != null and banner.visible == true, "Banner must be visible")
	assert(label != null and label.text.contains("Primordiais"), "Banner text must mention Primordiais")
	
	menu.call("_handle_interact")
	assert(int(menu.get("current_state")) == int(PauseMenuScript.MenuState.COMMAND_SELECT), "Interact must dismiss banner")
	menu.free()
	return true
