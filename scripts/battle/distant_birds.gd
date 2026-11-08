class_name DistantBirds
extends Node2D

## Renderiza e anima silhuetas suaves de pássaros cruzando o céu da arena em profundidade.

@export var cor_passaros: Color = Color(0.25, 0.18, 0.15, 0.75)
@export var velocidade_base: float = 60.0
@export var quantidade: int = 5

var _passaros: Array[Dictionary] = []


func _ready() -> void:
	z_index = -9
	_inicializar_passaros()


func _inicializar_passaros() -> void:
	_passaros.clear()
	for i: int in range(quantidade):
		_passaros.append({
			"pos": Vector2(-60.0 - (i * 45.0) - randf() * 40.0, 110.0 + (i * 24.0) + randf() * 25.0),
			"velocidade": velocidade_base + (randf() * 18.0 - 9.0),
			"escala": 0.85 + randf() * 0.35,
			"fase_asa": randf() * TAU,
			"velocidade_asa": 7.0 + randf() * 3.0
		})


func _process(delta: float) -> void:
	var vp_w: float = 1920.0
	var viewport: Viewport = get_viewport()
	if viewport != null and viewport.get_visible_rect().size.x > 0.0:
		vp_w = viewport.get_visible_rect().size.x

	var todos_passaram: bool = true
	for p: Dictionary in _passaros:
		var pos: Vector2 = p["pos"]
		pos.x += float(p["velocidade"]) * delta
		p["pos"] = pos
		p["fase_asa"] = float(p["fase_asa"]) + float(p["velocidade_asa"]) * delta
		if pos.x < vp_w + 90.0:
			todos_passaram = false

	if todos_passaram:
		_reiniciar_bando()

	queue_redraw()


func _reiniciar_bando() -> void:
	var base_y: float = 100.0 + randf() * 110.0
	for i: int in range(_passaros.size()):
		var p: Dictionary = _passaros[i]
		p["pos"] = Vector2(-70.0 - (i * 50.0) - randf() * 50.0, base_y + (i * 22.0) + (randf() * 20.0 - 10.0))
		p["velocidade"] = velocidade_base + (randf() * 18.0 - 9.0)


func _draw() -> void:
	for p: Dictionary in _passaros:
		var pos: Vector2 = p["pos"]
		var esc: float = float(p["escala"])
		var asa_y: float = sin(float(p["fase_asa"])) * 4.2 * esc

		var centro: Vector2 = pos
		var asa_esq: Vector2 = pos + Vector2(-6.5 * esc, asa_y)
		var asa_dir: Vector2 = pos + Vector2(6.5 * esc, asa_y)
		var bico: Vector2 = pos + Vector2(2.5 * esc, -1.0 * esc)

		draw_line(asa_esq, centro, cor_passaros, 1.8 * esc, true)
		draw_line(centro, asa_dir, cor_passaros, 1.8 * esc, true)
		draw_line(centro, bico, cor_passaros, 1.5 * esc, true)

