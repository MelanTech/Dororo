extends Node
class_name MoveEffect

@export var enable: bool = true
@export var window: Node2D
@export var model: GDCubismUserModel
@export var anim_controller: AnimationController
@export var rand_move: Node

@export var speed:float = 250

var is_moving: bool = false
var move_tween: Tween
var ok_to_move: bool
var move_lock : bool = false  # 移动锁，结点持有该锁，运动将被优先执行
	
func _process(delta: float) -> void:
	ok_to_move = enable and not window.dragging and (not window.docking or move_lock)
	if !ok_to_move:
		stop()
	
func move(target_pos: Vector2i, override: bool = false, pre_call: Callable = Callable(), post_call: Callable = Callable()):
	if not ok_to_move:
		return
		
	if override and not move_lock:
		stop()
		move_lock = true
		anim_controller.idle()
		if rand_move.enable:
			rand_move.timer.set_paused(false)
	elif is_moving:
		return
	
	is_moving = true
	_clear_tween()
	
	var direction = _get_movement_direction(target_pos)
	var duration = get_tree().root.get_window().position.distance_to(target_pos) / speed
	
	move_tween = create_tween()
	_on_movement_started(direction)
	
	if pre_call.is_valid():
		pre_call.call()
	
	move_tween.tween_property(get_tree().root.get_window(), "position", target_pos, duration)
	move_tween.finished.connect(_on_movement_finished.bind(post_call))

func stop():
	_clear_tween()
	_on_movement_finished()

func _get_movement_direction(target_pos: Vector2) -> int:
	var current_pos = get_tree().root.get_window().position
	return target_pos.x > current_pos.x
		
func _on_movement_finished(post_call: Callable = Callable()):
	is_moving = false
	
	if move_lock:
		move_lock = false
	
	if post_call.is_valid():
		post_call.call()

func _on_movement_started(direction):
	model.flip_h = direction
	
func _clear_tween():
	if move_tween and move_tween.is_valid():
		move_tween.kill()
