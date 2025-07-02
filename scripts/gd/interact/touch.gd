extends Node

@export var enable: bool = true
@export var controller: AnimationController
@export var model: GDCubismUserModel
@export var particle: GPUParticles2D

var current_hit_area: String

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and enable:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_stroke(event.is_pressed(), "")

func _stroke(enable: bool, hit_id: String):
	if enable:
		match hit_id:
			"Face":
				controller.set_expression("SmileEyeClosed")
				particle.emitting = true
			"Leg_back_L":
				controller.set_expression("Sullen")
	else:
		controller.set_expression("Idle")
		particle.emitting = false

func _on_hit_area(id: String, button_id: int) -> void:
	if button_id == MOUSE_BUTTON_RIGHT:
		_stroke(true, id)
