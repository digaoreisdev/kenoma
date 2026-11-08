class_name SkyClouds
extends Node2D

## Controla nuvens suaves semi-transparentes que deslizam lentamente no horizonte do pôr do sol.

@export var velocidade_deriva: float = 10.0
@export var quantidade_nuvens: int = 4
@export var cor_nuvem_sol: Color = Color(0.98, 0.82, 0.58, 0.25)
@export var cor_nuvem_sombra: Color = Color(0.88, 0.62, 0.45, 0.18)

var _nuvens: Array[Dictionary] = []
var _textura_blob: Texture2D = null


func _ready() -> void:
	z_index = -9
	_criar_textura_blob()
	_inicializar_nuvens()


func _criar_textura_blob() -> void:
	var grad: Gradient = Gradient.new()
	grad.colors = PackedColorArray([Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0)])
	grad.offsets = PackedFloat32Array([0.0, 1.0])

	var grad_tex: GradientTexture2D = GradientTexture2D.new()
	grad_tex.gradient = grad
	grad_tex.fill = GradientTexture2D.FILL_RADIAL
	grad_tex.fill_from = Vector2(0.5, 0.5)
	grad_tex.fill_to = Vector2(1.0, 0.5)
	grad_tex.width = 128
	grad_tex.height = 64
	_textura_blob = grad_tex


func _inicializar_nuvens() -> void:
	_nuvens.clear()
	var posicoes_iniciais_x: Array[float] = [120.0, 650.0, 1180.0, 1680.0]
	for i: int in range(quantidade_nuvens):
		var base_x: float = posicoes_iniciais_x[i % posicoes_iniciais_x.size()] + (randf() * 100.0 - 50.0)
		var base_y: float = 60.0 + (i * 35.0) + (randf() * 20.0 - 10.0)
		var blobs: Array[Dictionary] = []
		# Cada nuvem é formada por 3 a 5 "puffs" suaves agrupados
		for b: int in range(4):
			blobs.append({
				"offset": Vector2((b - 1.5) * 55.0 + (randf() * 20.0 - 10.0), (randf() * 16.0 - 8.0)),
				"escala": Vector2(1.8 + randf() * 0.8, 0.9 + randf() * 0.4),
				"cor": cor_nuvem_sol if b % 2 == 0 else cor_nuvem_sombra
			})

		_nuvens.append({
			"pos": Vector2(base_x, base_y),
			"velocidade": velocidade_deriva + (randf() * 6.0 - 3.0),
			"blobs": blobs
		})


func _process(delta: float) -> void:
	var vp_w: float = 1920.0
	var viewport: Viewport = get_viewport()
	if viewport != null and viewport.get_visible_rect().size.x > 0.0:
		vp_w = viewport.get_visible_rect().size.x

	for n: Dictionary in _nuvens:
		var pos: Vector2 = n["pos"]
		pos.x += float(n["velocidade"]) * delta
		if pos.x > vp_w + 220.0:
			pos.x = -220.0
			pos.y = 50.0 + randf() * 120.0
		n["pos"] = pos

	queue_redraw()


func _draw() -> void:
	if _textura_blob == null:
		return

	for n: Dictionary in _nuvens:
		var pos_nuvem: Vector2 = n["pos"]
		var blobs: Array = n["blobs"]
		for b: Dictionary in blobs:
			var offset: Vector2 = b["offset"]
			var esc: Vector2 = b["escala"]
			var cor: Color = b["cor"]

			var tam: Vector2 = Vector2(_textura_blob.get_width() * esc.x, _textura_blob.get_height() * esc.y)
			var dest_rect: Rect2 = Rect2(pos_nuvem + offset - (tam * 0.5), tam)
			draw_texture_rect(_textura_blob, dest_rect, false, cor)
