extends GDCubismEffectHitArea

@export var model:GDCubismUserModel
@export var root:Node2D

@onready var canvas_info: Dictionary = model.get_canvas_info()

var pressed: bool = false
var local_pos: Vector2 = Vector2.ZERO
var current_button_id: int

signal hit

func _input(event):
	if event as InputEventMouseButton:
		pressed = event.is_pressed()
		current_button_id = event.button_index

	if event as InputEventMouseMotion:
		local_pos = model.to_local(event.position)
	
func _process(delta):
	if pressed == true:
		set_target(recalc_mouse_position(local_pos))
		
func recalc_mouse_position(position):
	if canvas_info.is_empty() != true:
		var vct_viewport_size = Vector2(root.get_viewport_rect().size)
		var scale: float = vct_viewport_size.y / max(canvas_info.size_in_pixels.x, canvas_info.size_in_pixels.y)
		position -= vct_viewport_size / 2.0
		position /= Vector2(scale, scale)
		
	return position

func _on_hit_area_entered(model: GDCubismUserModel, id: String) -> void:
	hit.emit(id, current_button_id)
