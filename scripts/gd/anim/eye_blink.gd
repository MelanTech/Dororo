extends Node

@export var enable: bool = true
@export var controller: AnimationController

@export_range(0, 10, 0.5, "suffix:s") var blink_interval:float = 1
@export_range(0, 10, 0.1, "suffix:s") var blink_noise:float = 1

func _ready() -> void:
	if enable:
		var timer = Timer.new()
		timer.wait_time = blink_interval
		timer.timeout.connect(_blink)
		timer.one_shot = false
		add_child(timer)
		timer.start()
	
func _blink():
	var noise_time = randf_range(0, blink_noise)
	await get_tree().create_timer(noise_time).timeout
	controller.eye_blink()
	
