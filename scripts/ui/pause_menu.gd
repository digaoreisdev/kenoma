extends CanvasLayer

## Menu de pausa clássico JRPG HD-2D com suporte a grupo de 4 heróis, habilidades e primordiais.

signal menu_opened
signal menu_closed
signal command_selected(command_name: String)
signal character_selected(slot_index: int, character: CharacterData)

enum MenuState {
	CLOSED,
	COMMAND_SELECT,
	CHARACTER_SELECT,
	FORMATION_FIRST,
	FORMATION_SECOND,
	BANNER_DISPLAY,
	ITEM_SELECT,
	ITEM_TARGET,
	STATUS_VIEW,
	EQUIPMENT_VIEW,
}

const COMMAND_LABELS: Array[String] = [
	"Itens",
	"Habilidades",
	"Primordiais",
	"Equipamento",
	"Status",
	"Formação",
	"Configurações",
	"Salvar"
]

const EQUIP_SLOT_KEYS: Array[String] = ["main_hand", "off_hand", "head", "body", "accessory"]
const EQUIP_SLOT_NAMES: Array[String] = ["Mão Princ.", "Mão Secund.", "Cabeça", "Corpo", "Acessório"]

var current_state: MenuState = MenuState.CLOSED
var selected_command_index: int = 0
var selected_slot_index: int = 0
var selected_item_index: int = 0
var selected_equip_slot_index: int = 0
var current_selected_item: ItemData = null
var formation_first_slot: int = -1
var target_system_name: String = ""

@onready var panel_root: Control = get_node_or_null("MenuRoot")
@onready var command_panel: Control = get_node_or_null("MenuRoot/BodyHBox/CommandPanel")
@onready var commands_container: VBoxContainer = get_node_or_null("MenuRoot/BodyHBox/CommandPanel/Margin/CommandsVBox")
@onready var item_panel: Control = get_node_or_null("MenuRoot/BodyHBox/ItemPanel")
@onready var item_list: VBoxContainer = get_node_or_null("MenuRoot/BodyHBox/ItemPanel/Margin/ItemVBox/Scroll/ItemList")
@onready var empty_item_label: Label = get_node_or_null("MenuRoot/BodyHBox/ItemPanel/Margin/ItemVBox/EmptyLabel")
@onready var item_desc_label: Label = get_node_or_null("MenuRoot/BodyHBox/ItemPanel/Margin/ItemVBox/DescPanel/DescMargin/DescLabel")
@onready var status_panel: Control = get_node_or_null("MenuRoot/BodyHBox/StatusPanel")
@onready var status_portrait: TextureRect = get_node_or_null("MenuRoot/BodyHBox/StatusPanel/Margin/StatusVBox/CharInfoHBox/PortraitFrame/Portrait")
@onready var status_name_label: Label = get_node_or_null("MenuRoot/BodyHBox/StatusPanel/Margin/StatusVBox/CharInfoHBox/InfoVBox/NameLabel")
@onready var status_level_label: Label = get_node_or_null("MenuRoot/BodyHBox/StatusPanel/Margin/StatusVBox/CharInfoHBox/InfoVBox/LevelLabel")
@onready var status_exp_label: Label = get_node_or_null("MenuRoot/BodyHBox/StatusPanel/Margin/StatusVBox/ExpVBox/ExpLabel")
@onready var status_next_exp_label: Label = get_node_or_null("MenuRoot/BodyHBox/StatusPanel/Margin/StatusVBox/ExpVBox/NextExpLabel")
@onready var status_stats_grid: GridContainer = get_node_or_null("MenuRoot/BodyHBox/StatusPanel/Margin/StatusVBox/StatsGrid")
@onready var equip_panel: Control = get_node_or_null("MenuRoot/BodyHBox/EquipmentPanel")
@onready var equip_slots_vbox: VBoxContainer = get_node_or_null("MenuRoot/BodyHBox/EquipmentPanel/Margin/EquipVBox/SlotsVBox")
@onready var equip_preview_label: Label = get_node_or_null("MenuRoot/BodyHBox/EquipmentPanel/Margin/EquipVBox/PreviewPanel/Margin/PreviewLabel")
@onready var slots_container: VBoxContainer = get_node_or_null("MenuRoot/BodyHBox/PartyPanel/Margin/SlotsVBox")
@onready var map_label: Label = get_node_or_null("MenuRoot/FooterPanel/Margin/HBox/MapLabel")
@onready var playtime_label: Label = get_node_or_null("MenuRoot/FooterPanel/Margin/HBox/PlaytimeLabel")
@onready var gold_label: Label = get_node_or_null("MenuRoot/FooterPanel/Margin/HBox/GoldLabel")
@onready var banner_panel: Control = get_node_or_null("MenuRoot/NotificationBanner")
@onready var banner_label: Label = get_node_or_null("MenuRoot/NotificationBanner/BannerLabel")


