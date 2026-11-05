class_name PauseMenu
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

var current_state: MenuState = MenuState.CLOSED
var selected_command_index: int = 0
var selected_slot_index: int = 0
var formation_first_slot: int = -1
var target_system_name: String = ""

@onready var panel_root: Control = get_node_or_null("MenuRoot")
@onready var commands_container: VBoxContainer = get_node_or_null("MenuRoot/BodyHBox/CommandPanel/Margin/CommandsVBox")
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
	if panel_root != null:
		panel_root.visible = true
	hide_banner()
	_refresh_all()
	_update_command_selection()
	_update_character_selection()
	if has_node("/root/GameState"):
		get_node("/root/GameState").call("change_state", GameState.State.PAUSE)
	menu_opened.emit()


func close_menu() -> void:
	current_state = MenuState.CLOSED
	if panel_root != null:
		panel_root.visible = false
	hide_banner()
	if has_node("/root/GameState"):
		get_node("/root/GameState").call("change_state", GameState.State.EXPLORATION)
	menu_closed.emit()


func _handle_cancel() -> void:
	match current_state:
		MenuState.BANNER_DISPLAY:
			hide_banner()
			current_state = MenuState.COMMAND_SELECT
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
		"Habilidades", "Primordiais", "Equipamento", "Status":
			current_state = MenuState.CHARACTER_SELECT
			selected_slot_index = 0
			_update_character_selection()
		"Formação":
			current_state = MenuState.FORMATION_FIRST
			selected_slot_index = 0
			_update_character_selection()
		_:
			show_banner("Sistema de " + cmd_name + " em desenvolvimento")


func _on_character_chosen(slot_idx: int) -> void:
	var member: CharacterData = _get_party_member(slot_idx)
	if member != null:
		character_selected.emit(slot_idx, member)
		show_banner("Sistema de " + target_system_name + " (" + member.name + ") em desenvolvimento")
	else:
		show_banner("Espaço vazio selecionado")


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
	elif current_state in [MenuState.CHARACTER_SELECT, MenuState.FORMATION_FIRST, MenuState.FORMATION_SECOND]:
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
	var in_char_mode: bool = current_state in [MenuState.CHARACTER_SELECT, MenuState.FORMATION_FIRST, MenuState.FORMATION_SECOND]
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
