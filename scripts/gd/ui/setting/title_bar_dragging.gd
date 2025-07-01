extends NinePatchRect

@export var title: StringName
@export var show_close_button: bool = true

var drag_start_mouse_pos: Vector2i
var drag_start_window_pos: Vector2i
var dragging: bool = false

func _ready() -> void:
	$MarginContainer/HBoxContainer/Label.set_text(title)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if get_global_rect().has_point(event.global_position):
					dragging = true
					drag_start_mouse_pos = DisplayServer.mouse_get_position()
					drag_start_window_pos = $"../../../".position
			else:
				dragging = false
				
	if event is InputEventMouseMotion and dragging:
		var cur_mouse_pos = DisplayServer.mouse_get_position()
		var delta_pos = cur_mouse_pos - drag_start_mouse_pos
		$"../../../".position = drag_start_window_pos + delta_pos
		
func set_close_button_visibility(visible: bool):
	$MarginContainer/HBoxContainer/CloseButton.visible = visible