func _ready() -> void:
	layer = 80
	process_mode = Node.PROCESS_MODE_ALWAYS
	if panel_root != null:
		panel_root.visible = false
	current_state = MenuState.CLOSED


func _process(_delta: float) -> void:
	if current_state != MenuState.CLOSED:
		_refresh_footer()


func _unhandled_input(event: InputEvent) -> void:
	if current_state == MenuState.CLOSED:
		if event.is_action_pressed("action_menu"):
			if _can_open():
				get_viewport().set_input_as_handled()
				open_menu()
		return
	
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("action_cancel"):
		get_viewport().set_input_as_handled()
		_handle_cancel()
	elif event.is_action_pressed("action_interact") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_handle_interact()
	elif event.is_action_pressed("ui_up") or event.is_action_pressed("move_up"):
		get_viewport().set_input_as_handled()
		_navigate(-1)
	elif event.is_action_pressed("ui_down") or event.is_action_pressed("move_down"):
		get_viewport().set_input_as_handled()
		_navigate(1)


func _can_open() -> bool:
	if has_node("/root/DialogueManager"):
		var dm: Node = get_node("/root/DialogueManager")
		if dm.get("is_dialogue_active") == true:
			return false
	if has_node("/root/SceneManager"):
		var sm: Node = get_node("/root/SceneManager")
		if sm.get("is_transitioning") == true:
			return false
	if has_node("/root/GameState"):
		var gs: Node = get_node("/root/GameState")
		return bool(gs.call("is_exploration"))
	return true


func open_menu() -> void:
	current_state = MenuState.COMMAND_SELECT
	selected_command_index = 0
	selected_slot_index = 0
	selected_item_index = 0
	selected_equip_slot_index = 0
	current_selected_item = null
	if command_panel != null: command_panel.visible = true
	if item_panel != null: item_panel.visible = false
	if status_panel != null: status_panel.visible = false
	if equip_panel != null: equip_panel.visible = false
	if panel_root != null: panel_root.visible = true
	hide_banner()
	_refresh_all()
	_update_command_selection()
	_update_character_selection()
	if has_node("/root/GameState"):
		get_node("/root/GameState").call("change_state", GameState.State.PAUSE)
	menu_opened.emit()


func close_menu() -> void:
	current_state = MenuState.CLOSED
	if item_panel != null: item_panel.visible = false
	if status_panel != null: status_panel.visible = false
	if equip_panel != null: equip_panel.visible = false
	if command_panel != null: command_panel.visible = true
	if panel_root != null: panel_root.visible = false
	hide_banner()
	if has_node("/root/GameState"):
		get_node("/root/GameState").call("change_state", GameState.State.EXPLORATION)
	menu_closed.emit()


func _handle_cancel() -> void:
	match current_state:
		MenuState.BANNER_DISPLAY:
			hide_banner()
			current_state = MenuState.COMMAND_SELECT
		MenuState.STATUS_VIEW:
			_close_status_menu()
		MenuState.EQUIPMENT_VIEW:
			_close_equipment_menu()
		MenuState.ITEM_TARGET:
			current_state = MenuState.ITEM_SELECT
			_update_character_selection()
			_update_item_selection()
		MenuState.ITEM_SELECT:
			_close_item_menu()
		MenuState.CHARACTER_SELECT, MenuState.FORMATION_FIRST, MenuState.FORMATION_SECOND:
			current_state = MenuState.COMMAND_SELECT
			_update_character_selection()
		MenuState.COMMAND_SELECT:
			close_menu()
		_:
			close_menu()


