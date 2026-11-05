class_name TestPauseMenu
extends RefCounted

## Testes automatizados para CharacterData, PartyManager e PauseMenu (PT-BR).


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
	var pm: PartyManager = PartyManager.new()
	assert(pm != null, "PartyManager must instantiate")
	pm.reset_to_defaults()
	assert(pm.has_member(0) == true, "Slot 0 must have Lucas")
	assert(pm.has_member(1) == false, "Slot 1 must be empty")
	assert(pm.has_member(2) == false, "Slot 2 must be empty")
	assert(pm.has_member(3) == false, "Slot 3 must be empty")
	
	pm.add_gold(150)
	assert(pm.get_gold_text() == "150 G", "Gold text must be 150 G")
	pm.swap_members(0, 1)
	assert(pm.has_member(0) == false, "Slot 0 should now be empty")
	assert(pm.has_member(1) == true, "Slot 1 should now have Lucas")
	pm.free()
	return true


static func test_pause_menu_lifecycle() -> bool:
	var menu_scene: PackedScene = load("res://scenes/ui/pause_menu.tscn")
	assert(menu_scene != null, "pause_menu.tscn must be loadable")
	var menu: PauseMenu = menu_scene.instantiate() as PauseMenu
	assert(menu != null, "PauseMenu must instantiate")
	
	assert(menu.current_state == PauseMenu.MenuState.CLOSED, "Menu must start closed")
	menu.open_menu()
	assert(menu.current_state == PauseMenu.MenuState.COMMAND_SELECT, "State must be COMMAND_SELECT on open")
	assert(menu.panel_root.visible == true, "Root panel must be visible")
	
	menu.close_menu()
	assert(menu.current_state == PauseMenu.MenuState.CLOSED, "State must be CLOSED")
	assert(menu.panel_root.visible == false, "Root panel must be hidden")
	menu.free()
	return true


static func test_pause_menu_pt_br_commands() -> bool:
	var expected_commands: Array[String] = [
		"Itens", "Habilidades", "Primordiais", "Equipamento",
		"Status", "Formação", "Configurações", "Salvar"
	]
	assert(PauseMenu.COMMAND_LABELS == expected_commands, "PT-BR commands must match specification exactly")
	
	var menu_scene: PackedScene = load("res://scenes/ui/pause_menu.tscn")
	var menu: PauseMenu = menu_scene.instantiate() as PauseMenu
	menu.open_menu()
	
	menu._on_command_chosen(1) # Habilidades
	assert(menu.current_state == PauseMenu.MenuState.CHARACTER_SELECT, "Habilidades must prompt character select")
	assert(menu.target_system_name == "Habilidades", "Target system must be Habilidades")
	
	menu._handle_cancel()
	assert(menu.current_state == PauseMenu.MenuState.COMMAND_SELECT, "Cancel must return to command select")
	menu.free()
	return true


static func test_character_select_and_banner() -> bool:
	var menu_scene: PackedScene = load("res://scenes/ui/pause_menu.tscn")
	var menu: PauseMenu = menu_scene.instantiate() as PauseMenu
	menu.open_menu()
	
	menu._on_command_chosen(2) # Primordiais
	assert(menu.current_state == PauseMenu.MenuState.CHARACTER_SELECT, "Primordiais must enter character select")
	
	menu._on_character_chosen(0) # Select Lucas
	assert(menu.current_state == PauseMenu.MenuState.BANNER_DISPLAY, "State must become BANNER_DISPLAY")
	assert(menu.banner_panel.visible == true, "Banner must be visible")
	assert(menu.banner_label.text.contains("Primordiais"), "Banner text must mention Primordiais")
	
	menu._handle_interact()
	assert(menu.current_state == PauseMenu.MenuState.COMMAND_SELECT, "Interact must dismiss banner")
	menu.free()
	return true
