class_name SpawnPoint
extends Marker2D

## Ponto de spawn para ancoragem do jogador ao transicionar entre mapas.

@export var spawn_id: String = ""


func _ready() -> void:
	add_to_group("spawn_points")
