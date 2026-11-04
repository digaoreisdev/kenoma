extends Node

## Singleton global para gerenciamento do ciclo de vida e estados do jogo.

enum State {
	EXPLORATION,
	DIALOGUE,
	BATTLE,
	PAUSE,
}

signal state_changed(old_state: State, new_state: State)

var current_state: State = State.EXPLORATION


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	var old_state: State = current_state
	current_state = new_state
	state_changed.emit(old_state, new_state)


func is_state(state: State) -> bool:
	return current_state == state


func is_exploration() -> bool:
	return current_state == State.EXPLORATION