func _handle_interact() -> void:
	match current_state:
		MenuState.COMMAND_SELECT:
			_on_command_chosen(selected_command_index)
		MenuState.ITEM_SELECT:
			_on_item_chosen()
		MenuState.ITEM_TARGET:
			_use_current_item_on_slot(selected_slot_index)
		MenuState.CHARACTER_SELECT:
			_on_character_chosen(selected_slot_index)
		MenuState.FORMATION_FIRST:
			_handle_formation_first(selected_slot_index)
		MenuState.FORMATION_SECOND:
			_handle_formation_second(selected_slot_index)
		MenuState.BANNER_DISPLAY:
			hide_banner()
			current_state = MenuState.COMMAND_SELECT


func _on_command_chosen(cmd_idx: int) -> void:
	if cmd_idx < 0 or cmd_idx >= COMMAND_LABELS.size():
		return
	var cmd_name: String = COMMAND_LABELS[cmd_idx]
	command_selected.emit(cmd_name)
	target_system_name = cmd_name
	match cmd_name:
		"Itens":
			_open_item_menu()
		"Status":
			_open_status_menu(_get_party_member(selected_slot_index))
		"Equipamento":
			_open_equipment_menu(_get_party_member(selected_slot_index))
		"Habilidades", "Primordiais":
			current_state = MenuState.CHARACTER_SELECT
			selected_slot_index = 0
			_update_character_selection()
		"Formação":
			current_state = MenuState.FORMATION_FIRST
			selected_slot_index = 0
			_update_character_selection()
		_:
			show_banner("Sistema de " + cmd_name + " em desenvolvimento")


func _open_item_menu() -> void:
	current_state = MenuState.ITEM_SELECT
	selected_item_index = 0
	current_selected_item = null
	if command_panel != null:
		command_panel.visible = false
	if item_panel != null:
		item_panel.visible = true
	_refresh_item_list()
	_update_item_selection()


func _close_item_menu() -> void:
	current_state = MenuState.COMMAND_SELECT
	current_selected_item = null
	if item_panel != null:
		item_panel.visible = false
	if command_panel != null:
		command_panel.visible = true
	_update_command_selection()
	_update_character_selection()


func _on_item_chosen() -> void:
	var inv: Array[Dictionary] = _get_party_inventory()
	if inv.is_empty() or selected_item_index < 0 or selected_item_index >= inv.size():
		show_banner("Inventário vazio.")
		return
	var entry: Dictionary = inv[selected_item_index]
	current_selected_item = entry.get("item") as ItemData
	if current_selected_item == null:
		return
	current_state = MenuState.ITEM_TARGET
	selected_slot_index = 0
	_update_character_selection()


func _use_current_item_on_slot(slot_idx: int) -> void:
	if current_selected_item == null or not has_node("/root/PartyManager"):
		return
	var pm: Node = get_node("/root/PartyManager")
	var member: CharacterData = pm.call("get_member", slot_idx) as CharacterData
	if member == null:
		show_banner("Espaço vazio selecionado")
		return
	var success: bool = bool(pm.call("use_item", current_selected_item, slot_idx))
	if success:
		_refresh_party_slots()
		_refresh_item_list()
		_update_character_selection()
		show_banner("Usou %s em %s!" % [current_selected_item.name, member.name])
		var remaining: int = int(pm.call("get_item_count", current_selected_item.id))
		if remaining <= 0:
			current_state = MenuState.ITEM_SELECT
			_update_character_selection()
			_update_item_selection()


func _get_party_inventory() -> Array[Dictionary]:
	if has_node("/root/PartyManager"):
		var pm: Node = get_node("/root/PartyManager")
		return pm.call("get_inventory") as Array[Dictionary]
	return []


func _refresh_item_list() -> void:
	if item_list == null:
		return
	for child in item_list.get_children():
		child.queue_free()
	var inv: Array[Dictionary] = _get_party_inventory()
	var has_items: bool = not inv.is_empty()
	if empty_item_label != null:
		empty_item_label.visible = not has_items
	for i: int in range(inv.size()):
		var entry: Dictionary = inv[i]
		var it: ItemData = entry.get("item") as ItemData
		var qty: int = int(entry.get("quantity", 0))
		var it_name: String = it.name if it != null else "Desconhecido"
		var btn: Button = Button.new()
		btn.custom_minimum_size = Vector2(0, 44)
		btn.text = "%s   (x%d)" % [it_name, qty]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		item_list.add_child(btn)


