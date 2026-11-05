class_name DialogueBox
extends CanvasLayer

## Painel clássico de diálogo estilo JRPG com efeito de máquina de escrever.

signal line_displayed(index: int)
signal dialogue_completed

@export var text_speed: float = 0.025

var _lines: Array[DialogueLine] = []
var _current_index: int = 0
var _is_typing: bool = false
var _tween: Tween = null

@onready var panel_root: Control = get_node_or_null("PanelRoot")
@onready var speaker_label: Label = get_node_or_null("PanelRoot/DialoguePanel/Margin/HBox/TextVBox/SpeakerLabel")
@onready var content_label: Label = get_node_or_null("PanelRoot/DialoguePanel/Margin/HBox/TextVBox/ContentLabel")
@onready var portrait_rect: TextureRect = get_node_or_null("PanelRoot/DialoguePanel/Margin/HBox/Portrait")
@onready var next_arrow: CanvasItem = get_node_or_null("PanelRoot/DialoguePanel/Margin/HBox/TextVBox/ArrowContainer/NextArrow")


func _ready() -> void:
	layer = 90
	hide_dialogue()


func _unhandled_input(event: InputEvent) -> void:
	if panel_root == null or not panel_root.visible:
		return
	if event.is_action_pressed("action_interact"):
		get_viewport().set_input_as_handled()
		advance()


func start(lines: Array) -> void:
	_lines.clear()
	for item: Variant in lines:
		if item is DialogueLine:
			_lines.append(item as DialogueLine)
		elif item is Dictionary:
			_lines.append(DialogueLine.from_dict(item as Dictionary))
	if _lines.is_empty():
		return
	_current_index = 0
	if panel_root != null:
		panel_root.visible = true
	_show_line(0)


func _show_line(index: int) -> void:
	if index >= _lines.size() or content_label == null:
		return
	var line: DialogueLine = _lines[index]
	_setup_speaker_and_portrait(line)
	content_label.text = line.text
	content_label.visible_ratio = 0.0
	_is_typing = true
	if next_arrow != null:
		next_arrow.visible = false
	_start_typewriter(line.text)
	line_displayed.emit(index)


func _setup_speaker_and_portrait(line: DialogueLine) -> void:
	if speaker_label != null:
		speaker_label.text = line.speaker
		speaker_label.visible = not line.speaker.is_empty()
	if portrait_rect != null:
		portrait_rect.texture = line.portrait
		portrait_rect.visible = (line.portrait != null)


func _start_typewriter(full_text: String) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	var duration: float = maxf(0.1, float(full_text.length()) * text_speed)
	_tween = create_tween()
	_tween.tween_property(content_label, "visible_ratio", 1.0, duration)
	_tween.finished.connect(_on_typing_finished)


func _on_typing_finished() -> void:
	_is_typing = false
	if next_arrow != null:
		next_arrow.visible = true


func skip_typing() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	if content_label != null:
		content_label.visible_ratio = 1.0
	_on_typing_finished()


func advance() -> void:
	if _is_typing:
		skip_typing()
	else:
		_current_index += 1
		if _current_index < _lines.size():
			_show_line(_current_index)
		else:
			hide_dialogue()
			dialogue_completed.emit()


func hide_dialogue() -> void:
	if panel_root != null:
		panel_root.visible = false
	_is_typing = false
	if _tween != null and _tween.is_valid():
		_tween.kill()
