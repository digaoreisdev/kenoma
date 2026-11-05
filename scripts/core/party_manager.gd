extends Node

## Singleton global para gerenciamento da equipe (Party), recursos e tempo de jogo.

signal party_updated
signal gold_changed(new_gold: int)

var party_slots: Array[CharacterData] = [null, null, null, null]
var gold: int = 0
var playtime_seconds: float = 0.0
var current_map_name: String = "Ruínas de Kenoma"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	reset_to_defaults()


func _process(delta: float) -> void:
	playtime_seconds += delta


func reset_to_defaults() -> void:
	party_slots = [
		CharacterData.create_default_lucas(),
		null,
		null,
		null
	]
	gold = 0
	playtime_seconds = 0.0
	party_updated.emit()


func get_member(slot_index: int) -> CharacterData:
	if slot_index < 0 or slot_index >= party_slots.size():
		return null
	return party_slots[slot_index]


func has_member(slot_index: int) -> bool:
	return get_member(slot_index) != null


func set_member(slot_index: int, member: CharacterData) -> void:
	if slot_index >= 0 and slot_index < party_slots.size():
		party_slots[slot_index] = member
		party_updated.emit()


func get_active_party() -> Array[CharacterData]:
	var active: Array[CharacterData] = []
	for member: CharacterData in party_slots:
		if member != null:
			active.append(member)
	return active


func swap_members(slot_a: int, slot_b: int) -> void:
	if slot_a < 0 or slot_a >= party_slots.size() or slot_b < 0 or slot_b >= party_slots.size():
		return
	var temp: CharacterData = party_slots[slot_a]
	party_slots[slot_a] = party_slots[slot_b]
	party_slots[slot_b] = temp
	party_updated.emit()


func add_gold(amount: int) -> void:
	gold = maxi(0, gold + amount)
	gold_changed.emit(gold)


func get_gold_text() -> String:
	return "%d G" % gold


func get_formatted_playtime() -> String:
	var total_sec: int = int(playtime_seconds)
	var hours: int = total_sec / 3600
	var minutes: int = (total_sec % 3600) / 60
	var seconds: int = total_sec % 60
	return "%02d:%02d:%02d" % [hours, minutes, seconds]