func _update_item_selection() -> void:
	var inv: Array[Dictionary] = _get_party_inventory()
	if inv.is_empty():
		if item_desc_label != null:
			item_desc_label.text = "Inventário vazio."
		return
	selected_item_index = clampi(selected_item_index, 0, inv.size() - 1)
	var entry: Dictionary = inv[selected_item_index]
	var it: ItemData = entry.get("item") as ItemData
	if item_desc_label != null:
		item_desc_label.text = it.description if it != null else ""
	if item_list != null:
		var buttons: Array[Node] = item_list.get_children()
		for i: int in range(buttons.size()):
			var btn: Button = buttons[i] as Button
			if btn != null:
				var is_sel: bool = (i == selected_item_index and current_state == MenuState.ITEM_SELECT)
				btn.modulate = Color(1.2, 1.2, 0.6, 1.0) if is_sel else Color(1.0, 1.0, 1.0, 1.0)


func _on_character_chosen(slot_idx: int) -> void:
	var member: CharacterData = _get_party_member(slot_idx)
	if member != null:
		character_selected.emit(slot_idx, member)
		match target_system_name:
			"Status":
				_open_status_menu(member)
			"Equipamento":
				_open_equipment_menu(member)
			_:
				show_banner("Sistema de " + target_system_name + " (" + member.name + ") em desenvolvimento")
	else:
		show_banner("Espaço vazio selecionado")


func _open_status_menu(member: CharacterData) -> void:
	if member == null:
		member = _get_party_member(0)
	if member == null:
		show_banner("Nenhum personagem disponível.")
		return
	current_state = MenuState.STATUS_VIEW
	if command_panel != null: command_panel.visible = false
	if item_panel != null: item_panel.visible = false
	if equip_panel != null: equip_panel.visible = false
	if status_panel != null: status_panel.visible = true
	_populate_status_info(member)


func _populate_status_info(member: CharacterData) -> void:
	if status_name_label != null: status_name_label.text = member.name
	if status_level_label != null: status_level_label.text = "Nível %d" % member.level
	if status_portrait != null: status_portrait.texture = member.portrait
	if status_exp_label != null: status_exp_label.text = "EXP Atual: %d" % member.current_exp
	if status_next_exp_label != null: status_next_exp_label.text = "Próx. Nível: %d" % member.next_level_exp
	_populate_stats_grid(member)


func _populate_stats_grid(member: CharacterData) -> void:
	if status_stats_grid == null:
		return
	for c in status_stats_grid.get_children():
		c.queue_free()
	var stats_to_show: Array[Dictionary] = [
		{"name": "Força", "key": "strength"},
		{"name": "Defesa", "key": "defense"},
		{"name": "Poder Mágico", "key": "magic_power"},
		{"name": "Defesa Mágica", "key": "magic_defense"},
		{"name": "Agilidade", "key": "agility"},
		{"name": "Sorte", "key": "luck"},
	]
	for s: Dictionary in stats_to_show:
		var stat_name: String = s["name"]
		var key: String = s["key"]
		var base_val: int = member.get_base_stat(key)
		var bonus_val: int = member.get_equipment_bonus(key)
		var total_val: int = member.get_total_stat(key)
		var lbl_name: Label = Label.new()
		lbl_name.text = stat_name
		var lbl_val: Label = Label.new()
		if bonus_val > 0:
			lbl_val.text = "%d (+%d) = %d" % [base_val, bonus_val, total_val]
			lbl_val.modulate = Color(0.6, 1.0, 0.6, 1.0)
		else:
			lbl_val.text = str(total_val)
		status_stats_grid.add_child(lbl_name)
		status_stats_grid.add_child(lbl_val)


func _close_status_menu() -> void:
	if status_panel != null: status_panel.visible = false
	if command_panel != null: command_panel.visible = true
	current_state = MenuState.COMMAND_SELECT
	_update_command_selection()


func _open_equipment_menu(member: CharacterData) -> void:
	if member == null:
		member = _get_party_member(0)
	if member == null:
		show_banner("Nenhum personagem disponível.")
		return
	current_state = MenuState.EQUIPMENT_VIEW
	selected_equip_slot_index = 0
	if command_panel != null: command_panel.visible = false
	if item_panel != null: item_panel.visible = false
	if status_panel != null: status_panel.visible = false
	if equip_panel != null: equip_panel.visible = true
	_refresh_equipment_slots(member)
	_update_equipment_selection(member)


