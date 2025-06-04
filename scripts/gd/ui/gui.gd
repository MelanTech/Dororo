extends Control

func _on_window_middle_click() -> void:
	visible = !visible


func _on_window_docking(enable: bool, direction: int) -> void:
	if enable:
		visible = false
