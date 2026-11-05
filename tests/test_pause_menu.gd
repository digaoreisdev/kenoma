class_name TestPauseMenu
extends RefCounted

## Testes automatizados para CharacterData, PartyManager e PauseMenu (PT-BR).

const PartyManagerScript: GDScript = preload("res://scripts/core/party_manager.gd")
const PauseMenuScript: GDScript = preload("res://scripts/ui/pause_menu.gd")


static func run_tests(tree: SceneTree = null) -> bool:
	if tree == null:
		tree = Engine.get_main_loop() as SceneTree
	var passed: bool = true
	passed = passed and test_character_data_defaults()
	passed = passed and test_character_equipment_and_stats()
	passed = passed and test_party_manager_slots_and_swap()
	passed = passed and test_inventory_item_consumption_and_healing()
	passed = passed and test_pause_menu_lifecycle(tree)
	passed = passed and test_pause_menu_pt_br_commands(tree)
	passed = passed and test_character_select_and_banner(tree)
	passed = passed and test_pause_menu_item_submenu(tree)
	passed = passed and test_pause_menu_status_and_equipment_submenus(tree)
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


static func test_pause_menu_lifecycle(tree: SceneTree = null) -> bool:
	if tree == null:
		tree = Engine.get_main_loop() as SceneTree
	var menu_scene: PackedScene = load("res://scenes/ui/pause_menu.tscn")
	assert(menu_scene != null, "pause_menu.tscn must be loadable")
	var menu: CanvasLayer = menu_scene.instantiate() as CanvasLayer
	assert(menu != null, "PauseMenu must instantiate")
	if tree != null and tree.root != null:
		tree.root.add_child(menu)
	
	assert(int(menu.get("current_state")) == int(PauseMenuScript.MenuState.CLOSED), "Menu must start closed")
	menu.call("open_menu")
	assert(int(menu.get("current_state")) == int(PauseMenuScript.MenuState.COMMAND_SELECT), "State must be COMMAND_SELECT on open")
	var root: Control = menu.get("panel_root") as Control
	assert(root != null and root.visible == true, "Root panel must be visible")
	
	menu.call("close_menu")
	assert(int(menu.get("current_state")) == int(PauseMenuScript.MenuState.CLOSED), "State must be CLOSED")
	assert(root.visible == false, "Root panel must be hidden")
	if tree != null and tree.root != null:
		tree.root.remove_child(menu)
	menu.free()
	return true


static func test_pause_menu_pt_br_commands(tree: SceneTree = null) -> bool:
	if tree == null:
		tree = Engine.get_main_loop() as SceneTree
	var expected_commands: Array[String] = [
		"Itens", "Habilidades", "Primordiais", "Equipamento",
		"Status", "Formação", "Configurações", "Salvar"
	]
	var actual_commands: Array[String] = PauseMenuScript.COMMAND_LABELS
	assert(actual_commands == expected_commands, "PT-BR commands must match specification exactly")
	
	var menu_scene: PackedScene = load("res://scenes/ui/pause_menu.tscn")
	var menu: CanvasLayer = menu_scene.instantiate() as CanvasLayer
	if tree != null and tree.root != null:
		tree.root.add_child(menu)
	menu.call("open_menu")
	
	menu.call("_on_command_chosen", 1)
	assert(int(menu.get("current_state")) == int(PauseMenuScript.MenuState.CHARACTER_SELECT), "Habilidades must prompt character select")
	assert(str(menu.get("target_system_name")) == "Habilidades", "Target system must be Habilidades")
	
	menu.call("_handle_cancel")
	assert(int(menu.get("current_state")) == int(PauseMenuScript.MenuState.COMMAND_SELECT), "Cancel must return to command select")
	if tree != null and tree.root != null:
		tree.root.remove_child(menu)
	menu.free()
	return true


static func test_character_select_and_banner(tree: SceneTree = null) -> bool:
	if tree == null:
		tree = Engine.get_main_loop() as SceneTree
	var menu_scene: PackedScene = load("res://scenes/ui/pause_menu.tscn")
	var menu: CanvasLayer = menu_scene.instantiate() as CanvasLayer
	if tree != null and tree.root != null:
		tree.root.add_child(menu)
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
	if tree != null and tree.root != null:
		tree.root.remove_child(menu)
	menu.free()
	return true


static func test_inventory_item_consumption_and_healing() -> bool:
	var pm: Node = PartyManagerScript.new()
	assert(pm != null, "PartyManager instance must be created")
	pm.call("reset_to_defaults")
	assert(int(pm.call("get_item_count", "potion")) == 3, "Inventory must start with 3 Potions")
	
	var lucas: CharacterData = pm.call("get_member", 0) as CharacterData
	assert(lucas != null, "Lucas must exist in slot 0")
	lucas.current_hp = 50
	
	var potion: ItemData = ItemData.create_potion()
	var used: bool = bool(pm.call("use_item", potion, 0))
	assert(used == true, "Using potion on damaged Lucas must succeed")
	assert(lucas.current_hp == 100, "50 + 50 must heal Lucas to 100 PV")
	assert(int(pm.call("get_item_count", "potion")) == 2, "Potion quantity must reduce to 2")
	
	var used2: bool = bool(pm.call("use_item", potion, 0))
	assert(used2 == true, "Second potion must succeed and clamp to max_hp")
	assert(lucas.current_hp == 120, "100 + 50 must clamp to max 120 PV")
	assert(int(pm.call("get_item_count", "potion")) == 1, "Potion quantity must reduce to 1")
	
	var used_empty: bool = bool(pm.call("use_item", potion, 1))
	assert(used_empty == false, "Using potion on empty slot must return false")
	assert(int(pm.call("get_item_count", "potion")) == 1, "Quantity must not reduce on invalid use")
	pm.free()
	return true