func _close_equipment_menu() -> void:
	if equip_panel != null: equip_panel.visible = false
	if command_panel != null: command_panel.visible = true
	current_state = MenuState.COMMAND_SELECT
	_update_command_selection()


func _refresh_equipment_slots(member: CharacterData) -> void:
	if equip_slots_vbox == null or member == null:
		return
	var buttons: Array[Node] = equip_slots_vbox.get_children()
	for i: int in range(mini(buttons.size(), EQUIP_SLOT_KEYS.size())):
		var btn: Button = buttons[i] as Button
		var slot_key: String = EQUIP_SLOT_KEYS[i]
		var slot_name: String = EQUIP_SLOT_NAMES[i]
		var eq: EquipmentData = member.equipment.get(slot_key) as EquipmentData
		var eq_text: String = eq.name if eq != null else "(Vazio)"
		btn.text = "%s: %s" % [slot_name, eq_text]


func _update_equipment_selection(member: CharacterData) -> void:
	if equip_slots_vbox == null or member == null:
		return
	var buttons: Array[Node] = equip_slots_vbox.get_children()
	for i: int in range(buttons.size()):
		var btn: Button = buttons[i] as Button
		if btn != null:
			var is_sel: bool = (i == selected_equip_slot_index and current_state == MenuState.EQUIPMENT_VIEW)
			btn.modulate = Color(1.2, 1.2, 0.6, 1.0) if is_sel else Color(1.0, 1.0, 1.0, 1.0)
	if selected_equip_slot_index >= 0 and selected_equip_slot_index < EQUIP_SLOT_KEYS.size():
		var slot_key: String = EQUIP_SLOT_KEYS[selected_equip_slot_index]
		var eq: EquipmentData = member.equipment.get(slot_key) as EquipmentData
		if equip_preview_label != null:
			if eq != null:
				var bonus_str: String = ""
				for b_key in eq.stat_bonuses:
					bonus_str += "%s +%d " % [b_key.capitalize(), eq.stat_bonuses[b_key]]
				equip_preview_label.text = "%s [%s]" % [eq.name, bonus_str.strip_edges()]
			else:
				equip_preview_label.text = "Nenhum equipamento equipado neste slot."


func _handle_formation_first(slot_idx: int) -> void:
	formation_first_slot = slot_idx
	current_state = MenuState.FORMATION_SECOND
	show_banner("Selecione o segundo membro para trocar de posição")


func _handle_formation_second(slot_idx: int) -> void:
	if has_node("/root/PartyManager"):
		var pm: Node = get_node("/root/PartyManager")
		pm.call("swap_members", formation_first_slot, slot_idx)
	_refresh_party_slots()
	current_state = MenuState.COMMAND_SELECT
	_update_character_selection()
	show_banner("Formação reorganizada com sucesso!")


func _navigate(dir: int) -> void:
	if current_state == MenuState.COMMAND_SELECT:
		selected_command_index = posmod(selected_command_index + dir, COMMAND_LABELS.size())
		_update_command_selection()
	elif current_state == MenuState.ITEM_SELECT:
		var inv: Array[Dictionary] = _get_party_inventory()
		if not inv.is_empty():
			selected_item_index = posmod(selected_item_index + dir, inv.size())
			_update_item_selection()
	elif current_state == MenuState.EQUIPMENT_VIEW:
		selected_equip_slot_index = posmod(selected_equip_slot_index + dir, EQUIP_SLOT_KEYS.size())
		_update_equipment_selection(_get_party_member(selected_slot_index))
	elif current_state in [MenuState.CHARACTER_SELECT, MenuState.FORMATION_FIRST, MenuState.FORMATION_SECOND, MenuState.ITEM_TARGET]:
		selected_slot_index = posmod(selected_slot_index + dir, 4)
		_update_character_selection()


func show_banner(message: String) -> void:
	if banner_panel != null and banner_label != null:
		banner_label.text = message
		banner_panel.visible = true
	current_state = MenuState.BANNER_DISPLAY


func hide_banner() -> void:
	if banner_panel != null:
		banner_panel.visible = false


func _refresh_all() -> void:
	_refresh_party_slots()
	_refresh_footer()


func _refresh_party_slots() -> void:
	if slots_container == null:
		return
	for i: int in range(4):
		var member: CharacterData = _get_party_member(i)
		_update_slot_display(i, member)


