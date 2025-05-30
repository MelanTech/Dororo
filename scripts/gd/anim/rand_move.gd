extends Node

@export var enable: bool = false
@export var window: Node2D
@export var model: GDCubismUserModel
@export var controller:AnimationController
@export var move_interval: int = 10
@export var speed:float = 0.8

var is_moving: bool = false
var timer: Timer = Timer.new()
var move_tween: Tween

func _ready() -> void:
	timer.wait_time = move_interval
	timer.one_shot = false
	timer.timeout.connect(_start_random_movement)
	add_child(timer)
	timer.start()
	
func _process(delta: float) -> void:
	var ok_to_move = enable and not window.dragging
	timer.set_paused(!ok_to_move)
	
func _start_random_movement():
	is_moving = true
	timer.set_paused(true)
	
	if move_tween and move_tween.is_valid():
		move_tween.kill()
	
	# 计算随机参数
	var target_pos = _get_random_window_position()
	var direction = _get_movement_direction(target_pos)
	var speed = 200  # 像素/秒
	var distance = get_tree().root.get_window().position.distance_to(target_pos)
	var duration = distance / speed
	
	# 动画开始回调
	_on_animation_started(direction)
	
	# 创建新的补间动画
	move_tween = create_tween()
	move_tween.tween_property(get_tree().root.get_window(), "position", target_pos, duration)
	move_tween.finished.connect(_on_movement_finished)

func _get_random_window_position() -> Vector2i:
	var current_screen = DisplayServer.window_get_current_screen()
	var usable_rect = DisplayServer.screen_get_usable_rect(current_screen)
	
	# 计算有效范围（考虑到窗口大小）
	var max_x = usable_rect.size.x - get_window().size.x
	var max_y = usable_rect.size.y - get_window().size.y

	# 生成随机位置（使用整数避免亚像素渲染）
	return Vector2i(
		randi_range(usable_rect.position.x, usable_rect.position.x + max_x),
		randi_range(usable_rect.position.y, usable_rect.position.y + max_y)
	)

func _get_movement_direction(target_pos: Vector2) -> int:
	var current_pos = get_tree().root.get_window().position
	if target_pos.x <= current_pos.x:
		return 0
	else:
		return 1

func _on_movement_finished():
	_on_animation_finished()
	is_moving = false
	timer.set_paused(false)

func _on_animation_started(direction):
	model.flip_h = direction != 0
	controller.run()

func _on_animation_finished():
	controller.idle()
