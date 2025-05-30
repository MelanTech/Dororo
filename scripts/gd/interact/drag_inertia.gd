extends GDCubismEffectCustom

@export var model:GDCubismUserModel
@export var motion_x_name:String = "ParamAngleX"
@export var motion_y_name:String = "ParamAngleY"
@export var motion_max_speed:int = 2000
@export var acceleration: float = 8.0  # 加速度系数
@export var deceleration: float = 12.0 # 减速度系数
@export var drag_thresh:int = 20

var left_mouse_pressed:bool = false
var mouse_press_position
var is_dragging:bool = false

var param_x = null
var param_y = null
var current_velocity = Vector2.ZERO  # 使用Vector2存储当前速度
var target_velocity = Vector2.ZERO   # 目标速度

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				left_mouse_pressed = true
				mouse_press_position = event.position
				is_dragging = false
			else:
				left_mouse_pressed = false
				is_dragging = false
				target_velocity = Vector2.ZERO  # 松开时重置目标速度
				
	elif event is InputEventMouseMotion and left_mouse_pressed:
		var distance = (event.position - mouse_press_position).length()
		if distance > drag_thresh:
			is_dragging = true
			# 将鼠标速度映射到[-1, 1]范围
			var normalized_velocity = Vector2(
				clampf(event.velocity.x, -motion_max_speed, motion_max_speed) / motion_max_speed,
				clampf(event.velocity.y, -motion_max_speed, motion_max_speed) / motion_max_speed
			)
			target_velocity = normalized_velocity  # 更新目标速度
		else:
			target_velocity = Vector2.ZERO

func _on_cubism_init(model: GDCubismUserModel):
	for param in model.get_parameters():
		if param.id == motion_x_name:
			param_x = param
		elif param.id == motion_y_name:
			param_y = param

func _on_cubism_process(model: GDCubismUserModel, delta: float):
	if is_dragging:
		# 使用加速度逼近目标速度
		current_velocity = current_velocity.lerp(target_velocity, acceleration * delta)
	else:
		# 没有拖动时使用减速度逐渐停止
		current_velocity = current_velocity.lerp(Vector2.ZERO, deceleration * delta)
	
	# 应用参数变化
	if is_dragging:
		if not model.flip_h:
			param_x.value = -current_velocity.x * param_x.maximum_value
		else:
			param_x.value = current_velocity.x * param_x.maximum_value
		param_y.value = current_velocity.y * param_y.maximum_value

func _on_cubism_term(model: GDCubismUserModel):
	param_x = null
	param_y = null