func _update_slot_display(slot_idx: int, member: CharacterData) -> void:
	var slot_node: Control = slots_container.get_node_or_null("Slot" + str(slot_idx)) as Control
	if slot_node == null:
		return
	var active_box: Control = slot_node.get_node_or_null("ActiveBox") as Control
	var empty_box: Control = slot_node.get_node_or_null("EmptyBox") as Control
	if member != null:
		if active_box != null: active_box.visible = true
		if empty_box != null: empty_box.visible = false
		_populate_active_member_slot(active_box, member)
	else:
		if active_box != null: active_box.visible = false
		if empty_box != null: empty_box.visible = true


func _populate_active_member_slot(box: Control, member: CharacterData) -> void:
	if box == null or member == null:
		return
	var name_lbl: Label = box.get_node_or_null("Details/Header/NameLabel") as Label
	var lvl_lbl: Label = box.get_node_or_null("Details/Header/LevelLabel") as Label
	var hp_lbl: Label = box.get_node_or_null("Details/Stats/HPContainer/HPLabel") as Label
	var hp_bar: ProgressBar = box.get_node_or_null("Details/Stats/HPContainer/HPBar") as ProgressBar
	var mp_lbl: Label = box.get_node_or_null("Details/Stats/MPContainer/MPLabel") as Label
	var mp_bar: ProgressBar = box.get_node_or_null("Details/Stats/MPContainer/MPBar") as ProgressBar
	var prim_lbl: Label = box.get_node_or_null("Details/PrimordialLabel") as Label
	var port: TextureRect = box.get_node_or_null("PortraitFrame/Portrait") as TextureRect
	
	if name_lbl != null: name_lbl.text = member.name
	if lvl_lbl != null: lvl_lbl.text = "Nv. " + str(member.level)
	if hp_lbl != null: hp_lbl.text = "PV: %d / %d" % [member.current_hp, member.max_hp]
	if hp_bar != null:
		hp_bar.max_value = member.max_hp
		hp_bar.value = member.current_hp
	if mp_lbl != null: mp_lbl.text = "PM: %d / %d" % [member.current_mp, member.max_mp]
	if mp_bar != null:
		mp_bar.max_value = member.max_mp
		mp_bar.value = member.current_mp
	if prim_lbl != null:
		var p_name: String = member.equipped_primordial if not member.equipped_primordial.is_empty() else "Nenhum"
		prim_lbl.text = "Primordial: " + p_name
	if port != null: port.texture = member.portrait


func _refresh_footer() -> void:
	if has_node("/root/PartyManager"):
		var pm: Node = get_node("/root/PartyManager")
		if map_label != null:
			map_label.text = "Local: " + str(pm.get("current_map_name"))
		if playtime_label != null:
			playtime_label.text = "Tempo: " + str(pm.call("get_formatted_playtime"))
		if gold_label != null:
			gold_label.text = "Moedas: " + str(pm.call("get_gold_text"))


func _update_command_selection() -> void:
	if commands_container == null:
		return
	var buttons: Array[Node] = commands_container.get_children()
	for i: int in range(buttons.size()):
		var btn: Button = buttons[i] as Button
		if btn != null:
			var is_selected: bool = (i == selected_command_index and current_state == MenuState.COMMAND_SELECT)
			btn.modulate = Color(1.2, 1.1, 0.7, 1.0) if is_selected else Color(0.9, 0.9, 0.9, 0.85)


func _update_character_selection() -> void:
	if slots_container == null:
		return
	var in_char_mode: bool = current_state in [
		MenuState.CHARACTER_SELECT,
		MenuState.FORMATION_FIRST,
		MenuState.FORMATION_SECOND,
		MenuState.ITEM_TARGET
	]
	for i: int in range(4):
		var slot_node: Control = slots_container.get_node_or_null("Slot" + str(i)) as Control
		if slot_node != null:
			var hl: ReferenceRect = slot_node.get_node_or_null("HighlightBorder") as ReferenceRect
			if hl != null:
				hl.visible = in_char_mode and (i == selected_slot_index)


func _get_party_member(idx: int) -> CharacterData:
	if has_node("/root/PartyManager"):
		var pm: Node = get_node("/root/PartyManager")
		return pm.call("get_member", idx) as CharacterData
	return null

