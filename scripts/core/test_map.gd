class_name TestMap
extends Node2D

## Mapa sandbox com limites dinâmicos de câmera e entidades interativas.

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
		player.set_camera_limits(-400, -300, 400, 300)

