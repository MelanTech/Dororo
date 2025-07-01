extends Node

@export var enable: bool = true
@export var anim_controller: AnimationController
@export var chew_anim_time: float = 5

@onready var fileApi = get_node("/root/FileApi")

var anim_timer = Timer.new()

func _ready() -> void:
	get_viewport().connect("files_dropped", _on_file_dropped)
	
	anim_timer.wait_time = chew_anim_time
	anim_timer.one_shot = true
	anim_timer.timeout.connect(end_chew_anim)
	add_child(anim_timer)

func _on_file_dropped(files: Array[String]):
	if not enable:
		return
		
	if $"../Animation/EffectRandMove".is_moving:
		return
	if not files.is_empty():
		for file in files:
			fileApi.MoveFileToRecycleBin(file)
		_start_chew_anim()
		
func _start_chew_anim():
	anim_timer.start()
	anim_controller.set_expression("Chew")
	
func end_chew_anim():
	anim_controller.set_expression("Idle")
	
