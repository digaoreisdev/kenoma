class_name MiasmaRift
extends Area2D

## Representa uma Fenda de Miasma (Foco de Eco) no mapa de exploração que dispara encontros de combate.

signal rift_triggered(rift: MiasmaRift)

@export var rift_id: String = "fenda_01"
@export var disabled_on_victory: bool = true
@export var grupo_inimigo: Array[Dictionary] = []
@export var inimigo_recurso: Resource = null

var foi_ativada: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_verificar_estado_salvo()
	_inicializar_grupo_padrao()


func _verificar_estado_salvo() -> void:
	var sm: Node = get_node_or_null("/root/SceneManager")
	if sm != null and sm.has_method("is_rift_derrotada"):
		if bool(sm.call("is_rift_derrotada", rift_id)):
			desativar()


func _inicializar_grupo_padrao() -> void:
	if inimigo_recurso != null and inimigo_recurso.has_method("to_dictionary"):
		grupo_inimigo = [(inimigo_recurso as Object).call("to_dictionary")]
	elif grupo_inimigo.is_empty():
		grupo_inimigo = EnemyData.create_squad_cassian_8()


func _on_body_entered(body: Node2D) -> void:
	if foi_ativada:
		return
	if body is Player or body.is_in_group("player") or body.name == "Player":
		ativar_encontro(body)


func ativar_encontro(player: Node2D) -> void:
	foi_ativada = true
	rift_triggered.emit(self)
	var sm: Node = get_node_or_null("/root/SceneManager")
	var p_pos: Vector2 = player.global_position if player != null else global_position
	var dados: Dictionary = {
		"rift_id": rift_id,
		"player_pos": p_pos,
		"grupo_inimigo": grupo_inimigo.duplicate(true)
	}
	if sm != null and sm.has_method("iniciar_batalha"):
		sm.call("iniciar_batalha", dados)


func desativar() -> void:
	foi_ativada = true
	visible = false
	monitoring = false
	monitorable = false
	queue_free()
