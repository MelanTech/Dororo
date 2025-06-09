extends Node
class_name TimeCounter

var _counter:int = 0
var _duration: float = 0
var _reset_time:float = 0
var _paused: bool = true

func _init(reset_time) -> void:
	set_reset_time(reset_time)

func _process(delta: float) -> void:
	if !_paused:
		_duration += delta
		if _duration > _reset_time:
			reset()
	
func increase():
	if _counter == 0:
		start()
		
	_counter += 1
	_duration = 0
	
func get_count():
	return _counter

func set_reset_time(value: float):
	_reset_time = max(0, value)
	
func get_reset_time():
	return _reset_time
	
func start():
	_paused = false
	
func pause():
	_paused = true
	
func reset():
	_counter = 0
	_duration = 0
	pause()
	
