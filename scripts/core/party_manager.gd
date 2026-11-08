extends Node

## Singleton global para gerenciamento da equipe (Party), recursos e tempo de jogo.

signal party_updated
signal gold_changed(new_gold: int)
signal inventory_updated

var party_slots: Array[CharacterData] = [null, null, null, null]
var inventory: Array[Dictionary] = []
var unassigned_primordials: Array[PrimordialData] = []
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
		CharacterData.create_default_davi(),
		null,
		null
	]
	gold = 0
	playtime_seconds = 0.0
	inventory.clear()
	unassigned_primordials.clear()
	unassigned_primordials.append(PrimordialData.create_ignis())
	add_item(ItemData.create_potion(), 3)
	party_updated.emit()
	inventory_updated.emit()


func get_inventory() -> Array[Dictionary]:
	return inventory


func add_item(item: ItemData, qty: int = 1) -> void:
	if item == null or qty <= 0:
		return
	for entry: Dictionary in inventory:
		var it: ItemData = entry.get("item") as ItemData
		if it != null and it.id == item.id:
			entry["quantity"] = int(entry.get("quantity", 0)) + qty
			inventory_updated.emit()
			return
	inventory.append({"item": item, "quantity": qty})
	inventory_updated.emit()


func remove_item(item: ItemData, qty: int = 1) -> bool:
	if item == null or qty <= 0:
		return false
	for i: int in range(inventory.size()):
		var it: ItemData = inventory[i].get("item") as ItemData
		if it != null and it.id == item.id:
			var current_qty: int = int(inventory[i].get("quantity", 0))
			if current_qty < qty:
				return false
			inventory[i]["quantity"] = current_qty - qty
			if int(inventory[i]["quantity"]) <= 0:
				inventory.remove_at(i)
			inventory_updated.emit()
			return true
	return false


func get_item_count(item_id: String) -> int:
	for entry: Dictionary in inventory:
		var it: ItemData = entry.get("item") as ItemData
		if it != null and it.id == item_id:
			return int(entry.get("quantity", 0))
	return 0


func use_item(item: ItemData, target_member_index: int) -> bool:
	if item == null or target_member_index < 0 or target_member_index >= party_slots.size():
		return false
	var member: CharacterData = party_slots[target_member_index]
	if member == null:
		return false
	if not remove_item(item, 1):
		return false
	member.current_hp = mini(member.current_hp + item.effect_value, member.max_hp)
	party_updated.emit()
	return true


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


func get_unassigned_primordials() -> Array[PrimordialData]:
	return unassigned_primordials


func add_unassigned_primordial(primordial: PrimordialData) -> void:
	if primordial != null and not unassigned_primordials.has(primordial):
		unassigned_primordials.append(primordial)


func remove_unassigned_primordial(primordial: PrimordialData) -> bool:
	var idx: int = unassigned_primordials.find(primordial)
	if idx != -1:
		unassigned_primordials.remove_at(idx)
		return true
	return false

