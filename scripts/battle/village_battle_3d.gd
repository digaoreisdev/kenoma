@tool
class_name VillageBattle3D
extends Node3D

## Apresentação 3D da Batalha na Vila do Baltazar (HD-2D).
## Os elementos agora residem diretamente na árvore da cena (.tscn),
## permitindo seleção, movimentação e edição visual direta no Editor 3D do Godot.

@onready var terreno: TerrenoBatalha = get_node_or_null("Terrain") as TerrenoBatalha
@onready var camera_3d: Camera3D = get_node_or_null("Camera3D") as Camera3D
@onready var sun_light: DirectionalLight3D = get_node_or_null("DirectionalLight3D") as DirectionalLight3D
@onready var world_env: WorldEnvironment = get_node_or_null("WorldEnvironment") as WorldEnvironment
@onready var slots_container: Node3D = get_node_or_null("Slots") as Node3D


func _ready() -> void:
	_garantir_terreno()


func _garantir_terreno() -> void:
	if terreno == null:
		return
	const P_COBBLE: String = "res://assets/art/textures/terrain/cobblestone_01.png"
	const P_GRASS: String = "res://assets/art/textures/terrain/grass_01.png"
	if ResourceLoader.exists(P_COBBLE) and terreno.tex_estrada == null:
		terreno.tex_estrada = load(P_COBBLE) as Texture2D
	if ResourceLoader.exists(P_GRASS) and terreno.tex_grama == null:
		terreno.tex_grama = load(P_GRASS) as Texture2D
	terreno.tiling = 0.1
	if not Engine.is_editor_hint():
		terreno.gerar()
