extends Node

@export var enable: bool = true
@export var model:GDCubismUserModel
@export var controller: AnimationController
@export_range(0, 1, 0.1) var smooth_factor: float = 0.5

@onready var mouseTracker = get_node("/root/MouseTracker")

var _current_pos:Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	if enable and not $"../../..".docking:
		var screen_mouse_pos = mouseTracker.GetMousePositionGlobal()
		var window_center = get_tree().root.get_position() + (get_tree().root.get_size() / 2)
		var relative_pos = Vector2(window_center - screen_mouse_pos)
		_current_pos = _smooth(_current_pos, _rad2vec(relative_pos.angle()), smooth_factor)
		controller.target_point(_current_pos)
	else:
		_current_pos = _smooth(_current_pos, Vector2.ZERO, smooth_factor)
		controller.target_point(_current_pos)
		
func _rad2vec(rad):
	if not model.flip_h:
		return Vector2(-cos(rad), sin(rad))
	else:
		return Vector2(cos(rad), sin(rad))
		
func _smooth(current_pos: Vector2, target_pos: Vector2, factor: float):
	current_pos = (1 - factor) * current_pos + factor * target_pos
	return current_pos
