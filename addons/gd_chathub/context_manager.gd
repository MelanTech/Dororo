extends Node
class_name ContextManager

@export var _max_context_enable: bool = false
@export var _max_context: int = 20

const ROLE_USER:StringName = &'user'
const ROLE_ASSISTANT:StringName = &'assistant'
const ROLE_SYSTEM:StringName = &'system'

var _history: Array[Dictionary] = []

func add_context(role: StringName, content: String) -> void:
	if role not in ["user", "assistant", "system"]:
		push_warning("Invalid role '%s'. Must be 'user', 'assistant', or 'system'." % role)
		return

	var entry: Dictionary = {
		"role": role,
		"content": content
	}

	_history.append(entry)
	
	if _max_context_enable:
		_trim_history()

func get_context() -> Array:
	return _history.duplicate(true)

func clear_context() -> void:
	_history.clear()

func get_length() -> int:
	return _history.size()

func _trim_history() -> void:
	if _history.size() > _max_context:
		var to_remove := _history.size() - _max_context
		_history = _history.slice(to_remove, _history.size())
		
func set_max_context(max_context: int):
	_max_context = max_context
	_trim_history()
	
func get_max_context():
	return _max_context
	
func set_max_context_enable(enable: bool):
	_max_context_enable = enable
	
func get_max_context_enable():
	return _max_context_enable
