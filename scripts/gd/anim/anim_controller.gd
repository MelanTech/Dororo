extends Node
class_name AnimationController

@export var anim_tree: AnimationTree

func _ready() -> void:
	idle()

func idle():
	anim_tree["parameters/MotonTransition/transition_request"] = "Idle"
	
func run():
	anim_tree["parameters/MotonTransition/transition_request"] = "Run"
	
func eye_blink():
	anim_tree["parameters/Expression/EyeBlinkOneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	
func set_expression(name: String):
	anim_tree["parameters/Expression/Transition/transition_request"] = name
	
func target_point(target: Vector2):
	anim_tree["parameters/HeadControl/blend_position"] = target
