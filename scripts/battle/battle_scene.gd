class_name BattleScene
extends Node2D

## Cena wireframe de combate com gerenciador de batalha e labels de status em PT-BR.

@onready var battle_manager: BattleManager = get_node_or_null("BattleManager")
@onready var state_label: Label = get_node_or_null("CanvasLayer/UI/StateLabel")
@onready var turn_label: Label = get_node_or_null("CanvasLayer/UI/TurnLabel")


func _ready() -> void:
	if battle_manager != null:
		battle_manager.battle_state_changed.connect(_on_state_changed)
		_update_labels(battle_manager.current_state)


func _on_state_changed(_old_state: BattleManager.BattleState, new_state: BattleManager.BattleState) -> void:
	_update_labels(new_state)


func _update_labels(state: BattleManager.BattleState) -> void:
	if state_label != null and battle_manager != null:
		state_label.text = "Estado: %s" % battle_manager.get_state_name(state)
	if turn_label != null and battle_manager != null:
		turn_label.text = "Turno: %s" % ("Grupo do Jogador" if battle_manager.is_player_turn else "Inimigos")
