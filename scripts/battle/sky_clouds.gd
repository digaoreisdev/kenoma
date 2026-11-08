class_name SkyClouds
extends Node2D

## Renderiza e anima nuvens estilizadas em tons de pôr do sol derivando suavemente no horizonte.

@export var velocidade_base: float = 12.0
@export var quantidade_nuvens: int = 5

var _sprites: Array[Sprite2D] = []
var _velocidades: Array[float] = []
static var _textura_compartilhada: ImageTexture = null


func _enter_tree() -> void:
	z_index = -9
	inicializar()


func _ready() -> void:
	z_index = -9
	inicializar()


func inicializar() -> void:
	if not _sprites.is_empty():
		return
	if _textura_compartilhada == null:
		_textura_compartilhada = _gerar_textura_nuvem()
	_criar_sprites_nuvens()


func _process(delta: float) -> void:
	var vp_w: float = 1920.0
	var viewport: Viewport = get_viewport()
	if viewport != null and viewport.get_visible_rect().size.x > 0.0:
		vp_w = viewport.get_visible_rect().size.x

	for i: int in range(_sprites.size()):
		var spr: Sprite2D = _sprites[i]
		var vel: float = _velocidades[i]
		spr.position.x += vel * delta
		# Quando a nuvem sai totalmente pela direita, reaparece suavemente pela esquerda
		var largura_aprox: float = 256.0 * spr.scale.x
		if spr.position.x - (largura_aprox * 0.5) > vp_w + 50.0:
			spr.position.x = - (largura_aprox * 0.5) - 60.0
			spr.position.y = 45.0 + randf() * 140.0


func _criar_sprites_nuvens() -> void:
	for child: Node in get_children():
		child.queue_free()
	_sprites.clear()
	_velocidades.clear()

	# Distribui as nuvens ao longo da largura da tela no início
	var posicoes_x: Array[float] = [100.0, 520.0, 960.0, 1420.0, 1850.0]
	var posicoes_y: Array[float] = [55.0, 95.0, 65.0, 130.0, 80.0]
	var escalas: Array[Vector2] = [
		Vector2(1.6, 1.2),
		Vector2(1.2, 0.9),
		Vector2(2.1, 1.4),
		Vector2(1.4, 1.0),
		Vector2(1.8, 1.3)
	]

	for i: int in range(quantidade_nuvens):
		var spr: Sprite2D = Sprite2D.new()
		spr.name = "Cloud_%d" % i
		spr.texture = _textura_compartilhada
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		spr.position = Vector2(posicoes_x[i % posicoes_x.size()], posicoes_y[i % posicoes_y.size()])
		spr.scale = escalas[i % escalas.size()]
		# Modulação com leve variação de tom quente para dar volume e variedade
		var t: float = float(i) / float(quantidade_nuvens)
		spr.modulate = Color(1.0, 0.96 - t * 0.08, 0.88 - t * 0.14, 0.94)
		add_child(spr)
		_sprites.append(spr)
		_velocidades.append(velocidade_base + (i * 2.5 - 4.0))


static func _gerar_textura_nuvem() -> ImageTexture:
	var w: int = 256
	var h: int = 128
	var img: Image = Image.create(w, h, false, Image.FORMAT_RGBA8)
	# Lóbulos fofos que compõem a forma orgânica da nuvem: [cx, cy, rx, ry]
	var lobes: Array = [
		[128.0, 70.0, 80.0, 42.0],
		[85.0, 78.0, 55.0, 35.0],
		[172.0, 76.0, 55.0, 35.0],
		[105.0, 52.0, 44.0, 30.0],
		[150.0, 50.0, 48.0, 32.0],
		[58.0, 84.0, 34.0, 24.0],
		[198.0, 84.0, 34.0, 24.0]
	]

	for y: int in range(h):
		var t_y: float = float(y) / float(h)
		for x: int in range(w):
			var max_d: float = 0.0
			for l: Array in lobes:
				var cx: float = float(l[0])
				var cy: float = float(l[1])
				var rx: float = float(l[2])
				var ry: float = float(l[3])
				var dx: float = (float(x) - cx) / rx
				var dy: float = (float(y) - cy) / ry
				var d2: float = dx * dx + dy * dy
				if d2 < 1.0:
					var dist: float = sqrt(d2)
					# Queda cosseno suave para bordas esfumaçadas
					var val: float = 0.5 * (1.0 + cos(dist * PI))
					if val > max_d:
						max_d = val

			if max_d > 0.002:
				# Tons quentes e encorpados de entardecer: topo âmbar dourado, base alaranjada quente
				var r: float = 0.94 - t_y * 0.14
				var g: float = 0.62 - t_y * 0.22
				var b: float = 0.36 - t_y * 0.16
				var a: float = max_d * 0.95
				img.set_pixel(x, y, Color(r, g, b, a))
			else:
				img.set_pixel(x, y, Color(0, 0, 0, 0))

	return ImageTexture.create_from_image(img)