static func test_pause_menu_item_submenu(tree: SceneTree = null) -> bool:
	if tree == null:
		tree = Engine.get_main_loop() as SceneTree
	var menu_scene: PackedScene = load("res://scenes/ui/pause_menu.tscn")
	var menu: CanvasLayer = menu_scene.instantiate() as CanvasLayer
	if tree != null and tree.root != null:
		tree.root.add_child(menu)
	menu.call("open_menu")
	
	menu.call("_on_command_chosen", 0)
	assert(int(menu.get("current_state")) == int(PauseMenuScript.MenuState.ITEM_SELECT), "State must be ITEM_SELECT")
	var item_pan: Control = menu.get("item_panel") as Control
	var cmd_pan: Control = menu.get("command_panel") as Control
	assert(item_pan != null and item_pan.visible == true, "Item panel must be visible")
	assert(cmd_pan != null and cmd_pan.visible == false, "Command panel must be hidden")
	
	menu.call("_handle_interact")
	assert(int(menu.get("current_state")) == int(PauseMenuScript.MenuState.ITEM_TARGET), "State must be ITEM_TARGET")
	
	menu.call("_handle_cancel")
	assert(int(menu.get("current_state")) == int(PauseMenuScript.MenuState.ITEM_SELECT), "Cancel must return to ITEM_SELECT")
	
	menu.call("_handle_cancel")
	assert(int(menu.get("current_state")) == int(PauseMenuScript.MenuState.COMMAND_SELECT), "Cancel must return to COMMAND_SELECT")
	assert(cmd_pan.visible == true, "Command panel must be restored")
	assert(item_pan.visible == false, "Item panel must be hidden")
	if tree != null and tree.root != null:
		tree.root.remove_child(menu)
	menu.free()
	return true


static func test_character_equipment_and_stats() -> bool:
	var lucas: CharacterData = CharacterData.create_default_lucas()
	assert(lucas != null, "Lucas must instantiate")
	assert(lucas.get_base_stat("strength") == 14, "Base strength must be 14")
	assert(lucas.get_equipment_bonus("strength") == 5, "Espada Curta gives +5 strength")
	assert(lucas.get_total_stat("strength") == 19, "Total strength must be 19")
	assert(lucas.get_total_stat("defense") == 10, "Base defense without equipment is 10")
	
	var shield: EquipmentData = EquipmentData.new("iron_shield", "Escudo de Ferro", EquipmentData.SlotType.OFF_HAND, {"defense": 4})
	lucas.equip(shield, "off_hand")
	assert(lucas.get_equipment_bonus("defense") == 4, "Shield bonus must be 4")
	assert(lucas.get_total_stat("defense") == 14, "10 + 4 defense must be 14")
	return true


static func test_pause_menu_status_and_equipment_submenus(tree: SceneTree = null) -> bool:
	if tree == null:
		tree = Engine.get_main_loop() as SceneTree
	var menu_scene: PackedScene = load("res://scenes/ui/pause_menu.tscn")
	var menu: CanvasLayer = menu_scene.instantiate() as CanvasLayer
	if tree != null and tree.root != null:
		tree.root.add_child(menu)
	menu.call("open_menu")
	
	# Test Status submenu (Command 4: "Status")
	menu.call("_on_command_chosen", 4)
	assert(int(menu.get("current_state")) == int(PauseMenuScript.MenuState.STATUS_VIEW), "State must be STATUS_VIEW")
	var status_pan: Control = menu.get("status_panel") as Control
	assert(status_pan != null and status_pan.visible == true, "Status panel must be visible")
	menu.call("_handle_cancel")
	assert(int(menu.get("current_state")) == int(PauseMenuScript.MenuState.COMMAND_SELECT), "Cancel must return to COMMAND_SELECT")
	assert(status_pan.visible == false, "Status panel must be hidden")
	
	# Test Equipment submenu (Command 3: "Equipamento")
	menu.call("_on_command_chosen", 3)
	assert(int(menu.get("current_state")) == int(PauseMenuScript.MenuState.EQUIPMENT_VIEW), "State must be EQUIPMENT_VIEW")
	var equip_pan: Control = menu.get("equip_panel") as Control
	assert(equip_pan != null and equip_pan.visible == true, "Equipment panel must be visible")
	menu.call("_handle_cancel")
	assert(int(menu.get("current_state")) == int(PauseMenuScript.MenuState.COMMAND_SELECT), "Cancel must return to COMMAND_SELECT")
	assert(equip_pan.visible == false, "Equipment panel must be hidden")
	
	if tree != null and tree.root != null:
		tree.root.remove_child(menu)
	menu.free()
	return true
