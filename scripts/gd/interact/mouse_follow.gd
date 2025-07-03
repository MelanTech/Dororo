extends Node

@export var enable: bool = true
@export var model:GDCubismUserModel
@export var anim_controller: AnimationController
@export_range(0, 1, 0.1) var smooth_factor: float = 0.5

var _current_pos:Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	if enable and not $"../../..".docking:
		_current_pos = _smooth(_current_pos, _mouse2vec(), smooth_factor)
		anim_controller.target_point(_current_pos)
	else:
		_current_pos = _smooth(_current_pos, Vector2.ZERO, smooth_factor)
		anim_controller.target_point(_current_pos)
		
func _mouse2vec():
	var mouse_pos = DisplayServer.mouse_get_position()
	var window_size = get_tree().root.size
	var window_cpos = get_tree().root.position + window_size / 2
	var x_dis = mouse_pos.x - window_cpos.x
	var y_dis = mouse_pos.y - window_cpos.y
	var x_vec = clampf(x_dis / (window_size.x / 2.), -1, 1)
	var y_vec = clampf(y_dis / (window_size.y / 2.), -1, 1)
	return Vector2(x_vec, -y_vec)
		
func _smooth(current_pos: Vector2, target_pos: Vector2, factor: float):
	current_pos = (1 - factor) * current_pos + factor * target_pos
	return current_pos
