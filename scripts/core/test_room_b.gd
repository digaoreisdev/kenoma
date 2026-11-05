class_name TestRoomB
extends Node2D

## Sala aconchegante de teste (Room B) para validação de transições de cena e portas.

@onready var player: Player = get_node_or_null("Player")
@onready var floor_rect: ColorRect = get_node_or_null("Floor")


func _ready() -> void:
	_setup_camera_limits()


func _setup_camera_limits() -> void:
	if player == null:
		return
	if floor_rect != null:
		player.set_camera_limits(
			int(floor_rect.offset_left),
			int(floor_rect.offset_top),
			int(floor_rect.offset_right),
			int(floor_rect.offset_bottom)
		)
	else:
		player.set_camera_limits(-200, -150, 200, 150)

