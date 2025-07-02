extends Node

@export var enable: bool = false:
	set(value):
		enable = value
		timer.set_paused(!value)
		
@export var move_effect: MoveEffect
@export var anim_contorller: AnimationController
@export var move_interval: int = 3

var timer: Timer = Timer.new()
var move_tween: Tween

func _ready() -> void:
	timer.wait_time = move_interval
	timer.timeout.connect(_start_random_movement)
	add_child(timer)
	timer.start()
	
func _process(delta: float) -> void:
	if !enable and not move_effect.move_lock:
		move_effect.stop()  # 移动时关闭移动功能，则立即停止移动
	
func _start_random_movement():
	move_effect.move(_get_random_window_position(), false, _on_move_start, _on_move_finish)

func _get_random_window_position() -> Vector2i:
	var current_screen = DisplayServer.window_get_current_screen()
	var usable_rect = DisplayServer.screen_get_usable_rect(current_screen)
	
	var max_x = usable_rect.size.x - get_window().size.x
	var max_y = usable_rect.size.y - get_window().size.y

	return Vector2i(
		randi_range(usable_rect.position.x, usable_rect.position.x + max_x),
		randi_range(usable_rect.position.y, usable_rect.position.y + max_y)
	)
	
func _on_move_start():
	timer.set_paused(true)
	anim_contorller.run()
	
func _on_move_finish():
	timer.set_paused(false)
	anim_contorller.idle()
